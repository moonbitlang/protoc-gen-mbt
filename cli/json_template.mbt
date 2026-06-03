///|
fn CodeGenerator::gen_message_json(
  self : CodeGenerator,
  message : Message,
  content : StringBuilder,
) -> Unit raise {
  let message_name = message.import_path.path() |> to_camel_case
  if message.fields.is_empty() && message.oneofs.is_empty() {
    content.write_string(
      (
        $|pub impl ToJson for \{message_name} with to_json(_) {
        $|  {}
        $|}
        $|pub impl @json.FromJson for \{message_name} with from_json(_, _) -> \{message_name} noraise {
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
      $|pub impl ToJson for \{message_name} with to_json(self) {
      $|  let json: Map[String, Json] = {}
      $|
    ),
  )
  for field in message.fields {
    let field_name = "self.\{field.import_path.name() |> pascal_to_snake}"
    let json_name = field.json_name.unwrap_or(field.name)
    let field_type = self.get_moonbit_type(
      field,
      parent_path=message.import_path,
    )
    let has_default_value = field.default_value() is Some(_)
    let default_value = if field.default_value() is Some(default_value) {
      if field.type_ is Some(TYPE_STRING) {
        "\"\{default_value}\""
      } else if field.is_enum() {
        "\{field_type}::\{default_value}"
      } else {
        "\{default_value}"
      }
    } else {
      "Default::default()"
    }
    if field.is_optional() {
      content.write_string("  match \{field_name} {\n")
      let optional_match = if has_default_value {
        "Some(v) if v != \{default_value}"
      } else {
        "Some(v)"
      }
      if field.type_ is Some(TYPE_BYTES) {
        content.write_string(
          "      \{optional_match} => json[\"\{json_name}\"] = @lib.base64_encode(v).to_json()\n",
        )
      } else {
        content.write_string(
          "      \{optional_match} => json[\"\{json_name}\"] = v.to_json()\n",
        )
      }
      content.write_string(
        (
          #|      _ => ()
          #|    }
          #|
        ),
      )
    } else {
      content.write_string("  if \{field_name} != \{default_value} {\n")
      match field.type_ {
        Some(TYPE_BYTES) =>
          content.write_string(
            "  json[\"\{json_name}\"] = @lib.base64_encode(\{field_name}).to_json()\n",
          )
        _ =>
          content.write_string(
            "  json[\"\{json_name}\"] = \{field_name}.to_json()\n",
          )
      }
      content.write_string("  }\n")
    }
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
      $|pub impl @json.FromJson for \{message_name} with from_json(json: Json, path: @json.JsonPath) -> \{message_name} raise {
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
    let field_name = field.import_path.name() |> pascal_to_snake
    let json_name = field.json_name.unwrap()
    if field.is_optional() {
      match field.type_ {
        Some(TYPE_BYTES) =>
          content.write_string(
            "      (\"\{json_name}\", String(value)) => message.\{field_name} = Some(@lib.base64_decode(value))\n",
          )
        Some(TYPE_FLOAT) =>
          content.write_string(
            "      (\"\{json_name}\", Number(value, ..)) => message.\{field_name} = Some(Float::from_double(value))\n",
          )
        _ =>
          content.write_string(
            "      (\"\{json_name}\", value) => message.\{field_name} = Some(@json.from_json(value, path~))\n",
          )
      }
    } else if field.map_key_value() is Some(_) {
      content.write_string(
        "      (\"\{json_name}\", _) => message.\{field_name} = @json.from_json(value, path~)\n",
      )
    } else if field.is_list() {
      content.write_string(
        "      (\"\{json_name}\", Array(value)) => message.\{field_name} = value.map(v => \n",
      )
      if field.type_ is Some(TYPE_FLOAT) {
        content.write_string("Float::from_double(@json.from_json(v, path~)))\n")
      } else {
        content.write_string("@json.from_json(v, path~))\n")
      }
    } else {
      match field.type_ {
        Some(TYPE_FLOAT) =>
          content.write_string(
            "      (\"\{json_name}\", Number(value, ..)) => message.\{field_name} = Float::from_double(value)\n",
          )
        Some(TYPE_BYTES) =>
          content.write_string(
            "      (\"\{json_name}\", String(value)) => message.\{field_name} = @lib.base64_decode(value)\n",
          )
        _ =>
          content.write_string(
            "      (\"\{json_name}\", value) => message.\{field_name} = @json.from_json(value, path~)\n",
          )
      }
    }
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
      #|      key => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
      #|    }
      #|  }
      #|  message
      #|}
      #|
    ),
  )
}

