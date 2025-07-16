///|
typealias @protobuf.FieldDescriptorProto_Type as FieldType

///|
struct ImportPath {
  path : Array[String]
  package_name : String
} derive(Eq, Show, Hash)

///|
fn ImportPath::from(path : String, package_name~ : String = "") -> ImportPath {
  let parts = path.split(".")
  let import_path = []
  for part in parts {
    if part.is_empty() {
      continue
    }
    import_path.push(part.to_string())
  }
  { path: import_path, package_name }
}


///|
fn ImportPath::has_prefix(self : ImportPath, path : ImportPath) -> Bool {
  if self.package_name != path.package_name {
    return false
  }
  if self.path.length() < path.path.length() {
    return false
  }
  for i, j in self.path.zip_to_iter2(path.path) {
    if i != j {
      return false
    }
  }
  return true
}

///|
fn ImportPath::to_string(self : ImportPath) -> String {
  return self.path.join(".")
}

///|
fn ImportPath::append(self : ImportPath, part : String) -> ImportPath {
  let new_path = self.path.copy()
  new_path.push_iter(
    part
    .split(".")
    .filter_map(x => if x.is_empty() { None } else { Some(x.to_string()) }),
  )
  { path: new_path, package_name: self.package_name }
}

///|
fn ImportPath::parent_name(self : ImportPath) -> String {
  return self.path[:-1].join(".")
}

///|
fn ImportPath::name(self : ImportPath) -> String {
  if self.path.is_empty() {
    return ""
  }
  return self.path.last().unwrap()
}

///|
fn ImportPath::path(self : ImportPath) -> String {
  self.path.join(".")
}

///|
struct Field {
  desc : @protobuf.FieldDescriptorProto
  import_path : ImportPath
  parent : Message
  type_ : FieldType?
  type_name : String?
  json_name : String?
  options : @protobuf.FieldOptions?
  name : String
  oneof_index : Int?
  number : Int?
  proto3optional : Bool? // proto3 optional field
} derive(Eq, Show)

///|
fn Field::from(
  desc : @protobuf.FieldDescriptorProto,
  parent : Message
) -> Field {
  {
    desc,
    parent,
    import_path: parent.import_path.append(desc.name.unwrap()),
    type_: desc.type_,
    type_name: desc.type_name,
    json_name: desc.json_name,
    options: desc.options,
    name: desc.name.unwrap(),
    oneof_index: desc.oneof_index,
    number: desc.number,
    proto3optional: desc.proto3optional,
  }
}

///|
fn Field::is_pack(self : Field) -> Bool {
  return (self.desc.options is Some(options) && options.packed is Some(true)) ||
    (self.is_list() && self.is_base_type())
}

///|
fn Field::is_map(self : Field) -> Bool {
  self.is_list() && self.is_message()
}

///|
fn Field::is_list(self : Field) -> Bool {
  return self.desc.label is Some(FieldDescriptorProto_LABEL_REPEATED)
}

///|
fn Field::is_base_type(self : Field) -> Bool {
  guard self.type_ is Some(type_) else { return false }
  return match type_ {
    FieldType::FieldDescriptorProto_TYPE_BOOL
    | FieldType::FieldDescriptorProto_TYPE_INT32
    | FieldType::FieldDescriptorProto_TYPE_INT64
    | FieldType::FieldDescriptorProto_TYPE_UINT32
    | FieldType::FieldDescriptorProto_TYPE_UINT64
    | FieldType::FieldDescriptorProto_TYPE_SINT32
    | FieldType::FieldDescriptorProto_TYPE_SINT64
    | FieldType::FieldDescriptorProto_TYPE_SFIXED64
    | FieldType::FieldDescriptorProto_TYPE_FIXED64
    | FieldType::FieldDescriptorProto_TYPE_DOUBLE
    | FieldType::FieldDescriptorProto_TYPE_SFIXED32
    | FieldType::FieldDescriptorProto_TYPE_FIXED32
    | FieldType::FieldDescriptorProto_TYPE_FLOAT => true
    _ => false
  }
}

