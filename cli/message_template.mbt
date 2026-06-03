///|
fn CodeGenerator::get_moonbit_type(
  self : CodeGenerator,
  field : Field,
  parent_path? : ImportPath,
) -> String raise {
  guard field.type_ is Some(typ) else { raise UnsupportedType("Group") }
  return match typ {
    FieldDescriptorProto_Type::TYPE_DOUBLE => "Double"
    FieldDescriptorProto_Type::TYPE_FLOAT => "Float"
    FieldDescriptorProto_Type::TYPE_INT64 => "Int64"
    FieldDescriptorProto_Type::TYPE_UINT64 => "UInt64"
    FieldDescriptorProto_Type::TYPE_INT32 => "Int"
    FieldDescriptorProto_Type::TYPE_FIXED64 => "UInt64"
    FieldDescriptorProto_Type::TYPE_FIXED32 => "UInt"
    FieldDescriptorProto_Type::TYPE_BOOL => "Bool"
    FieldDescriptorProto_Type::TYPE_STRING => "String"
    FieldDescriptorProto_Type::TYPE_GROUP => raise UnsupportedType("Group")
    FieldDescriptorProto_Type::TYPE_MESSAGE => {
      let message_name = field.type_name.unwrap()
      if self.find_message(message_name) is Some(message) {
        let message_path = message.import_path
        if parent_path is Some(path) &&
          path.package_name != message_path.package_name {
          return "@\{self.qualified_name(message_path)}.\{message_path.path() |> to_camel_case}"
        }
        return message_path.path() |> to_camel_case
      }
      raise UnsupportedType("Message \{message_name} not found")
    }
    FieldDescriptorProto_Type::TYPE_BYTES => "Bytes"
    FieldDescriptorProto_Type::TYPE_UINT32 => "UInt"
    FieldDescriptorProto_Type::TYPE_ENUM => {
      let enum_name = field.type_name.unwrap()
      if self.find_enum(enum_name) is Some(enum_) {
        let path = enum_.import_path
        if parent_path is Some(path) && path.package_name != path.package_name {
          return "@\{self.qualified_name(path)}.\{path.path() |> to_camel_case}"
        }
        return path.path() |> to_camel_case
      }
      raise UnsupportedType("Enum \{enum_name} not found")
    }
    FieldDescriptorProto_Type::TYPE_SFIXED32 => "Int"
    FieldDescriptorProto_Type::TYPE_SFIXED64 => "Int64"
    FieldDescriptorProto_Type::TYPE_SINT32 => "Int"
    FieldDescriptorProto_Type::TYPE_SINT64 => "Int64"
  }
}

///|
fn CodeGenerator::gen_messages(
  self : CodeGenerator,
  messages : Array[Message],
  content : StringBuilder,
) -> Unit raise {
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
  message : Message,
  file : StringBuilder,
) -> Unit raise {
  let message_name = message.import_path.path() |> to_camel_case
  let message_path = message.import_path
  file.write_string("pub(all) struct \{message_name} {\n")
  for field in message.fields {
    let field_type = self.get_moonbit_type(field, parent_path=message_path)
    let field_name = field.import_path.name() |> pascal_to_snake
    if field.is_optional() {
      file.write_string("  mut \{field_name} : \{field_type}?\n")
    } else if field.map_key_value() is Some(map_entry) {
      let key_type = self.get_moonbit_type(
        map_entry.fields[0],
        parent_path=message_path,
      )
      let value_type = self.get_moonbit_type(
        map_entry.fields[1],
        parent_path=message_path,
      )
      file.write_string(
        "  mut \{field_name} : Map[\{key_type}, \{value_type}]\n",
      )
    } else if field.is_list() {
      file.write_string("  mut \{field_name} : Array[\{field_type}]\n")
    } else if field.is_message() {
      file.write_string("  mut \{field_name} : \{field_type} \n")
    } else if field.is_enum() {
      file.write_string("  mut \{field_name} : \{field_type} \n")
    } else {
      file.write_string("  mut \{field_name} : \{field_type}\n")
    }
  }
  let derive_list = self.derive_list().join(", ")
  for oneof in message.oneofs {
    let oneof_name = self.get_oneof_enum_name(message, oneof.import_path.name())
    let field_name = oneof.import_path.name() |> pascal_to_snake
    file.write_string("  mut \{field_name} : \{oneof_name}\n")
  }
  file.write_string("} derive(\{derive_list})\n")
  for oneof in message.oneofs {
    self.gen_oneof_enum(message, oneof, file)
  }
  self.gen_message_size(message, file)
  self.gen_message_default(message, file)
  self.gen_message_new(message, file)
  self.gen_message_reader(message, file)
  self.gen_message_writer(message, file)
  if self.support_json() {
    self.gen_message_json(message, file)
  }
  if self.support_async() {
    self.gen_message_reader(message, file, is_async=true)
    self.gen_message_writer(message, file, is_async=true)
  }
}

