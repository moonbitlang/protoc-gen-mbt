///|
fn Message::has_runtime_json_impl(self : Message) -> Bool {
  self.import_path.package_name == "google.protobuf" &&
  (self.name == "Timestamp" || self.name == "Duration")
}

///|
fn CodeGenerator::message_shape(
  self : CodeGenerator,
  message : Message,
) -> MessageShape raise {
  let storage_fields = []
  let codec_fields = []
  let json_fields = []
  let oneofs = []
  let has_runtime_json_impl = message.has_runtime_json_impl()
  for field in message.fields {
    storage_fields.push(self.field_storage_shape(field, message.import_path))
    codec_fields.push(self.field_codec_shape(field, message.import_path))
    if self.support_json() && !has_runtime_json_impl {
      json_fields.push(self.field_json_shape(field, message.import_path))
    }
  }
  for oneof in message.oneofs {
    oneofs.push(self.oneof_shape(message, oneof))
  }
  {
    message_name: message.import_path.path() |> to_camel_case,
    storage_fields,
    codec_fields,
    json_fields,
    oneofs,
    has_runtime_json_impl,
  }
}

///|
fn MessageShape::is_empty(self : MessageShape) -> Bool {
  self.storage_fields.is_empty() && self.oneofs.is_empty()
}
