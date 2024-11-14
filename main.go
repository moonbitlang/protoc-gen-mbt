// Copyright 2024 International Digital Economy Academy
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

package main

import (
	"fmt"
	"regexp"
	"strings"

	"golang.org/x/text/cases"
	"golang.org/x/text/language"
	"google.golang.org/protobuf/compiler/protogen"
	"google.golang.org/protobuf/encoding/protowire"
	"google.golang.org/protobuf/reflect/protoreflect"
	"google.golang.org/protobuf/types/pluginpb"
)

func main() {
	protogen.Options{}.Run(func(gen *protogen.Plugin) error {
		gen.SupportedFeatures = uint64(pluginpb.CodeGeneratorResponse_FEATURE_PROTO3_OPTIONAL)
		for _, f := range gen.Files {
			if f.Generate {
				genFile(gen, f)
			}
		}
		return nil
	})
}

func genFile(gen *protogen.Plugin, file *protogen.File) *protogen.GeneratedFile {
	filename := file.GeneratedFilenamePrefix + "_pb.mbt"
	g := gen.NewGeneratedFile(filename, "path")
	fmt.Fprintf(g, "// Code generated from %s.proto by protoc-gen-mbt. DO NOT EDIT.\n\n", file.GeneratedFilenamePrefix)

	for _, enum := range file.Enums {
		genEnum(g, enum)
	}

	genMessages(g, file.Messages)

	return g
}

func genEnum(g *protogen.GeneratedFile, enum *protogen.Enum) {
	fmt.Fprintf(g, "pub enum %s {\n", enum.GoIdent.GoName)
	for _, value := range enum.Values {
		fmt.Fprintf(g, "  %s\n", value.GoIdent.GoName)
	}
	fmt.Fprintf(g, "} derive(Eq, Show)\n")

	// To enum
	fmt.Fprintf(g, "pub fn to_enum(self : %s) -> @lib.Enum {\n", enum.GoIdent.GoName)
	fmt.Fprintf(g, "  match self {\n")
	for _, value := range enum.Values {
		fmt.Fprintf(g, "    %s::%s => %d\n", enum.GoIdent.GoName, value.GoIdent.GoName, value.Desc.Number())
	}
	fmt.Fprintf(g, "  }\n")
	fmt.Fprintf(g, "}\n")
	// From enum
	fmt.Fprintf(g, "pub fn %s::from_enum(i : @lib.Enum) -> %s {\n", enum.GoIdent.GoName, enum.GoIdent.GoName)
	fmt.Fprintf(g, "  match i._ {\n")
	for _, value := range enum.Values {
		fmt.Fprintf(g, "    %d => %s::%s\n", value.Desc.Number(), enum.GoIdent.GoName, value.GoIdent.GoName)
	}
	fmt.Fprintf(g, "    _ => Default::default()\n")
	fmt.Fprintf(g, "  }\n")
	fmt.Fprintf(g, "}\n")
	// Default
	fmt.Fprintf(g, "pub fn %s::default() -> %s {\n", enum.GoIdent.GoName, enum.GoIdent.GoName)
	fmt.Fprintf(g, "  %s::%s\n", enum.GoIdent.GoName, enum.Values[0].GoIdent.GoName)
	fmt.Fprintf(g, "}\n")
	// Sized
	fmt.Fprintf(g, "impl @lib.Sized for %s with size_of(self : %s) {\n", enum.GoIdent.GoName, enum.GoIdent.GoName)
	fmt.Fprintf(g, "  @lib.Sized::size_of(self.to_enum())\n")
	fmt.Fprintf(g, "}\n")
	// End
}

func genMessages(g *protogen.GeneratedFile, messages []*protogen.Message) {
	for _, m := range messages {
		// Generate nested enums first
		for _, enum := range m.Enums {
			genEnum(g, enum)
		}

		// Recursively process nested messages (if any)
		genMessages(g, m.Messages)

		// Generate the message itself
		genMessage(g, m)
	}
}

func PascalToSnake(s string) string {
	// Use regex to identify the positions where we need to insert an underscore.
	// This regex looks for transitions between a lowercase letter and an uppercase letter.
	regex := regexp.MustCompile("([a-z])([A-Z])")

	// Insert underscores and convert the string to lowercase.
	snake := regex.ReplaceAllString(s, "${1}_${2}")

	// Convert the entire string to lowercase
	return strings.ToLower(snake)
}

