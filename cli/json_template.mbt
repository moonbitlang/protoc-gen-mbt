///|
fn Message::has_runtime_json_impl(self : Message) -> Bool {
  self.import_path.package_name == "google.protobuf" &&
  (self.name == "Timestamp" || self.name == "Duration")
}

///|
fn CodeGenerator::gen_message_json(
  self : CodeGenerator,
  message : Message,
  content : StringBuilder,
) -> Unit raise {
  if message.has_runtime_json_impl() {
    return
  }
  let message_name = message.import_path.path() |> to_camel_case
  if message.fields.is_empty() && message.oneofs.is_empty() {
    content.write_string(
      (
        $|pub impl ToJson for \{message_name} with fn to_json(_) {
        $|  {}
        $|}
        $|pub impl @json.FromJson for \{message_name} with fn from_json(_, _) -> \{message_name} noraise {
        $|  \{message_name}::default()
        $|}
        $|
      ),
    )
    return
  }

  // To JSON
  content.write_string(
    (
      $|pub impl ToJson for \{message_name} with fn to_json(self) {
      $|  let json: Map[String, Json] = {}
      $|
    ),
  )
  for field in message.fields {
    let shape = self.field_json_shape(field, message.import_path)
    self.gen_field_json_to(shape, content)
  }
  for oneof in message.oneofs {
    let oneof_field = oneof.import_path.name() |> pascal_to_snake
    content.write_string(
      (
        $|  match self.\{oneof_field} {
        $|    NotSet => ()
        $|
      ),
    )
    for field in oneof.field {
      let json_name = field.json_name.unwrap()
      let field_type = field.import_path.name() |> to_camel_case
      content.write_string(
        "    \{field_type}(v) => json[\"\{json_name}\"] = v.to_json()\n",
      )
    }
    content.write_string("  }\n")
  }
  // From JSON
  content.write_string(
    (
      $|  Json::object(json)
      $|}
      $|pub impl @json.FromJson for \{message_name} with fn from_json(json: Json, path: @json.JsonPath) -> \{message_name} raise {
      $|  guard json is Object(obj) else {
      $|    raise @json.JsonDecodeError((path, "Expected an object for \{message_name}"))
      $|  }
      $|  let message = \{message_name}::default()
      $|  for key, value in obj {
      $|    match (key, value) {
      $|
    ),
  )
  for field in message.fields {
    let shape = self.field_json_shape(field, message.import_path)
    self.gen_field_json_from(shape, content)
  }
  for oneof in message.oneofs {
    let oneof_field = oneof.import_path.name() |> pascal_to_snake
    for field in oneof.field {
      let json_name = field.json_name.unwrap()
      content.write_string(
        "      (\"\{json_name}\", value) => message.\{oneof_field} = @json.from_json(value, path~)\n",
      )
    }
  }
  content.write_string(
    (
      #|      (key, _) => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
      #|    }
      #|  }
      #|  message
      #|}
      #|
    ),
  )
}
