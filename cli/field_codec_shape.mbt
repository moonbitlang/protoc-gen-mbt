///|
fn CodeGenerator::field_codec_value(
  self : CodeGenerator,
  field : Field,
  parent_path : ImportPath,
) -> FieldCodecValue raise {
  guard field.type_ is Some(type_) else {
    raise @model.UnexpectedType(
      "Field type is not set: \{field.import_path.name()}",
    )
  }
  let type_name = if field.is_enum() || field.is_message() {
    self.get_moonbit_type(field, parent_path~)
  } else {
    ""
  }
  { type_, type_name }
}

///|
fn CodeGenerator::field_codec_shape(
  self : CodeGenerator,
  field : Field,
  parent_path : ImportPath,
) -> FieldCodecShape raise {
  let value = self.field_codec_value(field, parent_path)
  let envelope = self.field_envelope_shape(field, is_packed=field.is_pack())
  let mut cardinality = FieldCodecCardinality::SingularField
  let mut key = None
  let mut key_envelope = None
  let mut map_value = None
  let mut map_value_envelope = None
  if field.is_pack() {
    cardinality = FieldCodecCardinality::PackedField
  } else if field.map_key_value() is Some(map_entry) {
    cardinality = FieldCodecCardinality::MapField
    key = Some(self.field_codec_value(map_entry.fields[0], parent_path))
    key_envelope = Some(self.field_envelope_shape(map_entry.fields[0]))
    map_value = Some(self.field_codec_value(map_entry.fields[1], parent_path))
    map_value_envelope = Some(self.field_envelope_shape(map_entry.fields[1]))
  } else if field.is_list() {
    cardinality = FieldCodecCardinality::RepeatedField
  } else if field.is_optional() {
    cardinality = FieldCodecCardinality::OptionalField
  }
  let presence = match cardinality {
    PackedField | RepeatedField | MapField =>
      FieldCodecPresence::EmitFieldWhenNonEmpty
    OptionalField => FieldCodecPresence::EmitFieldWhenSome
    SingularField =>
      if field.has_implicit_presence() {
        FieldCodecPresence::EmitFieldWhenNonDefault
      } else {
        FieldCodecPresence::AlwaysEmitField
      }
  }
  let read_mode = if field.is_list() && field.is_packable_scalar() {
    FieldCodecReadMode::ReadPackedAndUnpackedField
  } else {
    FieldCodecReadMode::ReadUnpackedField
  }
  {
    field_name: field.import_path.name() |> pascal_to_snake,
    value,
    envelope,
    cardinality,
    key,
    key_envelope,
    map_value,
    map_value_envelope,
    presence,
    read_mode,
  }
}

///|
fn FieldCodecValue::read_expr(
  self : FieldCodecValue,
  envelope : FieldEnvelopeShape,
  is_async? : Bool = false,
) -> String raise {
  let async_keyword = if is_async { "async_" } else { "" }
  match self.type_ {
    FieldDescriptorProto_Type::TYPE_BOOL
    | FieldDescriptorProto_Type::TYPE_INT32
    | FieldDescriptorProto_Type::TYPE_INT64
    | FieldDescriptorProto_Type::TYPE_UINT32
    | FieldDescriptorProto_Type::TYPE_UINT64
    | FieldDescriptorProto_Type::TYPE_FIXED32
    | FieldDescriptorProto_Type::TYPE_FIXED64
    | FieldDescriptorProto_Type::TYPE_SFIXED32
    | FieldDescriptorProto_Type::TYPE_SFIXED64
    | FieldDescriptorProto_Type::TYPE_FLOAT
    | FieldDescriptorProto_Type::TYPE_DOUBLE
    | FieldDescriptorProto_Type::TYPE_STRING
    | FieldDescriptorProto_Type::TYPE_BYTES =>
      "reader |> \{kind_read_func(self.type_, is_async~)}()"
    FieldDescriptorProto_Type::TYPE_SINT32
    | FieldDescriptorProto_Type::TYPE_SINT64 =>
      "(reader |> \{kind_read_func(self.type_, is_async~)}()).0"
    FieldDescriptorProto_Type::TYPE_ENUM =>
      "reader |> @lib.\{async_keyword}read_enum() |> \{self.type_name}::from_enum"
    FieldDescriptorProto_Type::TYPE_MESSAGE
    | FieldDescriptorProto_Type::TYPE_GROUP =>
      match envelope.kind {
        DelimitedMessageEnvelope =>
          "(reader |> @lib.\{async_keyword}read_delimited_message(\{envelope.field_number}U) : \{self.type_name})"
        LengthDelimitedEnvelope =>
          "(reader |> @lib.\{async_keyword}read_message() : \{self.type_name})"
        _ => raise @model.UnexpectedType("unexpected message field envelope")
      }
  }
}