///|
fn CodeGenerator::gen_message_default(
  self : CodeGenerator,
  message : Message,
  content : StringBuilder,
) -> Unit raise {
  let message_name = message.import_path.path() |> to_camel_case
  content.write_string(
    (
      $|pub impl Default for \{message_name} with default() -> \{message_name} {
      $|  \{message_name}::{
      $|
    ),
  )
  for field in message.fields {
    let field_type = self.get_moonbit_type(
      field,
      parent_path=message.import_path,
    )
    let field_name = field.import_path.name() |> pascal_to_snake
    if field.default_value() is Some(default_value) {
      let mut field_default_value = default_value
      if field.type_ is Some(TYPE_STRING) {
        field_default_value = "\"\{field_default_value}\""
      } else if field.is_enum() {
        field_default_value = "\{field_type}::\{default_value}"
      }
      if field.is_optional() {
        field_default_value = "Some(\{field_default_value})"
      }
      content.write_string("    \{field_name} : \{field_default_value},\n")
    } else if field.is_optional() {
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
    let oneof_name = self.get_oneof_enum_name(message, oneof.import_path.name())
    content.write_string(
      "    \{oneof.import_path.name()} : \{oneof_name}::NotSet,\n",
    )
  }
  content.write_string(
    (
      #|  }
      #|}
      #|
    ),
  )
}

///|
fn CodeGenerator::gen_message_new(
  self : CodeGenerator,
  message : Message,
  content : StringBuilder,
) -> Unit raise {
  let message_name = message.import_path.path() |> to_camel_case
  let constructor_arguments = []
  for field in message.fields {
    let mut field_name = field.import_path.name() |> pascal_to_snake
    let mut field_type = self.get_moonbit_type(
      field,
      parent_path=message.import_path,
    )
    if field.map_key_value() is Some(map_entry) {
      let key_type = self.get_moonbit_type(
        map_entry.fields[0],
        parent_path=message.import_path,
      )
      let value_type = self.get_moonbit_type(
        map_entry.fields[1],
        parent_path=message.import_path,
      )
      field_type = "Map[\{key_type}, \{value_type}]"
    } else if field.is_pack() || field.is_list() {
      field_type = "Array[\{field_type}]"
    } else if field.is_optional() {
      field_name = "\{field_name}?"
    }
    constructor_arguments.push("\{field_name} : \{field_type}")
  }
  for oneof in message.oneofs {
    let oneof_name = self.get_oneof_enum_name(message, oneof.import_path.name())
    let oneof_field_name = oneof.import_path.name() |> pascal_to_snake
    constructor_arguments.push(
      "\{oneof_field_name}?: \{oneof_name} = \{oneof_name}::NotSet",
    )
  }
  let constructor_arguments_string = constructor_arguments.join(", ")
  content.write_string(
    (
      $|pub fn \{message_name}::new(\{constructor_arguments_string}) -> \{message_name} {
      $|  \{message_name}::{
      $|
    ),
  )
  for field in message.fields {
    let field_name = field.import_path.name() |> pascal_to_snake
    content.write_string("    \{field_name},\n")
  }
  for oneof in message.oneofs {
    let oneof_field_name = oneof.import_path.name() |> pascal_to_snake
    content.write_string("    \{oneof_field_name},\n")
  }
  content.write_string(
    (
      #|  }
      #|}
      #|
    ),
  )
}

