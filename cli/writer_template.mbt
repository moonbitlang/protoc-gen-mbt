///|
fn CodeGenerator::gen_message_writer(
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
        $|pub impl @lib.\{async_keyword_to_title}Write for \{message_name} with fn write(_, _) -> Unit noraise {
        $|}
        $|
      ),
    )
    return
  }
  content.write_string(
    "pub impl @lib.\{async_keyword_to_title}Write for \{message_name} with fn write(self: \{message_name}, writer : &@lib.\{async_keyword_to_title}Writer) -> Unit raise {\n",
  )
  for field in message.fields {
    let shape = self.field_codec_shape(field, message.import_path)
    self.gen_field_codec_write(shape, content, is_async~)
  }
  for oneof in message.oneofs {
    let oneof_name = self.get_oneof_enum_name(message, oneof.import_path.name())
    let oneof_field_name = oneof.import_path.name() |> pascal_to_snake
    content.write_string("  match self.\{oneof_field_name} {\n")
    for field in oneof.field {
      let field_name = field.import_path.name() |> to_camel_case
      let field_number = field.number.unwrap()
      let tag_val = tag(field.type_.unwrap(), field_number, false)
      let field_write_type = self.gen_kind_write(field, "v", is_async~)
      content.write_string(
        (
          $|    \{oneof_name}::\{field_name}(v) => {
          $|      writer |> @lib.\{async_keyword_to_snake}write_varint(\{tag_val}UL)
          $|      \{field_write_type}
          $|     }
          $|
        ),
      )
    }
    content.write_string(
      (
        $|    \{oneof_name}::NotSet => ()
        $|  }
        $|
      ),
    )
  }
  content.write_string("}\n")
}

///|
fn CodeGenerator::gen_kind_write(
  _ : CodeGenerator,
  field : Field,
  variable : String,
  is_async? : Bool = false,
) -> String raise {
  guard field.type_ is Some(type_) else {
    raise @model.UnexpectedType(
      "Field type is not set: \{field.import_path.name()}",
    )
  }
  let value : FieldCodecValue = { type_, type_name: "", number: 0 }
  value.write_expr(variable, is_async~)
}