///|
fn FieldCodecValue::write_expr(
  self : FieldCodecValue,
  envelope : FieldEnvelopeShape,
  variable : String,
  is_async? : Bool = false,
) -> String raise {
  let async_keyword = if is_async { "async_" } else { "" }
  match self.type_ {
    FieldDescriptorProto_Type::TYPE_STRING =>
      "writer |> @lib.\{async_keyword}write_string(\{variable})"
    FieldDescriptorProto_Type::TYPE_BYTES =>
      "writer |> @lib.\{async_keyword}write_bytes(\{variable})"
    FieldDescriptorProto_Type::TYPE_MESSAGE
    | FieldDescriptorProto_Type::TYPE_GROUP =>
      match envelope.kind {
        DelimitedMessageEnvelope =>
          "writer |> @lib.\{async_keyword}write_delimited_message(\{envelope.field_number}U, \{variable})"
        LengthDelimitedEnvelope =>
          "writer |> @lib.\{async_keyword}write_message(\{variable})"
        _ => raise @model.UnexpectedType("unexpected message field envelope")
      }
    FieldDescriptorProto_Type::TYPE_FIXED32 =>
      "writer |> @lib.\{async_keyword}write_fixed32(\{variable})"
    FieldDescriptorProto_Type::TYPE_SFIXED32 =>
      "writer |> @lib.\{async_keyword}write_sfixed32(\{variable})"
    FieldDescriptorProto_Type::TYPE_FLOAT =>
      "writer |> @lib.\{async_keyword}write_float(\{variable})"
    FieldDescriptorProto_Type::TYPE_FIXED64 =>
      "writer |> @lib.\{async_keyword}write_fixed64(\{variable})"
    FieldDescriptorProto_Type::TYPE_SFIXED64 =>
      "writer |> @lib.\{async_keyword}write_sfixed64(\{variable})"
    FieldDescriptorProto_Type::TYPE_DOUBLE =>
      "writer |> @lib.\{async_keyword}write_double(\{variable})"
    FieldDescriptorProto_Type::TYPE_BOOL =>
      "writer |> @lib.\{async_keyword}write_bool(\{variable})"
    FieldDescriptorProto_Type::TYPE_INT32 =>
      "writer |> @lib.\{async_keyword}write_int32(\{variable})"
    FieldDescriptorProto_Type::TYPE_INT64 =>
      "writer |> @lib.\{async_keyword}write_int64(\{variable})"
    FieldDescriptorProto_Type::TYPE_SINT32 =>
      "writer |> @lib.\{async_keyword}write_sint32(\{variable})"
    FieldDescriptorProto_Type::TYPE_SINT64 =>
      "writer |> @lib.\{async_keyword}write_sint64(\{variable})"
    FieldDescriptorProto_Type::TYPE_UINT32 =>
      "writer |> @lib.\{async_keyword}write_uint32(\{variable})"
    FieldDescriptorProto_Type::TYPE_UINT64 =>
      "writer |> @lib.\{async_keyword}write_uint64(\{variable})"
    FieldDescriptorProto_Type::TYPE_ENUM =>
      "writer |> @lib.\{async_keyword}write_enum(\{variable}.to_enum())"
  }
}

///|
fn FieldCodecValue::packed_reader_func(
  self : FieldCodecValue,
  is_async? : Bool = false,
) -> String raise {
  let async_keyword = if is_async { "async_" } else { "" }
  match self.type_ {
    FieldDescriptorProto_Type::TYPE_ENUM => "@lib.\{async_keyword}read_enum"
    _ => kind_read_func(self.type_, is_async~)
  }
}

