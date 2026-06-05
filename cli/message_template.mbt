///|
fn CodeGenerator::get_moonbit_type(
  self : CodeGenerator,
  field : Field,
  parent_path? : ImportPath,
) -> String raise {
  guard field.type_ is Some(typ) else { raise @model.UnsupportedType("Group") }
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
    FieldDescriptorProto_Type::TYPE_GROUP =>
      raise @model.UnsupportedType("Group")
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
      raise @model.UnsupportedType("Message \{message_name} not found")
    }
    FieldDescriptorProto_Type::TYPE_BYTES => "Bytes"
    FieldDescriptorProto_Type::TYPE_UINT32 => "UInt"
    FieldDescriptorProto_Type::TYPE_ENUM => {
      let enum_name = field.type_name.unwrap()
      if self.find_enum(enum_name) is Some(enum_) {
        let enum_path = enum_.import_path
        if parent_path is Some(parent_path) &&
          parent_path.package_name != enum_path.package_name {
          return "@\{self.qualified_name(enum_path)}.\{enum_path.path() |> to_camel_case}"
        }
        return enum_path.path() |> to_camel_case
      }
      raise @model.UnsupportedType("Enum \{enum_name} not found")
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
    let shape = self.field_storage_shape(field, message_path)
    file.write_string("  mut \{shape.field_name} : \{shape.declaration_type}\n")
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
      $|pub impl Default for \{message_name} with fn default() -> \{message_name} {
      $|  \{message_name}::{
      $|
    ),
  )
  for field in message.fields {
    let shape = self.field_storage_shape(field, message.import_path)
    content.write_string("    \{shape.field_name} : \{shape.default_expr},\n")
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
    let shape = self.field_storage_shape(field, message.import_path)
    constructor_arguments.push(
      "\{shape.constructor_name} : \{shape.constructor_type}",
    )
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
    let shape = self.field_storage_shape(field, message.import_path)
    content.write_string("    \{shape.field_name},\n")
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
