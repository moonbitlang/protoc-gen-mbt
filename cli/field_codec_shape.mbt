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
  { type_, type_name, number: field.number.unwrap() }
}

///|
fn CodeGenerator::field_codec_shape(
  self : CodeGenerator,
  field : Field,
  parent_path : ImportPath,
) -> FieldCodecShape raise {
  let value = self.field_codec_value(field, parent_path)
  let mut cardinality = FieldCodecCardinality::SingularField
  let mut key = None
  let mut map_value = None
  if field.is_pack() {
    cardinality = FieldCodecCardinality::PackedField
  } else if field.map_key_value() is Some(map_entry) {
    cardinality = FieldCodecCardinality::MapField
    key = Some(self.field_codec_value(map_entry.fields[0], parent_path))
    map_value = Some(self.field_codec_value(map_entry.fields[1], parent_path))
  } else if field.is_list() {
    cardinality = FieldCodecCardinality::RepeatedField
  } else if field.is_optional() {
    cardinality = FieldCodecCardinality::OptionalField
  }
  {
    field_name: field.import_path.name() |> pascal_to_snake,
    field_number: value.number,
    value,
    cardinality,
    key,
    map_value,
    has_implicit_presence: field.has_implicit_presence(),
    accepts_packed_read: field.is_list() && field.is_packable_scalar(),
  }
}

///|
fn FieldCodecValue::read_expr(
  self : FieldCodecValue,
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
    FieldDescriptorProto_Type::TYPE_MESSAGE =>
      "(reader |> @lib.\{async_keyword}read_message() : \{self.type_name})"
    FieldDescriptorProto_Type::TYPE_GROUP =>
      raise @model.UnsupportedType("Group")
  }
}

