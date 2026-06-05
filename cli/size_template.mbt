///|
fn CodeGenerator::gen_message_size(
  self : CodeGenerator,
  shape : MessageShape,
  content : StringBuilder,
) -> Unit raise {
  if shape.is_empty() {
    content.write_string(
      (
        $|pub impl @lib.Sized for \{shape.message_name} with fn size_of(_) {
        $|  0
        $|}
        $|
      ),
    )
    return
  }
  content.write_string(
    (
      $|pub impl @lib.Sized for \{shape.message_name} with fn size_of(self) {
      $|  let mut size = 0U
      $|
    ),
  )
  for field in shape.codec_fields {
    self.gen_field_codec_size(field, content)
  }
  for oneof in shape.oneofs {
    self.gen_oneof_codec_size(oneof, content)
  }
  content.write_string(
    (
      #|  size
      #|}
      #|
    ),
  )
}
