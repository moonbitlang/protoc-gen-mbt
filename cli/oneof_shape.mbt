///|
fn CodeGenerator::oneof_shape(
  self : CodeGenerator,
  message : Message,
  oneof : OneOf,
) -> OneofShape raise {
  let message_name = message.import_path.path() |> to_camel_case
  let fields = []
  for field in oneof.field {
    let field_shape : OneofFieldShape = {
      constructor_name: field.import_path.name() |> to_camel_case,
      field_number: field.number.unwrap(),
      json_name: field.json_name.unwrap(),
      value_type: self.get_moonbit_type(field, parent_path=message.import_path),
      value: self.field_codec_value(field, message.import_path),
    }
    fields.push(field_shape)
  }
  {
    field_name: oneof.import_path.name() |> pascal_to_snake,
    enum_name: "\{message_name}_\{to_camel_case(oneof.import_path.name())}",
    fields,
  }
}

///|
fn OneofFieldShape::tag_value(self : OneofFieldShape) -> UInt64 {
  tag(self.value.type_, self.field_number, false)
}

///|
fn CodeGenerator::gen_oneof_codec_read(
  _ : CodeGenerator,
  shape : OneofShape,
  content : StringBuilder,
  is_async? : Bool = false,
) -> Unit raise {
  for field in shape.fields {
    content.write_string(
      "      (\{field.field_number}, _) => msg.\{shape.field_name} = \{field.value.read_expr(is_async~)} |> \{shape.enum_name}::\{field.constructor_name}\n",
    )
  }
}

///|
fn CodeGenerator::gen_oneof_codec_write(
  _ : CodeGenerator,
  shape : OneofShape,
  content : StringBuilder,
  is_async? : Bool = false,
) -> Unit raise {
  let async_keyword = if is_async { "async" } else { "" }
  let async_keyword_to_snake = async_keyword |> pascal_to_snake
  content.write_string("  match self.\{shape.field_name} {\n")
  for field in shape.fields {
    let field_write = field.value.write_expr("v", is_async~)
    content.write_string(
      (
        $|    \{shape.enum_name}::\{field.constructor_name}(v) => {
        $|      writer |> @lib.\{async_keyword_to_snake}write_varint(\{field.tag_value()}UL)
        $|      \{field_write}
        $|     }
        $|
      ),
    )
  }
  content.write_string(
    (
      $|    \{shape.enum_name}::NotSet => ()
      $|  }
      $|
    ),
  )
}

///|
fn CodeGenerator::gen_oneof_codec_size(
  _ : CodeGenerator,
  shape : OneofShape,
  content : StringBuilder,
) -> Unit {
  content.write_string("  match self.\{shape.field_name} {\n")
  for field in shape.fields {
    let (delta_size, need_v) = field.value.unpacked_size_expr(
      "v",
      field.field_number,
    )
    let value_binding = if need_v { "v" } else { "_" }
    content.write_string(
      (
        $|    \{field.constructor_name}(\{value_binding}) => { size += \{delta_size} }
        $|
      ),
    )
  }
  content.write_string(
    (
      #|    NotSet => ()
      #|  }
      #|
    ),
  )
}

///|
fn CodeGenerator::gen_oneof_json_to(
  _ : CodeGenerator,
  shape : OneofShape,
  content : StringBuilder,
) -> Unit {
  content.write_string(
    (
      $|  match self.\{shape.field_name} {
      $|    NotSet => ()
      $|
    ),
  )
  for field in shape.fields {
    content.write_string(
      "    \{field.constructor_name}(v) => json[\"\{field.json_name}\"] = v.to_json()\n",
    )
  }
  content.write_string("  }\n")
}

///|
fn CodeGenerator::gen_oneof_json_from(
  _ : CodeGenerator,
  shape : OneofShape,
  content : StringBuilder,
) -> Unit {
  for field in shape.fields {
    content.write_string(
      "      (\"\{field.json_name}\", value) => message.\{shape.field_name} = @json.from_json(value, path~)\n",
    )
  }
}
