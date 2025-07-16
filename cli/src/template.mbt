///|
fn CodeGenerator::gen_package(self : CodeGenerator, file : Package) -> Unit {
  self.gen_file(file)
  let package_name = file.package_name.replace_all(old=".", new="/")
  let filename = "\{self.project_name}/src/\{package_name}/moon.pkg.json"
  let import_list = []
  for dep in file.dependency {
    let dep_package = dep.package_name.replace_all(old=".", new="/")
    import_list.push("\"\{self.project_name}/\{dep_package}\"")
  }
  let imports = import_list.join("      ,")
  let content =
    $| {
    $|  "import": [
    $|      "moonbit-community/protobuf/lib",
    $|      \{imports}
    $|  ]
    $| }
  let file = File::new(filename, content~)
  self.push_file(file)
}

///|
fn CodeGenerator::gen_module(self : CodeGenerator) -> Unit {
  let filename = "\{self.project_name}/moon.mod.json"
  let content =
    #| {
    $| "name": "username/\{self.project_name}",
    #| "version": "0.1.0",
    #| "readme": "",
    #| "repository": "",
    #| "license": "",
    #| "keywords": [],
    #| "description": "",
    #| "source": "src",
    #| "deps": {
    #|   "moonbit-community/protobuf/lib": "0.1.0"
    #|  }
    #| }
  let file = File::new(filename, content~)
  self.push_file(file)
}

///|
fn CodeGenerator::gen_file(self : CodeGenerator, file : Package) -> Unit {
  let package_name = file.package_name.replace_all(old=".", new="/")
  let filename = "\{self.project_name}/src/\{package_name}/top.mbt"
  let content = StringBuilder::new()
  for enum_ in file.enums {
    self.gen_enum(enum_, content)
  }
  self.gen_messages(file.message_type, content)
  let file = File::from_builder(filename, content~)
  self.push_file(file)
}

///|
fn CodeGenerator::gen_enum(
  self : CodeGenerator,
  enum_ : Enum,
  file : StringBuilder
) -> Unit {
  let enum_name = enum_.import_path.path() |> to_camel_case
  file.write_string("pub(all) enum \{enum_name} {\n")
  for value in enum_.value {
    let value_name = to_camel_case(value.name.unwrap())
    file.write_string("  \{value_name}\n")
  }
  file.write_string("} derive(Eq, Show)\n")

  // To enum
  file.write_string(
    "fn \{enum_name}::to_enum(self : \{enum_name}) -> @lib.Enum {\n",
  )
  file.write_string("  match self {\n")
  for value in enum_.value {
    let value_name = to_camel_case(value.name.unwrap())
    file.write_string(
      "    \{enum_name}::\{value_name} => \{value.number.unwrap()}\n",
    )
  }
  file.write_string("  }\n")
  file.write_string("}\n")

  // From enum
  file.write_string(
    "fn \{enum_name}::from_enum(i : @lib.Enum) -> \{enum_name} {\n",
  )
  file.write_string("  match i.inner() {\n")
  for value in enum_.value {
    let value_name = to_camel_case(value.name.unwrap())
    file.write_string(
      "    \{value.number.unwrap()} => \{enum_name}::\{value_name}\n",
    )
  }
  file.write_string("    _ => Default::default()\n")
  file.write_string("  }\n")
  file.write_string("}\n")

  // Default
  if enum_.value.length() > 0 {
    let first_value_name = to_camel_case(enum_.value[0].name.unwrap())
    file.write_string(
      "pub impl Default for \{enum_name} with default() -> \{enum_name} {\n",
    )
    file.write_string("  \{enum_name}::\{first_value_name}\n")
    file.write_string("}\n")
  }

  // Sized
  file.write_string(
    "pub impl @lib.Sized for \{enum_name} with size_of(self : \{enum_name}) {\n",
  )
  file.write_string("  @lib.Sized::size_of(self.to_enum())\n")
  file.write_string("}\n")
  // End
}