func genMessage(g *protogen.GeneratedFile, m *protogen.Message) {
	fmt.Fprintf(g, "pub struct %s {\n", m.GoIdent.GoName)

	// Regular fields
	for _, field := range m.Fields {
		if field.Oneof != nil && !field.Oneof.Desc.IsSynthetic() {
			// Skip fields that are part of a non-synthetic oneof; they'll be handled separately
			continue
		}
		fieldType := getFieldMbtType(field)
		fieldName := PascalToSnake(field.Desc.JSONName())

		if field.Oneof != nil && field.Oneof.Desc.IsSynthetic() {
			fmt.Fprintf(g, "  mut %s : %s?\n", fieldName, fieldType)
		} else {
			fmt.Fprintf(g, "  mut %s : %s\n", fieldName, fieldType)
		}
	}

	// Oneof fields
	// Fields in oneofs must not have labels (required / optional / repeated).
	for _, oneof := range m.Oneofs {
		if oneof.Desc.IsSynthetic() {
			// Skip synthetic oneofs; they're not part of the user-defined message
			continue
		}
		enumName := oneOfEnumName(m, oneof)
		fieldName := PascalToSnake(oneof.GoName)
		fmt.Fprintf(g, "  mut %s : %s\n", fieldName, enumName)
		// Generate the enum for the oneof
		// defer to ensure the enum is generated after the struct (not nested)
		defer genOneofEnum(g, m, oneof)
	}

	g.P("} derive(Default, Eq, Show)")

	genMessageSize(g, m)
	genMessageRead(g, m)
	genMessageWrite(g, m)
}

func genOneofEnum(g *protogen.GeneratedFile, m *protogen.Message, oneof *protogen.Oneof) {
	enumName := oneOfEnumName(m, oneof)
	fmt.Fprintf(g, "pub enum %s {\n", enumName)
	for _, field := range oneof.Fields {
		fieldType := getFieldMbtType(field)
		fmt.Fprintf(g, "  %s(%s)\n", field.GoName, fieldType)
	}
	fmt.Fprintf(g, "  NotSet\n")
	fmt.Fprintf(g, "} derive(Eq, Show)\n")
	// Default
	fmt.Fprintf(g, "pub fn %s::default() -> %s {\n", enumName, enumName)
	fmt.Fprintf(g, "  NotSet\n")
	fmt.Fprintf(g, "}\n")
}

func getFieldMbtType(field *protogen.Field) string {
	fieldType := getMbtType(field)

	// Check if the field is repeated or map
	if field.Desc.IsMap() {
		keyType := getFieldMbtType(field.Message.Fields[0])
		valueType := getFieldMbtType(field.Message.Fields[1])
		fieldType = fmt.Sprintf("Map[%s, %s]", keyType, valueType)
	} else if field.Desc.Cardinality() == protoreflect.Repeated {
		fieldType = fmt.Sprintf("Array[%s]", fieldType)
	}

	return fieldType
}

func getMbtType(field *protogen.Field) string {
	var fieldType string
	switch field.Desc.Kind() {
	case protoreflect.BoolKind:
		fieldType = "Bool"
	case protoreflect.Int32Kind:
		fieldType = "Int"
	case protoreflect.Int64Kind:
		fieldType = "Int64"
	case protoreflect.Sfixed32Kind:
		fieldType = "Int"
	case protoreflect.Sfixed64Kind:
		fieldType = "Int64"
	case protoreflect.Sint32Kind:
		fieldType = "Int"
	case protoreflect.Sint64Kind:
		fieldType = "Int64"
	case protoreflect.Fixed32Kind:
		fieldType = "UInt"
	case protoreflect.Uint32Kind:
		fieldType = "UInt"
	case protoreflect.Fixed64Kind:
		fieldType = "UInt64"
	case protoreflect.Uint64Kind:
		fieldType = "UInt64"
	case protoreflect.FloatKind:
		fieldType = "Float"
	case protoreflect.DoubleKind:
		fieldType = "Double"
	case protoreflect.StringKind:
		fieldType = "String"
	case protoreflect.BytesKind:
		fieldType = "Bytes"
	case protoreflect.MessageKind:
		fieldType = field.Message.GoIdent.GoName
	case protoreflect.EnumKind:
		fieldType = field.Enum.GoIdent.GoName
	default:
		panic("unreachable")
	}
	return fieldType
}

