///|
fn CodeGenerator::field_envelope_shape(
  _ : CodeGenerator,
  field : Field,
  is_packed? : Bool = false,
) -> FieldEnvelopeShape raise {
  let field_number = field.number.unwrap()
  if is_packed {
    return {
      field_number,
      wire_type: WIRE_TYPE_LENGTH_DELIMITED,
      kind: PackedEnvelope,
    }
  }
  guard field.type_ is Some(type_) else {
    raise @model.UnexpectedType(
      "Field type is not set: \{field.import_path.name()}",
    )
  }
  match type_ {
    FieldDescriptorProto_Type::TYPE_BOOL
    | FieldDescriptorProto_Type::TYPE_ENUM
    | FieldDescriptorProto_Type::TYPE_INT32
    | FieldDescriptorProto_Type::TYPE_INT64
    | FieldDescriptorProto_Type::TYPE_SINT32
    | FieldDescriptorProto_Type::TYPE_SINT64
    | FieldDescriptorProto_Type::TYPE_UINT32
    | FieldDescriptorProto_Type::TYPE_UINT64 =>
      { field_number, wire_type: WIRE_TYPE_VARINT, kind: ScalarEnvelope }
    FieldDescriptorProto_Type::TYPE_FIXED64
    | FieldDescriptorProto_Type::TYPE_SFIXED64
    | FieldDescriptorProto_Type::TYPE_DOUBLE =>
      { field_number, wire_type: WIRE_TYPE_FIXED64, kind: ScalarEnvelope }
    FieldDescriptorProto_Type::TYPE_STRING
    | FieldDescriptorProto_Type::TYPE_BYTES =>
      {
        field_number,
        wire_type: WIRE_TYPE_LENGTH_DELIMITED,
        kind: LengthDelimitedEnvelope,
      }
    FieldDescriptorProto_Type::TYPE_MESSAGE
    | FieldDescriptorProto_Type::TYPE_GROUP =>
      match field.codec_message_encoding() {
        DelimitedMessage =>
          {
            field_number,
            wire_type: WIRE_TYPE_START_GROUP,
            kind: DelimitedMessageEnvelope,
          }
        LengthPrefixedMessage =>
          {
            field_number,
            wire_type: WIRE_TYPE_LENGTH_DELIMITED,
            kind: LengthDelimitedEnvelope,
          }
      }
    FieldDescriptorProto_Type::TYPE_FIXED32
    | FieldDescriptorProto_Type::TYPE_SFIXED32
    | FieldDescriptorProto_Type::TYPE_FLOAT =>
      { field_number, wire_type: WIRE_TYPE_FIXED32, kind: ScalarEnvelope }
  }
}

///|
fn FieldEnvelopeShape::tag_value(self : FieldEnvelopeShape) -> UInt64 {
  encode_tag(self.field_number, self.wire_type)
}

///|
fn FieldEnvelopeShape::writes_own_field_tags(self : FieldEnvelopeShape) -> Bool {
  self.kind == DelimitedMessageEnvelope
}

///|
fn FieldEnvelopeShape::read_wire_pattern(
  self : FieldEnvelopeShape,
  value : FieldCodecValue,
) -> String raise {
  match value.type_ {
    FieldDescriptorProto_Type::TYPE_MESSAGE
    | FieldDescriptorProto_Type::TYPE_GROUP =>
      runtime_wire_type_const(self.wire_type)
    _ => "_"
  }
}

///|
fn FieldEnvelopeShape::size_expr(
  self : FieldEnvelopeShape,
  payload_size_expr : String,
) -> String {
  match self.kind {
    DelimitedMessageEnvelope =>
      "@lib.size_of_delimited_field(\{self.field_number}U, \{payload_size_expr})"
    LengthDelimitedEnvelope | PackedEnvelope =>
      "@lib.size_of_length_delimited_field(\{self.field_number}U, \{payload_size_expr})"
    ScalarEnvelope =>
      "@lib.size_of_field(\{self.field_number}U, \{payload_size_expr})"
  }
}
