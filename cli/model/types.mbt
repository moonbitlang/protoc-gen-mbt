///|
using @protobuf {type FieldDescriptorProto_Type}

///|
pub(all) suberror GenerateError {
  UnsupportedType(String)
  UnexpectedType(String)
}

///|
pub(all) struct ImportPath {
  path : Array[String]
  package_name : String
} derive(Eq, Debug, Hash)

///|
pub fn ImportPath::from(
  path : String,
  package_name? : String = "",
) -> ImportPath {
  let parts = path.split(".")
  let import_path = []
  for part in parts {
    if part.is_empty() {
      continue
    }
    import_path.push(part.to_owned())
  }
  { path: import_path, package_name }
}

///|
pub fn ImportPath::has_prefix(self : ImportPath, path : ImportPath) -> Bool {
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
pub fn ImportPath::append(self : ImportPath, part : String) -> ImportPath {
  let new_path = self.path.copy()
  new_path.push_iter(
    part
    .split(".")
    .filter_map(x => if x.is_empty() { None } else { Some(x.to_owned()) }),
  )
  { path: new_path, package_name: self.package_name }
}

///|
pub fn ImportPath::name(self : ImportPath) -> String {
  if self.path.is_empty() {
    return ""
  }
  return self.path.last().unwrap()
}

///|
pub fn ImportPath::path(self : ImportPath) -> String {
  self.path.join(".")
}

///|
pub(all) enum Syntax {
  Proto2
  Proto3
  Editions
} derive(Eq, Debug)

///|
pub(all) struct Field {
  desc : @protobuf.FieldDescriptorProto
  import_path : ImportPath
  parent : Message
  type_ : FieldDescriptorProto_Type?
  type_name : String?
  json_name : String?
  options : @protobuf.FieldOptions?
  name : String
  oneof_index : Int?
  number : Int?
  proto3optional : Bool? // proto3 optional field
} derive(Eq, Debug)

///|
pub(all) struct FieldStorageShape {
  field_name : String
  declaration_type : String
  constructor_name : String
  constructor_type : String
  default_expr : String
} derive(Eq, Debug)

///|
pub(all) struct FieldCodecValue {
  type_ : FieldDescriptorProto_Type
  type_name : String
} derive(Eq, Debug)

///|
pub(all) enum FieldCodecMessageEncoding {
  LengthPrefixedMessage
  DelimitedMessage
} derive(Eq, Debug)

///|
pub(all) enum FieldEnvelopeKind {
  ScalarEnvelope
  LengthDelimitedEnvelope
  DelimitedMessageEnvelope
  PackedEnvelope
} derive(Eq, Debug)

///|
pub(all) struct FieldEnvelopeShape {
  field_number : Int
  wire_type : Int
  kind : FieldEnvelopeKind
} derive(Eq, Debug)

///|
pub(all) enum FieldCodecCardinality {
  SingularField
  OptionalField
  RepeatedField
  PackedField
  MapField
} derive(Eq, Debug)

///|
pub(all) enum FieldCodecPresence {
  AlwaysEmitField
  EmitFieldWhenSome
  EmitFieldWhenNonDefault
  EmitFieldWhenNonEmpty
} derive(Eq, Debug)

///|
pub(all) enum FieldCodecReadMode {
  ReadUnpackedField
  ReadPackedAndUnpackedField
} derive(Eq, Debug)

///|
pub(all) struct FieldCodecShape {
  field_name : String
  value : FieldCodecValue
  envelope : FieldEnvelopeShape
  cardinality : FieldCodecCardinality
  key : FieldCodecValue?
  key_envelope : FieldEnvelopeShape?
  map_value : FieldCodecValue?
  map_value_envelope : FieldEnvelopeShape?
  presence : FieldCodecPresence
  read_mode : FieldCodecReadMode
} derive(Eq, Debug)

///|
pub(all) enum FieldJsonCardinality {
  SingularJsonField
  OptionalJsonField
  RepeatedJsonField
  MapJsonField
} derive(Eq, Debug)

///|
pub(all) struct FieldJsonShape {
  field_name : String
  self_expr : String
  to_json_name : String
  from_json_name : String
  type_ : FieldDescriptorProto_Type
  default_expr : String
  has_default_value : Bool
  cardinality : FieldJsonCardinality
} derive(Eq, Debug)

///|
pub(all) struct OneofFieldShape {
  constructor_name : String
  json_name : String
  value_type : String
  value : FieldCodecValue
  envelope : FieldEnvelopeShape
} derive(Eq, Debug)

///|
pub(all) struct OneofShape {
  field_name : String
  enum_name : String
  fields : Array[OneofFieldShape]
} derive(Eq, Debug)

///|
pub(all) struct ServiceMethodShape {
  method_name : String
  input_type : String
  output_type : String
  client_streaming : Bool
  server_streaming : Bool
} derive(Eq, Debug)

///|
pub(all) struct ServiceShape {
  trait_name : String
  methods : Array[ServiceMethodShape]
} derive(Eq, Debug)

///|
pub(all) struct MessageShape {
  message_name : String
  storage_fields : Array[FieldStorageShape]
  codec_fields : Array[FieldCodecShape]
  json_fields : Array[FieldJsonShape]
  oneofs : Array[OneofShape]
  has_runtime_json_impl : Bool
} derive(Eq, Debug)

///|
fn Field::from(
  desc : @protobuf.FieldDescriptorProto,
  parent : Message,
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
    proto3optional: desc.proto3_optional,
  }
}