///|
fn CodeGenerator::get_moonbit_type(
  self : CodeGenerator,
  field : Field
) -> String {
  guard field.type_ is Some(typ) else { panic() }
  return match typ {
    FieldType::FieldDescriptorProto_TYPE_DOUBLE => "Double"
    FieldType::FieldDescriptorProto_TYPE_FLOAT => "Float"
    FieldType::FieldDescriptorProto_TYPE_INT64 => "Int64"
    FieldType::FieldDescriptorProto_TYPE_UINT64 => "UInt64"
    FieldType::FieldDescriptorProto_TYPE_INT32 => "Int"
    FieldType::FieldDescriptorProto_TYPE_FIXED64 => "UInt64"
    FieldType::FieldDescriptorProto_TYPE_FIXED32 => "UInt"
    FieldType::FieldDescriptorProto_TYPE_BOOL => "Bool"
    FieldType::FieldDescriptorProto_TYPE_STRING => "String"
    FieldType::FieldDescriptorProto_TYPE_GROUP =>
      abort("TODO: Group type is not supported")
    FieldType::FieldDescriptorProto_TYPE_MESSAGE => {
      let message_name = field.type_name.unwrap()
      if self.find_message(message_name) is Some(message) {
        return message.import_path.path() |> to_camel_case
      }
      // TODO: handle imported other package messages
      "UNKNOWN"
    }
    FieldType::FieldDescriptorProto_TYPE_BYTES => "Bytes"
    FieldType::FieldDescriptorProto_TYPE_UINT32 => "UInt"
    FieldType::FieldDescriptorProto_TYPE_ENUM => {
      let path = self.find_enum(field.type_name.unwrap())
      if path is Some(enum_) {
        return enum_.import_path.path() |> to_camel_case
      }
      // TODO: handle imported other package enums
      "UNKNOWN"
    }
    FieldType::FieldDescriptorProto_TYPE_SFIXED32 => "Int"
    FieldType::FieldDescriptorProto_TYPE_SFIXED64 => "Int64"
    FieldType::FieldDescriptorProto_TYPE_SINT32 => "Int"
    FieldType::FieldDescriptorProto_TYPE_SINT64 => "Int64"
  }
}

///|
fn CodeGenerator::gen_messages(
  self : CodeGenerator,
  messages : Array[Message],
  content : StringBuilder
) -> Unit {
  for message in messages {
    for enum_ in message.enums {
      self.gen_enum(enum_, content)
    }
    self.gen_messages(message.messages, content)
    self.gen_message(message, content)
  }
}

///|
fn CodeGenerator::gen_message(
  self : CodeGenerator,
  m : Message,
  file : StringBuilder
) -> Unit {
  let message_name = m.import_path.path() |> to_camel_case
  file.write_string("pub(all) struct \{message_name} {\n")
  for field in m.fields {
    let field_type = self.get_moonbit_type(field)
    let field_name = field.import_path.name() |> pascal_to_snake
    if field.is_optional() {
      file.write_string("  mut \{field_name} : \{field_type}?\n")
    } else if field.map_key_value() is Some(map_entry) {
      let key_type = self.get_moonbit_type(map_entry.fields[0])
      let value_type = self.get_moonbit_type(map_entry.fields[1])
      file.write_string(
        "  mut \{field_name} : Map[\{key_type}, \{value_type}]\n",
      )
    } else if field.is_list() {
      file.write_string("  mut \{field_name} : Array[\{field_type}]\n")
    } else if field.is_message() {
      file.write_string("  mut \{field_name} :  \{field_type} \n")
    } else if field.is_enum() {
      file.write_string("  mut \{field_name} :  \{field_type} \n")
    } else {
      file.write_string("  mut \{field_name} : \{field_type}\n")
    }
  }
  for oneof in m.oneofs {
    let oneof_name = self.get_oneof_enum_name(m, oneof.name)
    let field_name = oneof.name |> pascal_to_snake
    file.write_string("  mut \{field_name} : \{oneof_name}\n")
  }
  file.write_string("} derive(Eq, Show)\n")
  for oneof in m.oneofs {
    self.gen_oneof_enum(m, oneof, file)
  }
  self.gen_message_size(m, file)
  self.gen_message_default(m, file)
  self.gen_message_reader(m, file)
  self.gen_message_writer(m, file)
}

///|
fn CodeGenerator::gen_message_default(
  self : CodeGenerator,
  message : Message,
  content : StringBuilder
) -> Unit {
  let message_name = message.import_path.path() |> to_camel_case
  content.write_string(
    "pub impl Default for \{message_name} with default() -> \{message_name} {\n",
  )
  content.write_string("  {\n")
  for field in message.fields {
    let field_type = self.get_moonbit_type(field)
    let field_name = pascal_to_snake(field.json_name.unwrap())
    if field.is_optional() {
      content.write_string("    \{field_name} : None,\n")
    } else if field.map_key_value() is Some(_) {
      content.write_string("    \{field_name} : {},\n")
    } else if field.is_list() {
      content.write_string("    \{field_name} : [],\n")
    } else {
      content.write_string("    \{field_name} : \{field_type}::default(),\n")
    }
  }
  for oneof in message.oneofs {
    let oneof_name = self.get_oneof_enum_name(message, oneof.name)
    content.write_string("    \{oneof.name} : \{oneof_name}::NotSet,\n")
  }
  content.write_string("  }\n")
  content.write_string("}\n")
}