func genMessageSize(g *protogen.GeneratedFile, m *protogen.Message) {
	fmt.Fprintf(g, "impl @lib.Sized for %s with size_of(self) {\n", m.GoIdent.GoName)
	if len(m.Fields) == 0 {
		g.P("  0")
	} else {
		g.P("  let mut size = 0U")
		for _, field := range m.Fields {
			fieldName := PascalToSnake(field.Desc.JSONName())
			if field.Oneof != nil {
				continue
			}

			if field.Desc.IsPacked() {
				switch field.Desc.Kind() {
				case protoreflect.Fixed32Kind, protoreflect.Sfixed32Kind, protoreflect.FloatKind:
					fmt.Fprintf(g, "  size += %dU + { let size = self.%s.length().reinterpret_as_uint() * %d; @lib.size_of(size) + size}\n", protowire.SizeTag(field.Desc.Number()), fieldName, protowire.SizeFixed32())
				case protoreflect.Fixed64Kind, protoreflect.Sfixed64Kind, protoreflect.DoubleKind:
					fmt.Fprintf(g, "  size += %dU + { let size = self.%s.length().reinterpret_as_uint() * %d; @lib.size_of(size) + size}\n", protowire.SizeTag(field.Desc.Number()), fieldName, protowire.SizeFixed64())
				case protoreflect.Int32Kind, protoreflect.Int64Kind, protoreflect.Sint32Kind, protoreflect.Sint64Kind, protoreflect.Uint32Kind, protoreflect.Uint64Kind, protoreflect.BoolKind, protoreflect.EnumKind:
					fmt.Fprintf(g, "  size += %dU + { let size = self.%s.iter().map(@lib.size_of).fold(init=0U, UInt::op_add); @lib.size_of(size) + size }\n", protowire.SizeTag(field.Desc.Number()), fieldName)
				default:
					panic(fmt.Sprintf("unreachable: %s can't be packed", field.Desc.Kind()))
				}
			} else if field.Desc.IsList() {
				fmt.Fprintf(g, "  size += self.%s.iter().map(@lib.size_of).map(fn { s => %dU + @lib.size_of(s) + s }).fold(init=0U, UInt::op_add)\n", fieldName, protowire.SizeTag(field.Desc.Number()))
			} else if field.Desc.IsMap() {
				fmt.Fprintf(g, "  size += self.%s.iter().map(fn(key_value) {\n", fieldName)
				g.P("    let (k, v) = key_value")
				switch field.Desc.MapKey().Kind() {
				case protoreflect.StringKind, protoreflect.BytesKind, protoreflect.MessageKind:
					fmt.Fprintf(g, "    let key_size = %dU + { let size = @lib.size_of(k); @lib.size_of(size) + size }\n", protowire.SizeTag(0))
				case protoreflect.Fixed32Kind, protoreflect.Sfixed32Kind, protoreflect.FloatKind:
					fmt.Fprintf(g, "    let key_size = %dU + %dU\n", protowire.SizeTag(0), protowire.SizeFixed32())
				case protoreflect.Fixed64Kind, protoreflect.Sfixed64Kind, protoreflect.DoubleKind:
					fmt.Fprintf(g, "    let key_size = %dU + %dU\n", protowire.SizeTag(0), protowire.SizeFixed64())
				default:
					fmt.Fprintf(g, "    let key_size = %dU + @lib.size_of(k)\n", protowire.SizeTag(0))
				}
				switch field.Desc.MapValue().Kind() {
				case protoreflect.StringKind, protoreflect.BytesKind, protoreflect.MessageKind:
					fmt.Fprintf(g, "    let value_size = %dU + { let size = @lib.size_of(value); @lib.size_of(size) + size }\n", protowire.SizeTag(1))
				case protoreflect.Fixed32Kind, protoreflect.Sfixed32Kind, protoreflect.FloatKind:
					fmt.Fprintf(g, "    let value_size = %dU + %dU\n", protowire.SizeTag(1), protowire.SizeFixed32())
				case protoreflect.Fixed64Kind, protoreflect.Sfixed64Kind, protoreflect.DoubleKind:
					fmt.Fprintf(g, "    let value_size = %dU + %dU\n", protowire.SizeTag(1), protowire.SizeFixed64())
				default:
					fmt.Fprintf(g, "    let value_size = %dU + @lib.size_of(v)\n", protowire.SizeTag(1))
				}
				fmt.Fprintf(g, "    %dU + @lib.size_of(key_size + value_size) + key_size + value_size  }).fold(init=0U, UInt::op_add)\n", protowire.SizeTag(field.Desc.Number()))
			} else {
				switch field.Desc.Kind() {
				case protoreflect.StringKind, protoreflect.BytesKind, protoreflect.MessageKind:
					fmt.Fprintf(g, "  size += %dU + { let size = @lib.size_of(self.%s); @lib.size_of(size) + size }\n", protowire.SizeTag(field.Desc.Number()), fieldName)
				case protoreflect.Fixed32Kind, protoreflect.Sfixed32Kind, protoreflect.FloatKind:
					fmt.Fprintf(g, "  size += %dU + %dU\n", protowire.SizeTag(field.Desc.Number()), protowire.SizeFixed32())
				case protoreflect.Fixed64Kind, protoreflect.Sfixed64Kind, protoreflect.DoubleKind:
					fmt.Fprintf(g, "  size += %dU + %dU\n", protowire.SizeTag(field.Desc.Number()), protowire.SizeFixed64())
				default:
					fmt.Fprintf(g, "  size += %dU + @lib.size_of(self.%s)\n", protowire.SizeTag(field.Desc.Number()), fieldName)
				}
			}
		}
		for _, oneof := range m.Oneofs {
			var fieldName = PascalToSnake(oneof.GoName)
			if oneof.Desc.IsSynthetic() {
				fieldName = PascalToSnake(oneof.Fields[0].Desc.JSONName())
			}
			fmt.Fprintf(g, "  match self.%s {\n", fieldName)
			for _, field := range oneof.Fields {
				if oneof.Desc.IsSynthetic() {
					fmt.Fprint(g, "    Some(v) => ")
				} else {
					fmt.Fprintf(g, "    %s(v) => ", field.GoName)
				}
				switch field.Desc.Kind() {
				case protoreflect.StringKind, protoreflect.BytesKind, protoreflect.MessageKind:
					fmt.Fprintf(g, "size += %dU + { let size = @lib.size_of(v); @lib.size_of(size) + size }\n", protowire.SizeTag(field.Desc.Number()))
				case protoreflect.Fixed32Kind, protoreflect.Sfixed32Kind, protoreflect.FloatKind:
					fmt.Fprintf(g, "size += %dU + %dU\n", protowire.SizeTag(field.Desc.Number()), protowire.SizeFixed32())
				case protoreflect.Fixed64Kind, protoreflect.Sfixed64Kind, protoreflect.DoubleKind:
					fmt.Fprintf(g, "size += %dU + %dU\n", protowire.SizeTag(field.Desc.Number()), protowire.SizeFixed64())
				default:
					fmt.Fprintf(g, "size += %dU + @lib.size_of(v)\n", protowire.SizeTag(field.Desc.Number()))
				}
			}
			if oneof.Desc.IsSynthetic() {
				g.P("    None => ()")
			} else {
				g.P("    NotSet => ()")
			}
			g.P("  }")
		}
		g.P("  size")
	}
	g.P("}")
}

