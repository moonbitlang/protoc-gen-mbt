///|
fn CodeGenerator::gen_message_writer(
  self : CodeGenerator,
  message : Message,
  content : StringBuilder,
  is_async? : Bool = false,
) -> Unit raise {
  let message_name = message.import_path.path() |> to_camel_case
  let async_keyword = if is_async { "async" } else { "" }
  let async_keyword_to_snake = async_keyword |> pascal_to_snake
  let async_keyword_to_title = async_keyword |> title
  if message.fields.is_empty() && message.oneofs.is_empty() {
    content.write_string(
      (
        $|pub impl @lib.\{async_keyword_to_title}Write for \{message_name} with write(_, _) -> Unit noraise {
        $|}
        $|
      ),
    )
    return
  }
  content.write_string(
    "pub impl @lib.\{async_keyword_to_title}Write for \{message_name} with write(self: \{message_name}, writer : &@lib.\{async_keyword_to_title}Writer) -> Unit raise {\n",
  )
  for field in message.fields {
    let field_name = field.import_path.name() |> pascal_to_snake
    let field_number = field.number.unwrap()
    if field.is_pack() {
      let tag_val = tag(field.type_.unwrap(), field_number, true)
      content.write_string(
        "  writer |> @lib.\{async_keyword_to_snake}write_varint(\{tag_val}UL)\n",
      )
      match field.type_.unwrap() {
        FieldDescriptorProto_Type::TYPE_FIXED32
        | FieldDescriptorProto_Type::TYPE_SFIXED32
        | FieldDescriptorProto_Type::TYPE_FLOAT => {
          let fixed_size = sizeFixed32()
          content.write_string(
            "  let size = self.\{field_name}.length().reinterpret_as_uint() * \{fixed_size}\n",
          )
        }
        FieldDescriptorProto_Type::TYPE_FIXED64
        | FieldDescriptorProto_Type::TYPE_SFIXED64
        | FieldDescriptorProto_Type::TYPE_DOUBLE => {
          let fixed_size = sizeFixed64()
          content.write_string(
            "  let size = self.\{field_name}.length().reinterpret_as_uint() * \{fixed_size}\n",
          )
        }
        FieldDescriptorProto_Type::TYPE_INT32
        | FieldDescriptorProto_Type::TYPE_INT64
        | FieldDescriptorProto_Type::TYPE_SINT32
        | FieldDescriptorProto_Type::TYPE_SINT64
        | FieldDescriptorProto_Type::TYPE_UINT32
        | FieldDescriptorProto_Type::TYPE_UINT64
        | FieldDescriptorProto_Type::TYPE_BOOL
        | FieldDescriptorProto_Type::TYPE_ENUM =>
          content.write_string(
            "  let size = self.\{field_name}.iter().map(@lib.size_of).fold(init=0U, UInt::add)\n",
          )
        _ => raise UnexpectedType("packed field type: \{field.type_}")
      }
      let field_write_type = self.gen_kind_write(field, "item", is_async~)
      content.write_string(
        (
          $|  writer |> @lib.\{async_keyword_to_snake}write_uint32(size)
          $|  for item in self.\{field_name} {
          $|      \{field_write_type}
          $|  }
          $|
        ),
      )
    } else if field.map_key_value() is Some(map_entry) {
      let key_field = map_entry.fields[0]
      let value_field = map_entry.fields[1]
      let tag_val = tag(field.type_.unwrap(), field_number, false)
      content.write_string(
        (
          $|  let keys = self.\{field_name}.keys().collect()
          $|  for i in 0..<keys.length() {
          $|    let k = keys[i]
          $|    let v = self.\{field_name}.get(k).unwrap()
          $|    writer |> @lib.\{async_keyword_to_snake}write_varint(\{tag_val}UL)
          $|
        ),
      )
      match key_field.type_.unwrap() {
        FieldDescriptorProto_Type::TYPE_STRING
        | FieldDescriptorProto_Type::TYPE_BYTES
        | FieldDescriptorProto_Type::TYPE_MESSAGE => {
          let key_tag_size = size_tag(0)
          content.write_string(
            "    let key_size = \{key_tag_size}U + { let size = @lib.size_of(k); @lib.size_of(size) + size }\n",
          )
        }
        FieldDescriptorProto_Type::TYPE_FIXED32
        | FieldDescriptorProto_Type::TYPE_SFIXED32
        | FieldDescriptorProto_Type::TYPE_FLOAT => {
          let key_tag_size = size_tag(0)
          let fixed_size = sizeFixed32()
          content.write_string(
            "    let key_size = \{key_tag_size}U + \{fixed_size}U\n",
          )
        }
        FieldDescriptorProto_Type::TYPE_FIXED64
        | FieldDescriptorProto_Type::TYPE_SFIXED64
        | FieldDescriptorProto_Type::TYPE_DOUBLE => {
          let key_tag_size = size_tag(0)
          let fixed_size = sizeFixed64()
          content.write_string(
            "    let key_size = \{key_tag_size}U + \{fixed_size}U\n",
          )
        }
        _ => {
          let key_tag_size = size_tag(0)
          content.write_string(
            "    let key_size = \{key_tag_size}U + @lib.size_of(k)\n",
          )
        }
      }
      match value_field.type_.unwrap() {
        FieldDescriptorProto_Type::TYPE_STRING
        | FieldDescriptorProto_Type::TYPE_BYTES
        | FieldDescriptorProto_Type::TYPE_MESSAGE => {
          let value_tag_size = size_tag(1)
          content.write_string(
            "    let value_size = \{value_tag_size}U + { let size = @lib.size_of(v); @lib.size_of(size) + size }\n",
          )
        }
        FieldDescriptorProto_Type::TYPE_FIXED32
        | FieldDescriptorProto_Type::TYPE_SFIXED32
        | FieldDescriptorProto_Type::TYPE_FLOAT => {
          let value_tag_size = size_tag(1)
          let fixed_size = sizeFixed32()
          content.write_string(
            "    let value_size = \{value_tag_size}U + \{fixed_size}U\n",
          )
        }
        FieldDescriptorProto_Type::TYPE_FIXED64
        | FieldDescriptorProto_Type::TYPE_SFIXED64
        | FieldDescriptorProto_Type::TYPE_DOUBLE => {
          let value_tag_size = size_tag(1)
          let fixed_size = sizeFixed64()
          content.write_string(
            "    let value_size = \{value_tag_size}U + \{fixed_size}U\n",
          )
        }
        _ => {
          let value_tag_size = size_tag(1)
          content.write_string(
            "    let value_size = \{value_tag_size}U + @lib.size_of(v)\n",
          )
        }
      }
      let key_tag_val = tag(key_field.type_.unwrap(), 1, false)
      let value_tag_val = tag(value_field.type_.unwrap(), 2, false)
      let field_write_type_k = self.gen_kind_write(key_field, "k", is_async~)
      let field_write_type_v = self.gen_kind_write(value_field, "v", is_async~)
      content.write_string(
        (
          $|    writer |> @lib.\{async_keyword_to_snake}write_uint32(key_size + value_size)
          $|    writer |> @lib.\{async_keyword_to_snake}write_varint(\{key_tag_val}UL)
          $|    \{field_write_type_k}
          $|    writer |> @lib.\{async_keyword_to_snake}write_varint(\{value_tag_val}UL);
          $|    \{field_write_type_v}
          $|  }
          $| 
        ),
      )
    } else if field.is_list() {
      let tag_val = tag(field.type_.unwrap(), field_number, false)
      let field_write_type = self.gen_kind_write(field, "item", is_async~)
      content.write_string(
        (
          $|  for item in self.\{field_name} {
          $|    writer |> @lib.\{async_keyword_to_snake}write_varint(\{tag_val}UL)
          $|    \{field_write_type}
          $|  }
          $|
        ),
      )
    } else if field.is_optional() {
      let field_write_type = self.gen_kind_write(field, "v", is_async~)
      let tag_val = tag(field.type_.unwrap(), field_number, false)
      content.write_string(
        (
          $|  if self.\{field_name} is Some(v) {
          $|    writer |> @lib.\{async_keyword_to_snake}write_varint(\{tag_val}UL);
          $|    \{field_write_type}
          $|  }
          $|
        ),
      )
    } else {
      let field_write_type = self.gen_kind_write(
        field,
        "self.\{field_name}",
        is_async~,
      )
      let tag_val = tag(field.type_.unwrap(), field_number, false)
      content.write_string(
        (
          $|  writer |> @lib.\{async_keyword_to_snake}write_varint(\{tag_val}UL);
          $|  \{field_write_type}
        ),
      )
    }
  }
  for oneof in message.oneofs {
    let oneof_name = self.get_oneof_enum_name(message, oneof.import_path.name())
    let oneof_field_name = oneof.import_path.name() |> pascal_to_snake
    content.write_string("  match self.\{oneof_field_name} {\n")
    for field in oneof.field {
      let field_name = field.import_path.name() |> to_camel_case
      let field_number = field.number.unwrap()
      let tag_val = tag(field.type_.unwrap(), field_number, false)
      let field_write_type = self.gen_kind_write(field, "v", is_async~)
      content.write_string(
        (
          $|    \{oneof_name}::\{field_name}(v) => {
          $|      writer |> @lib.\{async_keyword_to_snake}write_varint(\{tag_val}UL)
          $|      \{field_write_type}
          $|     }
          $|
        ),
      )
    }
    content.write_string(
      (
        $|    \{oneof_name}::NotSet => ()
        $|  }
        $|
      ),
    )
  }
  content.write_string("}\n")
}