///|
fn CodeGenerator::gen_message_size(
  self : CodeGenerator,
  message : Message,
  content : StringBuilder
) -> Unit {
  let message_name = message.import_path.path() |> to_camel_case
  content.write_string(
    "pub impl @lib.Sized for \{message_name} with size_of(self) {\n",
  )
  if message.fields.length() == 0 {
    content.write_string("  0\n")
  } else {
    content.write_string("  let mut size = 0U\n")
    for field in message.fields {
      let field_name = pascal_to_snake(field.json_name.unwrap())
      let field_number = field.number.unwrap()
      if field.is_pack() {
        if field.type_ is Some(typ) {
          match typ {
            FieldType::FieldDescriptorProto_TYPE_FIXED32
            | FieldType::FieldDescriptorProto_TYPE_SFIXED32
            | FieldType::FieldDescriptorProto_TYPE_FLOAT => {
              let tag_size = size_tag(field_number)
              let fixed_size = sizeFixed32()
              content.write_string(
                "  size += \{tag_size}U + { let size = self.\{field_name}.length().reinterpret_as_uint() * \{fixed_size}; @lib.size_of(size) + size}\n",
              )
            }
            FieldType::FieldDescriptorProto_TYPE_FIXED64
            | FieldType::FieldDescriptorProto_TYPE_SFIXED64
            | FieldType::FieldDescriptorProto_TYPE_DOUBLE => {
              let tag_size = size_tag(field_number)
              let fixed_size = sizeFixed64()
              content.write_string(
                "  size += \{tag_size}U + { let size = self.\{field_name}.length().reinterpret_as_uint() * \{fixed_size}; @lib.size_of(size) + size}\n",
              )
            }
            FieldType::FieldDescriptorProto_TYPE_INT32
            | FieldType::FieldDescriptorProto_TYPE_INT64
            | FieldType::FieldDescriptorProto_TYPE_SINT32
            | FieldType::FieldDescriptorProto_TYPE_SINT64
            | FieldType::FieldDescriptorProto_TYPE_UINT32
            | FieldType::FieldDescriptorProto_TYPE_UINT64
            | FieldType::FieldDescriptorProto_TYPE_BOOL
            | FieldType::FieldDescriptorProto_TYPE_ENUM => {
              let tag_size = size_tag(field_number)
              content.write_string(
                "  size += \{tag_size}U + { let size = self.\{field_name}.iter().map(@lib.size_of).fold(init=0U, UInt::op_add); @lib.size_of(size) + size }\n",
              )
            }
            _ => panic()
          }
        }
      } else if field.map_key_value() is Some(map_entry) {
        let key_field = map_entry.fields[0]
        let value_field = map_entry.fields[1]
        let tag_size = size_tag(field_number)
        content.write_string(
          "  size += self.\{field_name}.iter().map(fn(key_value) {\n",
        )
        content.write_string("    let (k, v) = key_value\n")
        match key_field.type_.unwrap() {
          FieldType::FieldDescriptorProto_TYPE_STRING
          | FieldType::FieldDescriptorProto_TYPE_BYTES
          | FieldType::FieldDescriptorProto_TYPE_MESSAGE => {
            let key_tag_size = size_tag(0)
            content.write_string(
              "    let key_size = \{key_tag_size}U + { let size = @lib.size_of(k); @lib.size_of(size) + size }\n",
            )
          }
          FieldType::FieldDescriptorProto_TYPE_FIXED32
          | FieldType::FieldDescriptorProto_TYPE_SFIXED32
          | FieldType::FieldDescriptorProto_TYPE_FLOAT => {
            let key_tag_size = size_tag(0)
            let fixed_size = sizeFixed32()
            content.write_string(
              "    let key_size = \{key_tag_size}U + \{fixed_size}U\n",
            )
          }
          FieldType::FieldDescriptorProto_TYPE_FIXED64
          | FieldType::FieldDescriptorProto_TYPE_SFIXED64
          | FieldType::FieldDescriptorProto_TYPE_DOUBLE => {
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

        // Calculate value size
        match value_field.type_.unwrap() {
          FieldType::FieldDescriptorProto_TYPE_STRING
          | FieldType::FieldDescriptorProto_TYPE_BYTES
          | FieldType::FieldDescriptorProto_TYPE_MESSAGE => {
            let value_tag_size = size_tag(1)
            content.write_string(
              "    let value_size = \{value_tag_size}U + { let size = @lib.size_of(v); @lib.size_of(size) + size }\n",
            )
          }
          FieldType::FieldDescriptorProto_TYPE_FIXED32
          | FieldType::FieldDescriptorProto_TYPE_SFIXED32
          | FieldType::FieldDescriptorProto_TYPE_FLOAT => {
            let value_tag_size = size_tag(1)
            let fixed_size = sizeFixed32()
            content.write_string(
              "    let value_size = \{value_tag_size}U + \{fixed_size}U\n",
            )
          }
          FieldType::FieldDescriptorProto_TYPE_FIXED64
          | FieldType::FieldDescriptorProto_TYPE_SFIXED64
          | FieldType::FieldDescriptorProto_TYPE_DOUBLE => {
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
        content.write_string(
          "    \{tag_size}U + @lib.size_of(key_size + value_size) + key_size + value_size  }).fold(init=0U, UInt::op_add)\n",
        )
      } else if field.is_list() {
        let tag_size = size_tag(field_number)
        content.write_string(
          "  size += self.\{field_name}.iter().map(@lib.size_of).map(s => \{tag_size}U + @lib.size_of(s) + s).fold(init=0U, UInt::op_add)\n",
        )
      } else if field.is_optional() {
        content.write_string("  match self.\{field_name} {\n")
        content.write_string("    Some(v) => ")
        if field.type_ is Some(typ) {
          match typ {
            FieldType::FieldDescriptorProto_TYPE_STRING
            | FieldType::FieldDescriptorProto_TYPE_BYTES
            | FieldType::FieldDescriptorProto_TYPE_MESSAGE => {
              let tag_size = size_tag(field_number)
              content.write_string(
                "size += \{tag_size}U + { let size = @lib.size_of(v); @lib.size_of(size) + size }\n",
              )
            }
            FieldType::FieldDescriptorProto_TYPE_FIXED32
            | FieldType::FieldDescriptorProto_TYPE_SFIXED32
            | FieldType::FieldDescriptorProto_TYPE_FLOAT => {
              let tag_size = size_tag(field_number)
              let fixed_size = sizeFixed32()
              content.write_string("size += \{tag_size}U + \{fixed_size}U\n")
            }
            FieldType::FieldDescriptorProto_TYPE_FIXED64
            | FieldType::FieldDescriptorProto_TYPE_SFIXED64
            | FieldType::FieldDescriptorProto_TYPE_DOUBLE => {
              let tag_size = size_tag(field_number)
              let fixed_size = sizeFixed64()
              content.write_string("size += \{tag_size}U + \{fixed_size}U\n")
            }
            _ => {
              let tag_size = size_tag(field_number)
              content.write_string("size += \{tag_size}U + @lib.size_of(v)\n")
            }
          }
        }
        content.write_string("    None => ()\n")
        content.write_string("  }\n")
      } else if field.type_ is Some(typ) {
        match typ {
          FieldType::FieldDescriptorProto_TYPE_STRING
          | FieldType::FieldDescriptorProto_TYPE_BYTES
          | FieldType::FieldDescriptorProto_TYPE_MESSAGE => {
            let tag_size = size_tag(field_number)
            content.write_string(
              "  size += \{tag_size}U + { let size = @lib.size_of(self.\{field_name}); @lib.size_of(size) + size }\n",
            )
          }
          FieldType::FieldDescriptorProto_TYPE_FIXED32
          | FieldType::FieldDescriptorProto_TYPE_SFIXED32
          | FieldType::FieldDescriptorProto_TYPE_FLOAT => {
            let tag_size = size_tag(field_number)
            let fixed_size = sizeFixed32()
            content.write_string("  size += \{tag_size}U + \{fixed_size}U\n")
          }
          FieldType::FieldDescriptorProto_TYPE_FIXED64
          | FieldType::FieldDescriptorProto_TYPE_SFIXED64
          | FieldType::FieldDescriptorProto_TYPE_DOUBLE => {
            let tag_size = size_tag(field_number)
            let fixed_size = sizeFixed64()
            content.write_string("  size += \{tag_size}U + \{fixed_size}U\n")
          }
          _ => {
            let tag_size = size_tag(field_number)
            content.write_string(
              "  size += \{tag_size}U + @lib.size_of(self.\{field_name})\n",
            )
          }
        }
      }
    }
    for oneof in message.oneofs {
      let field_name = oneof.name |> pascal_to_snake
      content.write_string("  match self.\{field_name} {\n")
      for field in oneof.field {
        let field_name = field.import_path.name() |> to_camel_case
        content.write_string("    \{field_name}(v) => {  ")
        let field_number = field.number.unwrap()
        if field.type_ is Some(typ) {
          match typ {
            FieldType::FieldDescriptorProto_TYPE_STRING
            | FieldType::FieldDescriptorProto_TYPE_BYTES
            | FieldType::FieldDescriptorProto_TYPE_MESSAGE => {
              let tag_size = size_tag(field_number)
              content.write_string(
                "size += \{tag_size}U + { let size = @lib.size_of(v); @lib.size_of(size) + size }",
              )
            }
            FieldType::FieldDescriptorProto_TYPE_FIXED32
            | FieldType::FieldDescriptorProto_TYPE_SFIXED32
            | FieldType::FieldDescriptorProto_TYPE_FLOAT => {
              let tag_size = size_tag(field_number)
              let fixed_size = sizeFixed32()
              content.write_string("size += \{tag_size}U + \{fixed_size}U")
            }
            FieldType::FieldDescriptorProto_TYPE_FIXED64
            | FieldType::FieldDescriptorProto_TYPE_SFIXED64
            | FieldType::FieldDescriptorProto_TYPE_DOUBLE => {
              let tag_size = size_tag(field_number)
              let fixed_size = sizeFixed64()
              content.write_string("size += \{tag_size}U + \{fixed_size}U")
            }
            _ => {
              let tag_size = size_tag(field_number)
              content.write_string("size += \{tag_size}U + @lib.size_of(v)")
            }
          }
        }
        content.write_string("    }\n")
      }
      content.write_string("    NotSet => ()\n")
      content.write_string("  }\n")
    }
    content.write_string("  size\n")
  }
  content.write_string("}\n")
}

///|
fn CodeGenerator::get_oneof_enum_name(
  self : CodeGenerator,
  message : Message,
  oneof_name : String
) -> String {
  let message_name = message.import_path.path() |> to_camel_case
  return "\{message_name}_\{to_camel_case(oneof_name)}"
}

///|
fn gen_oneof_enum(
  self : CodeGenerator,
  message : Message,
  oneof : OneOf,
  content : StringBuilder
) -> Unit {
  let enum_name = self.get_oneof_enum_name(message, oneof.name)
  content.write_string("pub(all) enum \{enum_name} {\n")
  for field in oneof.field {
    let field_type = self.get_moonbit_type(field)
    let field_name = field.import_path.name() |> to_camel_case
    content.write_string("  \{field_name}(\{field_type})\n")
  }
  content.write_string("  NotSet\n")
  content.write_string("} derive(Eq, Show)\n")

  // Default
  content.write_string(
    "pub impl Default for \{enum_name} with default() -> \{enum_name} {\n",
  )
  content.write_string("  NotSet\n")
  content.write_string("}\n")
}

///|
fn gen_message_reader(
  self : CodeGenerator,
  message : Message,
  content : StringBuilder
) -> Unit {
  let message_name = message.import_path.path() |> to_camel_case
  content.write_string(
    "pub impl @lib.Read for \{message_name} with read(reader : &@lib.Reader) {\n",
  )
  let default_str = "  \{message_name}::default()\n"
  if message.fields.length() == 0 {
    content.write_string(default_str)
  } else {
    content.write_string("  let msg = \{default_str}\n")
    content.write_string("  while not(reader |> @lib.is_eof()) {\n")
    content.write_string("    match (reader |> @lib.read_tag()) {\n")
    for field in message.fields {
      if field.is_list() {
        self.gen_repeated_field_read(field, content)
      } else {
        self.gen_field_read(field, content)
      }
    }
    for oneof in message.oneofs {
      let oneof_name = self.get_oneof_enum_name(message, oneof.name)
      let oneof_field_name = oneof.name |> pascal_to_snake
      for field in oneof.field {
        let field_name = field.import_path.name() |> to_camel_case
        let field_number = field.number.unwrap()
        let type_name = self.get_moonbit_type(field)
        content.write_string(
          "      (\{field_number}, _) => msg.\{oneof_field_name} = \{gen_kind_read(field.type_.unwrap(), type_name)} |> \{oneof_name}::\{field_name}\n",
        )
      }
    }
    content.write_string(
      (
        #|     (_, wire) => reader |> @lib.read_unknown(wire)
        #|    }
        #| }
        #|  msg
      ),
    )
  }
  content.write_string("  }\n")
}

///|
fn gen_repeated_field_read(
  self : CodeGenerator,
  field : Field,
  content : StringBuilder
) -> Unit {
  let kind = field.type_.unwrap()
  let field_number = field.number.unwrap()
  let field_name = field.import_path.name() |> pascal_to_snake
  let mut name = ""
  if field.is_enum() {
    name = self.get_moonbit_type(field)
  }
  if field.is_message() {
    name = self.get_moonbit_type(field)
  }
  if field.is_pack() {
    match kind {
      FieldType::FieldDescriptorProto_TYPE_BOOL
      | FieldType::FieldDescriptorProto_TYPE_INT32
      | FieldType::FieldDescriptorProto_TYPE_INT64
      | FieldType::FieldDescriptorProto_TYPE_UINT32
      | FieldType::FieldDescriptorProto_TYPE_UINT64
      | FieldType::FieldDescriptorProto_TYPE_SINT32
      | FieldType::FieldDescriptorProto_TYPE_SINT64 =>
        content.write_string(
          "      (\{field_number}, _) => { msg.\{field_name}.push_iter((reader |> @lib.read_packed(\{kind_read_func(kind)}, None)).iter()) }\n",
        )

      // I64
      FieldType::FieldDescriptorProto_TYPE_SFIXED64
      | FieldType::FieldDescriptorProto_TYPE_FIXED64
      | FieldType::FieldDescriptorProto_TYPE_DOUBLE =>
        content.write_string(
          "      (\{field_number}, _) => { msg.\{field_name}.push_iter((reader |> @lib.read_packed(\{kind_read_func(kind)}, Some(64))).iter()) }\n",
        )

      // I32
      FieldType::FieldDescriptorProto_TYPE_SFIXED32
      | FieldType::FieldDescriptorProto_TYPE_FIXED32
      | FieldType::FieldDescriptorProto_TYPE_FLOAT =>
        content.write_string(
          "      (\{field_number}, _) => { msg.\{field_name}.push_iter((reader |> @lib.read_packed(\{kind_read_func(kind)}, Some(32))).iter()) }\n",
        )
      _ => panic() // unreachable
    }
  } else if field.map_key_value() is Some(_) {
    content.write_string(
      "      (\{field_number}, _) => { let {key, value} = \{gen_kind_read(kind, name)}; msg.\{field_name}[key] = value }\n",
    )
  } else {
    content.write_string(
      "      (\{field_number}, _) => msg.\{field_name}.push(\{gen_kind_read(kind, name)})\n",
    )
    // }
  }
}

///|
fn gen_field_read(
  self : CodeGenerator,
  field : Field,
  content : StringBuilder
) -> Unit {
  let field_name = field.import_path.name() |> pascal_to_snake
  let field_number = field.number.unwrap()
  let kind = field.type_.unwrap()
  let optional_constructor = if field.is_optional() { " |> Some" } else { "" }
  let type_name = if field.is_enum() || field.is_message() {
    self.get_moonbit_type(field)
  } else {
    ""
  }
  content.write_string(
    "      (\{field_number}, _) => msg.\{field_name} = \{gen_kind_read(kind, type_name)}\{optional_constructor}\n",
  )
}

///|
fn kind_read_func(kind : FieldType) -> String {
  match kind {
    FieldType::FieldDescriptorProto_TYPE_BOOL => "@lib.read_bool"
    FieldType::FieldDescriptorProto_TYPE_INT32 => "@lib.read_int32"
    FieldType::FieldDescriptorProto_TYPE_INT64 => "@lib.read_int64"
    FieldType::FieldDescriptorProto_TYPE_SINT32 => "@lib.read_sint32"
    FieldType::FieldDescriptorProto_TYPE_SINT64 => "@lib.read_sint64"
    FieldType::FieldDescriptorProto_TYPE_UINT32 => "@lib.read_uint32"
    FieldType::FieldDescriptorProto_TYPE_UINT64 => "@lib.read_uint64"
    FieldType::FieldDescriptorProto_TYPE_FIXED32 => "@lib.read_fixed32"
    FieldType::FieldDescriptorProto_TYPE_FIXED64 => "@lib.read_fixed64"
    FieldType::FieldDescriptorProto_TYPE_SFIXED32 => "@lib.read_sfixed32"
    FieldType::FieldDescriptorProto_TYPE_SFIXED64 => "@lib.read_sfixed64"
    FieldType::FieldDescriptorProto_TYPE_FLOAT => "@lib.read_float"
    FieldType::FieldDescriptorProto_TYPE_DOUBLE => "@lib.read_double"
    FieldType::FieldDescriptorProto_TYPE_STRING => "@lib.read_string"
    FieldType::FieldDescriptorProto_TYPE_BYTES => "@lib.read_bytes"
    FieldType::FieldDescriptorProto_TYPE_ENUM => "@lib.read_enum"
    FieldType::FieldDescriptorProto_TYPE_MESSAGE => "@lib.Read::read"
    FieldType::FieldDescriptorProto_TYPE_GROUP => panic()
  }
}

///|
fn gen_kind_read(field_type : FieldType, type_name : String) -> String {
  match field_type {
    FieldType::FieldDescriptorProto_TYPE_BOOL
    | FieldType::FieldDescriptorProto_TYPE_INT32
    | FieldType::FieldDescriptorProto_TYPE_INT64
    | FieldType::FieldDescriptorProto_TYPE_UINT32
    | FieldType::FieldDescriptorProto_TYPE_UINT64
    | FieldType::FieldDescriptorProto_TYPE_FIXED32
    | FieldType::FieldDescriptorProto_TYPE_FIXED64
    | FieldType::FieldDescriptorProto_TYPE_SFIXED32
    | FieldType::FieldDescriptorProto_TYPE_SFIXED64
    | FieldType::FieldDescriptorProto_TYPE_FLOAT
    | FieldType::FieldDescriptorProto_TYPE_DOUBLE
    | FieldType::FieldDescriptorProto_TYPE_STRING
    | FieldType::FieldDescriptorProto_TYPE_BYTES =>
      "reader |> \{kind_read_func(field_type)}()"
    FieldType::FieldDescriptorProto_TYPE_SINT32
    | FieldType::FieldDescriptorProto_TYPE_SINT64 =>
      "(reader |> \{kind_read_func(field_type)}()).inner()"
    FieldType::FieldDescriptorProto_TYPE_ENUM =>
      "reader |> @lib.read_enum() |> \{type_name}::from_enum"
    FieldType::FieldDescriptorProto_TYPE_MESSAGE =>
      "((reader |> @lib.read_message()) : \{type_name})"
    FieldType::FieldDescriptorProto_TYPE_GROUP => "panic()"
  }
}

///|
fn gen_message_writer(
  self : CodeGenerator,
  message : Message,
  content : StringBuilder
) -> Unit {
  let message_name = message.import_path.path() |> to_camel_case
  content.write_string(
    "pub impl @lib.Write for \{message_name} with write(self, writer) {\n",
  )
  if not(message.fields.is_empty()) {
    for field in message.fields {
      let field_name = field.import_path.name() |> pascal_to_snake
      let field_number = field.number.unwrap()
      if field.is_pack() {
        let tag_val = tag(field.type_.unwrap(), field_number, true)
        content.write_string("  writer |> @lib.write_varint(\{tag_val}UL)\n")
        match field.type_.unwrap() {
          FieldType::FieldDescriptorProto_TYPE_FIXED32
          | FieldType::FieldDescriptorProto_TYPE_SFIXED32
          | FieldType::FieldDescriptorProto_TYPE_FLOAT => {
            let fixed_size = sizeFixed32()
            content.write_string(
              "  let size = self.\{field_name}.length().reinterpret_as_uint() * \{fixed_size}\n",
            )
          }
          FieldType::FieldDescriptorProto_TYPE_FIXED64
          | FieldType::FieldDescriptorProto_TYPE_SFIXED64
          | FieldType::FieldDescriptorProto_TYPE_DOUBLE => {
            let fixed_size = sizeFixed64()
            content.write_string(
              "  let size = self.\{field_name}.length().reinterpret_as_uint() * \{fixed_size}\n",
            )
          }
          FieldType::FieldDescriptorProto_TYPE_INT32
          | FieldType::FieldDescriptorProto_TYPE_INT64
          | FieldType::FieldDescriptorProto_TYPE_SINT32
          | FieldType::FieldDescriptorProto_TYPE_SINT64
          | FieldType::FieldDescriptorProto_TYPE_UINT32
          | FieldType::FieldDescriptorProto_TYPE_UINT64
          | FieldType::FieldDescriptorProto_TYPE_BOOL
          | FieldType::FieldDescriptorProto_TYPE_ENUM =>
            content.write_string(
              "  let size = self.\{field_name}.iter().map(@lib.size_of).fold(init=0U, UInt::op_add)\n",
            )
          _ => panic()
        }
        content.write_string("  writer |> @lib.write_uint32(size)\n")
        content.write_string("  self.\{field_name}.iter().each(fn(v) {\n    ")
        gen_field_write(content, field.type_.unwrap(), "v")
        content.write_string("  })\n")
      } else if field.map_key_value() is Some(map_entry) {
        let key_field = map_entry.fields[0]
        let value_field = map_entry.fields[1]
        content.write_string(
          "  self.\{field_name}.iter().each(fn(key_value) {\n",
        )
        content.write_string("    let (k, v) = key_value\n")
        let tag_val = tag(field.type_.unwrap(), field_number, false)
        content.write_string("    writer |> @lib.write_varint(\{tag_val}UL)\n")
        match key_field.type_.unwrap() {
          FieldType::FieldDescriptorProto_TYPE_STRING
          | FieldType::FieldDescriptorProto_TYPE_BYTES
          | FieldType::FieldDescriptorProto_TYPE_MESSAGE => {
            let key_tag_size = size_tag(0)
            content.write_string(
              "    let key_size = \{key_tag_size}U + { let size = @lib.size_of(k); @lib.size_of(size) + size }\n",
            )
          }
          FieldType::FieldDescriptorProto_TYPE_FIXED32
          | FieldType::FieldDescriptorProto_TYPE_SFIXED32
          | FieldType::FieldDescriptorProto_TYPE_FLOAT => {
            let key_tag_size = size_tag(0)
            let fixed_size = sizeFixed32()
            content.write_string(
              "    let key_size = \{key_tag_size}U + \{fixed_size}U\n",
            )
          }
          FieldType::FieldDescriptorProto_TYPE_FIXED64
          | FieldType::FieldDescriptorProto_TYPE_SFIXED64
          | FieldType::FieldDescriptorProto_TYPE_DOUBLE => {
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
          FieldType::FieldDescriptorProto_TYPE_STRING
          | FieldType::FieldDescriptorProto_TYPE_BYTES
          | FieldType::FieldDescriptorProto_TYPE_MESSAGE => {
            let value_tag_size = size_tag(1)
            content.write_string(
              "    let value_size = \{value_tag_size}U + { let size = @lib.size_of(v); @lib.size_of(size) + size }\n",
            )
          }
          FieldType::FieldDescriptorProto_TYPE_FIXED32
          | FieldType::FieldDescriptorProto_TYPE_SFIXED32
          | FieldType::FieldDescriptorProto_TYPE_FLOAT => {
            let value_tag_size = size_tag(1)
            let fixed_size = sizeFixed32()
            content.write_string(
              "    let value_size = \{value_tag_size}U + \{fixed_size}U\n",
            )
          }
          FieldType::FieldDescriptorProto_TYPE_FIXED64
          | FieldType::FieldDescriptorProto_TYPE_SFIXED64
          | FieldType::FieldDescriptorProto_TYPE_DOUBLE => {
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
        content.write_string(
          "    writer |> @lib.write_uint32(key_size + value_size)\n",
        )
        let key_tag_val = tag(key_field.type_.unwrap(), 1, false)
        content.write_string(
          "    writer |> @lib.write_varint(\{key_tag_val}UL);\n    ",
        )
        gen_field_write(content, key_field.type_.unwrap(), "k")
        let value_tag_val = tag(value_field.type_.unwrap(), 2, false)
        content.write_string(
          "    writer |> @lib.write_varint(\{value_tag_val}UL);\n    ",
        )
        gen_field_write(content, value_field.type_.unwrap(), "v")
        content.write_string("  })\n")
      } else if field.is_list() {
        content.write_string("  self.\{field_name}.iter().each(fn(v) {\n")
        let tag_val = tag(field.type_.unwrap(), field_number, false)
        content.write_string(
          "    writer |> @lib.write_varint(\{tag_val}UL)\n    ",
        )
        gen_field_write(content, field.type_.unwrap(), "v")
        content.write_string("  })\n")
      } else if field.is_optional() {
        content.write_string("  match self.\{field_name} {\n")
        content.write_string("    Some(v) => {\n      ")
        let tag_val = tag(field.type_.unwrap(), field_number, false)
        content.write_string("writer |> @lib.write_varint(\{tag_val}UL);")
        gen_field_write(content, field.type_.unwrap(), "v")
        content.write_string("    }\n")
        content.write_string("    None => ()\n")
        content.write_string("  }\n")
      } else {
        content.write_string("  ")
        let tag_val = tag(field.type_.unwrap(), field_number, false)
        content.write_string("writer |> @lib.write_varint(\{tag_val}UL);")
        gen_field_write(content, field.type_.unwrap(), "self.\{field_name}")
      }
    }
  }
  for oneof in message.oneofs {
    let oneof_name = self.get_oneof_enum_name(message, oneof.name)
    let oneof_field_name = oneof.name |> pascal_to_snake
    content.write_string("  match self.\{oneof_field_name} {\n")
    for field in oneof.field {
      let field_name = field.import_path.name() |> to_camel_case
      let field_number = field.number.unwrap()
      let tag_val = tag(field.type_.unwrap(), field_number, false)
      content.write_string("    \{oneof_name}::\{field_name}(v) => {\n")
      content.write_string("      writer |> @lib.write_varint(\{tag_val}UL); ")
      gen_field_write(content, field.type_.unwrap(), "v")
      content.write_string("    }\n")
    }
    content.write_string("    \{oneof_name}::NotSet => ()\n")
    content.write_string("  }\n")
  }
  content.write_string("}\n")
}

///|
fn gen_field_write(
  content : StringBuilder,
  kind : FieldType,
  variable : String
) -> Unit {
  match kind {
    FieldType::FieldDescriptorProto_TYPE_STRING =>
      content.write_string("writer |> @lib.write_string(\{variable})\n")
    FieldType::FieldDescriptorProto_TYPE_BYTES =>
      content.write_string("writer |> @lib.write_bytes(\{variable})\n")
    FieldType::FieldDescriptorProto_TYPE_MESSAGE =>
      content.write_string(
        "writer |> @lib.write_uint32(@lib.size_of(\{variable})); @lib.Write::write(\{variable}, writer)\n",
      )
    FieldType::FieldDescriptorProto_TYPE_FIXED32 =>
      content.write_string("writer |> @lib.write_fixed32(\{variable})\n")
    FieldType::FieldDescriptorProto_TYPE_SFIXED32 =>
      content.write_string("writer |> @lib.write_sfixed32(\{variable})\n")
    FieldType::FieldDescriptorProto_TYPE_FLOAT =>
      content.write_string("writer |> @lib.write_float(\{variable})\n")
    FieldType::FieldDescriptorProto_TYPE_FIXED64 =>
      content.write_string("writer |> @lib.write_fixed64(\{variable})\n")
    FieldType::FieldDescriptorProto_TYPE_SFIXED64 =>
      content.write_string("writer |> @lib.write_sfixed64(\{variable})\n")
    FieldType::FieldDescriptorProto_TYPE_DOUBLE =>
      content.write_string("writer |> @lib.write_double(\{variable})\n")
    FieldType::FieldDescriptorProto_TYPE_BOOL =>
      content.write_string("writer |> @lib.write_bool(\{variable})\n")
    FieldType::FieldDescriptorProto_TYPE_INT32 =>
      content.write_string("writer |> @lib.write_int32(\{variable})\n")
    FieldType::FieldDescriptorProto_TYPE_INT64 =>
      content.write_string("writer |> @lib.write_int64(\{variable})\n")
    FieldType::FieldDescriptorProto_TYPE_SINT32 =>
      content.write_string("writer |> @lib.write_sint32(\{variable})\n")
    FieldType::FieldDescriptorProto_TYPE_SINT64 =>
      content.write_string("writer |> @lib.write_sint64(\{variable})\n")
    FieldType::FieldDescriptorProto_TYPE_UINT32 =>
      content.write_string("writer |> @lib.write_uint32(\{variable})\n")
    FieldType::FieldDescriptorProto_TYPE_UINT64 =>
      content.write_string("writer |> @lib.write_uint64(\{variable})\n")
    FieldType::FieldDescriptorProto_TYPE_ENUM =>
      content.write_string("writer |> @lib.write_enum(\{variable}.to_enum())\n")
    _ => panic()
  }
}
