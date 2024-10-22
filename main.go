package main

import (
	"regexp"
	"strings"

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
	g.P("// Code generated from ", file.GeneratedFilenamePrefix, ".proto", " by protoc-gen-mbt. DO NOT EDIT.")
	g.P()

	genEnums(g, file.Enums)
	genMessages(g, file.Messages)

	return g
}

func genEnums(g *protogen.GeneratedFile, enums []*protogen.Enum) {
	for _, enum := range enums {
		genEnum(g, enum)
	}
	if len(enums) > 0 {
		genEnumDefault(g, enums[0])
		genEnumFromProto(g, enums[0])
		genEnumToProto(g, enums[0])
	}
}

func genEnumFromProto(g *protogen.GeneratedFile, enum *protogen.Enum) {
	g.P("impl @lib.FromProto for ", enum.GoIdent.GoName, " with from(i : Int) {")
	g.P("\tmatch i {")
	for _, value := range enum.Values {
		g.P("\t\t", value.Desc.Number(), " => ", enum.GoIdent.GoName, "::", value.GoIdent.GoName)
	}
	g.P("\t\t_ => Default::default()")
	g.P("\t}")
	g.P("}\n")
	g.P()
}

func genEnumToProto(g *protogen.GeneratedFile, enum *protogen.Enum) {
	g.P("impl @lib.ToProto for ", enum.GoIdent.GoName, " with into(self) {")
	g.P("\tmatch self {")
	for _, value := range enum.Values {
		g.P("\t\t", enum.GoIdent.GoName, "::", value.GoIdent.GoName, " => ", value.Desc.Number())
	}
	g.P("\t}")
	g.P("}\n")
	g.P()
}

func genEnumDefault(g *protogen.GeneratedFile, enum *protogen.Enum) {
	g.P("impl Default for ", enum.GoIdent.GoName, " with default() {")
	g.P("\t", enum.GoIdent.GoName, "::", enum.Values[0].GoIdent.GoName)
	g.P("}\n")
	g.P()
}

func genEnum(g *protogen.GeneratedFile, enum *protogen.Enum) {
	g.P("enum ", enum.GoIdent.GoName, " {")
	for _, value := range enum.Values {
		g.P("\t", value.GoIdent.GoName)
	}
	g.P("}\n")
	g.P()
}

