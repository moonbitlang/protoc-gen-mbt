///|
fn CodeGenerator::gen_message_size(
  self : CodeGenerator,
  message : Message,
  content : StringBuilder,
) -> Unit raise {
  let message_name = message.import_path.path() |> to_camel_case
  if message.fields.is_empty() && message.oneofs.is_empty() {
    content.write_string(
      (
        $|pub impl @lib.Sized for \{message_name} with fn size_of(_) {
        $|  0
        $|}
        $|
      ),
    )
    return
  }
  content.write_string(
    (
      $|pub impl @lib.Sized for \{message_name} with fn size_of(self) {
      $|  let mut size = 0U
      $|
    ),
  )
  for field in message.fields {
    let shape = self.field_codec_shape(field, message.import_path)
    self.gen_field_codec_size(shape, content)
  }
  for oneof in message.oneofs {
    let field_name = oneof.import_path.name() |> pascal_to_snake
    content.write_string("  match self.\{field_name} {\n")
    for field in oneof.field {
      let field_name = field.import_path.name() |> to_camel_case
      let field_number = field.number.unwrap()
      let (delta_size, value_binding) = if field.type_ is Some(typ) {
        let value : FieldCodecValue = {
          type_: typ,
          type_name: "",
          number: field_number,
        }
        let (value_size, need_v) = value.unpacked_size_expr(
          "v",
          size_tag(field_number),
        )
        (value_size, if need_v { "v" } else { "_" })
      } else {
        ("0", "_")
      }
      content.write_string(
        (
          $|    \{field_name}(\{value_binding}) => { size += \{delta_size} }
          $|
        ),
      )
    }
    content.write_string(
      (
        #|    NotSet => ()
        #|  }
        #|
      ),
    )
  }
  content.write_string(
    (
      #|  size
      #|}
      #|
    ),
  )
}
