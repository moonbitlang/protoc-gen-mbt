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
        $|pub impl @lib.Sized for \{message_name} with size_of(_) {
        $|  0
        $|}
        $|
      ),
    )
    return
  }
  content.write_string(
    (
      $|pub impl @lib.Sized for \{message_name} with size_of(self) {
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
          _ => raise UnsupportedType("packed field type: \{typ}")
        }
        content.write_string("  size += \{delta_size}\n")
      }
    } else if field.map_key_value() is Some(map_entry) {
      let key_field = map_entry.fields[0]
      let value_field = map_entry.fields[1]
      let tag_size = size_tag(field_number)
      let key_size = match key_field.type_.unwrap() {
        FieldDescriptorProto_Type::TYPE_STRING
        | FieldDescriptorProto_Type::TYPE_BYTES
        | FieldDescriptorProto_Type::TYPE_MESSAGE => {
          let key_tag_size = size_tag(0)
          "\{key_tag_size}U + { let size = @lib.size_of(k); @lib.size_of(size) + size }"
        }
        FieldDescriptorProto_Type::TYPE_FIXED32
        | FieldDescriptorProto_Type::TYPE_SFIXED32
        | FieldDescriptorProto_Type::TYPE_FLOAT => {
          let key_tag_size = size_tag(0)
          let fixed_size = sizeFixed32()
          "\{key_tag_size}U + \{fixed_size}U"
        }
        FieldDescriptorProto_Type::TYPE_FIXED64
        | FieldDescriptorProto_Type::TYPE_SFIXED64
        | FieldDescriptorProto_Type::TYPE_DOUBLE => {
          let key_tag_size = size_tag(0)
          let fixed_size = sizeFixed64()
          "\{key_tag_size}U + \{fixed_size}U"
        }
        _ => {
          let key_tag_size = size_tag(0)
          "\{key_tag_size}U + @lib.size_of(k)"
        }
      }

      // Calculate value size
      let value_size = match value_field.type_.unwrap() {
        FieldDescriptorProto_Type::TYPE_STRING
        | FieldDescriptorProto_Type::TYPE_BYTES
        | FieldDescriptorProto_Type::TYPE_MESSAGE => {
          let value_tag_size = size_tag(1)
          "\{value_tag_size}U + { let size = @lib.size_of(v); @lib.size_of(size) + size }"
        }
        FieldDescriptorProto_Type::TYPE_FIXED32
        | FieldDescriptorProto_Type::TYPE_SFIXED32
        | FieldDescriptorProto_Type::TYPE_FLOAT => {
          let value_tag_size = size_tag(1)
          let fixed_size = sizeFixed32()
          "\{value_tag_size}U + \{fixed_size}U"
        }
        FieldDescriptorProto_Type::TYPE_FIXED64
        | FieldDescriptorProto_Type::TYPE_SFIXED64
        | FieldDescriptorProto_Type::TYPE_DOUBLE => {
          let value_tag_size = size_tag(1)
          let fixed_size = sizeFixed64()
          "\{value_tag_size}U + \{fixed_size}U"
        }
        _ => {
          let value_tag_size = size_tag(1)
          "\{value_tag_size}U + @lib.size_of(v)"
        }
      }
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
      content.write_string(
        (
          $|  for s in self.\{field_name} {
          $|    let s = @lib.size_of(s)
          $|    size += \{tag_size}U + @lib.size_of(s) + s
          $|  }
          $|
        ),
      )
    } else if field.is_optional() {
      guard field.type_ is Some(typ)
      let (delta_size, need_v) = match typ {
        FieldDescriptorProto_Type::TYPE_STRING
        | FieldDescriptorProto_Type::TYPE_BYTES
        | FieldDescriptorProto_Type::TYPE_MESSAGE => {
          let tag_size = size_tag(field_number)
          (
            "\{tag_size}U + { let size = @lib.size_of(v); @lib.size_of(size) + size }",
            true,
          )
        }
        FieldDescriptorProto_Type::TYPE_FIXED32
        | FieldDescriptorProto_Type::TYPE_SFIXED32
        | FieldDescriptorProto_Type::TYPE_FLOAT => {
          let tag_size = size_tag(field_number)
          let fixed_size = sizeFixed32()
          ("\{tag_size}U + \{fixed_size}U", false)
        }
        FieldDescriptorProto_Type::TYPE_FIXED64
        | FieldDescriptorProto_Type::TYPE_SFIXED64
        | FieldDescriptorProto_Type::TYPE_DOUBLE => {
          let tag_size = size_tag(field_number)
          let fixed_size = sizeFixed64()
          ("\{tag_size}U + \{fixed_size}U", false)
        }
        _ => {
          let tag_size = size_tag(field_number)
          ("\{tag_size}U + @lib.size_of(v)", true)
        }
      }
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
      let delta_size = match typ {
        FieldDescriptorProto_Type::TYPE_STRING
        | FieldDescriptorProto_Type::TYPE_BYTES
        | FieldDescriptorProto_Type::TYPE_MESSAGE => {
          let tag_size = size_tag(field_number)
          "\{tag_size}U + { let size = @lib.size_of(self.\{field_name}); @lib.size_of(size) + size }"
        }
        FieldDescriptorProto_Type::TYPE_FIXED32
        | FieldDescriptorProto_Type::TYPE_SFIXED32
        | FieldDescriptorProto_Type::TYPE_FLOAT => {
          let tag_size = size_tag(field_number)
          let fixed_size = sizeFixed32()
          "\{tag_size}U + \{fixed_size}U"
        }
        FieldDescriptorProto_Type::TYPE_FIXED64
        | FieldDescriptorProto_Type::TYPE_SFIXED64
        | FieldDescriptorProto_Type::TYPE_DOUBLE => {
          let tag_size = size_tag(field_number)
          let fixed_size = sizeFixed64()
          "\{tag_size}U + \{fixed_size}U"
        }
        _ => {
          let tag_size = size_tag(field_number)
          "\{tag_size}U + @lib.size_of(self.\{field_name})"
        }
      }
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
        match typ {
          FieldDescriptorProto_Type::TYPE_STRING
          | FieldDescriptorProto_Type::TYPE_BYTES
          | FieldDescriptorProto_Type::TYPE_MESSAGE => {
            let tag_size = size_tag(field_number)
            "\{tag_size}U + { let size = @lib.size_of(v); @lib.size_of(size) + size }"
          }
          FieldDescriptorProto_Type::TYPE_FIXED32
          | FieldDescriptorProto_Type::TYPE_SFIXED32
          | FieldDescriptorProto_Type::TYPE_FLOAT => {
            let tag_size = size_tag(field_number)
            let fixed_size = sizeFixed32()
            "\{tag_size}U + \{fixed_size}U"
          }
          FieldDescriptorProto_Type::TYPE_FIXED64
          | FieldDescriptorProto_Type::TYPE_SFIXED64
          | FieldDescriptorProto_Type::TYPE_DOUBLE => {
            let tag_size = size_tag(field_number)
            let fixed_size = sizeFixed64()
            "\{tag_size}U + \{fixed_size}U"
          }
          _ => {
            let tag_size = size_tag(field_number)
            "\{tag_size}U + @lib.size_of(v)"
          }
        }
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