func genMessageRead(g *protogen.GeneratedFile, m *protogen.Message) {
	fmt.Fprintf(g, "pub impl @lib.Read for %s with read(reader : @lib.Reader) {\n", m.GoIdent.GoName)
	defaultStr := fmt.Sprintf("  %s::default()", m.GoIdent.GoName)
	if len(m.Fields) == 0 {
		// Empty message, generate default
		g.P(defaultStr)
	} else {
		g.P(fmt.Sprintf("\tlet msg = %s", defaultStr))
		g.P("  while not(reader |> @lib.is_eof()) {")
		g.P("    match (reader |> @lib.read_tag!()) {")

		for _, field := range m.Fields {
			if field.Desc.Cardinality() == protoreflect.Repeated {
				genRepeatedFieldRead(field, g)
			} else {
				genFieldRead(field, m, g)
			}
		}

		g.P("      (_, wire) => reader |> @lib.read_unknown!(wire)")
		g.P("    }")
		g.P("  }")
		g.P("  msg")
	}
	g.P("}")
}

func tag(kind protoreflect.Kind, number protowire.Number, isPacked bool) uint64 {
	if isPacked {
		return protowire.EncodeTag(number, protowire.BytesType)
	}
	switch kind {
	case protoreflect.BoolKind, protoreflect.EnumKind, protoreflect.Int32Kind, protoreflect.Int64Kind,
		protoreflect.Sint32Kind, protoreflect.Sint64Kind, protoreflect.Uint32Kind, protoreflect.Uint64Kind:
		return protowire.EncodeTag(number, protowire.VarintType)
	case protoreflect.Fixed32Kind, protoreflect.Sfixed32Kind, protoreflect.FloatKind:
		return protowire.EncodeTag(number, protowire.Fixed32Type)
	case protoreflect.Fixed64Kind, protoreflect.Sfixed64Kind, protoreflect.DoubleKind:
		return protowire.EncodeTag(number, protowire.Fixed64Type)
	case protoreflect.StringKind, protoreflect.BytesKind, protoreflect.MessageKind:
		return protowire.EncodeTag(number, protowire.BytesType)
	default:
		panic("todo: tag deprecated group")
	}
}