///|
fn FieldCodecValue::unpacked_wire_type(self : FieldCodecValue) -> Int raise {
  match self.type_ {
    FieldDescriptorProto_Type::TYPE_BOOL
    | FieldDescriptorProto_Type::TYPE_ENUM
    | FieldDescriptorProto_Type::TYPE_INT32
    | FieldDescriptorProto_Type::TYPE_INT64
    | FieldDescriptorProto_Type::TYPE_SINT32
    | FieldDescriptorProto_Type::TYPE_SINT64
    | FieldDescriptorProto_Type::TYPE_UINT32
    | FieldDescriptorProto_Type::TYPE_UINT64 => WIRE_TYPE_VARINT
    FieldDescriptorProto_Type::TYPE_SFIXED64
    | FieldDescriptorProto_Type::TYPE_FIXED64
    | FieldDescriptorProto_Type::TYPE_DOUBLE => WIRE_TYPE_FIXED64
    FieldDescriptorProto_Type::TYPE_SFIXED32
    | FieldDescriptorProto_Type::TYPE_FIXED32
    | FieldDescriptorProto_Type::TYPE_FLOAT => WIRE_TYPE_FIXED32
    _ => raise @model.UnexpectedType("unexpected packable field type")
  }
}

///|
fn FieldCodecValue::packed_element_size(self : FieldCodecValue) -> String raise {
  match self.type_ {
    FieldDescriptorProto_Type::TYPE_BOOL
    | FieldDescriptorProto_Type::TYPE_ENUM
    | FieldDescriptorProto_Type::TYPE_INT32
    | FieldDescriptorProto_Type::TYPE_INT64
    | FieldDescriptorProto_Type::TYPE_SINT32
    | FieldDescriptorProto_Type::TYPE_SINT64
    | FieldDescriptorProto_Type::TYPE_UINT32
    | FieldDescriptorProto_Type::TYPE_UINT64 => "None"
    FieldDescriptorProto_Type::TYPE_SFIXED64
    | FieldDescriptorProto_Type::TYPE_FIXED64
    | FieldDescriptorProto_Type::TYPE_DOUBLE => "Some(8)"
    FieldDescriptorProto_Type::TYPE_SFIXED32
    | FieldDescriptorProto_Type::TYPE_FIXED32
    | FieldDescriptorProto_Type::TYPE_FLOAT => "Some(4)"
    _ => raise @model.UnexpectedType("unexpected packable field type")
  }
}

///|
fn FieldCodecValue::field_size_expr(
  self : FieldCodecValue,
  envelope : FieldEnvelopeShape,
  value_expr : String,
) -> (String, Bool) {
  match self.type_ {
    FieldDescriptorProto_Type::TYPE_STRING
    | FieldDescriptorProto_Type::TYPE_BYTES =>
      (envelope.size_expr("@lib.size_of(\{value_expr})"), true)
    FieldDescriptorProto_Type::TYPE_MESSAGE
    | FieldDescriptorProto_Type::TYPE_GROUP =>
      (envelope.size_expr("@lib.size_of(\{value_expr})"), true)
    FieldDescriptorProto_Type::TYPE_FIXED32
    | FieldDescriptorProto_Type::TYPE_SFIXED32
    | FieldDescriptorProto_Type::TYPE_FLOAT => {
      let fixed_size = sizeFixed32()
      (envelope.size_expr("\{fixed_size}U"), false)
    }
    FieldDescriptorProto_Type::TYPE_FIXED64
    | FieldDescriptorProto_Type::TYPE_SFIXED64
    | FieldDescriptorProto_Type::TYPE_DOUBLE => {
      let fixed_size = sizeFixed64()
      (envelope.size_expr("\{fixed_size}U"), false)
    }
    _ => (envelope.size_expr("@lib.size_of(\{value_expr})"), true)
  }
}

///|
fn FieldCodecShape::packed_data_size_expr(
  self : FieldCodecShape,
) -> String raise {
  match self.value.type_ {
    FieldDescriptorProto_Type::TYPE_FIXED32
    | FieldDescriptorProto_Type::TYPE_SFIXED32
    | FieldDescriptorProto_Type::TYPE_FLOAT => {
      let fixed_size = sizeFixed32()
      "self.\{self.field_name}.length().reinterpret_as_uint() * \{fixed_size}"
    }
    FieldDescriptorProto_Type::TYPE_FIXED64
    | FieldDescriptorProto_Type::TYPE_SFIXED64
    | FieldDescriptorProto_Type::TYPE_DOUBLE => {
      let fixed_size = sizeFixed64()
      "self.\{self.field_name}.length().reinterpret_as_uint() * \{fixed_size}"
    }
    FieldDescriptorProto_Type::TYPE_INT32
    | FieldDescriptorProto_Type::TYPE_INT64
    | FieldDescriptorProto_Type::TYPE_SINT32
    | FieldDescriptorProto_Type::TYPE_SINT64
    | FieldDescriptorProto_Type::TYPE_UINT32
    | FieldDescriptorProto_Type::TYPE_UINT64
    | FieldDescriptorProto_Type::TYPE_BOOL
    | FieldDescriptorProto_Type::TYPE_ENUM =>
      "self.\{self.field_name}.iter().map(@lib.size_of).fold(init=0U, UInt::add)"
    _ => raise @model.UnexpectedType("unexpected packed field type")
  }
}

