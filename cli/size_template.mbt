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
    let shape = self.oneof_shape(message, oneof)
    self.gen_oneof_codec_size(shape, content)
  }
  content.write_string(
    (
      #|  size
      #|}
      #|
    ),
  )
}
