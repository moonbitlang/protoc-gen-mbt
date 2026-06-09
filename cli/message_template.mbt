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
    FieldDescriptorProto_Type::TYPE_MESSAGE
    | FieldDescriptorProto_Type::TYPE_GROUP => {
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
  let shape = self.message_shape(message)
  file.write_string("pub(all) struct \{shape.message_name} {\n")
  for field in shape.storage_fields {
    file.write_string("  mut \{field.field_name} : \{field.declaration_type}\n")
  }
  let derive_list = self.derive_list().join(", ")
  for oneof in shape.oneofs {
    file.write_string("  mut \{oneof.field_name} : \{oneof.enum_name}\n")
  }
  file.write_string("} derive(\{derive_list})\n")
  for oneof in shape.oneofs {
    self.gen_oneof_enum(oneof, file)
  }
  self.gen_message_size(shape, file)
  self.gen_message_default(shape, file)
  self.gen_message_new(shape, file)
  self.gen_message_reader(shape, file)
  self.gen_message_writer(shape, file)
  if self.support_json() {
    self.gen_message_json(shape, file)
  }
  if self.support_async() {
    self.gen_message_reader(shape, file, is_async=true)
    self.gen_message_writer(shape, file, is_async=true)
  }
}

///|
fn CodeGenerator::gen_message_default(
  _ : CodeGenerator,
  shape : MessageShape,
  content : StringBuilder,
) -> Unit {
  content.write_string(
    (
      $|pub impl Default for \{shape.message_name} with fn default() -> \{shape.message_name} {
      $|  \{shape.message_name}::{
      $|
    ),
  )
  for field in shape.storage_fields {
    content.write_string("    \{field.field_name} : \{field.default_expr},\n")
  }
  for oneof in shape.oneofs {
    content.write_string(
      "    \{oneof.field_name} : \{oneof.enum_name}::NotSet,\n",
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
  _ : CodeGenerator,
  shape : MessageShape,
  content : StringBuilder,
) -> Unit {
  let constructor_arguments = []
  for field in shape.storage_fields {
    constructor_arguments.push(
      "\{field.constructor_name} : \{field.constructor_type}",
    )
  }
  for oneof in shape.oneofs {
    constructor_arguments.push(
      "\{oneof.field_name}?: \{oneof.enum_name} = \{oneof.enum_name}::NotSet",
    )
  }
  let constructor_arguments_string = constructor_arguments.join(", ")
  content.write_string(
    (
      $|pub fn \{shape.message_name}::new(\{constructor_arguments_string}) -> \{shape.message_name} {
      $|  \{shape.message_name}::{
      $|
    ),
  )
  for field in shape.storage_fields {
    content.write_string("    \{field.field_name},\n")
  }
  for oneof in shape.oneofs {
    content.write_string("    \{oneof.field_name},\n")
  }
  content.write_string(
    (
      #|  }
      #|}
      #|
    ),
  )
}