///|
pub fn Field::is_map(self : Field) -> Bool {
  self.is_list() && self.is_message()
}

///|
pub fn Field::is_list(self : Field) -> Bool {
  return self.desc.label is Some(LABEL_REPEATED)
}

///|
pub fn Field::is_packable_scalar(self : Field) -> Bool {
  guard self.type_ is Some(type_) else { return false }
  return match type_ {
    FieldDescriptorProto_Type::TYPE_BOOL
    | FieldDescriptorProto_Type::TYPE_ENUM
    | FieldDescriptorProto_Type::TYPE_INT32
    | FieldDescriptorProto_Type::TYPE_INT64
    | FieldDescriptorProto_Type::TYPE_UINT32
    | FieldDescriptorProto_Type::TYPE_UINT64
    | FieldDescriptorProto_Type::TYPE_SINT32
    | FieldDescriptorProto_Type::TYPE_SINT64
    | FieldDescriptorProto_Type::TYPE_SFIXED64
    | FieldDescriptorProto_Type::TYPE_FIXED64
    | FieldDescriptorProto_Type::TYPE_DOUBLE
    | FieldDescriptorProto_Type::TYPE_SFIXED32
    | FieldDescriptorProto_Type::TYPE_FIXED32
    | FieldDescriptorProto_Type::TYPE_FLOAT => true
    _ => false
  }
}

///|
pub fn Field::is_message(self : Field) -> Bool {
  return self.desc.type_
    is Some(
      FieldDescriptorProto_Type::TYPE_MESSAGE
      | FieldDescriptorProto_Type::TYPE_GROUP
    )
}

///|
pub fn Field::is_enum(self : Field) -> Bool {
  return self.desc.type_ is Some(FieldDescriptorProto_Type::TYPE_ENUM)
}