///|
fn FieldCodecValue::write_expr(
  self : FieldCodecValue,
  variable : String,
  is_async? : Bool = false,
) -> String raise {
  let async_keyword = if is_async { "async_" } else { "" }
  let async_keyword_to_title = if is_async { "Async" } else { "" }
  match self.type_ {
    FieldDescriptorProto_Type::TYPE_STRING =>
      "writer |> @lib.\{async_keyword}write_string(\{variable})\n"
    FieldDescriptorProto_Type::TYPE_BYTES =>
      "writer |> @lib.\{async_keyword}write_bytes(\{variable})\n"
    FieldDescriptorProto_Type::TYPE_MESSAGE =>
      "writer |> @lib.\{async_keyword}write_uint32(@lib.size_of(\{variable})); @lib.\{async_keyword_to_title}Write::write(\{variable}, writer)\n"
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
    _ => raise @model.UnexpectedType("unsupported field type")
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
    | FieldDescriptorProto_Type::TYPE_UINT64 => 0
    FieldDescriptorProto_Type::TYPE_SFIXED64
    | FieldDescriptorProto_Type::TYPE_FIXED64
    | FieldDescriptorProto_Type::TYPE_DOUBLE => 1
    FieldDescriptorProto_Type::TYPE_SFIXED32
    | FieldDescriptorProto_Type::TYPE_FIXED32
    | FieldDescriptorProto_Type::TYPE_FLOAT => 5
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
fn FieldCodecValue::unpacked_size_expr(
  self : FieldCodecValue,
  value_expr : String,
  tag_size : Int,
) -> (String, Bool) {
  match self.type_ {
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
  let tag_size = size_tag(self.field_number)
  let data_size = self.packed_data_size_expr()
  match self.value.type_ {
    FieldDescriptorProto_Type::TYPE_FIXED32
    | FieldDescriptorProto_Type::TYPE_SFIXED32
    | FieldDescriptorProto_Type::TYPE_FLOAT
    | FieldDescriptorProto_Type::TYPE_FIXED64
    | FieldDescriptorProto_Type::TYPE_SFIXED64
    | FieldDescriptorProto_Type::TYPE_DOUBLE =>
      "\{tag_size}U + { let size = \{data_size}; @lib.size_of(size) + size}"
    _ => "\{tag_size}U + { let size = \{data_size}; @lib.size_of(size) + size }"
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
  if shape.accepts_packed_read {
    let packed_read = "reader |> @lib.\{async_keyword_to_snake}read_packed(\{shape.value.packed_reader_func(is_async~)}, \{shape.value.packed_element_size()})"
    match shape.value.type_ {
      FieldDescriptorProto_Type::TYPE_SINT32
      | FieldDescriptorProto_Type::TYPE_SINT64 =>
        content.write_string(
          "      (\{shape.field_number}, 2) => { let packed = \{packed_read}; for item in packed { msg.\{shape.field_name}.push(item.0) } }\n",
        )
      FieldDescriptorProto_Type::TYPE_ENUM =>
        content.write_string(
          "      (\{shape.field_number}, 2) => { let packed = \{packed_read}; for item in packed { msg.\{shape.field_name}.push(\{shape.value.type_name}::from_enum(item)) } }\n",
        )
      _ =>
        content.write_string(
          "      (\{shape.field_number}, 2) => { msg.\{shape.field_name}.push_iter((\{packed_read}).iter()) }\n",
        )
    }
    content.write_string(
      "      (\{shape.field_number}, \{shape.value.unpacked_wire_type()}) => msg.\{shape.field_name}.push(\{shape.value.read_expr(is_async~)})\n",
    )
    return
  }
  match shape.cardinality {
    PackedField => raise @model.UnexpectedType("unpackable packed field")
    MapField =>
      content.write_string(
        "      (\{shape.field_number}, _) => { let {key, value} = \{shape.value.read_expr(is_async~)}; msg.\{shape.field_name}[key] = value }\n",
      )
    RepeatedField =>
      content.write_string(
        "      (\{shape.field_number}, _) => msg.\{shape.field_name}.push(\{shape.value.read_expr(is_async~)})\n",
      )
    OptionalField =>
      content.write_string(
        "      (\{shape.field_number}, _) => msg.\{shape.field_name} = \{shape.value.read_expr(is_async~)} |> Some\n",
      )
    SingularField =>
      content.write_string(
        "      (\{shape.field_number}, _) => msg.\{shape.field_name} = \{shape.value.read_expr(is_async~)}\n",
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
      let tag_val = tag(shape.value.type_, shape.field_number, true)
      content.write_string("  if !self.\{shape.field_name}.is_empty() {\n")
      content.write_string(
        "    writer |> @lib.\{async_keyword_to_snake}write_varint(\{tag_val}UL)\n",
      )
      content.write_string("    let size = \{shape.packed_data_size_expr()}\n")
      let field_write_type = shape.value.write_expr("item", is_async~)
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
      let tag_val = tag(shape.value.type_, shape.field_number, false)
      let key_tag_size = size_tag(key_field.number)
      let value_tag_size = size_tag(value_field.number)
      let (key_size, _) = key_field.unpacked_size_expr("k", key_tag_size)
      let (value_size, _) = value_field.unpacked_size_expr("v", value_tag_size)
      let key_tag_val = tag(key_field.type_, key_field.number, false)
      let value_tag_val = tag(value_field.type_, value_field.number, false)
      let field_write_type_k = key_field.write_expr("k", is_async~)
      let field_write_type_v = value_field.write_expr("v", is_async~)
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
    }
    RepeatedField => {
      let tag_val = tag(shape.value.type_, shape.field_number, false)
      let field_write_type = shape.value.write_expr("item", is_async~)
      content.write_string(
        (
          $|  for item in self.\{shape.field_name} {
          $|    writer |> @lib.\{async_keyword_to_snake}write_varint(\{tag_val}UL)
          $|    \{field_write_type}
          $|  }
          $|
        ),
      )
    }
    OptionalField => {
      let field_write_type = shape.value.write_expr("v", is_async~)
      let tag_val = tag(shape.value.type_, shape.field_number, false)
      content.write_string(
        (
          $|  if self.\{shape.field_name} is Some(v) {
          $|    writer |> @lib.\{async_keyword_to_snake}write_varint(\{tag_val}UL);
          $|    \{field_write_type}
          $|  }
          $|
        ),
      )
    }
    SingularField => {
      let field_write_type = shape.value.write_expr(
        "self.\{shape.field_name}",
        is_async~,
      )
      let tag_val = tag(shape.value.type_, shape.field_number, false)
      let field_write =
        $|  writer |> @lib.\{async_keyword_to_snake}write_varint(\{tag_val}UL);
        $|  \{field_write_type}
      if shape.has_implicit_presence {
        content.write_string(
          "  if self.\{shape.field_name} != Default::default() {\n",
        )
        content.write_string(field_write)
        content.write_string("  }\n")
      } else {
        content.write_string(field_write)
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
      content.write_string(
        (
          $|  if !self.\{shape.field_name}.is_empty() {
          $|    size += \{delta_size}
          $|  }
          $|
        ),
      )
    }
    MapField => {
      let key_field = shape.key.unwrap()
      let value_field = shape.map_value.unwrap()
      let tag_size = size_tag(shape.field_number)
      let (key_size, _) = key_field.unpacked_size_expr(
        "k",
        size_tag(key_field.number),
      )
      let (value_size, _) = value_field.unpacked_size_expr(
        "v",
        size_tag(value_field.number),
      )
      content.write_string(
        (
          $|  for k, v in self.\{shape.field_name} {
          $|    let key_size = \{key_size}
          $|    let value_size = \{value_size}
          $|    size += \{tag_size}U + @lib.size_of(key_size + value_size) + key_size + value_size
          $|  }
          $|
        ),
      )
    }
    RepeatedField => {
      let tag_size = size_tag(shape.field_number)
      let (delta_size, _) = shape.value.unpacked_size_expr("s", tag_size)
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
      let (delta_size, need_v) = shape.value.unpacked_size_expr(
        "v",
        size_tag(shape.field_number),
      )
      if need_v {
        content.write_string(
          (
            $|  if self.\{shape.field_name} is Some(v) {
            $|    size += \{delta_size}
            $|  }
            $|
          ),
        )
      } else {
        content.write_string(
          (
            $|  if self.\{shape.field_name} is Some(_) {
            $|    size += \{delta_size}
            $|  }
            $|
          ),
        )
      }
    }
    SingularField => {
      let (delta_size, _) = shape.value.unpacked_size_expr(
        "self.\{shape.field_name}",
        size_tag(shape.field_number),
      )
      if shape.has_implicit_presence {
        content.write_string(
          (
            $|  if self.\{shape.field_name} != Default::default() {
            $|    size += \{delta_size}
            $|  }
            $|
          ),
        )
      } else {
        content.write_string("  size += \{delta_size}\n")
      }
    }
  }
}
