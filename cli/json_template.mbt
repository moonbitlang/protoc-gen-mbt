///|
fn CodeGenerator::gen_message_json(
  self : CodeGenerator,
  shape : MessageShape,
  content : StringBuilder,
) -> Unit {
  if shape.has_runtime_json_impl {
    return
  }
  if shape.is_empty() {
    content.write_string(
      (
        $|pub impl ToJson for \{shape.message_name} with fn to_json(_) {
        $|  {}
        $|}
        $|pub impl @json.FromJson for \{shape.message_name} with fn from_json(_, _) -> \{shape.message_name} noraise {
        $|  \{shape.message_name}::default()
        $|}
        $|
      ),
    )
    return
  }

  // To JSON
  content.write_string(
    (
      $|pub impl ToJson for \{shape.message_name} with fn to_json(self) {
      $|  let json: Map[String, Json] = {}
      $|
    ),
  )
  for field in shape.json_fields {
    self.gen_field_json_to(field, content)
  }
  for oneof in shape.oneofs {
    self.gen_oneof_json_to(oneof, content)
  }
  // From JSON
  content.write_string(
    (
      $|  Json::object(json)
      $|}
      $|pub impl @json.FromJson for \{shape.message_name} with fn from_json(json: Json, path: @json.JsonPath) -> \{shape.message_name} raise {
      $|  guard json is Object(obj) else {
      $|    raise @json.JsonDecodeError((path, "Expected an object for \{shape.message_name}"))
      $|  }
      $|  let message = \{shape.message_name}::default()
      $|  for key, value in obj {
      $|    match (key, value) {
      $|
    ),
  )
  for field in shape.json_fields {
    self.gen_field_json_from(field, content)
  }
  for oneof in shape.oneofs {
    self.gen_oneof_json_from(oneof, content)
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
