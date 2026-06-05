///|
fn CodeGenerator::gen_message_reader(
  self : CodeGenerator,
  shape : MessageShape,
  content : StringBuilder,
  is_async? : Bool = false,
) -> Unit raise {
  let async_keyword = if is_async { "async" } else { "" }
  let async_keyword_to_snake = async_keyword |> pascal_to_snake
  let async_keyword_to_title = async_keyword |> title
  if shape.is_empty() {
    content.write_string(
      (
        $|pub impl @lib.\{async_keyword_to_title}Read for \{shape.message_name} with fn read_with_limit(_) -> \{shape.message_name} noraise {
        $|  \{shape.message_name}::default()
        $|}
        $|
      ),
    )
    return
  }
  content.write_string(
    (
      $|pub impl @lib.\{async_keyword_to_title}Read for \{shape.message_name} with fn read_with_limit(reader : @lib.LimitedReader[&@lib.\{async_keyword_to_title}Reader]) -> \{shape.message_name} raise {
      $|  let msg = \{shape.message_name}::default()
      $|
    ),
  )
  content.write_string(
    (
      $|  while (reader |> @lib.\{async_keyword_to_snake}read_next_message_field()) is Some((field_number, wire)) {
      $|    match (field_number, wire) {
      $|
    ),
  )
  for field in shape.codec_fields {
    self.gen_field_codec_read(field, content, is_async~)
  }
  for oneof in shape.oneofs {
    self.gen_oneof_codec_read(oneof, content, is_async~)
  }
  content.write_string(
    (
      $|      _ => reader |> @lib.\{async_keyword_to_snake}skip_message_field(wire)
      $|    }
      $|  }
      $|  msg
      $|}
      $|
    ),
  )
}

///|
fn kind_read_func(
  kind : FieldDescriptorProto_Type,
  is_async? : Bool = false,
) -> String raise {
  let async_keyword = if is_async { "async_" } else { "" }
  match kind {
    FieldDescriptorProto_Type::TYPE_BOOL => "@lib.\{async_keyword}read_bool"
    FieldDescriptorProto_Type::TYPE_INT32 => "@lib.\{async_keyword}read_int32"
    FieldDescriptorProto_Type::TYPE_INT64 => "@lib.\{async_keyword}read_int64"
    FieldDescriptorProto_Type::TYPE_SINT32 => "@lib.\{async_keyword}read_sint32"
    FieldDescriptorProto_Type::TYPE_SINT64 => "@lib.\{async_keyword}read_sint64"
    FieldDescriptorProto_Type::TYPE_UINT32 => "@lib.\{async_keyword}read_uint32"
    FieldDescriptorProto_Type::TYPE_UINT64 => "@lib.\{async_keyword}read_uint64"
    FieldDescriptorProto_Type::TYPE_FIXED32 =>
      "@lib.\{async_keyword}read_fixed32"
    FieldDescriptorProto_Type::TYPE_FIXED64 =>
      "@lib.\{async_keyword}read_fixed64"
    FieldDescriptorProto_Type::TYPE_SFIXED32 =>
      "@lib.\{async_keyword}read_sfixed32"
    FieldDescriptorProto_Type::TYPE_SFIXED64 =>
      "@lib.\{async_keyword}read_sfixed64"
    FieldDescriptorProto_Type::TYPE_FLOAT => "@lib.\{async_keyword}read_float"
    FieldDescriptorProto_Type::TYPE_DOUBLE => "@lib.\{async_keyword}read_double"
    FieldDescriptorProto_Type::TYPE_STRING => "@lib.\{async_keyword}read_string"
    FieldDescriptorProto_Type::TYPE_BYTES => "@lib.\{async_keyword}read_bytes"
    FieldDescriptorProto_Type::TYPE_ENUM =>
      raise @model.UnsupportedType("enum type")
    FieldDescriptorProto_Type::TYPE_MESSAGE =>
      raise @model.UnexpectedType("message type")
    FieldDescriptorProto_Type::TYPE_GROUP =>
      raise @model.UnsupportedType("Group")
  }
}
