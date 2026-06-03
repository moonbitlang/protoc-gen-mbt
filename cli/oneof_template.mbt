///|
fn CodeGenerator::get_oneof_enum_name(
  _ : CodeGenerator,
  message : Message,
  oneof_name : String,
) -> String {
  let message_name = message.import_path.path() |> to_camel_case
  return "\{message_name}_\{to_camel_case(oneof_name)}"
}

///|
fn CodeGenerator::gen_oneof_enum(
  self : CodeGenerator,
  message : Message,
  oneof : OneOf,
  content : StringBuilder,
) -> Unit raise {
  let enum_name = self.get_oneof_enum_name(message, oneof.import_path.name())
  content.write_string("pub(all) enum \{enum_name} {\n")
  for field in oneof.field {
    let field_type = self.get_moonbit_type(
      field,
      parent_path=message.import_path,
    )
    let field_name = field.import_path.name() |> to_camel_case
    content.write_string("  \{field_name}(\{field_type})\n")
  }
  let derive_list = self.derive_list().join(", ")
  content.write_string(
    (
      $|  NotSet
      $|} derive(\{derive_list})
      $|pub impl Default for \{enum_name} with fn default() -> \{enum_name} {
      $|  NotSet
      $|}
      $|
    ),
  )
  if self.support_json() {
    // From Json
    content.write_string(
      "pub impl @json.FromJson for \{enum_name} with fn from_json(json: Json, path: @json.JsonPath) -> \{enum_name} raise {\n",
    )
    for field in oneof.field {
      let field_name = field.import_path.name() |> to_camel_case
      content.write_string(
        (
          $|  try { \{enum_name}::\{field_name}(json |> @json.from_json(path~)) } catch {
          $|    _ => ()
          $|  } noraise {
          $|    v => return v
          $|  }
          $|
        ),
      )
    }
    content.write_string(
      (
        $|\{enum_name}::NotSet
        $|}
        $|pub impl ToJson for \{enum_name} with fn to_json(self : \{enum_name}) -> Json {
        $|  match self {
        // To Json
        $|
      ),
    )
    for field in oneof.field {
      let field_name = field.import_path.name() |> to_camel_case
      content.write_string(
        "    \{enum_name}::\{field_name}(v) => v.to_json()\n",
      )
    }
    content.write_string(
      (
        $|    \{enum_name}::NotSet => Json::null()
        $|  }
        $|}
        $|
      ),
    )
  }
}
