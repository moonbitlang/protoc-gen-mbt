///|
fn CodeGenerator::gen_oneof_enum(
  self : CodeGenerator,
  shape : OneofShape,
  content : StringBuilder,
) -> Unit {
  content.write_string("pub(all) enum \{shape.enum_name} {\n")
  for field in shape.fields {
    content.write_string("  \{field.constructor_name}(\{field.value_type})\n")
  }
  let derive_list = self.derive_list().join(", ")
  content.write_string(
    (
      $|  NotSet
      $|} derive(\{derive_list})
      $|pub impl Default for \{shape.enum_name} with fn default() -> \{shape.enum_name} {
      $|  NotSet
      $|}
      $|
    ),
  )
  if self.support_json() {
    // From Json
    content.write_string(
      "pub impl @json.FromJson for \{shape.enum_name} with fn from_json(json: Json, path: @json.JsonPath) -> \{shape.enum_name} raise {\n",
    )
    for field in shape.fields {
      content.write_string(
        (
          $|  try { \{shape.enum_name}::\{field.constructor_name}(json |> @json.from_json(path~)) } catch {
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
        $|\{shape.enum_name}::NotSet
        $|}
        $|pub impl ToJson for \{shape.enum_name} with fn to_json(self : \{shape.enum_name}) -> Json {
        $|  match self {
        // To Json
        $|
      ),
    )
    for field in shape.fields {
      content.write_string(
        "    \{shape.enum_name}::\{field.constructor_name}(v) => v.to_json()\n",
      )
    }
    content.write_string(
      (
        $|    \{shape.enum_name}::NotSet => Json::null()
        $|  }
        $|}
        $|
      ),
    )
  }
}