///|
fn FieldCodecShape::packed_delta_size_expr(
  self : FieldCodecShape,
) -> String raise {
  let data_size = self.packed_data_size_expr()
  self.envelope.size_expr(data_size)
}

///|
fn FieldCodecShape::presence_guard_expr(
  self : FieldCodecShape,
  value_binding? : String = "v",
) -> String? {
  match self.presence {
    FieldCodecPresence::AlwaysEmitField => None
    FieldCodecPresence::EmitFieldWhenSome =>
      Some("self.\{self.field_name} is Some(\{value_binding})")
    FieldCodecPresence::EmitFieldWhenNonDefault =>
      Some("self.\{self.field_name} != Default::default()")
    FieldCodecPresence::EmitFieldWhenNonEmpty =>
      Some("!self.\{self.field_name}.is_empty()")
  }
}

///|
fn CodeGenerator::gen_field_codec_read(
  _ : CodeGenerator,
  shape : FieldCodecShape,
  content : StringBuilder,
  is_async? : Bool = false,
) -> Unit raise {
  let async_keyword = if is_async { "async" } else { "" }
  let async_keyword_to_snake = async_keyword |> pascal_to_snake
  match shape.read_mode {
    FieldCodecReadMode::ReadPackedAndUnpackedField => {
      let packed_read = "reader |> @lib.\{async_keyword_to_snake}read_packed(\{shape.value.packed_reader_func(is_async~)}, \{shape.value.packed_element_size()})"
      match shape.value.type_ {
        FieldDescriptorProto_Type::TYPE_SINT32
        | FieldDescriptorProto_Type::TYPE_SINT64 =>
          content.write_string(
            "      (\{shape.envelope.field_number}, \{runtime_wire_type_const(WIRE_TYPE_LENGTH_DELIMITED)}) => { let packed = \{packed_read}; for item in packed { msg.\{shape.field_name}.push(item.0) } }\n",
          )
        FieldDescriptorProto_Type::TYPE_ENUM =>
          content.write_string(
            "      (\{shape.envelope.field_number}, \{runtime_wire_type_const(WIRE_TYPE_LENGTH_DELIMITED)}) => { let packed = \{packed_read}; for item in packed { msg.\{shape.field_name}.push(\{shape.value.type_name}::from_enum(item)) } }\n",
          )
        _ =>
          content.write_string(
            "      (\{shape.envelope.field_number}, \{runtime_wire_type_const(WIRE_TYPE_LENGTH_DELIMITED)}) => { msg.\{shape.field_name}.push_iter((\{packed_read}).iter()) }\n",
          )
      }
      content.write_string(
        "      (\{shape.envelope.field_number}, \{runtime_wire_type_const(shape.value.unpacked_wire_type())}) => msg.\{shape.field_name}.push(\{shape.value.read_expr(shape.envelope, is_async~)})\n",
      )
      return
    }
    FieldCodecReadMode::ReadUnpackedField => ()
  }
  match shape.cardinality {
    PackedField => raise @model.UnexpectedType("unpackable packed field")
    MapField =>
      content.write_string(
        "      (\{shape.envelope.field_number}, \{shape.envelope.read_wire_pattern(shape.value)}) => { let {key, value} = \{shape.value.read_expr(shape.envelope, is_async~)}; msg.\{shape.field_name}[key] = value }\n",
      )
    RepeatedField =>
      content.write_string(
        "      (\{shape.envelope.field_number}, \{shape.envelope.read_wire_pattern(shape.value)}) => msg.\{shape.field_name}.push(\{shape.value.read_expr(shape.envelope, is_async~)})\n",
      )
    OptionalField =>
      content.write_string(
        "      (\{shape.envelope.field_number}, \{shape.envelope.read_wire_pattern(shape.value)}) => msg.\{shape.field_name} = \{shape.value.read_expr(shape.envelope, is_async~)} |> Some\n",
      )
    SingularField =>
      content.write_string(
        "      (\{shape.envelope.field_number}, \{shape.envelope.read_wire_pattern(shape.value)}) => msg.\{shape.field_name} = \{shape.value.read_expr(shape.envelope, is_async~)}\n",
      )
  }
}

