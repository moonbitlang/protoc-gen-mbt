///|
fn CodeGenerator::gen_message_writer(
  self : CodeGenerator,
  shape : MessageShape,
  content : StringBuilder,
  is_async? : Bool = false,
) -> Unit raise {
  let async_keyword = if is_async { "async" } else { "" }
  let async_keyword_to_title = async_keyword |> title
  if shape.is_empty() {
    content.write_string(
      (
        $|pub impl @lib.\{async_keyword_to_title}Write for \{shape.message_name} with fn write(_, _) -> Unit noraise {
        $|}
        $|
      ),
    )
    return
  }
  content.write_string(
    "pub impl @lib.\{async_keyword_to_title}Write for \{shape.message_name} with fn write(self: \{shape.message_name}, writer : &@lib.\{async_keyword_to_title}Writer) -> Unit raise {\n",
  )
  for field in shape.codec_fields {
    self.gen_field_codec_write(field, content, is_async~)
  }
  for oneof in shape.oneofs {
    self.gen_oneof_codec_write(oneof, content, is_async~)
  }
  content.write_string("}\n")
}
