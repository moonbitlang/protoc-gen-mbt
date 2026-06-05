///|
fn CodeGenerator::gen_message_reader(
  self : CodeGenerator,
  message : Message,
  content : StringBuilder,
  is_async? : Bool = false,
) -> Unit raise {
  let message_name = message.import_path.path() |> to_camel_case
  let async_keyword = if is_async { "async" } else { "" }
  let async_keyword_to_snake = async_keyword |> pascal_to_snake
  let async_keyword_to_title = async_keyword |> title
  if message.fields.is_empty() && message.oneofs.is_empty() {
    content.write_string(
      (
        $|pub impl @lib.\{async_keyword_to_title}Read for \{message_name} with fn read_with_limit(_) -> \{message_name} noraise {
        $|  \{message_name}::default()
        $|}
        $|
      ),
    )
    return
  }
  content.write_string(
    (
      $|pub impl @lib.\{async_keyword_to_title}Read for \{message_name} with fn read_with_limit(reader : @lib.LimitedReader[&@lib.\{async_keyword_to_title}Reader]) -> \{message_name} raise {
      $|  let msg = \{message_name}::default()
      $|
    ),
  )
  content.write_string(
    (
      $|  try {
      $|    for ;; {
      $|      match (reader |> @lib.\{async_keyword_to_snake}read_tag()) {
      $|
    ),
  )
  for field in message.fields {
    let shape = self.field_codec_shape(field, message.import_path)
    self.gen_field_codec_read(shape, content, is_async~)
  }
  for oneof in message.oneofs {
    let oneof_name = self.get_oneof_enum_name(message, oneof.import_path.name())
    let oneof_field_name = oneof.import_path.name() |> pascal_to_snake
    for field in oneof.field {
      let field_name = field.import_path.name() |> to_camel_case
      let field_number = field.number.unwrap()
      let type_name = self.get_moonbit_type(
        field,
        parent_path=message.import_path,
      )
      content.write_string(
        "        (\{field_number}, _) => msg.\{oneof_field_name} = \{gen_kind_read(field.type_.unwrap(), type_name, is_async~)} |> \{oneof_name}::\{field_name}\n",
      )
    }
  }
  content.write_string(
    (
      $|       (_, wire) => reader |> @lib.\{async_keyword |> pascal_to_snake}read_unknown(wire)
      $|      }
      $|    }
      $|  } catch {
      $|    @lib.EndOfStream => ()
      $|    err => raise err
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

///|
fn gen_kind_read(
  field_type : FieldDescriptorProto_Type,
  type_name : String,
  is_async? : Bool = false,
) -> String raise {
  let async_keyword = if is_async { "async_" } else { "" }
  match field_type {
    FieldDescriptorProto_Type::TYPE_BOOL
    | FieldDescriptorProto_Type::TYPE_INT32
    | FieldDescriptorProto_Type::TYPE_INT64
    | FieldDescriptorProto_Type::TYPE_UINT32
    | FieldDescriptorProto_Type::TYPE_UINT64
    | FieldDescriptorProto_Type::TYPE_FIXED32
    | FieldDescriptorProto_Type::TYPE_FIXED64
    | FieldDescriptorProto_Type::TYPE_SFIXED32
    | FieldDescriptorProto_Type::TYPE_SFIXED64
    | FieldDescriptorProto_Type::TYPE_FLOAT
    | FieldDescriptorProto_Type::TYPE_DOUBLE
    | FieldDescriptorProto_Type::TYPE_STRING
    | FieldDescriptorProto_Type::TYPE_BYTES =>
      "reader |> \{kind_read_func(field_type, is_async~)}()"
    FieldDescriptorProto_Type::TYPE_SINT32
    | FieldDescriptorProto_Type::TYPE_SINT64 =>
      "(reader |> \{kind_read_func(field_type, is_async~)}()).0"
    FieldDescriptorProto_Type::TYPE_ENUM =>
      "reader |> @lib.\{async_keyword}read_enum() |> \{type_name}::from_enum"
    FieldDescriptorProto_Type::TYPE_MESSAGE =>
      "(reader |> @lib.\{async_keyword}read_message() : \{type_name})"
    FieldDescriptorProto_Type::TYPE_GROUP =>
      raise @model.UnsupportedType("Group")
  }
}