///|
fn CodeGenerator::gen_field_codec_write(
  _ : CodeGenerator,
  shape : FieldCodecShape,
  content : StringBuilder,
  is_async? : Bool = false,
) -> Unit raise {
  let async_keyword = if is_async { "async" } else { "" }
  let async_keyword_to_snake = async_keyword |> pascal_to_snake
  match shape.cardinality {
    PackedField => {
      let tag_val = shape.envelope.tag_value()
      guard shape.presence_guard_expr() is Some(presence_guard) else {
        raise @model.UnexpectedType("packed field without presence guard")
      }
      content.write_string("  if \{presence_guard} {\n")
      content.write_string(
        "    writer |> @lib.\{async_keyword_to_snake}write_varint(\{tag_val}UL)\n",
      )
      content.write_string("    let size = \{shape.packed_data_size_expr()}\n")
      let field_write_type = shape.value.write_expr(
        shape.envelope,
        "item",
        is_async~,
      )
      content.write_string(
        (
          $|    writer |> @lib.\{async_keyword_to_snake}write_uint32(size)
          $|    for item in self.\{shape.field_name} {
          $|        \{field_write_type}
          $|    }
          $|  }
          $|
        ),
      )
    }
    MapField => {
      let key_field = shape.key.unwrap()
      let value_field = shape.map_value.unwrap()
      let key_envelope = shape.key_envelope.unwrap()
      let value_envelope = shape.map_value_envelope.unwrap()
      let tag_val = shape.envelope.tag_value()
      let (key_size, _) = key_field.field_size_expr(key_envelope, "k")
      let (value_size, _) = value_field.field_size_expr(value_envelope, "v")
      let key_tag_val = key_envelope.tag_value()
      let value_tag_val = value_envelope.tag_value()
      let field_write_type_k = key_field.write_expr(
        key_envelope,
        "k",
        is_async~,
      )
      let field_write_type_v = value_field.write_expr(
        value_envelope,
        "v",
        is_async~,
      )
      match shape.envelope.kind {
        DelimitedMessageEnvelope =>
          content.write_string(
            (
              $|  let keys = self.\{shape.field_name}.keys().collect()
              $|  for i in 0..<keys.length() {
              $|    let k = keys[i]
              $|    let v = self.\{shape.field_name}.get(k).unwrap()
              $|    writer |> @lib.\{async_keyword_to_snake}write_varint(\{tag_val}UL)
              $|    writer |> @lib.\{async_keyword_to_snake}write_varint(\{key_tag_val}UL)
              $|    \{field_write_type_k}
              $|    writer |> @lib.\{async_keyword_to_snake}write_varint(\{value_tag_val}UL);
              $|    \{field_write_type_v}
              $|    writer |> @lib.\{async_keyword_to_snake}write_tag((\{shape.envelope.field_number}U, @lib.WIRE_TYPE_END_GROUP))
              $|  }
              $|
            ),
          )
        LengthDelimitedEnvelope =>
          content.write_string(
            (
              $|  let keys = self.\{shape.field_name}.keys().collect()
              $|  for i in 0..<keys.length() {
              $|    let k = keys[i]
              $|    let v = self.\{shape.field_name}.get(k).unwrap()
              $|    writer |> @lib.\{async_keyword_to_snake}write_varint(\{tag_val}UL)
              $|    let key_size = \{key_size}
              $|    let value_size = \{value_size}
              $|    writer |> @lib.\{async_keyword_to_snake}write_uint32(key_size + value_size)
              $|    writer |> @lib.\{async_keyword_to_snake}write_varint(\{key_tag_val}UL)
              $|    \{field_write_type_k}
              $|    writer |> @lib.\{async_keyword_to_snake}write_varint(\{value_tag_val}UL);
              $|    \{field_write_type_v}
              $|  }
              $|
            ),
          )
        _ => raise @model.UnexpectedType("unexpected map field envelope")
      }
    }
    RepeatedField => {
      let tag_val = shape.envelope.tag_value()
      let field_write_type = shape.value.write_expr(
        shape.envelope,
        "item",
        is_async~,
      )
      content.write_string("  for item in self.\{shape.field_name} {\n")
      if !shape.envelope.writes_own_field_tags() {
        content.write_string(
          "    writer |> @lib.\{async_keyword_to_snake}write_varint(\{tag_val}UL)\n",
        )
      }
      content.write_string("    \{field_write_type}\n")
      content.write_string("  }\n")
    }
    OptionalField => {
      let field_write_type = shape.value.write_expr(
        shape.envelope,
        "v",
        is_async~,
      )
      let tag_val = shape.envelope.tag_value()
      guard shape.presence_guard_expr() is Some(presence_guard) else {
        raise @model.UnexpectedType("optional field without presence guard")
      }
      content.write_string("  if \{presence_guard} {\n")
      if !shape.envelope.writes_own_field_tags() {
        content.write_string(
          "    writer |> @lib.\{async_keyword_to_snake}write_varint(\{tag_val}UL);\n",
        )
      }
      content.write_string("    \{field_write_type}\n")
      content.write_string("  }\n")
    }
    SingularField => {
      let field_write_type = shape.value.write_expr(
        shape.envelope,
        "self.\{shape.field_name}",
        is_async~,
      )
      let tag_val = shape.envelope.tag_value()
      let field_write = if shape.envelope.writes_own_field_tags() {
        "  \{field_write_type}\n"
      } else {
        "  writer |> @lib.\{async_keyword_to_snake}write_varint(\{tag_val}UL);\n  \{field_write_type}\n"
      }
      match shape.presence_guard_expr() {
        Some(presence_guard) => {
          content.write_string("  if \{presence_guard} {\n")
          content.write_string(field_write)
          content.write_string("  }\n")
        }
        None => content.write_string(field_write)
      }
    }
  }
}

