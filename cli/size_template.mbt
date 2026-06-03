///|
fn gen_unpacked_value_size_expr(
  typ : FieldDescriptorProto_Type,
  value_expr : String,
  tag_size : Int,
) -> (String, Bool) {
  match typ {
    FieldDescriptorProto_Type::TYPE_STRING
    | FieldDescriptorProto_Type::TYPE_BYTES
    | FieldDescriptorProto_Type::TYPE_MESSAGE =>
      (
        "\{tag_size}U + { let size = @lib.size_of(\{value_expr}); @lib.size_of(size) + size }",
        true,
      )
    FieldDescriptorProto_Type::TYPE_FIXED32
    | FieldDescriptorProto_Type::TYPE_SFIXED32
    | FieldDescriptorProto_Type::TYPE_FLOAT => {
      let fixed_size = sizeFixed32()
      ("\{tag_size}U + \{fixed_size}U", false)
    }
    FieldDescriptorProto_Type::TYPE_FIXED64
    | FieldDescriptorProto_Type::TYPE_SFIXED64
    | FieldDescriptorProto_Type::TYPE_DOUBLE => {
      let fixed_size = sizeFixed64()
      ("\{tag_size}U + \{fixed_size}U", false)
    }
    _ => ("\{tag_size}U + @lib.size_of(\{value_expr})", true)
  }
}

///|
fn CodeGenerator::gen_message_size(
  _ : CodeGenerator,
  message : Message,
  content : StringBuilder,
) -> Unit raise {
  let message_name = message.import_path.path() |> to_camel_case
  if message.fields.is_empty() && message.oneofs.is_empty() {
    content.write_string(
      (
        $|pub impl @lib.Sized for \{message_name} with fn size_of(_) {
        $|  0
        $|}
        $|
      ),
    )
    return
  }
  content.write_string(
    (
      $|pub impl @lib.Sized for \{message_name} with fn size_of(self) {
      $|  let mut size = 0U
      $|
    ),
  )
  for field in message.fields {
    let field_name = pascal_to_snake(field.name)
    let field_number = field.number.unwrap()
    if field.is_pack() {
      if field.type_ is Some(typ) {
        let delta_size = match typ {
          FieldDescriptorProto_Type::TYPE_FIXED32
          | FieldDescriptorProto_Type::TYPE_SFIXED32
          | FieldDescriptorProto_Type::TYPE_FLOAT => {
            let tag_size = size_tag(field_number)
            let fixed_size = sizeFixed32()
            "\{tag_size}U + { let size = self.\{field_name}.length().reinterpret_as_uint() * \{fixed_size}; @lib.size_of(size) + size}"
          }
          FieldDescriptorProto_Type::TYPE_FIXED64
          | FieldDescriptorProto_Type::TYPE_SFIXED64
          | FieldDescriptorProto_Type::TYPE_DOUBLE => {
            let tag_size = size_tag(field_number)
            let fixed_size = sizeFixed64()
            "\{tag_size}U + { let size = self.\{field_name}.length().reinterpret_as_uint() * \{fixed_size}; @lib.size_of(size) + size}"
          }
          FieldDescriptorProto_Type::TYPE_INT32
          | FieldDescriptorProto_Type::TYPE_INT64
          | FieldDescriptorProto_Type::TYPE_SINT32
          | FieldDescriptorProto_Type::TYPE_SINT64
          | FieldDescriptorProto_Type::TYPE_UINT32
          | FieldDescriptorProto_Type::TYPE_UINT64
          | FieldDescriptorProto_Type::TYPE_BOOL
          | FieldDescriptorProto_Type::TYPE_ENUM => {
            let tag_size = size_tag(field_number)
            "\{tag_size}U + { let size = self.\{field_name}.iter().map(@lib.size_of).fold(init=0U, UInt::add); @lib.size_of(size) + size }"
          }
          _ => raise UnsupportedType("unexpected packed field type")
        }
        content.write_string("  size += \{delta_size}\n")
      }
    } else if field.map_key_value() is Some(map_entry) {
      let key_field = map_entry.fields[0]
      let value_field = map_entry.fields[1]
      let tag_size = size_tag(field_number)
      let (key_size, _) = gen_unpacked_value_size_expr(
        key_field.type_.unwrap(),
        "k",
        size_tag(key_field.number.unwrap()),
      )
      let (value_size, _) = gen_unpacked_value_size_expr(
        value_field.type_.unwrap(),
        "v",
        size_tag(value_field.number.unwrap()),
      )
      content.write_string(
        (
          $|  for k, v in self.\{field_name} {
          $|    let key_size = \{key_size}
          $|    let value_size = \{value_size}
          $|    size += \{tag_size}U + @lib.size_of(key_size + value_size) + key_size + value_size
          $|  }
          $|
        ),
      )
    } else if field.is_list() {
      let tag_size = size_tag(field_number)
      guard field.type_ is Some(typ)
      let (delta_size, _) = gen_unpacked_value_size_expr(typ, "s", tag_size)
      content.write_string(
        (
          $|  for s in self.\{field_name} {
          $|    size += \{delta_size}
          $|  }
          $|
        ),
      )
    } else if field.is_optional() {
      guard field.type_ is Some(typ)
      let (delta_size, need_v) = gen_unpacked_value_size_expr(
        typ,
        "v",
        size_tag(field_number),
      )
      if need_v {
        content.write_string(
          (
            $|  if self.\{field_name} is Some(v) {
            $|    size += \{delta_size}
            $|  }
            $|
          ),
        )
      } else {
        content.write_string(
          (
            $|  if self.\{field_name} is Some(_) {
            $|    size += \{delta_size}
            $|  }
            $|
          ),
        )
      }
    } else if field.type_ is Some(typ) {
      let (delta_size, _) = gen_unpacked_value_size_expr(
        typ,
        "self.\{field_name}",
        size_tag(field_number),
      )
      content.write_string("  size += \{delta_size}\n")
    }
  }
  for oneof in message.oneofs {
    let field_name = oneof.import_path.name() |> pascal_to_snake
    content.write_string("  match self.\{field_name} {\n")
    for field in oneof.field {
      let field_name = field.import_path.name() |> to_camel_case
      let field_number = field.number.unwrap()
      let delta_size = if field.type_ is Some(typ) {
        let (value_size, _) = gen_unpacked_value_size_expr(
          typ,
          "v",
          size_tag(field_number),
        )
        value_size
      } else {
        "0"
      }
      content.write_string(
        (
          $|    \{field_name}(v) => { size += \{delta_size} }
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
  content.write_string(
    (
      #|  size
      #|}
      #|
    ),
  )
}
