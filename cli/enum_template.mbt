///|
fn Enum::unknown_value_variant_name(self : Enum) -> String {
  let names : Map[String, Int] = {}
  for value in self.value {
    let value_name = to_camel_case(value.name.unwrap())
    names[value_name] = names.get_or_default(value_name, 0) + 1
  }
  let mut suffix = 0
  while true {
    let name = if suffix == 0 { "Unknown" } else { "Unknown\{suffix}" }
    if !names.contains(name) {
      return name
    }
    suffix += 1
  }
  panic()
}

///|
fn CodeGenerator::gen_enum(
  self : CodeGenerator,
  enum_ : Enum,
  file : StringBuilder,
) -> Unit {
  let derive_list = self.derive_list().join(", ")
  let enum_name = enum_.import_path.path() |> to_camel_case
  let unknown_variant_name = enum_.unknown_value_variant_name()
  file.write_string("pub(all) enum \{enum_name} {\n")
  for value in enum_.value {
    let value_name = to_camel_case(value.name.unwrap())
    file.write_string("  \{value_name}\n")
  }
  if enum_.is_open() {
    file.write_string("  \{unknown_variant_name}(@lib.Enum)\n")
  }
  file.write_string("} derive(\{derive_list})\n")

  // To enum
  file.write_string(
    (
      $|pub fn \{enum_name}::to_enum(self : \{enum_name}) -> @lib.Enum {
      $|  match self {
      $|
    ),
  )
  for value in enum_.value {
    let value_name = to_camel_case(value.name.unwrap())
    file.write_string(
      "    \{enum_name}::\{value_name} => \{value.number.unwrap()}\n",
    )
  }
  if enum_.is_open() {
    file.write_string(
      "    \{enum_name}::\{unknown_variant_name}(value) => value\n",
    )
  }
  // From enum
  file.write_string(
    (
      $|  }
      $|}
      $|pub fn \{enum_name}::from_enum(i : @lib.Enum) -> \{enum_name} {
      $|  match i.0 {
      $|
    ),
  )
  for value in enum_.value {
    let value_name = to_camel_case(value.name.unwrap())
    file.write_string(
      "    \{value.number.unwrap()} => \{enum_name}::\{value_name}\n",
    )
  }
  if enum_.is_open() {
    file.write_string("    _ => \{enum_name}::\{unknown_variant_name}(i)\n")
  } else {
    file.write_string("    _ => Default::default()\n")
  }
  file.write_string("  }\n}\n")

  // Default
  if enum_.value.length() > 0 {
    let first_value_name = to_camel_case(enum_.value[0].name.unwrap())
    file.write_string(
      (
        $|pub impl Default for \{enum_name} with fn default() -> \{enum_name} {
        $|  \{enum_name}::\{first_value_name}
        $|}
        $|
      ),
    )
  }

  // Sized
  file.write_string(
    (
      $|pub impl @lib.Sized for \{enum_name} with fn size_of(self : \{enum_name}) {
      $|  @lib.Sized::size_of(self.to_enum())
      $|}
      $|
    ),
  )

  // From JSON
  if self.support_json() {
    file.write_string(
      "pub impl @json.FromJson for \{enum_name} with fn from_json(json: Json, path: @json.JsonPath) -> \{enum_name} raise {\n",
    )
    file.write_string("  match json {\n")
    for value in enum_.value {
      let value_name = to_camel_case(value.name.unwrap())
      file.write_string(
        "    String(\"\{value_name}\") => \{enum_name}::\{value_name}\n",
      )
    }
    for value in enum_.value {
      let value_name = to_camel_case(value.name.unwrap())
      file.write_string(
        "    Number(\{value.number.unwrap()}, ..) => \{enum_name}::\{value_name}\n",
      )
    }
    if enum_.is_open() {
      file.write_string(
        (
          $|    Number(value, ..) =>
          $|      if value.trunc() == value {
          $|        \{enum_name}::\{unknown_variant_name}(@lib.Enum(value.to_uint()))
          $|      } else {
          $|        raise @json.JsonDecodeError((path, "Expected an integer number or string for enum"))
          $|      }
          $|
        ),
      )
    }

    // To JSON
    file.write_string(
      (
        $|    _ =>  raise @json.JsonDecodeError((path, "Expected a number or string for enum"))
        $|  }
        $|}
        $|pub impl ToJson for \{enum_name} with fn to_json(self : \{enum_name}) -> Json {
        $|  match self {
        $|
      ),
    )
    for value in enum_.value {
      let value_name = to_camel_case(value.name.unwrap())
      file.write_string(
        "    \{enum_name}::\{value_name} => \"\{value_name}\"\n",
      )
    }
    if enum_.is_open() {
      file.write_string(
        "    \{enum_name}::\{unknown_variant_name}(value) => value.0.to_json()\n",
      )
    }
    file.write_string(
      (
        #|  }
        #|}
        #|
      ),
    )
  }

  // End
}
