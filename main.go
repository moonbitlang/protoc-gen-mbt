package main

import (
	"regexp"
	"strings"

	"google.golang.org/protobuf/compiler/protogen"
	"google.golang.org/protobuf/reflect/protoreflect"
)

func main() {
	protogen.Options{}.Run(func(gen *protogen.Plugin) error {
		for _, f := range gen.Files {
			if f.Generate {
				generateFile(gen, f)
			}
		}
		return nil
	})
}

func generateFile(gen *protogen.Plugin, file *protogen.File) *protogen.GeneratedFile {
	filename := file.GeneratedFilenamePrefix + ".pb.mbt"
	g := gen.NewGeneratedFile(filename, "path")
	g.P("// Code generated from ", file.GeneratedFilenamePrefix, ".proto", " by protoc-gen-mbt. DO NOT EDIT.")
	g.P()

	generateEnums(g, file.Enums)
	generateMessages(g, file.Messages)

	return g
}

func generateEnums(g *protogen.GeneratedFile, enums []*protogen.Enum) {
	for _, enum := range enums {
		generateEnum(g, enum)
	}
}

func generateEnum(g *protogen.GeneratedFile, enum *protogen.Enum) {
	g.P("enum ", enum.GoIdent.GoName, " {")
	for _, value := range enum.Values {
		g.P("  ", value.GoIdent.GoName)
	}
	g.P("}")
	g.P()
}

func generateMessages(g *protogen.GeneratedFile, messages []*protogen.Message) {
	for _, m := range messages {
		// Generate nested enums first
		generateEnums(g, m.Enums)

		// Recursively process nested messages (if any)
		generateMessages(g, m.Messages)

		// Generate the message itself
		generateMessage(g, m)
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

func generateMessage(g *protogen.GeneratedFile, m *protogen.Message) {
	g.P("struct ", m.GoIdent.GoName, " {")

	// Regular fields
	for _, field := range m.Fields {
		if field.Oneof != nil && !field.Oneof.Desc.IsSynthetic() {
			// Skip fields that are part of a non-synthetic oneof; they'll be handled separately
			continue
		}
		fieldType := getFieldType(field)
		// fieldName should in pascalcase
		fieldName := PascalToSnake(field.GoName)

		g.P("  ", fieldName, " : ", fieldType)
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
		g.P("  ", fieldName, " : ", enumName)
		// Generate the enum for the oneof
		// defer to ensure the enum is generated after the struct (not nested)
		defer generateOneofEnum(g, m, oneof)
	}

	g.P("}")
	g.P()
}

func generateOneofEnum(g *protogen.GeneratedFile, m *protogen.Message, oneof *protogen.Oneof) {
	enumName := m.GoIdent.GoName + "_" + strings.Title(oneof.GoName)
	g.P("enum ", enumName, " {")
	for _, field := range oneof.Fields {
		fieldType := getFieldType(field)
		variantName := field.GoName + "(" + fieldType + ")"
		g.P("  ", variantName)
	}
	g.P("  None")
	g.P("}")
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
	case protoreflect.Uint32Kind:
		fieldType = "UInt"
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
		fieldType = field.GoIdent.GoName
	}

	// Check if the field is repeated
	if field.Desc.Cardinality() == protoreflect.Repeated {
		fieldType = "Array[" + fieldType + "]"
	}

	return fieldType
}