///|
pub fn Field::map_key_value(self : Field) -> Message? {
  if !self.is_map() {
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
pub(all) struct Package {
  desc : @protobuf.FileDescriptorProto
  message_type : Array[Message]
  enums : Array[Enum]
  services : Array[Service]
  name : String
  package_name : String
  import_path : ImportPath
  options : @protobuf.FileOptions?
  dependency : Array[Package]
  syntax : Syntax
} derive(Eq, Debug)

///|
pub fn Package::from(desc : @protobuf.FileDescriptorProto) -> Package {
  let name = desc.name.unwrap_or("unknown.proto")
  let package_name = desc.package_.unwrap_or_default()
  let package_ = {
    desc,
    message_type: [],
    enums: [],
    services: [],
    name,
    package_name,
    import_path: ImportPath::from("", package_name~),
    options: desc.options,
    dependency: [],
    syntax: match desc.syntax {
      Some("proto3") => Proto3
      Some("proto2") => Proto2
      Some("editions") => Editions
      Some(_) => panic()
      None => Proto2 // if syntax is not specified, default to proto2
    },
  }
  for message in desc.message_type {
    package_.message_type.push(Message::from_file(message, package_))
  }
  for enum_ in desc.enum_type {
    package_.enums.push(Enum::from_file(enum_, package_))
  }
  for service in desc.service {
    package_.services.push(Service::from_file(service, package_))
  }
  package_
}

///|
pub fn Package::find_message(self : Package, path : ImportPath) -> Message? {
  if !path.has_prefix(self.import_path) {
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
pub fn Package::find_enum(self : Package, path : ImportPath) -> Enum? {
  if !path.has_prefix(self.import_path) {
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
pub(all) struct Enum {
  desc : @protobuf.EnumDescriptorProto
  file : Package?
  import_path : ImportPath
  name : String
  parent : Message?
  options : @protobuf.EnumOptions?
  value : Array[@protobuf.EnumValueDescriptorProto]
} derive(Eq, Debug)

///|
fn Enum::from_file(
  desc : @protobuf.EnumDescriptorProto,
  file : Package,
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
  parent : Message,
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
pub(all) struct OneOf {
  desc : @protobuf.OneofDescriptorProto
  import_path : ImportPath
  file : Package?
  parent : Message?
  options : @protobuf.OneofOptions?
  field : Array[Field] // fields in this oneof
  name : String
} derive(Eq, Debug)

///|
fn OneOf::from_message(
  message : Message,
  desc : @protobuf.OneofDescriptorProto,
  field : Array[Field],
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
pub(all) struct Message {
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
} derive(Eq, Debug)

///|
pub(all) struct Method {
  desc : @protobuf.MethodDescriptorProto
  name : String
  input_type : String
  output_type : String
  client_streaming : Bool
  server_streaming : Bool
} derive(Eq, Debug)

///|
fn Method::from_service(desc : @protobuf.MethodDescriptorProto) -> Method {
  {
    desc,
    name: desc.name.unwrap(),
    input_type: desc.input_type.unwrap(),
    output_type: desc.output_type.unwrap(),
    client_streaming: desc.client_streaming.unwrap_or(false),
    server_streaming: desc.server_streaming.unwrap_or(false),
  }
}

///|
pub(all) struct Service {
  desc : @protobuf.ServiceDescriptorProto
  file : Package?
  import_path : ImportPath
  name : String
  methods : Array[Method]
} derive(Eq, Debug)

///|
fn Service::from_file(
  desc : @protobuf.ServiceDescriptorProto,
  file : Package,
) -> Service {
  let methods = []
  for rpc in desc.method_ {
    methods.push(Method::from_service(rpc))
  }
  {
    desc,
    file: Some(file),
    import_path: file.import_path.append(desc.name.unwrap()),
    name: desc.name.unwrap(),
    methods,
  }
}

///|
fn Message::from_file(
  desc : @protobuf.DescriptorProto,
  file : Package,
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
  parent : Message,
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
pub fn Message::is_map(self : Message) -> Bool {
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
pub fn Field::is_oneof(self : Field) -> Bool {
  return self.oneof_index is Some(_) && self.proto3optional is None
}

///|
pub fn Field::is_synthetic_oneof(self : Field) -> Bool {
  return self.oneof_index is Some(_) && self.proto3optional is Some(true)
}

///|
pub fn Field::default_value(self : Field) -> String? {
  self.desc.default_value
}

///|
fn Message::get_oneof_fields_by_index(
  self : Message,
  index : Int,
) -> Array[Field] {
  return self.desc.field
    .filter(field => field.oneof_index is Some(idx) && idx == index)
    .map(field => Field::from(field, self))
}