func kindReadFunc(kind protoreflect.Kind) string {
	switch kind {
	case protoreflect.BoolKind:
		return "@lib.read_bool"
	case protoreflect.Int32Kind:
		return "@lib.read_int32"
	case protoreflect.Int64Kind:
		return "@lib.read_int64"
	case protoreflect.Sint32Kind:
		return "@lib.read_sint32"
	case protoreflect.Sint64Kind:
		return "@lib.read_sint64"
	case protoreflect.Uint32Kind:
		return "@lib.read_uint32"
	case protoreflect.Uint64Kind:
		return "@lib.read_uint64"
	case protoreflect.Fixed32Kind:
		return "@lib.read_fixed32"
	case protoreflect.Fixed64Kind:
		return "@lib.read_fixed64"
	case protoreflect.Sfixed32Kind:
		return "@lib.read_sfixed32"
	case protoreflect.Sfixed64Kind:
		return "@lib.read_sfixed64"
	case protoreflect.FloatKind:
		return "@lib.read_float"
	case protoreflect.DoubleKind:
		return "@lib.read_double"
	case protoreflect.StringKind:
		return "@lib.read_string"
	case protoreflect.BytesKind:
		return "@lib.read_bytes"
	case protoreflect.EnumKind:
		return "@lib.read_enum"
	case protoreflect.MessageKind:
		return "@lib.Read::read"
	case protoreflect.GroupKind:
		return "panic()"
	default:
		panic("unreachable")
	}
}

func genKindRead(kind protoreflect.Kind, typeName string) string {
	switch kind {
	case protoreflect.BoolKind,
		protoreflect.Int32Kind,
		protoreflect.Int64Kind,
		protoreflect.Uint32Kind,
		protoreflect.Uint64Kind,
		protoreflect.Fixed32Kind,
		protoreflect.Fixed64Kind,
		protoreflect.Sfixed32Kind,
		protoreflect.Sfixed64Kind,
		protoreflect.FloatKind,
		protoreflect.DoubleKind,
		protoreflect.StringKind,
		protoreflect.BytesKind:
		return fmt.Sprintf("reader |> %s!()", kindReadFunc(kind))
	case protoreflect.Sint32Kind,
		protoreflect.Sint64Kind:
		return fmt.Sprintf("(reader |> %s!())._", kindReadFunc(kind))
	case protoreflect.EnumKind:
		return "reader |> @lib.read_enum!() |> " + typeName + "::from_enum"
	case protoreflect.MessageKind:
		return fmt.Sprintf("((reader |> @lib.read_message!()) : %s)", typeName)
	case protoreflect.GroupKind:
		return "panic()"
	default:
		panic("unreachable")
	}
}