///|
fn CodeGenerator::gen_field_codec_size(
  _ : CodeGenerator,
  shape : FieldCodecShape,
  content : StringBuilder,
) -> Unit raise {
  match shape.cardinality {
    PackedField => {
      let delta_size = shape.packed_delta_size_expr()
      guard shape.presence_guard_expr() is Some(presence_guard) else {
        raise @model.UnexpectedType("packed field without presence guard")
      }
      content.write_string(
        (
          $|  if \{presence_guard} {
          $|    size += \{delta_size}
          $|  }
          $|
        ),
      )
    }
    MapField => {
      let key_field = shape.key.unwrap()
      let value_field = shape.map_value.unwrap()
      let key_envelope = shape.key_envelope.unwrap()
      let value_envelope = shape.map_value_envelope.unwrap()
      let (key_size, _) = key_field.field_size_expr(key_envelope, "k")
      let (value_size, _) = value_field.field_size_expr(value_envelope, "v")
      let field_size = shape.envelope.size_expr("key_size + value_size")
      content.write_string(
        (
          $|  for k, v in self.\{shape.field_name} {
          $|    let key_size = \{key_size}
          $|    let value_size = \{value_size}
          $|    size += \{field_size}
          $|  }
          $|
        ),
      )
    }
    RepeatedField => {
      let (delta_size, _) = shape.value.field_size_expr(shape.envelope, "s")
      content.write_string(
        (
          $|  for s in self.\{shape.field_name} {
          $|    size += \{delta_size}
          $|  }
          $|
        ),
      )
    }
    OptionalField => {
      let (delta_size, need_v) = shape.value.field_size_expr(
        shape.envelope,
        "v",
      )
      let value_binding = if need_v { "v" } else { "_" }
      guard shape.presence_guard_expr(value_binding~) is Some(presence_guard) else {
        raise @model.UnexpectedType("optional field without presence guard")
      }
      content.write_string(
        (
          $|  if \{presence_guard} {
          $|    size += \{delta_size}
          $|  }
          $|
        ),
      )
    }
    SingularField => {
      let (delta_size, _) = shape.value.field_size_expr(
        shape.envelope,
        "self.\{shape.field_name}",
      )
      match shape.presence_guard_expr() {
        Some(presence_guard) =>
          content.write_string(
            (
              $|  if \{presence_guard} {
              $|    size += \{delta_size}
              $|  }
              $|
            ),
          )
        None => content.write_string("  size += \{delta_size}\n")
      }
    }
  }
}
