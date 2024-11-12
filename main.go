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
)

func main() {
	protogen.Options{}.Run(func(gen *protogen.Plugin) error {
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

func genMessageRead(g *protogen.GeneratedFile, m *protogen.Message) {
	fmt.Fprintf(g, "pub impl @lib.Read for %s with read(reader : @lib.Reader) {", m.GoIdent.GoName)
	defaultStr := fmt.Sprintf("  %s::default()", m.GoIdent.GoName)
	if len(m.Fields) == 0 {
		// Empty message, generate default
		g.P(defaultStr)
	} else {
		g.P(fmt.Sprintf("\tlet msg = %s", defaultStr))
		g.P("  while not(reader |> @lib.is_eof!()) {")
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

func tag(field *protogen.Field, kind protoreflect.Kind) uint64 {
	if field.Desc.Cardinality() == protoreflect.Repeated {
		// Repeated fields have wire type 2
		return protowire.EncodeTag(field.Desc.Number(), 2)
	}
	return protowire.EncodeTag(field.Desc.Number(), mapFieldKindToWireType(kind))
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
		return fmt.Sprintf("((reader |> @lib.Read::read!()) : %s)", typeName)
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

func writeToWriter(g *protogen.GeneratedFile, m *protogen.Message) {
	for _, field := range m.Fields {
		if field.Desc.IsMap() {
			g.P("\t// MAP")
		} else if field.Desc.Cardinality() == protoreflect.Repeated {
			writeRepeatedField(g, field)
		} else if field.Oneof != nil {
			g.P("\t// ONEOF")
		} else {
			writeField(g, field)
		}
	}
}

func writeRepeatedField(g *protogen.GeneratedFile, field *protogen.Field) {
	g.P("\t// REPEATED")
	fieldName := PascalToSnake(field.GoName)
	tagValue := tag(field, field.Desc.Kind())
	fieldType := field.Desc.Kind()
	kind := field.Desc.Kind()
	sizeFnName := getSizeFnName(kind, "m")
	if isFixed(kind) {
		g.P(fmt.Sprintf("\tw.write_packed_fixed_with_tag(%d, self.%s, fn(w, m) { w.write_%s(m) }, fn(m) { %s })", tagValue, fieldName, fieldType, sizeFnName))
	} else {
		g.P(fmt.Sprintf("\tw.write_packed_with_tag(%d, self.%s, fn(w, m) { w.write_%s(m) }, fn(m) { %s })", tagValue, fieldName, fieldType, sizeFnName))
		// g.P(fmt.Sprintf("\tw.write_packed_with_tag(%d)", tagValue))
	}
}

func getSizeFnName(kind protoreflect.Kind, m string) string {
	switch kind {
	case protoreflect.BoolKind, protoreflect.EnumKind, protoreflect.Int32Kind, protoreflect.Int64Kind, protoreflect.Uint32Kind, protoreflect.Uint64Kind:
		return fmt.Sprintf("@lib.Sized::size_of(%s)", m)
	case protoreflect.Sint32Kind:
		return fmt.Sprintf("@lib.Sized::size_of(@lib.SInt(%s))", m)
	case protoreflect.Sint64Kind:
		return fmt.Sprintf("@lib.Sized::size_of(@lib.SInt64(%s))", m)
	case protoreflect.Fixed64Kind, protoreflect.Sfixed64Kind, protoreflect.DoubleKind:
		return "8"
	case protoreflect.Fixed32Kind, protoreflect.Sfixed32Kind, protoreflect.FloatKind:
		return "4"
	case protoreflect.StringKind, protoreflect.BytesKind:
		return fmt.Sprintf("@lib.Sized::size_of(%s.length())", m)
	case protoreflect.MessageKind:
		return fmt.Sprintf("@lib.Sized::size_of(%s)", m)
	}
	panic("unreachable")
}

func isFixed(kind protoreflect.Kind) bool {
	switch kind {
	case protoreflect.Fixed32Kind, protoreflect.Fixed64Kind, protoreflect.DoubleKind, protoreflect.Sfixed32Kind, protoreflect.Sfixed64Kind, protoreflect.FloatKind:
		return true
	}
	return false
}

func writeField(g *protogen.GeneratedFile, field *protogen.Field) {
	fieldName := PascalToSnake(field.GoName)
	tagValue := tag(field, field.Desc.Kind())
	fieldType := getFieldMbtType(field)
	kind := field.Desc.Kind()
	g.P(fmt.Sprintf("\tif self.%s != %s::default() { w.write_with_tag(%d, fn(w) { w.write_%s(self.%s) }) }", fieldName, fieldType, tagValue, kind, fieldName))
}

func genMessageWrite(g *protogen.GeneratedFile, m *protogen.Message) {
	name := m.GoIdent.GoName
	g.P(fmt.Sprintf("impl @lib.MessageWrite for %s with write_to_writer(self, w : @lib.Writer) {", name))
	if len(m.Fields) == 0 {
		g.P("\t")
	} else {
		writeToWriter(g, m)
	}
	g.P("}\n")

	g.P(fmt.Sprintf("impl @lib.MessageWrite for %s with get_size(self) {", name))
	if len(m.Fields) == 0 {
		g.P("\t0")
	} else {
		// TODO
		g.P("\t0")
		// writeGetSize(g, m.Fields)
	}
	g.P("}\n")
}

func mapFieldKindToWireType(kind protoreflect.Kind) protowire.Type {
	switch kind {
	case protoreflect.BoolKind, protoreflect.EnumKind, protoreflect.Int32Kind, protoreflect.Int64Kind,
		protoreflect.Sint32Kind, protoreflect.Sint64Kind, protoreflect.Uint32Kind, protoreflect.Uint64Kind:
		return protowire.VarintType
	case protoreflect.Fixed32Kind, protoreflect.Sfixed32Kind, protoreflect.FloatKind:
		return protowire.Fixed32Type
	case protoreflect.Fixed64Kind, protoreflect.Sfixed64Kind, protoreflect.DoubleKind:
		return protowire.Fixed64Type
	case protoreflect.StringKind, protoreflect.BytesKind, protoreflect.MessageKind:
		return protowire.BytesType
	case protoreflect.GroupKind:
		return protowire.StartGroupType
	default:
		panic("unreachable")
	}
}

// func writeGetSize(g *protogen.GeneratedFile, fields []*protogen.Field) {
// 	g.P("\t0U +")
// 	for _, field := range fields {
// 		tagValue := protowire.EncodeTag(field.Desc.Number(), mapFieldKindToWireType(field.Desc.Kind()))
// 		tagSize := sizeOfVarint(tagValue)
// 		fieldName := PascalToSnake(field.GoName)
// 		if field.Desc.IsMap() {
// 			keyField := field.Message.Fields[0]
// 			valueField := field.Message.Fields[1]
// 			keyTag := protowire.EncodeTag(keyField.Desc.Number(), mapFieldKindToWireType(keyField.Desc.Kind()))
// 			valueTag := protowire.EncodeTag(valueField.Desc.Number(), mapFieldKindToWireType(valueField.Desc.Kind()))
// 			keyTagSize := sizeOfVarint(keyTag)
// 			valueTagSize := sizeOfVarint(valueTag)
// 			g.P(fmt.Sprintf("\t%dU + %dU + self.get_%s_size(self.%s.keys()) + %dU + self.get_%s_size(self.%s.values()) +", tagSize, keyTagSize, keyField.Desc.Kind(), fieldName, valueTagSize, valueField.Desc.Kind(), fieldName))
// 		} else {
// 			g.P(fmt.Sprintf("\t%dU + self.get_%s_size(self.%s) +", tagSize, field.Desc.Kind(), fieldName))
// 		}
// 	}
// }

func sizeOfVarint(value uint64) int {
	return protowire.SizeVarint(value)
}

func oneOfEnumName(m *protogen.Message, oneof *protogen.Oneof) string {
	return m.GoIdent.GoName + "_" + cases.Title(language.English).String(oneof.GoName)
}