func genFieldRead(field *protogen.Field, m *protogen.Message, g *protogen.GeneratedFile) {
	kind := field.Desc.Kind()
	fieldNumber := field.Desc.Number()
	var fieldName = PascalToSnake(field.Desc.JSONName())
	var oneOfConstructor = ""
	var optionalConstructor = ""
	if field.Oneof != nil {
		if field.Oneof.Desc.IsSynthetic() {
			optionalConstructor = " |> Some"
		} else {
			fieldName = PascalToSnake(field.Oneof.GoName)
			oneOfConstructor = fmt.Sprintf(" |> %s::%s", oneOfEnumName(m, field.Oneof), field.GoName)
		}
	}
	var name string = ""
	if field.Enum != nil {
		name = field.Enum.GoIdent.GoName
	}
	if field.Message != nil {
		name = field.Message.GoIdent.GoName
	}
	fmt.Fprintf(g, "      (%d, _) => msg.%s = %s%s%s\n", fieldNumber, fieldName, genKindRead(kind, name), oneOfConstructor, optionalConstructor)

}

func genRepeatedFieldRead(field *protogen.Field, g *protogen.GeneratedFile) {
	kind := field.Desc.Kind()
	fieldNumber := field.Desc.Number()
	fieldName := PascalToSnake(field.Desc.JSONName())
	var name string = ""
	if field.Enum != nil {
		name = field.Enum.GoIdent.GoName
	}
	if field.Message != nil {
		name = field.Message.GoIdent.GoName
	}
	if field.Desc.IsPacked() {
		switch field.Desc.Kind() {
		// VARINT except enum which is not scalar
		case protoreflect.BoolKind, protoreflect.Int32Kind, protoreflect.Int64Kind, protoreflect.Uint32Kind, protoreflect.Uint64Kind, protoreflect.Sint32Kind, protoreflect.Sint64Kind:
			fmt.Fprintf(g, "      (%d, _) => { msg.%s.push_iter((reader |> @lib.read_packed!(%s, None)).iter()) }\n", fieldNumber, fieldName, kindReadFunc(kind))
		// I64
		case protoreflect.Sfixed64Kind, protoreflect.Fixed64Kind, protoreflect.DoubleKind:
			fmt.Fprintf(g, "      (%d, _) => { msg.%s.push_iter((reader |> @lib.read_packed!(%s, Some(64))).iter()) }\n", fieldNumber, fieldName, kindReadFunc(kind))
		// I32
		case protoreflect.Sfixed32Kind, protoreflect.Fixed32Kind, protoreflect.FloatKind:
			fmt.Fprintf(g, "      (%d, _) => { msg.%s.push_iter((reader |> @lib.read_packed!(%s, Some(32))).iter()) }\n", fieldNumber, fieldName, kindReadFunc(kind))
		default:
			panic("unreachable")
		}
	} else if field.Desc.IsMap() {
		fmt.Fprintf(g, "      (%d, _) => { let {key, value} = %s; msg.%s[key] = value}\n", fieldNumber, genKindRead(kind, name), fieldName)
	} else {
		fmt.Fprintf(g, "      (%d, _) => msg.%s.push(%s)\n", fieldNumber, fieldName, genKindRead(kind, name))
	}
}