///|
fn CodeGenerator::gen_kind_write(
  _ : CodeGenerator,
  field : Field,
  variable : String,
  is_async? : Bool = false,
) -> String raise {
  guard field.type_ is Some(field_type) else {
    raise UnexpectedType("Field type is not set: \{field.import_path.name()}")
  }
  let async_keyword = if is_async { "async_" } else { "" }
  let async_kewyord_to_title = if is_async { "Async" } else { "" }
  match field_type {
    FieldDescriptorProto_Type::TYPE_STRING =>
      "writer |> @lib.\{async_keyword}write_string(\{variable})\n"
    FieldDescriptorProto_Type::TYPE_BYTES =>
      "writer |> @lib.\{async_keyword}write_bytes(\{variable})\n"
    FieldDescriptorProto_Type::TYPE_MESSAGE =>
      "writer |> @lib.\{async_keyword}write_uint32(@lib.size_of(\{variable})); @lib.\{async_kewyord_to_title}Write::write(\{variable}, writer)\n"
    FieldDescriptorProto_Type::TYPE_FIXED32 =>
      "writer |> @lib.\{async_keyword}write_fixed32(\{variable})\n"
    FieldDescriptorProto_Type::TYPE_SFIXED32 =>
      "writer |> @lib.\{async_keyword}write_sfixed32(\{variable})\n"
    FieldDescriptorProto_Type::TYPE_FLOAT =>
      "writer |> @lib.\{async_keyword}write_float(\{variable})\n"
    FieldDescriptorProto_Type::TYPE_FIXED64 =>
      "writer |> @lib.\{async_keyword}write_fixed64(\{variable})\n"
    FieldDescriptorProto_Type::TYPE_SFIXED64 =>
      "writer |> @lib.\{async_keyword}write_sfixed64(\{variable})\n"
    FieldDescriptorProto_Type::TYPE_DOUBLE =>
      "writer |> @lib.\{async_keyword}write_double(\{variable})\n"
    FieldDescriptorProto_Type::TYPE_BOOL =>
      "writer |> @lib.\{async_keyword}write_bool(\{variable})\n"
    FieldDescriptorProto_Type::TYPE_INT32 =>
      "writer |> @lib.\{async_keyword}write_int32(\{variable})\n"
    FieldDescriptorProto_Type::TYPE_INT64 =>
      "writer |> @lib.\{async_keyword}write_int64(\{variable})\n"
    FieldDescriptorProto_Type::TYPE_SINT32 =>
      "writer |> @lib.\{async_keyword}write_sint32(\{variable})\n"
    FieldDescriptorProto_Type::TYPE_SINT64 =>
      "writer |> @lib.\{async_keyword}write_sint64(\{variable})\n"
    FieldDescriptorProto_Type::TYPE_UINT32 =>
      "writer |> @lib.\{async_keyword}write_uint32(\{variable})\n"
    FieldDescriptorProto_Type::TYPE_UINT64 =>
      "writer |> @lib.\{async_keyword}write_uint64(\{variable})\n"
    FieldDescriptorProto_Type::TYPE_ENUM =>
      "writer |> @lib.\{async_keyword}write_enum(\{variable}.to_enum())\n"
    _ =>
      raise UnexpectedType(
        "Unsupported field type: \{field_type} for field \{field.import_path.name()}",
      )
  }
}