func genMessages(g *protogen.GeneratedFile, messages []*protogen.Message) {
	for _, m := range messages {
		// Generate nested enums first
		genEnums(g, m.Enums)

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
	g.P("struct ", m.GoIdent.GoName, " {")
	defer genMessageRead(g, m)
	defer genMessageWrite(g, m)

	// Regular fields
	for _, field := range m.Fields {
		if field.Oneof != nil && !field.Oneof.Desc.IsSynthetic() {
			// Skip fields that are part of a non-synthetic oneof; they'll be handled separately
			continue
		}
		fieldType := getFieldType(field)
		// fieldName should in pascalcase
		fieldName := PascalToSnake(field.GoName)

		g.P("\tmut ", fieldName, " : ", fieldType)
	}

	// Oneof fields
	// Fields in oneofs must not have labels (required / optional / repeated).
	for _, oneof := range m.Oneofs {
		if oneof.Desc.IsSynthetic() {
			// Skip synthetic oneofs; they're not part of the user-defined message
			continue
		}
		enumName := m.GoIdent.GoName + "_" + strings.Title(oneof.GoName)
		fieldName := strings.ToLower(oneof.GoIdent.GoName)
		g.P("\tmut ", fieldName, " : ", enumName)
		// Generate the enum for the oneof
		// defer to ensure the enum is generated after the struct (not nested)
		defer genOneofEnum(g, m, oneof)
	}

	g.P("} derive(Default)")
	g.P()
}

func genOneofEnum(g *protogen.GeneratedFile, m *protogen.Message, oneof *protogen.Oneof) {
	enumName := m.GoIdent.GoName + "_" + strings.Title(oneof.GoName)
	g.P("enum ", enumName, " {")
	for _, field := range oneof.Fields {
		fieldType := getFieldType(field)
		variantName := field.GoName + "(" + fieldType + ")"
		g.P("\t", variantName)
	}
	g.P("\tNone")
	g.P("} derive(Default)")
	g.P()
}

func getFieldType(field *protogen.Field) string {
	fieldType := ""
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

	// Check if the field is repeated or map
	// else if field.Desc.Cardinality() == protoreflect.Repeated {
	// 	fieldType = "Array[" + fieldType + "]"
	// } if field.Desc.IsMap() {
	// 	keyType := getFieldType(field.Message.Fields[0])
	// 	valueType := getFieldType(field.Message.Fields[1])
	// 	fieldType = "Map[" + keyType + ", " + valueType + "]"
	// }
	if field.Desc.IsMap() {
		keyType := getFieldType(field.Message.Fields[0])
		valueType := getFieldType(field.Message.Fields[1])
		fieldType = "Map[" + keyType + ", " + valueType + "]"
	} else if field.Desc.Cardinality() == protoreflect.Repeated {
		fieldType = "Array[" + fieldType + "]"
	}

	return fieldType
}

func genMessageRead(g *protogen.GeneratedFile, m *protogen.Message) {
	name := m.GoIdent.GoName
	g.P("impl @lib.MessageRead for ", name, " with from_reader(br : @lib.BytesReader, b : Bytes) {")
	defaultStr := "\t" + name + "::default()"
	if len(m.Fields) == 0 {
		// Empty message, generate default
		g.P("\tbr.read_to_end()")
		g.P(defaultStr)
	} else {
		g.P("\tlet msg = ", defaultStr)
		g.P("\twhile br.is_eof().not() {")
		g.P("\t\tmatch br.next_tag?(b) {")

		for _, field := range m.Fields {
			// special case for repeated field as it's in the `LEN` wiretype and we need to treat it as Array
			kind := field.Desc.Kind()
			if field.Desc.Cardinality() == protoreflect.Repeated {
				genRepeatedFieldRead(field, g, kind)
			} else {
				genFieldRead(field, kind, name, g)
			}
		}

		g.P("\t\t\tOk(t) => br.read_unknown!(b, t)")
		g.P("\t\t\tErr(e) => raise e")
		g.P("\t\t}")
		g.P("\t}")
		g.P("\tmsg")
	}
	g.P("}\n")
}

func genFieldRead(field *protogen.Field, kind protoreflect.Kind, name string, g *protogen.GeneratedFile) {
	tag := protowire.EncodeTag(field.Desc.Number(), mapFieldKindToWireType(kind))
	if field.Oneof != nil && !field.Oneof.Desc.IsSynthetic() {
		fieldName := strings.ToLower(name + "_" + field.Oneof.GoName)
		enumName := name + "_" + strings.Title(field.Oneof.GoName)
		g.P("\t\t\tOk(", tag, ") => msg.", fieldName, " = ", enumName, "::", field.GoName, "(br.read_", kind, "!(b))")
	} else {
		fieldName := PascalToSnake(field.GoName)
		g.P("\t\t\tOk(", tag, ") => msg.", fieldName, " = br.read_", kind, "!(b)")
	}
}

func genRepeatedFieldRead(field *protogen.Field, g *protogen.GeneratedFile, kind protoreflect.Kind) {
	// repeated fields have wire type 2
	tag := protowire.EncodeTag(field.Desc.Number(), 2)
	fieldName := PascalToSnake(field.GoName)
	g.P("\t\t\tOk(", tag, ") => msg.", fieldName, " = br.read_packed!(b, fn(br, b) { br.read_", kind, "!(b) })")
}

func writeToWriter(g *protogen.GeneratedFile, m *protogen.Message) {

}

func genMessageWrite(g *protogen.GeneratedFile, m *protogen.Message) {
	// TODO: unused var
	name := m.GoIdent.GoName
	g.P("impl @lib.MessageWrite for ", name, " with write_to_writer(self, w : @lib.Writer) {")
	if len(m.Fields) == 0 {
		// just skip if there is no field
		g.P("\t")
	} else {
		writeToWriter(g, m)
	}
	g.P("}\n")

	g.P("impl @lib.MessageWrite for ", name, " with get_size(self) {")
	if len(m.Fields) == 0 {
		// just skip if there is no field
		g.P("\t0")
	} else {
		writeGetSize(g, m.Fields)
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

func writeGetSize(g *protogen.GeneratedFile, field []*protogen.Field) {
	g.P("\t0U +")
	for _, field := range field {
		tag := protowire.EncodeTag(field.Desc.Number(), mapFieldKindToWireType(field.Desc.Kind()))
		tagSize := sizeOfVarint(tag)
		fieldName := PascalToSnake(field.GoName)
		if field.Desc.IsMap() {
			// map field has 2 fields, key and value
			// we need to calculate the size of the key and value
			keyField := field.Message.Fields[0]
			valueField := field.Message.Fields[1]
			keyTag := protowire.EncodeTag(keyField.Desc.Number(), mapFieldKindToWireType(keyField.Desc.Kind()))
			valueTag := protowire.EncodeTag(valueField.Desc.Number(), mapFieldKindToWireType(valueField.Desc.Kind()))
			keyTagSize := sizeOfVarint(keyTag)
			valueTagSize := sizeOfVarint(valueTag)
			g.P("\t", tagSize, "U + ", keyTagSize, "U + self.get_", keyField.Desc.Kind(), "_size(self.", fieldName, ".keys()) + ", valueTagSize, "U + self.get_", valueField.Desc.Kind(), "_size(self.", fieldName, ".values()) +")
		} else {
			g.P("\t", tagSize, "U + self.get_", field.Desc.Kind(), "_size(self.", fieldName, ") +")
		}
	}
}

func sizeOfVarint(value uint64) int {
	if value <= 0x7F {
		return 1
	} else if value <= 0x3FFF {
		return 2
	} else if value <= 0x1FFFFF {
		return 3
	} else if value <= 0xFFFFFFF {
		return 4
	} else {
		return 5
	}
}