///|
fn Field::is_message(self : Field) -> Bool {
  return self.desc.type_ is Some(FieldType::FieldDescriptorProto_TYPE_MESSAGE)
}

///|
fn Field::is_enum(self : Field) -> Bool {
  return self.desc.type_ is Some(FieldType::FieldDescriptorProto_TYPE_ENUM)
}

///|
fn Field::is_optional(self : Field) -> Bool {
  return self.desc.proto3optional is Some(true)
}

///|
fn Field::map_key_value(self : Field) -> Message? {
  if not(self.is_map()) {
    return None
  }
  let full_name = ImportPath::from(self.type_name.unwrap_or(""))
  for nested in self.parent.messages {
    if nested.is_map() && nested.import_path.name() == full_name.name() {
      return nested |> Some
    }
  }
  None
}

///|
struct Package {
  desc : @protobuf.FileDescriptorProto
  message_type : Array[Message]
  enums : Array[Enum]
  name : String
  package_name : String
  import_path : ImportPath
  options : @protobuf.FileOptions?
  dependency : Array[Package]
} derive(Eq, Show)

///|
fn Package::from(
  desc : @protobuf.FileDescriptorProto,
  file_descriptors_map~ : Map[String, Package]
) -> Package {
  let name = desc.name.unwrap_or("unknown.proto")
  let package_name = desc.package.unwrap_or_default()
  let package_ = {
    desc,
    message_type: [],
    enums: [],
    name,
    package_name,
    import_path: ImportPath::from("", package_name~),
    options: desc.options,
    dependency: [],
  }
  for message in desc.message_type {
    package_.message_type.push(Message::from_file(message, package_))
  }
  for enum_ in desc.enum_type {
    package_.enums.push(Enum::from_file(enum_, package_))
  }
  for dep in desc.dependency {
    if file_descriptors_map.contains(dep) {
      package_.dependency.push(file_descriptors_map.get(dep).unwrap())
    }
  }
  package_
}

///|
fn Package::find_message(self : Package, path : ImportPath) -> Message? {
  if not(path.has_prefix(self.import_path)) {
    return None
  }
  for message in self.message_type {
    if message.find_message(path) is Some(m) {
      return Some(m)
    }
  }
  None
}

///|
fn Package::find_enum(self : Package, path : ImportPath) -> Enum? {
  if not(path.has_prefix(self.import_path)) {
    return None
  }
  for enum_ in self.enums {
    if path.has_prefix(enum_.import_path) {
      return Some(enum_)
    }
  }
  for message in self.message_type {
    if message.fine_enum(path) is Some(e) {
      return Some(e)
    }
  }
  None
}

///|
struct Enum {
  desc : @protobuf.EnumDescriptorProto
  file : Package?
  import_path : ImportPath
  name : String
  parent : Message?
  options : @protobuf.EnumOptions?
  value : Array[@protobuf.EnumValueDescriptorProto]
} derive(Eq, Show)

///|
fn Enum::from_file(
  desc : @protobuf.EnumDescriptorProto,
  file : Package
) -> Enum {
  return {
    desc,
    file: Some(file),
    import_path: file.import_path.append(desc.name.unwrap()),
    name: desc.name.unwrap(),
    parent: None,
    options: desc.options,
    value: desc.value,
  }
}

///|
fn Enum::from_message(
  desc : @protobuf.EnumDescriptorProto,
  parent : Message
) -> Enum {
  return {
    desc,
    file: None,
    import_path: parent.import_path.append(desc.name.unwrap()),
    name: desc.name.unwrap(),
    parent: Some(parent),
    options: desc.options,
    value: desc.value,
  }
}

///|
struct OneOf {
  desc : @protobuf.OneofDescriptorProto
  import_path : ImportPath
  file : Package?
  parent : Message?
  options : @protobuf.OneofOptions?
  field : Array[Field] // fields in this oneof
  name : String
} derive(Eq, Show)

