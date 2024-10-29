package main

import (
	"fmt"
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
	g.P(fmt.Sprintf("// Code generated from %s.proto by protoc-gen-mbt. DO NOT EDIT.", file.GeneratedFilenamePrefix))
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
	g.P(fmt.Sprintf("impl @lib.FromProto for %s with from(i : Int) {", enum.GoIdent.GoName))
	g.P("\tmatch i {")
	for _, value := range enum.Values {
		g.P(fmt.Sprintf("\t\t%d => %s::%s", value.Desc.Number(), enum.GoIdent.GoName, value.GoIdent.GoName))
	}
	g.P("\t\t_ => Default::default()")
	g.P("\t}")
	g.P("}")
	g.P()
}

func genEnumToProto(g *protogen.GeneratedFile, enum *protogen.Enum) {
	g.P(fmt.Sprintf("impl @lib.ToProto for %s with into(self) {", enum.GoIdent.GoName))
	g.P("\tmatch self {")
	for _, value := range enum.Values {
		g.P(fmt.Sprintf("\t\t%s::%s => %d", enum.GoIdent.GoName, value.GoIdent.GoName, value.Desc.Number()))
	}
	g.P("\t}")
	g.P("}")
	g.P()
}

func genEnumDefault(g *protogen.GeneratedFile, enum *protogen.Enum) {
	enumName := enum.GoIdent.GoName
	g.P(fmt.Sprintf("fn %s::default() -> %s {", enumName, enumName))
	g.P(fmt.Sprintf("\t%s::%s", enumName, enum.Values[0].GoIdent.GoName))
	g.P("}")
	g.P()
}

func genEnum(g *protogen.GeneratedFile, enum *protogen.Enum) {
	g.P(fmt.Sprintf("enum %s {", enum.GoIdent.GoName))
	for _, value := range enum.Values {
		g.P(fmt.Sprintf("\t%s", value.GoIdent.GoName))
	}
	g.P("} derive(Eq)")
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
	g.P(fmt.Sprintf("struct %s {", m.GoIdent.GoName))
	defer genMessageRead(g, m)
	defer genMessageWrite(g, m)

	// Regular fields
	for _, field := range m.Fields {
		if field.Oneof != nil && !field.Oneof.Desc.IsSynthetic() {
			// Skip fields that are part of a non-synthetic oneof; they'll be handled separately
			continue
		}
		fieldType := getFieldMbtType(field)
		// fieldName should in pascalcase
		fieldName := PascalToSnake(field.GoName)

		g.P(fmt.Sprintf("\tmut %s : %s", fieldName, fieldType))
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
		g.P(fmt.Sprintf("\tmut %s : %s", fieldName, enumName))
		// Generate the enum for the oneof
		// defer to ensure the enum is generated after the struct (not nested)
		defer genOneofEnum(g, m, oneof)
	}

	g.P("} derive(Default, Eq)")
	g.P()
}

func genOneofEnum(g *protogen.GeneratedFile, m *protogen.Message, oneof *protogen.Oneof) {
	enumName := m.GoIdent.GoName + "_" + strings.Title(oneof.GoName)
	g.P(fmt.Sprintf("enum %s {", enumName))
	for _, field := range oneof.Fields {
		fieldType := getFieldMbtType(field)
		variantName := fmt.Sprintf("%s(%s)", field.GoName, fieldType)
		g.P(fmt.Sprintf("\t%s", variantName))
	}
	g.P("\tOneofNone")
	g.P("} derive(Default, Eq)")
	g.P()
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
	name := m.GoIdent.GoName
	g.P(fmt.Sprintf("impl @lib.MessageRead for %s with from_reader(br : @lib.BytesReader, b : Bytes) {", name))
	defaultStr := fmt.Sprintf("\t%s::default()", name)
	if len(m.Fields) == 0 {
		// Empty message, generate default
		g.P("\tbr.read_to_end()")
		g.P(defaultStr)
	} else {
		g.P(fmt.Sprintf("\tlet msg = %s", defaultStr))
		g.P("\twhile br.is_eof().not() {")
		g.P("\t\tmatch br.next_tag?(b) {")

		for _, field := range m.Fields {
			// Special case for repeated field as it's in the `LEN` wiretype and we need to treat it as Array
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

func tag(field *protogen.Field, kind protoreflect.Kind) uint64 {
	if field.Desc.Cardinality() == protoreflect.Repeated {
		// Repeated fields have wire type 2
		return protowire.EncodeTag(field.Desc.Number(), 2)
	}
	return protowire.EncodeTag(field.Desc.Number(), mapFieldKindToWireType(kind))
}

func genFieldRead(field *protogen.Field, kind protoreflect.Kind, name string, g *protogen.GeneratedFile) {
	tagValue := tag(field, kind)
	if field.Oneof != nil && !field.Oneof.Desc.IsSynthetic() {
		fieldName := strings.ToLower(name + "_" + field.Oneof.GoName)
		enumName := name + "_" + strings.Title(field.Oneof.GoName)
		g.P(fmt.Sprintf("\t\t\tOk(%d) => msg.%s = %s::%s(br.read_%s!(b))", tagValue, fieldName, enumName, field.GoName, kind))
	} else {
		fieldName := PascalToSnake(field.GoName)
		g.P(fmt.Sprintf("\t\t\tOk(%d) => msg.%s = br.read_%s!(b)", tagValue, fieldName, kind))
	}
}

func genRepeatedFieldRead(field *protogen.Field, g *protogen.GeneratedFile, kind protoreflect.Kind) {
	tagValue := tag(field, kind)
	fieldName := PascalToSnake(field.GoName)
	g.P(fmt.Sprintf("\t\t\tOk(%d) => msg.%s = br.read_packed!(b, fn(br, b) { br.read_%s!(b) })", tagValue, fieldName, kind))
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
		return fmt.Sprintf("@lib.sizeof_varint(%s.to_uint64())", m)
	case protoreflect.Sint32Kind:
		return fmt.Sprintf("@lib.sizeof_sint32(%s)", m)
	case protoreflect.Sint64Kind:
		return fmt.Sprintf("@lib.sizeof_sint64(%s)", m)
	case protoreflect.Fixed64Kind, protoreflect.Sfixed64Kind, protoreflect.DoubleKind:
		return "8"
	case protoreflect.Fixed32Kind, protoreflect.Sfixed32Kind, protoreflect.FloatKind:
		return "4"
	case protoreflect.StringKind, protoreflect.BytesKind:
		return fmt.Sprintf("@lib.sizeof_len(%s.len())", m)
	case protoreflect.MessageKind:
		return fmt.Sprintf("@lib.sizeof_len(%s.get_size())", m)
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