func genMessageWrite(g *protogen.GeneratedFile, m *protogen.Message) {
	fmt.Fprintf(g, "pub impl @lib.Write for %s with write(self, writer) {\n", m.GoIdent.GoName)
	if len(m.Fields) != 0 {
		for _, field := range m.Fields {
			fieldName := PascalToSnake(field.Desc.JSONName())
			if field.Oneof != nil {
				continue
			}
			if field.Desc.IsPacked() {
				fmt.Fprintf(g, "  writer |> @lib.write_varint(%dUL)\n", tag(field.Desc.Kind(), field.Desc.Number(), true))
				switch field.Desc.Kind() {
				case protoreflect.Fixed32Kind, protoreflect.Sfixed32Kind, protoreflect.FloatKind:
					fmt.Fprintf(g, "  let size = self.%s.length().reinterpret_as_uint() * %d\n", fieldName, protowire.SizeFixed32())
				case protoreflect.Fixed64Kind, protoreflect.Sfixed64Kind, protoreflect.DoubleKind:
					fmt.Fprintf(g, "  let size = self.%s.length().reinterpret_as_uint() * %d\n", fieldName, protowire.SizeFixed64())
				case protoreflect.Int32Kind, protoreflect.Int64Kind, protoreflect.Sint32Kind, protoreflect.Sint64Kind, protoreflect.Uint32Kind, protoreflect.Uint64Kind, protoreflect.BoolKind, protoreflect.EnumKind:
					fmt.Fprintf(g, "  let size = self.%s.iter().map(@lib.size_of).fold(init=0U, UInt::op_add)\n", fieldName)
				default:
					panic(fmt.Sprintf("unreachable: %s can't be packed", field.Desc.Kind()))
				}
				g.P("  writer |> @lib.write_uint32(size)")
				fmt.Fprintf(g, "  self.%s.iter().each(fn(v) {\n    ", fieldName)
				genFieldWrite(g, field.Desc.Kind(), "v")
				g.P("  })")
			} else if field.Desc.IsList() {
				fmt.Fprintf(g, "  self.%s.iter().each(fn(v) {\n", fieldName)
				fmt.Fprintf(g, "    writer |> @lib.write_varint(%dUL)\n    ", tag(field.Desc.Kind(), field.Desc.Number(), false))
				genFieldWrite(g, field.Desc.Kind(), "v")
				g.P("  })")
			} else if field.Desc.IsMap() {
				fmt.Fprintf(g, "  self.%s.iter().each(fn(key_value) {\n", fieldName)
				g.P("    let (k, v) = key_value")
				fmt.Fprintf(g, "    writer |> @lib.write_varint(%dUL)\n", tag(field.Desc.Kind(), field.Desc.Number(), false))
				switch field.Desc.MapKey().Kind() {
				case protoreflect.StringKind, protoreflect.BytesKind, protoreflect.MessageKind:
					fmt.Fprintf(g, "    let key_size = %dU + { let size = @lib.size_of(k); @lib.size_of(size) + size }\n", protowire.SizeTag(0))
				case protoreflect.Fixed32Kind, protoreflect.Sfixed32Kind, protoreflect.FloatKind:
					fmt.Fprintf(g, "    let key_size = %dU + %dU\n", protowire.SizeTag(0), protowire.SizeFixed32())
				case protoreflect.Fixed64Kind, protoreflect.Sfixed64Kind, protoreflect.DoubleKind:
					fmt.Fprintf(g, "    let key_size = %dU + %dU\n", protowire.SizeTag(0), protowire.SizeFixed64())
				default:
					fmt.Fprintf(g, "    let key_size = %dU + @lib.size_of(k)\n", protowire.SizeTag(0))
				}
				switch field.Desc.MapValue().Kind() {
				case protoreflect.StringKind, protoreflect.BytesKind, protoreflect.MessageKind:
					fmt.Fprintf(g, "    let value_size = %dU + { let size = @lib.size_of(value); @lib.size_of(size) + size }\n", protowire.SizeTag(1))
				case protoreflect.Fixed32Kind, protoreflect.Sfixed32Kind, protoreflect.FloatKind:
					fmt.Fprintf(g, "    let value_size = %dU + %dU\n", protowire.SizeTag(1), protowire.SizeFixed32())
				case protoreflect.Fixed64Kind, protoreflect.Sfixed64Kind, protoreflect.DoubleKind:
					fmt.Fprintf(g, "    let value_size = %dU + %dU\n", protowire.SizeTag(1), protowire.SizeFixed64())
				default:
					fmt.Fprintf(g, "    let value_size = %dU + @lib.size_of(v)\n", protowire.SizeTag(1))
				}
				fmt.Fprintf(g, "    writer |> @lib.write_uint32(@lib.size_of(key_size + value_size) + key_size + value_size)\n")
				mapKey := field.Desc.MapKey()
				mapValue := field.Desc.MapValue()
				fmt.Fprint(g, "    ")
				fmt.Fprintf(g, "writer |> @lib.write_varint(%dUL);", tag(mapKey.Kind(), mapKey.Number(), false))
				genFieldWrite(g, mapKey.Kind(), "k")
				fmt.Fprint(g, "    ")
				fmt.Fprintf(g, "writer |> @lib.write_varint(%dUL);", tag(mapValue.Kind(), mapValue.Number(), false))
				genFieldWrite(g, mapValue.Kind(), "v")
				g.P("  })")
			} else {
				fmt.Fprint(g, "  ")
				fmt.Fprintf(g, "writer |> @lib.write_varint(%dUL);", tag(field.Desc.Kind(), field.Desc.Number(), false))
				genFieldWrite(g, field.Desc.Kind(), "self."+fieldName)
			}
		}
		for _, oneof := range m.Oneofs {
			var fieldName = PascalToSnake(oneof.GoName)
			if oneof.Desc.IsSynthetic() {
				fieldName = PascalToSnake(oneof.Fields[0].Desc.JSONName())
			}
			fmt.Fprintf(g, "  match self.%s {\n", fieldName)
			for _, field := range oneof.Fields {
				if oneof.Desc.IsSynthetic() {
					g.P("    Some(v) => {")
				} else {
					fmt.Fprintf(g, "    %s(v) => {\n", field.GoName)
				}
				fmt.Fprint(g, "      ")
				fmt.Fprintf(g, "writer |> @lib.write_varint(%dUL);", tag(field.Desc.Kind(), field.Desc.Number(), false))
				genFieldWrite(g, field.Desc.Kind(), "v")
				g.P("    }")
			}
			if oneof.Desc.IsSynthetic() {
				g.P("    None => ()")
			} else {
				g.P("    NotSet => ()")
			}
			g.P("  }")
		}
	}
	g.P("}")
}