///|
fn OneOf::from_message(
  message : Message,
  desc : @protobuf.OneofDescriptorProto,
  field : Array[Field]
) -> OneOf {
  {
    desc,
    import_path: message.import_path.append(desc.name.unwrap()),
    file: message.file,
    parent: Some(message),
    options: desc.options,
    field,
    name: desc.name.unwrap(),
  }
}

///|
struct Message {
  desc : @protobuf.DescriptorProto
  import_path : ImportPath
  name : String
  file : Package?
  parent : Message?
  fields : Array[Field] // not include oneof fields
  oneofs : Array[OneOf]
  messages : Array[Message]
  enums : Array[Enum]
  options : @protobuf.MessageOptions?
} derive(Eq, Show)

///|
fn Message::from_file(
  desc : @protobuf.DescriptorProto,
  file : Package
) -> Message {
  let message = {
    file: Some(file),
    desc,
    fields: [],
    import_path: file.import_path.append(desc.name.unwrap()),
    oneofs: [],
    parent: None,
    messages: [],
    enums: [],
    options: desc.options,
    name: desc.name.unwrap(),
  }
  for enum_ in desc.enum_type {
    message.enums.push(Enum::from_message(enum_, message))
  }
  for field in desc.field {
    let field = Field::from(field, message)
    if field.is_oneof() {
      continue
    }
    message.fields.push(field)
  }
  for idx, oneof in desc.oneof_decl {
    let field = message.get_oneof_fields_by_index(idx)
    if field.length() == 1 && field[0].is_synthetic_oneof() {
      continue
    }
    let oneof = OneOf::from_message(message, oneof, field)
    message.oneofs.push(oneof)
  }
  for nested in desc.nested_type {
    message.messages.push(Message::child(nested, message))
  }
  message
}

///|
fn Message::child(
  desc : @protobuf.DescriptorProto,
  parent : Message
) -> Message {
  let message = {
    file: parent.file,
    desc,
    import_path: parent.import_path.append(desc.name.unwrap()),
    fields: [],
    oneofs: [],
    parent: Some(parent),
    messages: [],
    enums: [],
    options: desc.options,
    name: desc.name.unwrap(),
  }
  for enum_ in desc.enum_type {
    message.enums.push(Enum::from_message(enum_, message))
  }
  for field in desc.field {
    let field = Field::from(field, message)
    if field.is_oneof() {
      // synthetic oneof fields are not included in the message field list
      continue
    }
    message.fields.push(field)
  }
  for idx, oneof in desc.oneof_decl {
    let field = message.get_oneof_fields_by_index(idx)
    if field.length() == 1 && field[0].is_synthetic_oneof() {
      continue
    }
    let oneof = OneOf::from_message(message, oneof, field)
    message.oneofs.push(oneof)
  }
  for nested in desc.nested_type {
    message.messages.push(Message::child(nested, message))
  }
  message
}

///|
fn Message::is_map(self : Message) -> Bool {
  return self.options is Some(options) && options.map_entry is Some(true)
}

///|
fn Message::fine_enum(self : Message, path : ImportPath) -> Enum? {
  if self.enums.filter(enum_ => enum_.import_path == path).iter().head()
    is Some(e) {
    return Some(e)
  }
  for nested in self.messages {
    if path.has_prefix(nested.import_path) {
      return nested.fine_enum(path)
    }
  }
  None
}

///|
fn Message::find_message(self : Message, path : ImportPath) -> Message? {
  if self.import_path == path {
    return Some(self)
  }
  for nested in self.messages {
    if path.has_prefix(nested.import_path) {
      return nested.find_message(path)
    }
  }
  None
}

///|
fn Field::is_oneof(self : Field) -> Bool {
  return self.oneof_index is Some(_) && self.proto3optional is None
}

///|
fn Field::is_synthetic_oneof(self : Field) -> Bool {
  return self.oneof_index is Some(_) && self.proto3optional is Some(true)
}

///|
fn Message::get_oneof_fields_by_index(
  self : Message,
  index : Int
) -> Array[Field] {
  return self.desc.field
    .filter(field => field.oneof_index is Some(idx) && idx == index)
    .map(field => Field::from(field, self))
}
