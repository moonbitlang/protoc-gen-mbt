///|
fn CodeGenerator::field_json_shape(
  self : CodeGenerator,
  field : Field,
  parent_path : ImportPath,
) -> FieldJsonShape raise {
  guard field.type_ is Some(type_) else {
    raise @model.UnexpectedType(
      "Field type is not set: \{field.import_path.name()}",
    )
  }
  let field_name = field.import_path.name() |> pascal_to_snake
  let field_type = self.get_moonbit_type(field, parent_path~)
  let has_default_value = field.default_value() is Some(_)
  let default_expr = if field.default_value() is Some(default_value) {
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
  let cardinality = if field.map_key_value() is Some(_) {
    FieldJsonCardinality::MapJsonField
  } else if field.is_list() {
    FieldJsonCardinality::RepeatedJsonField
  } else if field.is_optional() {
    FieldJsonCardinality::OptionalJsonField
  } else {
    FieldJsonCardinality::SingularJsonField
  }
  {
    field_name,
    self_expr: "self.\{field_name}",
    to_json_name: field.json_name.unwrap_or(field.name),
    from_json_name: field.json_name.unwrap(),
    type_,
    default_expr,
    has_default_value,
    cardinality,
  }
}

///|
fn FieldJsonShape::to_json_expr(
  self : FieldJsonShape,
  value_expr : String,
) -> String {
  if self.type_ is TYPE_BYTES {
    "@lib.base64_encode(\{value_expr}).to_json()"
  } else {
    "\{value_expr}.to_json()"
  }
}

///|
fn CodeGenerator::gen_field_json_to(
  _ : CodeGenerator,
  shape : FieldJsonShape,
  content : StringBuilder,
) -> Unit {
  match shape.cardinality {
    OptionalJsonField => {
      content.write_string("  match \{shape.self_expr} {\n")
      let optional_match = if shape.has_default_value {
        "Some(v) if v != \{shape.default_expr}"
      } else {
        "Some(v)"
      }
      content.write_string(
        "      \{optional_match} => json[\"\{shape.to_json_name}\"] = \{shape.to_json_expr("v")}\n",
      )
      content.write_string(
        (
          #|      _ => ()
          #|    }
          #|
        ),
      )
    }
    SingularJsonField | RepeatedJsonField | MapJsonField => {
      content.write_string(
        "  if \{shape.self_expr} != \{shape.default_expr} {\n",
      )
      content.write_string(
        "  json[\"\{shape.to_json_name}\"] = \{shape.to_json_expr(shape.self_expr)}\n",
      )
      content.write_string("  }\n")
    }
  }
}

///|
fn CodeGenerator::gen_field_json_from(
  _ : CodeGenerator,
  shape : FieldJsonShape,
  content : StringBuilder,
) -> Unit {
  match shape.cardinality {
    OptionalJsonField =>
      match shape.type_ {
        TYPE_BYTES =>
          content.write_string(
            "      (\"\{shape.from_json_name}\", String(value)) => message.\{shape.field_name} = Some(try @lib.base64_decode(value) catch { _ => raise @json.JsonDecodeError((path, \"Invalid base64 encoding\")) })\n",
          )
        TYPE_FLOAT =>
          content.write_string(
            "      (\"\{shape.from_json_name}\", Number(value, ..)) => message.\{shape.field_name} = Some(Float::from_double(value))\n",
          )
        _ =>
          content.write_string(
            "      (\"\{shape.from_json_name}\", value) => message.\{shape.field_name} = Some(@json.from_json(value, path~))\n",
          )
      }
    MapJsonField =>
      content.write_string(
        "      (\"\{shape.from_json_name}\", _) => message.\{shape.field_name} = @json.from_json(value, path~)\n",
      )
    RepeatedJsonField => {
      content.write_string(
        "      (\"\{shape.from_json_name}\", Array(value)) => message.\{shape.field_name} = value.map(v => \n",
      )
      if shape.type_ is TYPE_FLOAT {
        content.write_string("Float::from_double(@json.from_json(v, path~)))\n")
      } else {
        content.write_string("@json.from_json(v, path~))\n")
      }
    }
    SingularJsonField =>
      match shape.type_ {
        TYPE_FLOAT =>
          content.write_string(
            "      (\"\{shape.from_json_name}\", Number(value, ..)) => message.\{shape.field_name} = Float::from_double(value)\n",
          )
        TYPE_BYTES =>
          content.write_string(
            "      (\"\{shape.from_json_name}\", String(value)) => message.\{shape.field_name} = try @lib.base64_decode(value) catch { _ => raise @json.JsonDecodeError((path, \"Invalid base64 encoding\")) }\n",
          )
        _ =>
          content.write_string(
            "      (\"\{shape.from_json_name}\", value) => message.\{shape.field_name} = @json.from_json(value, path~)\n",
          )
      }
  }
}
