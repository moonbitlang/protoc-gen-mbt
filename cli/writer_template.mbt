///|
fn CodeGenerator::gen_message_writer(
  self : CodeGenerator,
  message : Message,
  content : StringBuilder,
  is_async? : Bool = false,
) -> Unit raise {
  let message_name = message.import_path.path() |> to_camel_case
  let async_keyword = if is_async { "async" } else { "" }
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
    let shape = self.oneof_shape(message, oneof)
    self.gen_oneof_codec_write(shape, content, is_async~)
  }
  content.write_string("}\n")
}