func genFieldWrite(g *protogen.GeneratedFile, kind protoreflect.Kind, variable string) {
	switch kind {
	case protoreflect.StringKind:
		fmt.Fprintf(g, "writer |> @lib.write_string(%s)\n", variable)
	case protoreflect.BytesKind:
		fmt.Fprintf(g, "writer |> @lib.write_bytes(%s)\n", variable)
	case protoreflect.MessageKind:
		fmt.Fprintf(g, "writer |> @lib.write_uint32(@lib.size_of(%s)); @lib.Write::write(%s, writer)\n", variable, variable)
	case protoreflect.Fixed32Kind:
		fmt.Fprintf(g, "writer |> @lib.write_fixed32(%s)\n", variable)
	case protoreflect.Sfixed32Kind:
		fmt.Fprintf(g, "writer |> @lib.write_sfixed32(%s)\n", variable)
	case protoreflect.FloatKind:
		fmt.Fprintf(g, "writer |> @lib.write_float(%s)\n", variable)
	case protoreflect.Fixed64Kind:
		fmt.Fprintf(g, "writer |> @lib.write_fixed64(%s)\n", variable)
	case protoreflect.Sfixed64Kind:
		fmt.Fprintf(g, "writer |> @lib.write_sfixed64(%s)\n", variable)
	case protoreflect.DoubleKind:
		fmt.Fprintf(g, "writer |> @lib.write_double(%s)\n", variable)
	case protoreflect.BoolKind:
		fmt.Fprintf(g, "writer |> @lib.write_bool(%s)\n", variable)
	case protoreflect.Int32Kind:
		fmt.Fprintf(g, "writer |> @lib.write_int32(%s)\n", variable)
	case protoreflect.Int64Kind:
		fmt.Fprintf(g, "writer |> @lib.write_int64(%s)\n", variable)
	case protoreflect.Sint32Kind:
		fmt.Fprintf(g, "writer |> @lib.write_sint32(%s)\n", variable)
	case protoreflect.Sint64Kind:
		fmt.Fprintf(g, "writer |> @lib.write_sint64(%s)\n", variable)
	case protoreflect.Uint32Kind:
		fmt.Fprintf(g, "writer |> @lib.write_uint32(%s)\n", variable)
	case protoreflect.Uint64Kind:
		fmt.Fprintf(g, "writer |> @lib.write_uint64(%s)\n", variable)
	case protoreflect.EnumKind:
		fmt.Fprintf(g, "writer |> @lib.write_enum(%s.to_enum())\n", variable)
	default:
		panic("todo: support deprecated group")
	}
}

func oneOfEnumName(m *protogen.Message, oneof *protogen.Oneof) string {
	return m.GoIdent.GoName + "_" + cases.Title(language.English).String(oneof.GoName)
}
