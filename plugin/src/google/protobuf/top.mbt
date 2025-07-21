///|
pub(all) enum Edition {
  EDITION_UNKNOWN
  EDITION_LEGACY
  EDITION_PROTO2
  EDITION_PROTO3
  EDITION_2023
  EDITION_2024
  EDITION_1_TEST_ONLY
  EDITION_2_TEST_ONLY
  EDITION_99997_TEST_ONLY
  EDITION_99998_TEST_ONLY
  EDITION_99999_TEST_ONLY
  EDITION_MAX
} derive(Eq, Show)

///|
pub fn Edition::to_enum(self : Edition) -> @lib.Enum {
  match self {
    Edition::EDITION_UNKNOWN => 0
    Edition::EDITION_LEGACY => 900
    Edition::EDITION_PROTO2 => 998
    Edition::EDITION_PROTO3 => 999
    Edition::EDITION_2023 => 1000
    Edition::EDITION_2024 => 1001
    Edition::EDITION_1_TEST_ONLY => 1
    Edition::EDITION_2_TEST_ONLY => 2
    Edition::EDITION_99997_TEST_ONLY => 99997
    Edition::EDITION_99998_TEST_ONLY => 99998
    Edition::EDITION_99999_TEST_ONLY => 99999
    Edition::EDITION_MAX => 2147483647
  }
}

///|
pub fn Edition::from_enum(i : @lib.Enum) -> Edition {
  match i.inner() {
    0 => Edition::EDITION_UNKNOWN
    900 => Edition::EDITION_LEGACY
    998 => Edition::EDITION_PROTO2
    999 => Edition::EDITION_PROTO3
    1000 => Edition::EDITION_2023
    1001 => Edition::EDITION_2024
    1 => Edition::EDITION_1_TEST_ONLY
    2 => Edition::EDITION_2_TEST_ONLY
    99997 => Edition::EDITION_99997_TEST_ONLY
    99998 => Edition::EDITION_99998_TEST_ONLY
    99999 => Edition::EDITION_99999_TEST_ONLY
    2147483647 => Edition::EDITION_MAX
    _ => Default::default()
  }
}

///|
pub impl Default for Edition with default() -> Edition {
  Edition::EDITION_UNKNOWN
}

///|
pub impl @lib.Sized for Edition with size_of(self : Edition) {
  @lib.Sized::size_of(self.to_enum())
}

///|
pub impl @json.FromJson for Edition with from_json(
  json : Json,
  path : @json.JsonPath
) -> Edition raise {
  match json {
    String(s) if s == "EDITION_UNKNOWN" => Edition::EDITION_UNKNOWN
    String(s) if s == "EDITION_LEGACY" => Edition::EDITION_LEGACY
    String(s) if s == "EDITION_PROTO2" => Edition::EDITION_PROTO2
    String(s) if s == "EDITION_PROTO3" => Edition::EDITION_PROTO3
    String(s) if s == "EDITION_2023" => Edition::EDITION_2023
    String(s) if s == "EDITION_2024" => Edition::EDITION_2024
    String(s) if s == "EDITION_1_TEST_ONLY" => Edition::EDITION_1_TEST_ONLY
    String(s) if s == "EDITION_2_TEST_ONLY" => Edition::EDITION_2_TEST_ONLY
    String(s) if s == "EDITION_99997_TEST_ONLY" =>
      Edition::EDITION_99997_TEST_ONLY
    String(s) if s == "EDITION_99998_TEST_ONLY" =>
      Edition::EDITION_99998_TEST_ONLY
    String(s) if s == "EDITION_99999_TEST_ONLY" =>
      Edition::EDITION_99999_TEST_ONLY
    String(s) if s == "EDITION_MAX" => Edition::EDITION_MAX
    Number(n) if n == 0 => Edition::EDITION_UNKNOWN
    Number(n) if n == 900 => Edition::EDITION_LEGACY
    Number(n) if n == 998 => Edition::EDITION_PROTO2
    Number(n) if n == 999 => Edition::EDITION_PROTO3
    Number(n) if n == 1000 => Edition::EDITION_2023
    Number(n) if n == 1001 => Edition::EDITION_2024
    Number(n) if n == 1 => Edition::EDITION_1_TEST_ONLY
    Number(n) if n == 2 => Edition::EDITION_2_TEST_ONLY
    Number(n) if n == 99997 => Edition::EDITION_99997_TEST_ONLY
    Number(n) if n == 99998 => Edition::EDITION_99998_TEST_ONLY
    Number(n) if n == 99999 => Edition::EDITION_99999_TEST_ONLY
    Number(n) if n == 2147483647 => Edition::EDITION_MAX
    _ =>
      raise @json.JsonDecodeError(
        (path, "Expected a number or string for enum"),
      )
  }
}

///|
pub impl ToJson for Edition with to_json(self : Edition) -> Json {
  match self {
    Edition::EDITION_UNKNOWN => "EDITION_UNKNOWN"
    Edition::EDITION_LEGACY => "EDITION_LEGACY"
    Edition::EDITION_PROTO2 => "EDITION_PROTO2"
    Edition::EDITION_PROTO3 => "EDITION_PROTO3"
    Edition::EDITION_2023 => "EDITION_2023"
    Edition::EDITION_2024 => "EDITION_2024"
    Edition::EDITION_1_TEST_ONLY => "EDITION_1_TEST_ONLY"
    Edition::EDITION_2_TEST_ONLY => "EDITION_2_TEST_ONLY"
    Edition::EDITION_99997_TEST_ONLY => "EDITION_99997_TEST_ONLY"
    Edition::EDITION_99998_TEST_ONLY => "EDITION_99998_TEST_ONLY"
    Edition::EDITION_99999_TEST_ONLY => "EDITION_99999_TEST_ONLY"
    Edition::EDITION_MAX => "EDITION_MAX"
  }
}

///|
pub(all) struct FileDescriptorSet {
  mut file : Array[FileDescriptorProto]
} derive(Eq, Show)

///|
pub impl @lib.Sized for FileDescriptorSet with size_of(self) {
  let mut size = 0U
  size += self.file
    .iter()
    .map(@lib.size_of)
    .map(s => 1U + @lib.size_of(s) + s)
    .fold(init=0U, UInt::op_add)
  size
}

///|
pub impl Default for FileDescriptorSet with default() -> FileDescriptorSet {
  FileDescriptorSet::{ file: [] }
}

///|
pub impl @lib.Read for FileDescriptorSet with read(reader : &@lib.Reader) {
  let msg = FileDescriptorSet::default()
  while not(reader |> @lib.is_eof()) {
    match (reader |> @lib.read_tag()) {
      (1, _) =>
        msg.file.push((reader |> @lib.read_message() : FileDescriptorProto))
      (_, wire) => reader |> @lib.read_unknown(wire)
    }
  }
  msg
}

///|
pub impl @lib.Write for FileDescriptorSet with write(self, writer) {
  self.file
  .iter()
  .each(fn(v) {
    writer |> @lib.write_varint(10UL)
    writer |> @lib.write_uint32(@lib.size_of(v))
    @lib.Write::write(v, writer)
  })
}

///|
pub impl ToJson for FileDescriptorSet with to_json(self) {
  let json : Map[String, Json] = {}
  if self.file != Default::default() {
    json["file"] = self.file.to_json()
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for FileDescriptorSet with from_json(
  json : Json,
  path : @json.JsonPath
) -> FileDescriptorSet raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError(
      (path, "Expected an object for FileDescriptorSet"),
    )
  }
  let message = FileDescriptorSet::default()
  for key, value in obj {
    match (key, value) {
      ("file", Array(value)) =>
        message.file = value.map(v => @json.from_json(v, path~))
      key => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub(all) struct FileDescriptorProto {
  mut name : String?
  mut package : String?
  mut dependency : Array[String]
  mut public_dependency : Array[Int]
  mut weak_dependency : Array[Int]
  mut message_type : Array[DescriptorProto]
  mut enum_type : Array[EnumDescriptorProto]
  mut service : Array[ServiceDescriptorProto]
  mut extension : Array[FieldDescriptorProto]
  mut options : FileOptions?
  mut source_code_info : SourceCodeInfo?
  mut syntax : String?
  mut edition : Edition?
} derive(Eq, Show)

///|
pub impl @lib.Sized for FileDescriptorProto with size_of(self) {
  let mut size = 0U
  match self.name {
    Some(v) =>
      size += 1U +
        {
          let size = @lib.size_of(v)
          @lib.size_of(size) + size
        }
    None => ()
  }
  match self.package {
    Some(v) =>
      size += 1U +
        {
          let size = @lib.size_of(v)
          @lib.size_of(size) + size
        }
    None => ()
  }
  size += self.dependency
    .iter()
    .map(@lib.size_of)
    .map(s => 1U + @lib.size_of(s) + s)
    .fold(init=0U, UInt::op_add)
  size += self.public_dependency
    .iter()
    .map(@lib.size_of)
    .map(s => 1U + @lib.size_of(s) + s)
    .fold(init=0U, UInt::op_add)
  size += self.weak_dependency
    .iter()
    .map(@lib.size_of)
    .map(s => 1U + @lib.size_of(s) + s)
    .fold(init=0U, UInt::op_add)
  size += self.message_type
    .iter()
    .map(@lib.size_of)
    .map(s => 1U + @lib.size_of(s) + s)
    .fold(init=0U, UInt::op_add)
  size += self.enum_type
    .iter()
    .map(@lib.size_of)
    .map(s => 1U + @lib.size_of(s) + s)
    .fold(init=0U, UInt::op_add)
  size += self.service
    .iter()
    .map(@lib.size_of)
    .map(s => 1U + @lib.size_of(s) + s)
    .fold(init=0U, UInt::op_add)
  size += self.extension
    .iter()
    .map(@lib.size_of)
    .map(s => 1U + @lib.size_of(s) + s)
    .fold(init=0U, UInt::op_add)
  match self.options {
    Some(v) =>
      size += 1U +
        {
          let size = @lib.size_of(v)
          @lib.size_of(size) + size
        }
    None => ()
  }
  match self.source_code_info {
    Some(v) =>
      size += 1U +
        {
          let size = @lib.size_of(v)
          @lib.size_of(size) + size
        }
    None => ()
  }
  match self.syntax {
    Some(v) =>
      size += 1U +
        {
          let size = @lib.size_of(v)
          @lib.size_of(size) + size
        }
    None => ()
  }
  match self.edition {
    Some(v) => size += 1U + @lib.size_of(v)
    None => ()
  }
  size
}

///|
pub impl Default for FileDescriptorProto with default() -> FileDescriptorProto {
  FileDescriptorProto::{
    name: None,
    package: None,
    dependency: [],
    public_dependency: [],
    weak_dependency: [],
    message_type: [],
    enum_type: [],
    service: [],
    extension: [],
    options: None,
    source_code_info: None,
    syntax: None,
    edition: None,
  }
}

///|
pub impl @lib.Read for FileDescriptorProto with read(reader : &@lib.Reader) {
  let msg = FileDescriptorProto::default()
  while not(reader |> @lib.is_eof()) {
    match (reader |> @lib.read_tag()) {
      (1, _) => msg.name = reader |> @lib.read_string() |> Some
      (2, _) => msg.package = reader |> @lib.read_string() |> Some
      (3, _) => msg.dependency.push(reader |> @lib.read_string())
      (10, _) => msg.public_dependency.push(reader |> @lib.read_int32())
      (11, _) => msg.weak_dependency.push(reader |> @lib.read_int32())
      (4, _) =>
        msg.message_type.push((reader |> @lib.read_message() : DescriptorProto))
      (5, _) =>
        msg.enum_type.push(
          (reader |> @lib.read_message() : EnumDescriptorProto),
        )
      (6, _) =>
        msg.service.push(
          (reader |> @lib.read_message() : ServiceDescriptorProto),
        )
      (7, _) =>
        msg.extension.push(
          (reader |> @lib.read_message() : FieldDescriptorProto),
        )
      (8, _) =>
        msg.options = (reader |> @lib.read_message() : FileOptions) |> Some
      (9, _) =>
        msg.source_code_info = (reader |> @lib.read_message() : SourceCodeInfo)
          |> Some
      (12, _) => msg.syntax = reader |> @lib.read_string() |> Some
      (14, _) =>
        msg.edition = reader |> @lib.read_enum() |> Edition::from_enum |> Some
      (_, wire) => reader |> @lib.read_unknown(wire)
    }
  }
  msg
}

///|
pub impl @lib.Write for FileDescriptorProto with write(self, writer) {
  match self.name {
    Some(v) => {
      writer |> @lib.write_varint(10UL)
      writer |> @lib.write_string(v)
    }
    None => ()
  }
  match self.package {
    Some(v) => {
      writer |> @lib.write_varint(18UL)
      writer |> @lib.write_string(v)
    }
    None => ()
  }
  self.dependency
  .iter()
  .each(fn(v) {
    writer |> @lib.write_varint(26UL)
    writer |> @lib.write_string(v)
  })
  self.public_dependency
  .iter()
  .each(fn(v) {
    writer |> @lib.write_varint(80UL)
    writer |> @lib.write_int32(v)
  })
  self.weak_dependency
  .iter()
  .each(fn(v) {
    writer |> @lib.write_varint(88UL)
    writer |> @lib.write_int32(v)
  })
  self.message_type
  .iter()
  .each(fn(v) {
    writer |> @lib.write_varint(34UL)
    writer |> @lib.write_uint32(@lib.size_of(v))
    @lib.Write::write(v, writer)
  })
  self.enum_type
  .iter()
  .each(fn(v) {
    writer |> @lib.write_varint(42UL)
    writer |> @lib.write_uint32(@lib.size_of(v))
    @lib.Write::write(v, writer)
  })
  self.service
  .iter()
  .each(fn(v) {
    writer |> @lib.write_varint(50UL)
    writer |> @lib.write_uint32(@lib.size_of(v))
    @lib.Write::write(v, writer)
  })
  self.extension
  .iter()
  .each(fn(v) {
    writer |> @lib.write_varint(58UL)
    writer |> @lib.write_uint32(@lib.size_of(v))
    @lib.Write::write(v, writer)
  })
  match self.options {
    Some(v) => {
      writer |> @lib.write_varint(66UL)
      writer |> @lib.write_uint32(@lib.size_of(v))
      @lib.Write::write(v, writer)
    }
    None => ()
  }
  match self.source_code_info {
    Some(v) => {
      writer |> @lib.write_varint(74UL)
      writer |> @lib.write_uint32(@lib.size_of(v))
      @lib.Write::write(v, writer)
    }
    None => ()
  }
  match self.syntax {
    Some(v) => {
      writer |> @lib.write_varint(98UL)
      writer |> @lib.write_string(v)
    }
    None => ()
  }
  match self.edition {
    Some(v) => {
      writer |> @lib.write_varint(112UL)
      writer |> @lib.write_enum(v.to_enum())
    }
    None => ()
  }
}

///|
pub impl ToJson for FileDescriptorProto with to_json(self) {
  let json : Map[String, Json] = {}
  match self.name {
    Some(v) => json["name"] = v.to_json()
    _ => ()
  }
  match self.package {
    Some(v) => json["package"] = v.to_json()
    _ => ()
  }
  if self.dependency != Default::default() {
    json["dependency"] = self.dependency.to_json()
  }
  if self.public_dependency != Default::default() {
    json["publicDependency"] = self.public_dependency.to_json()
  }
  if self.weak_dependency != Default::default() {
    json["weakDependency"] = self.weak_dependency.to_json()
  }
  if self.message_type != Default::default() {
    json["messageType"] = self.message_type.to_json()
  }
  if self.enum_type != Default::default() {
    json["enumType"] = self.enum_type.to_json()
  }
  if self.service != Default::default() {
    json["service"] = self.service.to_json()
  }
  if self.extension != Default::default() {
    json["extension"] = self.extension.to_json()
  }
  match self.options {
    Some(v) => json["options"] = v.to_json()
    _ => ()
  }
  match self.source_code_info {
    Some(v) => json["sourceCodeInfo"] = v.to_json()
    _ => ()
  }
  match self.syntax {
    Some(v) => json["syntax"] = v.to_json()
    _ => ()
  }
  match self.edition {
    Some(v) => json["edition"] = v.to_json()
    _ => ()
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for FileDescriptorProto with from_json(
  json : Json,
  path : @json.JsonPath
) -> FileDescriptorProto raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError(
      (path, "Expected an object for FileDescriptorProto"),
    )
  }
  let message = FileDescriptorProto::default()
  for key, value in obj {
    match (key, value) {
      ("name", value) => message.name = Some(@json.from_json(value, path~))
      ("package", value) =>
        message.package = Some(@json.from_json(value, path~))
      ("dependency", Array(value)) =>
        message.dependency = value.map(v => @json.from_json(v, path~))
      ("publicDependency", Array(value)) =>
        message.public_dependency = value.map(v => @json.from_json(v, path~))
      ("weakDependency", Array(value)) =>
        message.weak_dependency = value.map(v => @json.from_json(v, path~))
      ("messageType", Array(value)) =>
        message.message_type = value.map(v => @json.from_json(v, path~))
      ("enumType", Array(value)) =>
        message.enum_type = value.map(v => @json.from_json(v, path~))
      ("service", Array(value)) =>
        message.service = value.map(v => @json.from_json(v, path~))
      ("extension", Array(value)) =>
        message.extension = value.map(v => @json.from_json(v, path~))
      ("options", value) =>
        message.options = Some(@json.from_json(value, path~))
      ("sourceCodeInfo", value) =>
        message.source_code_info = Some(@json.from_json(value, path~))
      ("syntax", value) => message.syntax = Some(@json.from_json(value, path~))
      ("edition", value) =>
        message.edition = Some(@json.from_json(value, path~))
      key => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub(all) struct DescriptorProto_ExtensionRange {
  mut start : Int?
  mut end : Int?
  mut options : ExtensionRangeOptions?
} derive(Eq, Show)

///|
pub impl @lib.Sized for DescriptorProto_ExtensionRange with size_of(self) {
  let mut size = 0U
  match self.start {
    Some(v) => size += 1U + @lib.size_of(v)
    None => ()
  }
  match self.end {
    Some(v) => size += 1U + @lib.size_of(v)
    None => ()
  }
  match self.options {
    Some(v) =>
      size += 1U +
        {
          let size = @lib.size_of(v)
          @lib.size_of(size) + size
        }
    None => ()
  }
  size
}

///|
pub impl Default for DescriptorProto_ExtensionRange with default() -> DescriptorProto_ExtensionRange {
  DescriptorProto_ExtensionRange::{ start: None, end: None, options: None }
}

///|
pub impl @lib.Read for DescriptorProto_ExtensionRange with read(
  reader : &@lib.Reader
) {
  let msg = DescriptorProto_ExtensionRange::default()
  while not(reader |> @lib.is_eof()) {
    match (reader |> @lib.read_tag()) {
      (1, _) => msg.start = reader |> @lib.read_int32() |> Some
      (2, _) => msg.end = reader |> @lib.read_int32() |> Some
      (3, _) =>
        msg.options = (reader |> @lib.read_message() : ExtensionRangeOptions)
          |> Some
      (_, wire) => reader |> @lib.read_unknown(wire)
    }
  }
  msg
}

///|
pub impl @lib.Write for DescriptorProto_ExtensionRange with write(self, writer) {
  match self.start {
    Some(v) => {
      writer |> @lib.write_varint(8UL)
      writer |> @lib.write_int32(v)
    }
    None => ()
  }
  match self.end {
    Some(v) => {
      writer |> @lib.write_varint(16UL)
      writer |> @lib.write_int32(v)
    }
    None => ()
  }
  match self.options {
    Some(v) => {
      writer |> @lib.write_varint(26UL)
      writer |> @lib.write_uint32(@lib.size_of(v))
      @lib.Write::write(v, writer)
    }
    None => ()
  }
}

///|
pub impl ToJson for DescriptorProto_ExtensionRange with to_json(self) {
  let json : Map[String, Json] = {}
  match self.start {
    Some(v) => json["start"] = v.to_json()
    _ => ()
  }
  match self.end {
    Some(v) => json["end"] = v.to_json()
    _ => ()
  }
  match self.options {
    Some(v) => json["options"] = v.to_json()
    _ => ()
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for DescriptorProto_ExtensionRange with from_json(
  json : Json,
  path : @json.JsonPath
) -> DescriptorProto_ExtensionRange raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError(
      (path, "Expected an object for DescriptorProto_ExtensionRange"),
    )
  }
  let message = DescriptorProto_ExtensionRange::default()
  for key, value in obj {
    match (key, value) {
      ("start", value) => message.start = Some(@json.from_json(value, path~))
      ("end", value) => message.end = Some(@json.from_json(value, path~))
      ("options", value) =>
        message.options = Some(@json.from_json(value, path~))
      key => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub(all) struct DescriptorProto_ReservedRange {
  mut start : Int?
  mut end : Int?
} derive(Eq, Show)

///|
pub impl @lib.Sized for DescriptorProto_ReservedRange with size_of(self) {
  let mut size = 0U
  match self.start {
    Some(v) => size += 1U + @lib.size_of(v)
    None => ()
  }
  match self.end {
    Some(v) => size += 1U + @lib.size_of(v)
    None => ()
  }
  size
}

///|
pub impl Default for DescriptorProto_ReservedRange with default() -> DescriptorProto_ReservedRange {
  DescriptorProto_ReservedRange::{ start: None, end: None }
}

///|
pub impl @lib.Read for DescriptorProto_ReservedRange with read(
  reader : &@lib.Reader
) {
  let msg = DescriptorProto_ReservedRange::default()
  while not(reader |> @lib.is_eof()) {
    match (reader |> @lib.read_tag()) {
      (1, _) => msg.start = reader |> @lib.read_int32() |> Some
      (2, _) => msg.end = reader |> @lib.read_int32() |> Some
      (_, wire) => reader |> @lib.read_unknown(wire)
    }
  }
  msg
}

///|
pub impl @lib.Write for DescriptorProto_ReservedRange with write(self, writer) {
  match self.start {
    Some(v) => {
      writer |> @lib.write_varint(8UL)
      writer |> @lib.write_int32(v)
    }
    None => ()
  }
  match self.end {
    Some(v) => {
      writer |> @lib.write_varint(16UL)
      writer |> @lib.write_int32(v)
    }
    None => ()
  }
}

///|
pub impl ToJson for DescriptorProto_ReservedRange with to_json(self) {
  let json : Map[String, Json] = {}
  match self.start {
    Some(v) => json["start"] = v.to_json()
    _ => ()
  }
  match self.end {
    Some(v) => json["end"] = v.to_json()
    _ => ()
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for DescriptorProto_ReservedRange with from_json(
  json : Json,
  path : @json.JsonPath
) -> DescriptorProto_ReservedRange raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError(
      (path, "Expected an object for DescriptorProto_ReservedRange"),
    )
  }
  let message = DescriptorProto_ReservedRange::default()
  for key, value in obj {
    match (key, value) {
      ("start", value) => message.start = Some(@json.from_json(value, path~))
      ("end", value) => message.end = Some(@json.from_json(value, path~))
      key => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub(all) struct DescriptorProto {
  mut name : String?
  mut field : Array[FieldDescriptorProto]
  mut extension : Array[FieldDescriptorProto]
  mut nested_type : Array[DescriptorProto]
  mut enum_type : Array[EnumDescriptorProto]
  mut extension_range : Array[DescriptorProto_ExtensionRange]
  mut oneof_decl : Array[OneofDescriptorProto]
  mut options : MessageOptions?
  mut reserved_range : Array[DescriptorProto_ReservedRange]
  mut reserved_name : Array[String]
} derive(Eq, Show)

///|
pub impl @lib.Sized for DescriptorProto with size_of(self) {
  let mut size = 0U
  match self.name {
    Some(v) =>
      size += 1U +
        {
          let size = @lib.size_of(v)
          @lib.size_of(size) + size
        }
    None => ()
  }
  size += self.field
    .iter()
    .map(@lib.size_of)
    .map(s => 1U + @lib.size_of(s) + s)
    .fold(init=0U, UInt::op_add)
  size += self.extension
    .iter()
    .map(@lib.size_of)
    .map(s => 1U + @lib.size_of(s) + s)
    .fold(init=0U, UInt::op_add)
  size += self.nested_type
    .iter()
    .map(@lib.size_of)
    .map(s => 1U + @lib.size_of(s) + s)
    .fold(init=0U, UInt::op_add)
  size += self.enum_type
    .iter()
    .map(@lib.size_of)
    .map(s => 1U + @lib.size_of(s) + s)
    .fold(init=0U, UInt::op_add)
  size += self.extension_range
    .iter()
    .map(@lib.size_of)
    .map(s => 1U + @lib.size_of(s) + s)
    .fold(init=0U, UInt::op_add)
  size += self.oneof_decl
    .iter()
    .map(@lib.size_of)
    .map(s => 1U + @lib.size_of(s) + s)
    .fold(init=0U, UInt::op_add)
  match self.options {
    Some(v) =>
      size += 1U +
        {
          let size = @lib.size_of(v)
          @lib.size_of(size) + size
        }
    None => ()
  }
  size += self.reserved_range
    .iter()
    .map(@lib.size_of)
    .map(s => 1U + @lib.size_of(s) + s)
    .fold(init=0U, UInt::op_add)
  size += self.reserved_name
    .iter()
    .map(@lib.size_of)
    .map(s => 1U + @lib.size_of(s) + s)
    .fold(init=0U, UInt::op_add)
  size
}

///|
pub impl Default for DescriptorProto with default() -> DescriptorProto {
  DescriptorProto::{
    name: None,
    field: [],
    extension: [],
    nested_type: [],
    enum_type: [],
    extension_range: [],
    oneof_decl: [],
    options: None,
    reserved_range: [],
    reserved_name: [],
  }
}

///|
pub impl @lib.Read for DescriptorProto with read(reader : &@lib.Reader) {
  let msg = DescriptorProto::default()
  while not(reader |> @lib.is_eof()) {
    match (reader |> @lib.read_tag()) {
      (1, _) => msg.name = reader |> @lib.read_string() |> Some
      (2, _) =>
        msg.field.push((reader |> @lib.read_message() : FieldDescriptorProto))
      (6, _) =>
        msg.extension.push(
          (reader |> @lib.read_message() : FieldDescriptorProto),
        )
      (3, _) =>
        msg.nested_type.push((reader |> @lib.read_message() : DescriptorProto))
      (4, _) =>
        msg.enum_type.push(
          (reader |> @lib.read_message() : EnumDescriptorProto),
        )
      (5, _) =>
        msg.extension_range.push(
          (reader |> @lib.read_message() : DescriptorProto_ExtensionRange),
        )
      (8, _) =>
        msg.oneof_decl.push(
          (reader |> @lib.read_message() : OneofDescriptorProto),
        )
      (7, _) =>
        msg.options = (reader |> @lib.read_message() : MessageOptions) |> Some
      (9, _) =>
        msg.reserved_range.push(
          (reader |> @lib.read_message() : DescriptorProto_ReservedRange),
        )
      (10, _) => msg.reserved_name.push(reader |> @lib.read_string())
      (_, wire) => reader |> @lib.read_unknown(wire)
    }
  }
  msg
}

///|
pub impl @lib.Write for DescriptorProto with write(self, writer) {
  match self.name {
    Some(v) => {
      writer |> @lib.write_varint(10UL)
      writer |> @lib.write_string(v)
    }
    None => ()
  }
  self.field
  .iter()
  .each(fn(v) {
    writer |> @lib.write_varint(18UL)
    writer |> @lib.write_uint32(@lib.size_of(v))
    @lib.Write::write(v, writer)
  })
  self.extension
  .iter()
  .each(fn(v) {
    writer |> @lib.write_varint(50UL)
    writer |> @lib.write_uint32(@lib.size_of(v))
    @lib.Write::write(v, writer)
  })
  self.nested_type
  .iter()
  .each(fn(v) {
    writer |> @lib.write_varint(26UL)
    writer |> @lib.write_uint32(@lib.size_of(v))
    @lib.Write::write(v, writer)
  })
  self.enum_type
  .iter()
  .each(fn(v) {
    writer |> @lib.write_varint(34UL)
    writer |> @lib.write_uint32(@lib.size_of(v))
    @lib.Write::write(v, writer)
  })
  self.extension_range
  .iter()
  .each(fn(v) {
    writer |> @lib.write_varint(42UL)
    writer |> @lib.write_uint32(@lib.size_of(v))
    @lib.Write::write(v, writer)
  })
  self.oneof_decl
  .iter()
  .each(fn(v) {
    writer |> @lib.write_varint(66UL)
    writer |> @lib.write_uint32(@lib.size_of(v))
    @lib.Write::write(v, writer)
  })
  match self.options {
    Some(v) => {
      writer |> @lib.write_varint(58UL)
      writer |> @lib.write_uint32(@lib.size_of(v))
      @lib.Write::write(v, writer)
    }
    None => ()
  }
  self.reserved_range
  .iter()
  .each(fn(v) {
    writer |> @lib.write_varint(74UL)
    writer |> @lib.write_uint32(@lib.size_of(v))
    @lib.Write::write(v, writer)
  })
  self.reserved_name
  .iter()
  .each(fn(v) {
    writer |> @lib.write_varint(82UL)
    writer |> @lib.write_string(v)
  })
}

///|
pub impl ToJson for DescriptorProto with to_json(self) {
  let json : Map[String, Json] = {}
  match self.name {
    Some(v) => json["name"] = v.to_json()
    _ => ()
  }
  if self.field != Default::default() {
    json["field"] = self.field.to_json()
  }
  if self.extension != Default::default() {
    json["extension"] = self.extension.to_json()
  }
  if self.nested_type != Default::default() {
    json["nestedType"] = self.nested_type.to_json()
  }
  if self.enum_type != Default::default() {
    json["enumType"] = self.enum_type.to_json()
  }
  if self.extension_range != Default::default() {
    json["extensionRange"] = self.extension_range.to_json()
  }
  if self.oneof_decl != Default::default() {
    json["oneofDecl"] = self.oneof_decl.to_json()
  }
  match self.options {
    Some(v) => json["options"] = v.to_json()
    _ => ()
  }
  if self.reserved_range != Default::default() {
    json["reservedRange"] = self.reserved_range.to_json()
  }
  if self.reserved_name != Default::default() {
    json["reservedName"] = self.reserved_name.to_json()
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for DescriptorProto with from_json(
  json : Json,
  path : @json.JsonPath
) -> DescriptorProto raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError(
      (path, "Expected an object for DescriptorProto"),
    )
  }
  let message = DescriptorProto::default()
  for key, value in obj {
    match (key, value) {
      ("name", value) => message.name = Some(@json.from_json(value, path~))
      ("field", Array(value)) =>
        message.field = value.map(v => @json.from_json(v, path~))
      ("extension", Array(value)) =>
        message.extension = value.map(v => @json.from_json(v, path~))
      ("nestedType", Array(value)) =>
        message.nested_type = value.map(v => @json.from_json(v, path~))
      ("enumType", Array(value)) =>
        message.enum_type = value.map(v => @json.from_json(v, path~))
      ("extensionRange", Array(value)) =>
        message.extension_range = value.map(v => @json.from_json(v, path~))
      ("oneofDecl", Array(value)) =>
        message.oneof_decl = value.map(v => @json.from_json(v, path~))
      ("options", value) =>
        message.options = Some(@json.from_json(value, path~))
      ("reservedRange", Array(value)) =>
        message.reserved_range = value.map(v => @json.from_json(v, path~))
      ("reservedName", Array(value)) =>
        message.reserved_name = value.map(v => @json.from_json(v, path~))
      key => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub(all) enum ExtensionRangeOptions_VerificationState {
  DECLARATION
  UNVERIFIED
} derive(Eq, Show)

///|
pub fn ExtensionRangeOptions_VerificationState::to_enum(
  self : ExtensionRangeOptions_VerificationState
) -> @lib.Enum {
  match self {
    ExtensionRangeOptions_VerificationState::DECLARATION => 0
    ExtensionRangeOptions_VerificationState::UNVERIFIED => 1
  }
}

///|
pub fn ExtensionRangeOptions_VerificationState::from_enum(
  i : @lib.Enum
) -> ExtensionRangeOptions_VerificationState {
  match i.inner() {
    0 => ExtensionRangeOptions_VerificationState::DECLARATION
    1 => ExtensionRangeOptions_VerificationState::UNVERIFIED
    _ => Default::default()
  }
}

///|
pub impl Default for ExtensionRangeOptions_VerificationState with default() -> ExtensionRangeOptions_VerificationState {
  ExtensionRangeOptions_VerificationState::DECLARATION
}

///|
pub impl @lib.Sized for ExtensionRangeOptions_VerificationState with size_of(
  self : ExtensionRangeOptions_VerificationState
) {
  @lib.Sized::size_of(self.to_enum())
}

///|
pub impl @json.FromJson for ExtensionRangeOptions_VerificationState with from_json(
  json : Json,
  path : @json.JsonPath
) -> ExtensionRangeOptions_VerificationState raise {
  match json {
    String(s) if s == "DECLARATION" =>
      ExtensionRangeOptions_VerificationState::DECLARATION
    String(s) if s == "UNVERIFIED" =>
      ExtensionRangeOptions_VerificationState::UNVERIFIED
    Number(n) if n == 0 => ExtensionRangeOptions_VerificationState::DECLARATION
    Number(n) if n == 1 => ExtensionRangeOptions_VerificationState::UNVERIFIED
    _ =>
      raise @json.JsonDecodeError(
        (path, "Expected a number or string for enum"),
      )
  }
}

///|
pub impl ToJson for ExtensionRangeOptions_VerificationState with to_json(
  self : ExtensionRangeOptions_VerificationState
) -> Json {
  match self {
    ExtensionRangeOptions_VerificationState::DECLARATION => "DECLARATION"
    ExtensionRangeOptions_VerificationState::UNVERIFIED => "UNVERIFIED"
  }
}

///|
pub(all) struct ExtensionRangeOptions_Declaration {
  mut number : Int?
  mut full_name : String?
  mut type_ : String?
  mut reserved : Bool?
  mut repeated : Bool?
} derive(Eq, Show)

///|
pub impl @lib.Sized for ExtensionRangeOptions_Declaration with size_of(self) {
  let mut size = 0U
  match self.number {
    Some(v) => size += 1U + @lib.size_of(v)
    None => ()
  }
  match self.full_name {
    Some(v) =>
      size += 1U +
        {
          let size = @lib.size_of(v)
          @lib.size_of(size) + size
        }
    None => ()
  }
  match self.type_ {
    Some(v) =>
      size += 1U +
        {
          let size = @lib.size_of(v)
          @lib.size_of(size) + size
        }
    None => ()
  }
  match self.reserved {
    Some(v) => size += 1U + @lib.size_of(v)
    None => ()
  }
  match self.repeated {
    Some(v) => size += 1U + @lib.size_of(v)
    None => ()
  }
  size
}

///|
pub impl Default for ExtensionRangeOptions_Declaration with default() -> ExtensionRangeOptions_Declaration {
  ExtensionRangeOptions_Declaration::{
    number: None,
    full_name: None,
    type_: None,
    reserved: None,
    repeated: None,
  }
}

///|
pub impl @lib.Read for ExtensionRangeOptions_Declaration with read(
  reader : &@lib.Reader
) {
  let msg = ExtensionRangeOptions_Declaration::default()
  while not(reader |> @lib.is_eof()) {
    match (reader |> @lib.read_tag()) {
      (1, _) => msg.number = reader |> @lib.read_int32() |> Some
      (2, _) => msg.full_name = reader |> @lib.read_string() |> Some
      (3, _) => msg.type_ = reader |> @lib.read_string() |> Some
      (5, _) => msg.reserved = reader |> @lib.read_bool() |> Some
      (6, _) => msg.repeated = reader |> @lib.read_bool() |> Some
      (_, wire) => reader |> @lib.read_unknown(wire)
    }
  }
  msg
}

///|
pub impl @lib.Write for ExtensionRangeOptions_Declaration with write(
  self,
  writer
) {
  match self.number {
    Some(v) => {
      writer |> @lib.write_varint(8UL)
      writer |> @lib.write_int32(v)
    }
    None => ()
  }
  match self.full_name {
    Some(v) => {
      writer |> @lib.write_varint(18UL)
      writer |> @lib.write_string(v)
    }
    None => ()
  }
  match self.type_ {
    Some(v) => {
      writer |> @lib.write_varint(26UL)
      writer |> @lib.write_string(v)
    }
    None => ()
  }
  match self.reserved {
    Some(v) => {
      writer |> @lib.write_varint(40UL)
      writer |> @lib.write_bool(v)
    }
    None => ()
  }
  match self.repeated {
    Some(v) => {
      writer |> @lib.write_varint(48UL)
      writer |> @lib.write_bool(v)
    }
    None => ()
  }
}

///|
pub impl ToJson for ExtensionRangeOptions_Declaration with to_json(self) {
  let json : Map[String, Json] = {}
  match self.number {
    Some(v) => json["number"] = v.to_json()
    _ => ()
  }
  match self.full_name {
    Some(v) => json["fullName"] = v.to_json()
    _ => ()
  }
  match self.type_ {
    Some(v) => json["type"] = v.to_json()
    _ => ()
  }
  match self.reserved {
    Some(v) => json["reserved"] = v.to_json()
    _ => ()
  }
  match self.repeated {
    Some(v) => json["repeated"] = v.to_json()
    _ => ()
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for ExtensionRangeOptions_Declaration with from_json(
  json : Json,
  path : @json.JsonPath
) -> ExtensionRangeOptions_Declaration raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError(
      (path, "Expected an object for ExtensionRangeOptions_Declaration"),
    )
  }
  let message = ExtensionRangeOptions_Declaration::default()
  for key, value in obj {
    match (key, value) {
      ("number", value) => message.number = Some(@json.from_json(value, path~))
      ("fullName", value) =>
        message.full_name = Some(@json.from_json(value, path~))
      ("type", value) => message.type_ = Some(@json.from_json(value, path~))
      ("reserved", value) =>
        message.reserved = Some(@json.from_json(value, path~))
      ("repeated", value) =>
        message.repeated = Some(@json.from_json(value, path~))
      key => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub(all) struct ExtensionRangeOptions {
  mut uninterpreted_option : Array[UninterpretedOption]
  mut declaration : Array[ExtensionRangeOptions_Declaration]
  mut features : FeatureSet?
  mut verification : ExtensionRangeOptions_VerificationState?
} derive(Eq, Show)

///|
pub impl @lib.Sized for ExtensionRangeOptions with size_of(self) {
  let mut size = 0U
  size += self.uninterpreted_option
    .iter()
    .map(@lib.size_of)
    .map(s => 2U + @lib.size_of(s) + s)
    .fold(init=0U, UInt::op_add)
  size += self.declaration
    .iter()
    .map(@lib.size_of)
    .map(s => 1U + @lib.size_of(s) + s)
    .fold(init=0U, UInt::op_add)
  match self.features {
    Some(v) =>
      size += 2U +
        {
          let size = @lib.size_of(v)
          @lib.size_of(size) + size
        }
    None => ()
  }
  match self.verification {
    Some(v) => size += 1U + @lib.size_of(v)
    None => ()
  }
  size
}

///|
pub impl Default for ExtensionRangeOptions with default() -> ExtensionRangeOptions {
  ExtensionRangeOptions::{
    uninterpreted_option: [],
    declaration: [],
    features: None,
    verification: Some(ExtensionRangeOptions_VerificationState::UNVERIFIED),
  }
}

///|
pub impl @lib.Read for ExtensionRangeOptions with read(reader : &@lib.Reader) {
  let msg = ExtensionRangeOptions::default()
  while not(reader |> @lib.is_eof()) {
    match (reader |> @lib.read_tag()) {
      (999, _) =>
        msg.uninterpreted_option.push(
          (reader |> @lib.read_message() : UninterpretedOption),
        )
      (2, _) =>
        msg.declaration.push(
          (reader |> @lib.read_message() : ExtensionRangeOptions_Declaration),
        )
      (50, _) =>
        msg.features = (reader |> @lib.read_message() : FeatureSet) |> Some
      (3, _) =>
        msg.verification = reader
          |> @lib.read_enum()
          |> ExtensionRangeOptions_VerificationState::from_enum
          |> Some
      (_, wire) => reader |> @lib.read_unknown(wire)
    }
  }
  msg
}

///|
pub impl @lib.Write for ExtensionRangeOptions with write(self, writer) {
  self.uninterpreted_option
  .iter()
  .each(fn(v) {
    writer |> @lib.write_varint(7994UL)
    writer |> @lib.write_uint32(@lib.size_of(v))
    @lib.Write::write(v, writer)
  })
  self.declaration
  .iter()
  .each(fn(v) {
    writer |> @lib.write_varint(18UL)
    writer |> @lib.write_uint32(@lib.size_of(v))
    @lib.Write::write(v, writer)
  })
  match self.features {
    Some(v) => {
      writer |> @lib.write_varint(402UL)
      writer |> @lib.write_uint32(@lib.size_of(v))
      @lib.Write::write(v, writer)
    }
    None => ()
  }
  match self.verification {
    Some(v) => {
      writer |> @lib.write_varint(24UL)
      writer |> @lib.write_enum(v.to_enum())
    }
    None => ()
  }
}

///|
pub impl ToJson for ExtensionRangeOptions with to_json(self) {
  let json : Map[String, Json] = {}
  if self.uninterpreted_option != Default::default() {
    json["uninterpretedOption"] = self.uninterpreted_option.to_json()
  }
  if self.declaration != Default::default() {
    json["declaration"] = self.declaration.to_json()
  }
  match self.features {
    Some(v) => json["features"] = v.to_json()
    _ => ()
  }
  match self.verification {
    Some(v) if v != ExtensionRangeOptions_VerificationState::UNVERIFIED =>
      json["verification"] = v.to_json()
    _ => ()
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for ExtensionRangeOptions with from_json(
  json : Json,
  path : @json.JsonPath
) -> ExtensionRangeOptions raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError(
      (path, "Expected an object for ExtensionRangeOptions"),
    )
  }
  let message = ExtensionRangeOptions::default()
  for key, value in obj {
    match (key, value) {
      ("uninterpretedOption", Array(value)) =>
        message.uninterpreted_option = value.map(v => @json.from_json(v, path~))
      ("declaration", Array(value)) =>
        message.declaration = value.map(v => @json.from_json(v, path~))
      ("features", value) =>
        message.features = Some(@json.from_json(value, path~))
      ("verification", value) =>
        message.verification = Some(@json.from_json(value, path~))
      key => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub(all) enum FieldDescriptorProto_Type {
  TYPE_DOUBLE
  TYPE_FLOAT
  TYPE_INT64
  TYPE_UINT64
  TYPE_INT32
  TYPE_FIXED64
  TYPE_FIXED32
  TYPE_BOOL
  TYPE_STRING
  TYPE_GROUP
  TYPE_MESSAGE
  TYPE_BYTES
  TYPE_UINT32
  TYPE_ENUM
  TYPE_SFIXED32
  TYPE_SFIXED64
  TYPE_SINT32
  TYPE_SINT64
} derive(Eq, Show)

///|
pub fn FieldDescriptorProto_Type::to_enum(
  self : FieldDescriptorProto_Type
) -> @lib.Enum {
  match self {
    FieldDescriptorProto_Type::TYPE_DOUBLE => 1
    FieldDescriptorProto_Type::TYPE_FLOAT => 2
    FieldDescriptorProto_Type::TYPE_INT64 => 3
    FieldDescriptorProto_Type::TYPE_UINT64 => 4
    FieldDescriptorProto_Type::TYPE_INT32 => 5
    FieldDescriptorProto_Type::TYPE_FIXED64 => 6
    FieldDescriptorProto_Type::TYPE_FIXED32 => 7
    FieldDescriptorProto_Type::TYPE_BOOL => 8
    FieldDescriptorProto_Type::TYPE_STRING => 9
    FieldDescriptorProto_Type::TYPE_GROUP => 10
    FieldDescriptorProto_Type::TYPE_MESSAGE => 11
    FieldDescriptorProto_Type::TYPE_BYTES => 12
    FieldDescriptorProto_Type::TYPE_UINT32 => 13
    FieldDescriptorProto_Type::TYPE_ENUM => 14
    FieldDescriptorProto_Type::TYPE_SFIXED32 => 15
    FieldDescriptorProto_Type::TYPE_SFIXED64 => 16
    FieldDescriptorProto_Type::TYPE_SINT32 => 17
    FieldDescriptorProto_Type::TYPE_SINT64 => 18
  }
}

///|
pub fn FieldDescriptorProto_Type::from_enum(
  i : @lib.Enum
) -> FieldDescriptorProto_Type {
  match i.inner() {
    1 => FieldDescriptorProto_Type::TYPE_DOUBLE
    2 => FieldDescriptorProto_Type::TYPE_FLOAT
    3 => FieldDescriptorProto_Type::TYPE_INT64
    4 => FieldDescriptorProto_Type::TYPE_UINT64
    5 => FieldDescriptorProto_Type::TYPE_INT32
    6 => FieldDescriptorProto_Type::TYPE_FIXED64
    7 => FieldDescriptorProto_Type::TYPE_FIXED32
    8 => FieldDescriptorProto_Type::TYPE_BOOL
    9 => FieldDescriptorProto_Type::TYPE_STRING
    10 => FieldDescriptorProto_Type::TYPE_GROUP
    11 => FieldDescriptorProto_Type::TYPE_MESSAGE
    12 => FieldDescriptorProto_Type::TYPE_BYTES
    13 => FieldDescriptorProto_Type::TYPE_UINT32
    14 => FieldDescriptorProto_Type::TYPE_ENUM
    15 => FieldDescriptorProto_Type::TYPE_SFIXED32
    16 => FieldDescriptorProto_Type::TYPE_SFIXED64
    17 => FieldDescriptorProto_Type::TYPE_SINT32
    18 => FieldDescriptorProto_Type::TYPE_SINT64
    _ => Default::default()
  }
}

///|
pub impl Default for FieldDescriptorProto_Type with default() -> FieldDescriptorProto_Type {
  FieldDescriptorProto_Type::TYPE_DOUBLE
}

///|
pub impl @lib.Sized for FieldDescriptorProto_Type with size_of(
  self : FieldDescriptorProto_Type
) {
  @lib.Sized::size_of(self.to_enum())
}

///|
pub impl @json.FromJson for FieldDescriptorProto_Type with from_json(
  json : Json,
  path : @json.JsonPath
) -> FieldDescriptorProto_Type raise {
  match json {
    String(s) if s == "TYPE_DOUBLE" => FieldDescriptorProto_Type::TYPE_DOUBLE
    String(s) if s == "TYPE_FLOAT" => FieldDescriptorProto_Type::TYPE_FLOAT
    String(s) if s == "TYPE_INT64" => FieldDescriptorProto_Type::TYPE_INT64
    String(s) if s == "TYPE_UINT64" => FieldDescriptorProto_Type::TYPE_UINT64
    String(s) if s == "TYPE_INT32" => FieldDescriptorProto_Type::TYPE_INT32
    String(s) if s == "TYPE_FIXED64" => FieldDescriptorProto_Type::TYPE_FIXED64
    String(s) if s == "TYPE_FIXED32" => FieldDescriptorProto_Type::TYPE_FIXED32
    String(s) if s == "TYPE_BOOL" => FieldDescriptorProto_Type::TYPE_BOOL
    String(s) if s == "TYPE_STRING" => FieldDescriptorProto_Type::TYPE_STRING
    String(s) if s == "TYPE_GROUP" => FieldDescriptorProto_Type::TYPE_GROUP
    String(s) if s == "TYPE_MESSAGE" => FieldDescriptorProto_Type::TYPE_MESSAGE
    String(s) if s == "TYPE_BYTES" => FieldDescriptorProto_Type::TYPE_BYTES
    String(s) if s == "TYPE_UINT32" => FieldDescriptorProto_Type::TYPE_UINT32
    String(s) if s == "TYPE_ENUM" => FieldDescriptorProto_Type::TYPE_ENUM
    String(s) if s == "TYPE_SFIXED32" =>
      FieldDescriptorProto_Type::TYPE_SFIXED32
    String(s) if s == "TYPE_SFIXED64" =>
      FieldDescriptorProto_Type::TYPE_SFIXED64
    String(s) if s == "TYPE_SINT32" => FieldDescriptorProto_Type::TYPE_SINT32
    String(s) if s == "TYPE_SINT64" => FieldDescriptorProto_Type::TYPE_SINT64
    Number(n) if n == 1 => FieldDescriptorProto_Type::TYPE_DOUBLE
    Number(n) if n == 2 => FieldDescriptorProto_Type::TYPE_FLOAT
    Number(n) if n == 3 => FieldDescriptorProto_Type::TYPE_INT64
    Number(n) if n == 4 => FieldDescriptorProto_Type::TYPE_UINT64
    Number(n) if n == 5 => FieldDescriptorProto_Type::TYPE_INT32
    Number(n) if n == 6 => FieldDescriptorProto_Type::TYPE_FIXED64
    Number(n) if n == 7 => FieldDescriptorProto_Type::TYPE_FIXED32
    Number(n) if n == 8 => FieldDescriptorProto_Type::TYPE_BOOL
    Number(n) if n == 9 => FieldDescriptorProto_Type::TYPE_STRING
    Number(n) if n == 10 => FieldDescriptorProto_Type::TYPE_GROUP
    Number(n) if n == 11 => FieldDescriptorProto_Type::TYPE_MESSAGE
    Number(n) if n == 12 => FieldDescriptorProto_Type::TYPE_BYTES
    Number(n) if n == 13 => FieldDescriptorProto_Type::TYPE_UINT32
    Number(n) if n == 14 => FieldDescriptorProto_Type::TYPE_ENUM
    Number(n) if n == 15 => FieldDescriptorProto_Type::TYPE_SFIXED32
    Number(n) if n == 16 => FieldDescriptorProto_Type::TYPE_SFIXED64
    Number(n) if n == 17 => FieldDescriptorProto_Type::TYPE_SINT32
    Number(n) if n == 18 => FieldDescriptorProto_Type::TYPE_SINT64
    _ =>
      raise @json.JsonDecodeError(
        (path, "Expected a number or string for enum"),
      )
  }
}

///|
pub impl ToJson for FieldDescriptorProto_Type with to_json(
  self : FieldDescriptorProto_Type
) -> Json {
  match self {
    FieldDescriptorProto_Type::TYPE_DOUBLE => "TYPE_DOUBLE"
    FieldDescriptorProto_Type::TYPE_FLOAT => "TYPE_FLOAT"
    FieldDescriptorProto_Type::TYPE_INT64 => "TYPE_INT64"
    FieldDescriptorProto_Type::TYPE_UINT64 => "TYPE_UINT64"
    FieldDescriptorProto_Type::TYPE_INT32 => "TYPE_INT32"
    FieldDescriptorProto_Type::TYPE_FIXED64 => "TYPE_FIXED64"
    FieldDescriptorProto_Type::TYPE_FIXED32 => "TYPE_FIXED32"
    FieldDescriptorProto_Type::TYPE_BOOL => "TYPE_BOOL"
    FieldDescriptorProto_Type::TYPE_STRING => "TYPE_STRING"
    FieldDescriptorProto_Type::TYPE_GROUP => "TYPE_GROUP"
    FieldDescriptorProto_Type::TYPE_MESSAGE => "TYPE_MESSAGE"
    FieldDescriptorProto_Type::TYPE_BYTES => "TYPE_BYTES"
    FieldDescriptorProto_Type::TYPE_UINT32 => "TYPE_UINT32"
    FieldDescriptorProto_Type::TYPE_ENUM => "TYPE_ENUM"
    FieldDescriptorProto_Type::TYPE_SFIXED32 => "TYPE_SFIXED32"
    FieldDescriptorProto_Type::TYPE_SFIXED64 => "TYPE_SFIXED64"
    FieldDescriptorProto_Type::TYPE_SINT32 => "TYPE_SINT32"
    FieldDescriptorProto_Type::TYPE_SINT64 => "TYPE_SINT64"
  }
}

///|
pub(all) enum FieldDescriptorProto_Label {
  LABEL_OPTIONAL
  LABEL_REPEATED
  LABEL_REQUIRED
} derive(Eq, Show)

///|
pub fn FieldDescriptorProto_Label::to_enum(
  self : FieldDescriptorProto_Label
) -> @lib.Enum {
  match self {
    FieldDescriptorProto_Label::LABEL_OPTIONAL => 1
    FieldDescriptorProto_Label::LABEL_REPEATED => 3
    FieldDescriptorProto_Label::LABEL_REQUIRED => 2
  }
}

///|
pub fn FieldDescriptorProto_Label::from_enum(
  i : @lib.Enum
) -> FieldDescriptorProto_Label {
  match i.inner() {
    1 => FieldDescriptorProto_Label::LABEL_OPTIONAL
    3 => FieldDescriptorProto_Label::LABEL_REPEATED
    2 => FieldDescriptorProto_Label::LABEL_REQUIRED
    _ => Default::default()
  }
}

///|
pub impl Default for FieldDescriptorProto_Label with default() -> FieldDescriptorProto_Label {
  FieldDescriptorProto_Label::LABEL_OPTIONAL
}

///|
pub impl @lib.Sized for FieldDescriptorProto_Label with size_of(
  self : FieldDescriptorProto_Label
) {
  @lib.Sized::size_of(self.to_enum())
}

///|
pub impl @json.FromJson for FieldDescriptorProto_Label with from_json(
  json : Json,
  path : @json.JsonPath
) -> FieldDescriptorProto_Label raise {
  match json {
    String(s) if s == "LABEL_OPTIONAL" =>
      FieldDescriptorProto_Label::LABEL_OPTIONAL
    String(s) if s == "LABEL_REPEATED" =>
      FieldDescriptorProto_Label::LABEL_REPEATED
    String(s) if s == "LABEL_REQUIRED" =>
      FieldDescriptorProto_Label::LABEL_REQUIRED
    Number(n) if n == 1 => FieldDescriptorProto_Label::LABEL_OPTIONAL
    Number(n) if n == 3 => FieldDescriptorProto_Label::LABEL_REPEATED
    Number(n) if n == 2 => FieldDescriptorProto_Label::LABEL_REQUIRED
    _ =>
      raise @json.JsonDecodeError(
        (path, "Expected a number or string for enum"),
      )
  }
}

///|
pub impl ToJson for FieldDescriptorProto_Label with to_json(
  self : FieldDescriptorProto_Label
) -> Json {
  match self {
    FieldDescriptorProto_Label::LABEL_OPTIONAL => "LABEL_OPTIONAL"
    FieldDescriptorProto_Label::LABEL_REPEATED => "LABEL_REPEATED"
    FieldDescriptorProto_Label::LABEL_REQUIRED => "LABEL_REQUIRED"
  }
}

///|
pub(all) struct FieldDescriptorProto {
  mut name : String?
  mut number : Int?
  mut label : FieldDescriptorProto_Label?
  mut type_ : FieldDescriptorProto_Type?
  mut type_name : String?
  mut extendee : String?
  mut default_value : String?
  mut oneof_index : Int?
  mut json_name : String?
  mut options : FieldOptions?
  mut proto3_optional : Bool?
} derive(Eq, Show)

///|
pub impl @lib.Sized for FieldDescriptorProto with size_of(self) {
  let mut size = 0U
  match self.name {
    Some(v) =>
      size += 1U +
        {
          let size = @lib.size_of(v)
          @lib.size_of(size) + size
        }
    None => ()
  }
  match self.number {
    Some(v) => size += 1U + @lib.size_of(v)
    None => ()
  }
  match self.label {
    Some(v) => size += 1U + @lib.size_of(v)
    None => ()
  }
  match self.type_ {
    Some(v) => size += 1U + @lib.size_of(v)
    None => ()
  }
  match self.type_name {
    Some(v) =>
      size += 1U +
        {
          let size = @lib.size_of(v)
          @lib.size_of(size) + size
        }
    None => ()
  }
  match self.extendee {
    Some(v) =>
      size += 1U +
        {
          let size = @lib.size_of(v)
          @lib.size_of(size) + size
        }
    None => ()
  }
  match self.default_value {
    Some(v) =>
      size += 1U +
        {
          let size = @lib.size_of(v)
          @lib.size_of(size) + size
        }
    None => ()
  }
  match self.oneof_index {
    Some(v) => size += 1U + @lib.size_of(v)
    None => ()
  }
  match self.json_name {
    Some(v) =>
      size += 1U +
        {
          let size = @lib.size_of(v)
          @lib.size_of(size) + size
        }
    None => ()
  }
  match self.options {
    Some(v) =>
      size += 1U +
        {
          let size = @lib.size_of(v)
          @lib.size_of(size) + size
        }
    None => ()
  }
  match self.proto3_optional {
    Some(v) => size += 2U + @lib.size_of(v)
    None => ()
  }
  size
}

///|
pub impl Default for FieldDescriptorProto with default() -> FieldDescriptorProto {
  FieldDescriptorProto::{
    name: None,
    number: None,
    label: None,
    type_: None,
    type_name: None,
    extendee: None,
    default_value: None,
    oneof_index: None,
    json_name: None,
    options: None,
    proto3_optional: None,
  }
}

///|
pub impl @lib.Read for FieldDescriptorProto with read(reader : &@lib.Reader) {
  let msg = FieldDescriptorProto::default()
  while not(reader |> @lib.is_eof()) {
    match (reader |> @lib.read_tag()) {
      (1, _) => msg.name = reader |> @lib.read_string() |> Some
      (3, _) => msg.number = reader |> @lib.read_int32() |> Some
      (4, _) =>
        msg.label = reader
          |> @lib.read_enum()
          |> FieldDescriptorProto_Label::from_enum
          |> Some
      (5, _) =>
        msg.type_ = reader
          |> @lib.read_enum()
          |> FieldDescriptorProto_Type::from_enum
          |> Some
      (6, _) => msg.type_name = reader |> @lib.read_string() |> Some
      (2, _) => msg.extendee = reader |> @lib.read_string() |> Some
      (7, _) => msg.default_value = reader |> @lib.read_string() |> Some
      (9, _) => msg.oneof_index = reader |> @lib.read_int32() |> Some
      (10, _) => msg.json_name = reader |> @lib.read_string() |> Some
      (8, _) =>
        msg.options = (reader |> @lib.read_message() : FieldOptions) |> Some
      (17, _) => msg.proto3_optional = reader |> @lib.read_bool() |> Some
      (_, wire) => reader |> @lib.read_unknown(wire)
    }
  }
  msg
}

///|
pub impl @lib.Write for FieldDescriptorProto with write(self, writer) {
  match self.name {
    Some(v) => {
      writer |> @lib.write_varint(10UL)
      writer |> @lib.write_string(v)
    }
    None => ()
  }
  match self.number {
    Some(v) => {
      writer |> @lib.write_varint(24UL)
      writer |> @lib.write_int32(v)
    }
    None => ()
  }
  match self.label {
    Some(v) => {
      writer |> @lib.write_varint(32UL)
      writer |> @lib.write_enum(v.to_enum())
    }
    None => ()
  }
  match self.type_ {
    Some(v) => {
      writer |> @lib.write_varint(40UL)
      writer |> @lib.write_enum(v.to_enum())
    }
    None => ()
  }
  match self.type_name {
    Some(v) => {
      writer |> @lib.write_varint(50UL)
      writer |> @lib.write_string(v)
    }
    None => ()
  }
  match self.extendee {
    Some(v) => {
      writer |> @lib.write_varint(18UL)
      writer |> @lib.write_string(v)
    }
    None => ()
  }
  match self.default_value {
    Some(v) => {
      writer |> @lib.write_varint(58UL)
      writer |> @lib.write_string(v)
    }
    None => ()
  }
  match self.oneof_index {
    Some(v) => {
      writer |> @lib.write_varint(72UL)
      writer |> @lib.write_int32(v)
    }
    None => ()
  }
  match self.json_name {
    Some(v) => {
      writer |> @lib.write_varint(82UL)
      writer |> @lib.write_string(v)
    }
    None => ()
  }
  match self.options {
    Some(v) => {
      writer |> @lib.write_varint(66UL)
      writer |> @lib.write_uint32(@lib.size_of(v))
      @lib.Write::write(v, writer)
    }
    None => ()
  }
  match self.proto3_optional {
    Some(v) => {
      writer |> @lib.write_varint(136UL)
      writer |> @lib.write_bool(v)
    }
    None => ()
  }
}

///|
pub impl ToJson for FieldDescriptorProto with to_json(self) {
  let json : Map[String, Json] = {}
  match self.name {
    Some(v) => json["name"] = v.to_json()
    _ => ()
  }
  match self.number {
    Some(v) => json["number"] = v.to_json()
    _ => ()
  }
  match self.label {
    Some(v) => json["label"] = v.to_json()
    _ => ()
  }
  match self.type_ {
    Some(v) => json["type"] = v.to_json()
    _ => ()
  }
  match self.type_name {
    Some(v) => json["typeName"] = v.to_json()
    _ => ()
  }
  match self.extendee {
    Some(v) => json["extendee"] = v.to_json()
    _ => ()
  }
  match self.default_value {
    Some(v) => json["defaultValue"] = v.to_json()
    _ => ()
  }
  match self.oneof_index {
    Some(v) => json["oneofIndex"] = v.to_json()
    _ => ()
  }
  match self.json_name {
    Some(v) => json["jsonName"] = v.to_json()
    _ => ()
  }
  match self.options {
    Some(v) => json["options"] = v.to_json()
    _ => ()
  }
  match self.proto3_optional {
    Some(v) => json["proto3Optional"] = v.to_json()
    _ => ()
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for FieldDescriptorProto with from_json(
  json : Json,
  path : @json.JsonPath
) -> FieldDescriptorProto raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError(
      (path, "Expected an object for FieldDescriptorProto"),
    )
  }
  let message = FieldDescriptorProto::default()
  for key, value in obj {
    match (key, value) {
      ("name", value) => message.name = Some(@json.from_json(value, path~))
      ("number", value) => message.number = Some(@json.from_json(value, path~))
      ("label", value) => message.label = Some(@json.from_json(value, path~))
      ("type", value) => message.type_ = Some(@json.from_json(value, path~))
      ("typeName", value) =>
        message.type_name = Some(@json.from_json(value, path~))
      ("extendee", value) =>
        message.extendee = Some(@json.from_json(value, path~))
      ("defaultValue", value) =>
        message.default_value = Some(@json.from_json(value, path~))
      ("oneofIndex", value) =>
        message.oneof_index = Some(@json.from_json(value, path~))
      ("jsonName", value) =>
        message.json_name = Some(@json.from_json(value, path~))
      ("options", value) =>
        message.options = Some(@json.from_json(value, path~))
      ("proto3Optional", value) =>
        message.proto3_optional = Some(@json.from_json(value, path~))
      key => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub(all) struct OneofDescriptorProto {
  mut name : String?
  mut options : OneofOptions?
} derive(Eq, Show)

///|
pub impl @lib.Sized for OneofDescriptorProto with size_of(self) {
  let mut size = 0U
  match self.name {
    Some(v) =>
      size += 1U +
        {
          let size = @lib.size_of(v)
          @lib.size_of(size) + size
        }
    None => ()
  }
  match self.options {
    Some(v) =>
      size += 1U +
        {
          let size = @lib.size_of(v)
          @lib.size_of(size) + size
        }
    None => ()
  }
  size
}

///|
pub impl Default for OneofDescriptorProto with default() -> OneofDescriptorProto {
  OneofDescriptorProto::{ name: None, options: None }
}

///|
pub impl @lib.Read for OneofDescriptorProto with read(reader : &@lib.Reader) {
  let msg = OneofDescriptorProto::default()
  while not(reader |> @lib.is_eof()) {
    match (reader |> @lib.read_tag()) {
      (1, _) => msg.name = reader |> @lib.read_string() |> Some
      (2, _) =>
        msg.options = (reader |> @lib.read_message() : OneofOptions) |> Some
      (_, wire) => reader |> @lib.read_unknown(wire)
    }
  }
  msg
}

///|
pub impl @lib.Write for OneofDescriptorProto with write(self, writer) {
  match self.name {
    Some(v) => {
      writer |> @lib.write_varint(10UL)
      writer |> @lib.write_string(v)
    }
    None => ()
  }
  match self.options {
    Some(v) => {
      writer |> @lib.write_varint(18UL)
      writer |> @lib.write_uint32(@lib.size_of(v))
      @lib.Write::write(v, writer)
    }
    None => ()
  }
}

///|
pub impl ToJson for OneofDescriptorProto with to_json(self) {
  let json : Map[String, Json] = {}
  match self.name {
    Some(v) => json["name"] = v.to_json()
    _ => ()
  }
  match self.options {
    Some(v) => json["options"] = v.to_json()
    _ => ()
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for OneofDescriptorProto with from_json(
  json : Json,
  path : @json.JsonPath
) -> OneofDescriptorProto raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError(
      (path, "Expected an object for OneofDescriptorProto"),
    )
  }
  let message = OneofDescriptorProto::default()
  for key, value in obj {
    match (key, value) {
      ("name", value) => message.name = Some(@json.from_json(value, path~))
      ("options", value) =>
        message.options = Some(@json.from_json(value, path~))
      key => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub(all) struct EnumDescriptorProto_EnumReservedRange {
  mut start : Int?
  mut end : Int?
} derive(Eq, Show)

///|
pub impl @lib.Sized for EnumDescriptorProto_EnumReservedRange with size_of(self) {
  let mut size = 0U
  match self.start {
    Some(v) => size += 1U + @lib.size_of(v)
    None => ()
  }
  match self.end {
    Some(v) => size += 1U + @lib.size_of(v)
    None => ()
  }
  size
}

///|
pub impl Default for EnumDescriptorProto_EnumReservedRange with default() -> EnumDescriptorProto_EnumReservedRange {
  EnumDescriptorProto_EnumReservedRange::{ start: None, end: None }
}

///|
pub impl @lib.Read for EnumDescriptorProto_EnumReservedRange with read(
  reader : &@lib.Reader
) {
  let msg = EnumDescriptorProto_EnumReservedRange::default()
  while not(reader |> @lib.is_eof()) {
    match (reader |> @lib.read_tag()) {
      (1, _) => msg.start = reader |> @lib.read_int32() |> Some
      (2, _) => msg.end = reader |> @lib.read_int32() |> Some
      (_, wire) => reader |> @lib.read_unknown(wire)
    }
  }
  msg
}

///|
pub impl @lib.Write for EnumDescriptorProto_EnumReservedRange with write(
  self,
  writer
) {
  match self.start {
    Some(v) => {
      writer |> @lib.write_varint(8UL)
      writer |> @lib.write_int32(v)
    }
    None => ()
  }
  match self.end {
    Some(v) => {
      writer |> @lib.write_varint(16UL)
      writer |> @lib.write_int32(v)
    }
    None => ()
  }
}

///|
pub impl ToJson for EnumDescriptorProto_EnumReservedRange with to_json(self) {
  let json : Map[String, Json] = {}
  match self.start {
    Some(v) => json["start"] = v.to_json()
    _ => ()
  }
  match self.end {
    Some(v) => json["end"] = v.to_json()
    _ => ()
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for EnumDescriptorProto_EnumReservedRange with from_json(
  json : Json,
  path : @json.JsonPath
) -> EnumDescriptorProto_EnumReservedRange raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError(
      (path, "Expected an object for EnumDescriptorProto_EnumReservedRange"),
    )
  }
  let message = EnumDescriptorProto_EnumReservedRange::default()
  for key, value in obj {
    match (key, value) {
      ("start", value) => message.start = Some(@json.from_json(value, path~))
      ("end", value) => message.end = Some(@json.from_json(value, path~))
      key => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub(all) struct EnumDescriptorProto {
  mut name : String?
  mut value : Array[EnumValueDescriptorProto]
  mut options : EnumOptions?
  mut reserved_range : Array[EnumDescriptorProto_EnumReservedRange]
  mut reserved_name : Array[String]
} derive(Eq, Show)

///|
pub impl @lib.Sized for EnumDescriptorProto with size_of(self) {
  let mut size = 0U
  match self.name {
    Some(v) =>
      size += 1U +
        {
          let size = @lib.size_of(v)
          @lib.size_of(size) + size
        }
    None => ()
  }
  size += self.value
    .iter()
    .map(@lib.size_of)
    .map(s => 1U + @lib.size_of(s) + s)
    .fold(init=0U, UInt::op_add)
  match self.options {
    Some(v) =>
      size += 1U +
        {
          let size = @lib.size_of(v)
          @lib.size_of(size) + size
        }
    None => ()
  }
  size += self.reserved_range
    .iter()
    .map(@lib.size_of)
    .map(s => 1U + @lib.size_of(s) + s)
    .fold(init=0U, UInt::op_add)
  size += self.reserved_name
    .iter()
    .map(@lib.size_of)
    .map(s => 1U + @lib.size_of(s) + s)
    .fold(init=0U, UInt::op_add)
  size
}

///|
pub impl Default for EnumDescriptorProto with default() -> EnumDescriptorProto {
  EnumDescriptorProto::{
    name: None,
    value: [],
    options: None,
    reserved_range: [],
    reserved_name: [],
  }
}

///|
pub impl @lib.Read for EnumDescriptorProto with read(reader : &@lib.Reader) {
  let msg = EnumDescriptorProto::default()
  while not(reader |> @lib.is_eof()) {
    match (reader |> @lib.read_tag()) {
      (1, _) => msg.name = reader |> @lib.read_string() |> Some
      (2, _) =>
        msg.value.push(
          (reader |> @lib.read_message() : EnumValueDescriptorProto),
        )
      (3, _) =>
        msg.options = (reader |> @lib.read_message() : EnumOptions) |> Some
      (4, _) =>
        msg.reserved_range.push(
          (reader |> @lib.read_message() : EnumDescriptorProto_EnumReservedRange),
        )
      (5, _) => msg.reserved_name.push(reader |> @lib.read_string())
      (_, wire) => reader |> @lib.read_unknown(wire)
    }
  }
  msg
}

///|
pub impl @lib.Write for EnumDescriptorProto with write(self, writer) {
  match self.name {
    Some(v) => {
      writer |> @lib.write_varint(10UL)
      writer |> @lib.write_string(v)
    }
    None => ()
  }
  self.value
  .iter()
  .each(fn(v) {
    writer |> @lib.write_varint(18UL)
    writer |> @lib.write_uint32(@lib.size_of(v))
    @lib.Write::write(v, writer)
  })
  match self.options {
    Some(v) => {
      writer |> @lib.write_varint(26UL)
      writer |> @lib.write_uint32(@lib.size_of(v))
      @lib.Write::write(v, writer)
    }
    None => ()
  }
  self.reserved_range
  .iter()
  .each(fn(v) {
    writer |> @lib.write_varint(34UL)
    writer |> @lib.write_uint32(@lib.size_of(v))
    @lib.Write::write(v, writer)
  })
  self.reserved_name
  .iter()
  .each(fn(v) {
    writer |> @lib.write_varint(42UL)
    writer |> @lib.write_string(v)
  })
}

///|
pub impl ToJson for EnumDescriptorProto with to_json(self) {
  let json : Map[String, Json] = {}
  match self.name {
    Some(v) => json["name"] = v.to_json()
    _ => ()
  }
  if self.value != Default::default() {
    json["value"] = self.value.to_json()
  }
  match self.options {
    Some(v) => json["options"] = v.to_json()
    _ => ()
  }
  if self.reserved_range != Default::default() {
    json["reservedRange"] = self.reserved_range.to_json()
  }
  if self.reserved_name != Default::default() {
    json["reservedName"] = self.reserved_name.to_json()
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for EnumDescriptorProto with from_json(
  json : Json,
  path : @json.JsonPath
) -> EnumDescriptorProto raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError(
      (path, "Expected an object for EnumDescriptorProto"),
    )
  }
  let message = EnumDescriptorProto::default()
  for key, value in obj {
    match (key, value) {
      ("name", value) => message.name = Some(@json.from_json(value, path~))
      ("value", Array(value)) =>
        message.value = value.map(v => @json.from_json(v, path~))
      ("options", value) =>
        message.options = Some(@json.from_json(value, path~))
      ("reservedRange", Array(value)) =>
        message.reserved_range = value.map(v => @json.from_json(v, path~))
      ("reservedName", Array(value)) =>
        message.reserved_name = value.map(v => @json.from_json(v, path~))
      key => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub(all) struct EnumValueDescriptorProto {
  mut name : String?
  mut number : Int?
  mut options : EnumValueOptions?
} derive(Eq, Show)

///|
pub impl @lib.Sized for EnumValueDescriptorProto with size_of(self) {
  let mut size = 0U
  match self.name {
    Some(v) =>
      size += 1U +
        {
          let size = @lib.size_of(v)
          @lib.size_of(size) + size
        }
    None => ()
  }
  match self.number {
    Some(v) => size += 1U + @lib.size_of(v)
    None => ()
  }
  match self.options {
    Some(v) =>
      size += 1U +
        {
          let size = @lib.size_of(v)
          @lib.size_of(size) + size
        }
    None => ()
  }
  size
}

///|
pub impl Default for EnumValueDescriptorProto with default() -> EnumValueDescriptorProto {
  EnumValueDescriptorProto::{ name: None, number: None, options: None }
}

///|
pub impl @lib.Read for EnumValueDescriptorProto with read(reader : &@lib.Reader) {
  let msg = EnumValueDescriptorProto::default()
  while not(reader |> @lib.is_eof()) {
    match (reader |> @lib.read_tag()) {
      (1, _) => msg.name = reader |> @lib.read_string() |> Some
      (2, _) => msg.number = reader |> @lib.read_int32() |> Some
      (3, _) =>
        msg.options = (reader |> @lib.read_message() : EnumValueOptions) |> Some
      (_, wire) => reader |> @lib.read_unknown(wire)
    }
  }
  msg
}

///|
pub impl @lib.Write for EnumValueDescriptorProto with write(self, writer) {
  match self.name {
    Some(v) => {
      writer |> @lib.write_varint(10UL)
      writer |> @lib.write_string(v)
    }
    None => ()
  }
  match self.number {
    Some(v) => {
      writer |> @lib.write_varint(16UL)
      writer |> @lib.write_int32(v)
    }
    None => ()
  }
  match self.options {
    Some(v) => {
      writer |> @lib.write_varint(26UL)
      writer |> @lib.write_uint32(@lib.size_of(v))
      @lib.Write::write(v, writer)
    }
    None => ()
  }
}

///|
pub impl ToJson for EnumValueDescriptorProto with to_json(self) {
  let json : Map[String, Json] = {}
  match self.name {
    Some(v) => json["name"] = v.to_json()
    _ => ()
  }
  match self.number {
    Some(v) => json["number"] = v.to_json()
    _ => ()
  }
  match self.options {
    Some(v) => json["options"] = v.to_json()
    _ => ()
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for EnumValueDescriptorProto with from_json(
  json : Json,
  path : @json.JsonPath
) -> EnumValueDescriptorProto raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError(
      (path, "Expected an object for EnumValueDescriptorProto"),
    )
  }
  let message = EnumValueDescriptorProto::default()
  for key, value in obj {
    match (key, value) {
      ("name", value) => message.name = Some(@json.from_json(value, path~))
      ("number", value) => message.number = Some(@json.from_json(value, path~))
      ("options", value) =>
        message.options = Some(@json.from_json(value, path~))
      key => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub(all) struct ServiceDescriptorProto {
  mut name : String?
  mut method_ : Array[MethodDescriptorProto]
  mut options : ServiceOptions?
} derive(Eq, Show)

///|
pub impl @lib.Sized for ServiceDescriptorProto with size_of(self) {
  let mut size = 0U
  match self.name {
    Some(v) =>
      size += 1U +
        {
          let size = @lib.size_of(v)
          @lib.size_of(size) + size
        }
    None => ()
  }
  size += self.method_
    .iter()
    .map(@lib.size_of)
    .map(s => 1U + @lib.size_of(s) + s)
    .fold(init=0U, UInt::op_add)
  match self.options {
    Some(v) =>
      size += 1U +
        {
          let size = @lib.size_of(v)
          @lib.size_of(size) + size
        }
    None => ()
  }
  size
}

///|
pub impl Default for ServiceDescriptorProto with default() -> ServiceDescriptorProto {
  ServiceDescriptorProto::{ name: None, method_: [], options: None }
}

///|
pub impl @lib.Read for ServiceDescriptorProto with read(reader : &@lib.Reader) {
  let msg = ServiceDescriptorProto::default()
  while not(reader |> @lib.is_eof()) {
    match (reader |> @lib.read_tag()) {
      (1, _) => msg.name = reader |> @lib.read_string() |> Some
      (2, _) =>
        msg.method_.push(
          (reader |> @lib.read_message() : MethodDescriptorProto),
        )
      (3, _) =>
        msg.options = (reader |> @lib.read_message() : ServiceOptions) |> Some
      (_, wire) => reader |> @lib.read_unknown(wire)
    }
  }
  msg
}

///|
pub impl @lib.Write for ServiceDescriptorProto with write(self, writer) {
  match self.name {
    Some(v) => {
      writer |> @lib.write_varint(10UL)
      writer |> @lib.write_string(v)
    }
    None => ()
  }
  self.method_
  .iter()
  .each(fn(v) {
    writer |> @lib.write_varint(18UL)
    writer |> @lib.write_uint32(@lib.size_of(v))
    @lib.Write::write(v, writer)
  })
  match self.options {
    Some(v) => {
      writer |> @lib.write_varint(26UL)
      writer |> @lib.write_uint32(@lib.size_of(v))
      @lib.Write::write(v, writer)
    }
    None => ()
  }
}

///|
pub impl ToJson for ServiceDescriptorProto with to_json(self) {
  let json : Map[String, Json] = {}
  match self.name {
    Some(v) => json["name"] = v.to_json()
    _ => ()
  }
  if self.method_ != Default::default() {
    json["method"] = self.method_.to_json()
  }
  match self.options {
    Some(v) => json["options"] = v.to_json()
    _ => ()
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for ServiceDescriptorProto with from_json(
  json : Json,
  path : @json.JsonPath
) -> ServiceDescriptorProto raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError(
      (path, "Expected an object for ServiceDescriptorProto"),
    )
  }
  let message = ServiceDescriptorProto::default()
  for key, value in obj {
    match (key, value) {
      ("name", value) => message.name = Some(@json.from_json(value, path~))
      ("method", Array(value)) =>
        message.method_ = value.map(v => @json.from_json(v, path~))
      ("options", value) =>
        message.options = Some(@json.from_json(value, path~))
      key => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub(all) struct MethodDescriptorProto {
  mut name : String?
  mut input_type : String?
  mut output_type : String?
  mut options : MethodOptions?
  mut client_streaming : Bool?
  mut server_streaming : Bool?
} derive(Eq, Show)

///|
pub impl @lib.Sized for MethodDescriptorProto with size_of(self) {
  let mut size = 0U
  match self.name {
    Some(v) =>
      size += 1U +
        {
          let size = @lib.size_of(v)
          @lib.size_of(size) + size
        }
    None => ()
  }
  match self.input_type {
    Some(v) =>
      size += 1U +
        {
          let size = @lib.size_of(v)
          @lib.size_of(size) + size
        }
    None => ()
  }
  match self.output_type {
    Some(v) =>
      size += 1U +
        {
          let size = @lib.size_of(v)
          @lib.size_of(size) + size
        }
    None => ()
  }
  match self.options {
    Some(v) =>
      size += 1U +
        {
          let size = @lib.size_of(v)
          @lib.size_of(size) + size
        }
    None => ()
  }
  match self.client_streaming {
    Some(v) => size += 1U + @lib.size_of(v)
    None => ()
  }
  match self.server_streaming {
    Some(v) => size += 1U + @lib.size_of(v)
    None => ()
  }
  size
}

///|
pub impl Default for MethodDescriptorProto with default() -> MethodDescriptorProto {
  MethodDescriptorProto::{
    name: None,
    input_type: None,
    output_type: None,
    options: None,
    client_streaming: Some(false),
    server_streaming: Some(false),
  }
}

///|
pub impl @lib.Read for MethodDescriptorProto with read(reader : &@lib.Reader) {
  let msg = MethodDescriptorProto::default()
  while not(reader |> @lib.is_eof()) {
    match (reader |> @lib.read_tag()) {
      (1, _) => msg.name = reader |> @lib.read_string() |> Some
      (2, _) => msg.input_type = reader |> @lib.read_string() |> Some
      (3, _) => msg.output_type = reader |> @lib.read_string() |> Some
      (4, _) =>
        msg.options = (reader |> @lib.read_message() : MethodOptions) |> Some
      (5, _) => msg.client_streaming = reader |> @lib.read_bool() |> Some
      (6, _) => msg.server_streaming = reader |> @lib.read_bool() |> Some
      (_, wire) => reader |> @lib.read_unknown(wire)
    }
  }
  msg
}

///|
pub impl @lib.Write for MethodDescriptorProto with write(self, writer) {
  match self.name {
    Some(v) => {
      writer |> @lib.write_varint(10UL)
      writer |> @lib.write_string(v)
    }
    None => ()
  }
  match self.input_type {
    Some(v) => {
      writer |> @lib.write_varint(18UL)
      writer |> @lib.write_string(v)
    }
    None => ()
  }
  match self.output_type {
    Some(v) => {
      writer |> @lib.write_varint(26UL)
      writer |> @lib.write_string(v)
    }
    None => ()
  }
  match self.options {
    Some(v) => {
      writer |> @lib.write_varint(34UL)
      writer |> @lib.write_uint32(@lib.size_of(v))
      @lib.Write::write(v, writer)
    }
    None => ()
  }
  match self.client_streaming {
    Some(v) => {
      writer |> @lib.write_varint(40UL)
      writer |> @lib.write_bool(v)
    }
    None => ()
  }
  match self.server_streaming {
    Some(v) => {
      writer |> @lib.write_varint(48UL)
      writer |> @lib.write_bool(v)
    }
    None => ()
  }
}

///|
pub impl ToJson for MethodDescriptorProto with to_json(self) {
  let json : Map[String, Json] = {}
  match self.name {
    Some(v) => json["name"] = v.to_json()
    _ => ()
  }
  match self.input_type {
    Some(v) => json["inputType"] = v.to_json()
    _ => ()
  }
  match self.output_type {
    Some(v) => json["outputType"] = v.to_json()
    _ => ()
  }
  match self.options {
    Some(v) => json["options"] = v.to_json()
    _ => ()
  }
  match self.client_streaming {
    Some(v) if v != false => json["clientStreaming"] = v.to_json()
    _ => ()
  }
  match self.server_streaming {
    Some(v) if v != false => json["serverStreaming"] = v.to_json()
    _ => ()
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for MethodDescriptorProto with from_json(
  json : Json,
  path : @json.JsonPath
) -> MethodDescriptorProto raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError(
      (path, "Expected an object for MethodDescriptorProto"),
    )
  }
  let message = MethodDescriptorProto::default()
  for key, value in obj {
    match (key, value) {
      ("name", value) => message.name = Some(@json.from_json(value, path~))
      ("inputType", value) =>
        message.input_type = Some(@json.from_json(value, path~))
      ("outputType", value) =>
        message.output_type = Some(@json.from_json(value, path~))
      ("options", value) =>
        message.options = Some(@json.from_json(value, path~))
      ("clientStreaming", value) =>
        message.client_streaming = Some(@json.from_json(value, path~))
      ("serverStreaming", value) =>
        message.server_streaming = Some(@json.from_json(value, path~))
      key => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub(all) enum FileOptions_OptimizeMode {
  SPEED
  CODE_SIZE
  LITE_RUNTIME
} derive(Eq, Show)

///|
pub fn FileOptions_OptimizeMode::to_enum(
  self : FileOptions_OptimizeMode
) -> @lib.Enum {
  match self {
    FileOptions_OptimizeMode::SPEED => 1
    FileOptions_OptimizeMode::CODE_SIZE => 2
    FileOptions_OptimizeMode::LITE_RUNTIME => 3
  }
}

///|
pub fn FileOptions_OptimizeMode::from_enum(
  i : @lib.Enum
) -> FileOptions_OptimizeMode {
  match i.inner() {
    1 => FileOptions_OptimizeMode::SPEED
    2 => FileOptions_OptimizeMode::CODE_SIZE
    3 => FileOptions_OptimizeMode::LITE_RUNTIME
    _ => Default::default()
  }
}

///|
pub impl Default for FileOptions_OptimizeMode with default() -> FileOptions_OptimizeMode {
  FileOptions_OptimizeMode::SPEED
}

///|
pub impl @lib.Sized for FileOptions_OptimizeMode with size_of(
  self : FileOptions_OptimizeMode
) {
  @lib.Sized::size_of(self.to_enum())
}

///|
pub impl @json.FromJson for FileOptions_OptimizeMode with from_json(
  json : Json,
  path : @json.JsonPath
) -> FileOptions_OptimizeMode raise {
  match json {
    String(s) if s == "SPEED" => FileOptions_OptimizeMode::SPEED
    String(s) if s == "CODE_SIZE" => FileOptions_OptimizeMode::CODE_SIZE
    String(s) if s == "LITE_RUNTIME" => FileOptions_OptimizeMode::LITE_RUNTIME
    Number(n) if n == 1 => FileOptions_OptimizeMode::SPEED
    Number(n) if n == 2 => FileOptions_OptimizeMode::CODE_SIZE
    Number(n) if n == 3 => FileOptions_OptimizeMode::LITE_RUNTIME
    _ =>
      raise @json.JsonDecodeError(
        (path, "Expected a number or string for enum"),
      )
  }
}

///|
pub impl ToJson for FileOptions_OptimizeMode with to_json(
  self : FileOptions_OptimizeMode
) -> Json {
  match self {
    FileOptions_OptimizeMode::SPEED => "SPEED"
    FileOptions_OptimizeMode::CODE_SIZE => "CODE_SIZE"
    FileOptions_OptimizeMode::LITE_RUNTIME => "LITE_RUNTIME"
  }
}

///|
pub(all) struct FileOptions {
  mut java_package : String?
  mut java_outer_classname : String?
  mut java_multiple_files : Bool?
  mut java_generate_equals_and_hash : Bool?
  mut java_string_check_utf8 : Bool?
  mut optimize_for : FileOptions_OptimizeMode?
  mut go_package : String?
  mut cc_generic_services : Bool?
  mut java_generic_services : Bool?
  mut py_generic_services : Bool?
  mut deprecated : Bool?
  mut cc_enable_arenas : Bool?
  mut objc_class_prefix : String?
  mut csharp_namespace : String?
  mut swift_prefix : String?
  mut php_class_prefix : String?
  mut php_namespace : String?
  mut php_metadata_namespace : String?
  mut ruby_package : String?
  mut features : FeatureSet?
  mut uninterpreted_option : Array[UninterpretedOption]
} derive(Eq, Show)

///|
pub impl @lib.Sized for FileOptions with size_of(self) {
  let mut size = 0U
  match self.java_package {
    Some(v) =>
      size += 1U +
        {
          let size = @lib.size_of(v)
          @lib.size_of(size) + size
        }
    None => ()
  }
  match self.java_outer_classname {
    Some(v) =>
      size += 1U +
        {
          let size = @lib.size_of(v)
          @lib.size_of(size) + size
        }
    None => ()
  }
  match self.java_multiple_files {
    Some(v) => size += 1U + @lib.size_of(v)
    None => ()
  }
  match self.java_generate_equals_and_hash {
    Some(v) => size += 2U + @lib.size_of(v)
    None => ()
  }
  match self.java_string_check_utf8 {
    Some(v) => size += 2U + @lib.size_of(v)
    None => ()
  }
  match self.optimize_for {
    Some(v) => size += 1U + @lib.size_of(v)
    None => ()
  }
  match self.go_package {
    Some(v) =>
      size += 1U +
        {
          let size = @lib.size_of(v)
          @lib.size_of(size) + size
        }
    None => ()
  }
  match self.cc_generic_services {
    Some(v) => size += 2U + @lib.size_of(v)
    None => ()
  }
  match self.java_generic_services {
    Some(v) => size += 2U + @lib.size_of(v)
    None => ()
  }
  match self.py_generic_services {
    Some(v) => size += 2U + @lib.size_of(v)
    None => ()
  }
  match self.deprecated {
    Some(v) => size += 2U + @lib.size_of(v)
    None => ()
  }
  match self.cc_enable_arenas {
    Some(v) => size += 2U + @lib.size_of(v)
    None => ()
  }
  match self.objc_class_prefix {
    Some(v) =>
      size += 2U +
        {
          let size = @lib.size_of(v)
          @lib.size_of(size) + size
        }
    None => ()
  }
  match self.csharp_namespace {
    Some(v) =>
      size += 2U +
        {
          let size = @lib.size_of(v)
          @lib.size_of(size) + size
        }
    None => ()
  }
  match self.swift_prefix {
    Some(v) =>
      size += 2U +
        {
          let size = @lib.size_of(v)
          @lib.size_of(size) + size
        }
    None => ()
  }
  match self.php_class_prefix {
    Some(v) =>
      size += 2U +
        {
          let size = @lib.size_of(v)
          @lib.size_of(size) + size
        }
    None => ()
  }
  match self.php_namespace {
    Some(v) =>
      size += 2U +
        {
          let size = @lib.size_of(v)
          @lib.size_of(size) + size
        }
    None => ()
  }
  match self.php_metadata_namespace {
    Some(v) =>
      size += 2U +
        {
          let size = @lib.size_of(v)
          @lib.size_of(size) + size
        }
    None => ()
  }
  match self.ruby_package {
    Some(v) =>
      size += 2U +
        {
          let size = @lib.size_of(v)
          @lib.size_of(size) + size
        }
    None => ()
  }
  match self.features {
    Some(v) =>
      size += 2U +
        {
          let size = @lib.size_of(v)
          @lib.size_of(size) + size
        }
    None => ()
  }
  size += self.uninterpreted_option
    .iter()
    .map(@lib.size_of)
    .map(s => 2U + @lib.size_of(s) + s)
    .fold(init=0U, UInt::op_add)
  size
}

///|
pub impl Default for FileOptions with default() -> FileOptions {
  FileOptions::{
    java_package: None,
    java_outer_classname: None,
    java_multiple_files: Some(false),
    java_generate_equals_and_hash: None,
    java_string_check_utf8: Some(false),
    optimize_for: Some(FileOptions_OptimizeMode::SPEED),
    go_package: None,
    cc_generic_services: Some(false),
    java_generic_services: Some(false),
    py_generic_services: Some(false),
    deprecated: Some(false),
    cc_enable_arenas: Some(true),
    objc_class_prefix: None,
    csharp_namespace: None,
    swift_prefix: None,
    php_class_prefix: None,
    php_namespace: None,
    php_metadata_namespace: None,
    ruby_package: None,
    features: None,
    uninterpreted_option: [],
  }
}

///|
pub impl @lib.Read for FileOptions with read(reader : &@lib.Reader) {
  let msg = FileOptions::default()
  while not(reader |> @lib.is_eof()) {
    match (reader |> @lib.read_tag()) {
      (1, _) => msg.java_package = reader |> @lib.read_string() |> Some
      (8, _) => msg.java_outer_classname = reader |> @lib.read_string() |> Some
      (10, _) => msg.java_multiple_files = reader |> @lib.read_bool() |> Some
      (20, _) =>
        msg.java_generate_equals_and_hash = reader |> @lib.read_bool() |> Some
      (27, _) => msg.java_string_check_utf8 = reader |> @lib.read_bool() |> Some
      (9, _) =>
        msg.optimize_for = reader
          |> @lib.read_enum()
          |> FileOptions_OptimizeMode::from_enum
          |> Some
      (11, _) => msg.go_package = reader |> @lib.read_string() |> Some
      (16, _) => msg.cc_generic_services = reader |> @lib.read_bool() |> Some
      (17, _) => msg.java_generic_services = reader |> @lib.read_bool() |> Some
      (18, _) => msg.py_generic_services = reader |> @lib.read_bool() |> Some
      (23, _) => msg.deprecated = reader |> @lib.read_bool() |> Some
      (31, _) => msg.cc_enable_arenas = reader |> @lib.read_bool() |> Some
      (36, _) => msg.objc_class_prefix = reader |> @lib.read_string() |> Some
      (37, _) => msg.csharp_namespace = reader |> @lib.read_string() |> Some
      (39, _) => msg.swift_prefix = reader |> @lib.read_string() |> Some
      (40, _) => msg.php_class_prefix = reader |> @lib.read_string() |> Some
      (41, _) => msg.php_namespace = reader |> @lib.read_string() |> Some
      (44, _) =>
        msg.php_metadata_namespace = reader |> @lib.read_string() |> Some
      (45, _) => msg.ruby_package = reader |> @lib.read_string() |> Some
      (50, _) =>
        msg.features = (reader |> @lib.read_message() : FeatureSet) |> Some
      (999, _) =>
        msg.uninterpreted_option.push(
          (reader |> @lib.read_message() : UninterpretedOption),
        )
      (_, wire) => reader |> @lib.read_unknown(wire)
    }
  }
  msg
}

///|
pub impl @lib.Write for FileOptions with write(self, writer) {
  match self.java_package {
    Some(v) => {
      writer |> @lib.write_varint(10UL)
      writer |> @lib.write_string(v)
    }
    None => ()
  }
  match self.java_outer_classname {
    Some(v) => {
      writer |> @lib.write_varint(66UL)
      writer |> @lib.write_string(v)
    }
    None => ()
  }
  match self.java_multiple_files {
    Some(v) => {
      writer |> @lib.write_varint(80UL)
      writer |> @lib.write_bool(v)
    }
    None => ()
  }
  match self.java_generate_equals_and_hash {
    Some(v) => {
      writer |> @lib.write_varint(160UL)
      writer |> @lib.write_bool(v)
    }
    None => ()
  }
  match self.java_string_check_utf8 {
    Some(v) => {
      writer |> @lib.write_varint(216UL)
      writer |> @lib.write_bool(v)
    }
    None => ()
  }
  match self.optimize_for {
    Some(v) => {
      writer |> @lib.write_varint(72UL)
      writer |> @lib.write_enum(v.to_enum())
    }
    None => ()
  }
  match self.go_package {
    Some(v) => {
      writer |> @lib.write_varint(90UL)
      writer |> @lib.write_string(v)
    }
    None => ()
  }
  match self.cc_generic_services {
    Some(v) => {
      writer |> @lib.write_varint(128UL)
      writer |> @lib.write_bool(v)
    }
    None => ()
  }
  match self.java_generic_services {
    Some(v) => {
      writer |> @lib.write_varint(136UL)
      writer |> @lib.write_bool(v)
    }
    None => ()
  }
  match self.py_generic_services {
    Some(v) => {
      writer |> @lib.write_varint(144UL)
      writer |> @lib.write_bool(v)
    }
    None => ()
  }
  match self.deprecated {
    Some(v) => {
      writer |> @lib.write_varint(184UL)
      writer |> @lib.write_bool(v)
    }
    None => ()
  }
  match self.cc_enable_arenas {
    Some(v) => {
      writer |> @lib.write_varint(248UL)
      writer |> @lib.write_bool(v)
    }
    None => ()
  }
  match self.objc_class_prefix {
    Some(v) => {
      writer |> @lib.write_varint(290UL)
      writer |> @lib.write_string(v)
    }
    None => ()
  }
  match self.csharp_namespace {
    Some(v) => {
      writer |> @lib.write_varint(298UL)
      writer |> @lib.write_string(v)
    }
    None => ()
  }
  match self.swift_prefix {
    Some(v) => {
      writer |> @lib.write_varint(314UL)
      writer |> @lib.write_string(v)
    }
    None => ()
  }
  match self.php_class_prefix {
    Some(v) => {
      writer |> @lib.write_varint(322UL)
      writer |> @lib.write_string(v)
    }
    None => ()
  }
  match self.php_namespace {
    Some(v) => {
      writer |> @lib.write_varint(330UL)
      writer |> @lib.write_string(v)
    }
    None => ()
  }
  match self.php_metadata_namespace {
    Some(v) => {
      writer |> @lib.write_varint(354UL)
      writer |> @lib.write_string(v)
    }
    None => ()
  }
  match self.ruby_package {
    Some(v) => {
      writer |> @lib.write_varint(362UL)
      writer |> @lib.write_string(v)
    }
    None => ()
  }
  match self.features {
    Some(v) => {
      writer |> @lib.write_varint(402UL)
      writer |> @lib.write_uint32(@lib.size_of(v))
      @lib.Write::write(v, writer)
    }
    None => ()
  }
  self.uninterpreted_option
  .iter()
  .each(fn(v) {
    writer |> @lib.write_varint(7994UL)
    writer |> @lib.write_uint32(@lib.size_of(v))
    @lib.Write::write(v, writer)
  })
}

///|
pub impl ToJson for FileOptions with to_json(self) {
  let json : Map[String, Json] = {}
  match self.java_package {
    Some(v) => json["javaPackage"] = v.to_json()
    _ => ()
  }
  match self.java_outer_classname {
    Some(v) => json["javaOuterClassname"] = v.to_json()
    _ => ()
  }
  match self.java_multiple_files {
    Some(v) if v != false => json["javaMultipleFiles"] = v.to_json()
    _ => ()
  }
  match self.java_generate_equals_and_hash {
    Some(v) => json["javaGenerateEqualsAndHash"] = v.to_json()
    _ => ()
  }
  match self.java_string_check_utf8 {
    Some(v) if v != false => json["javaStringCheckUtf8"] = v.to_json()
    _ => ()
  }
  match self.optimize_for {
    Some(v) if v != FileOptions_OptimizeMode::SPEED =>
      json["optimizeFor"] = v.to_json()
    _ => ()
  }
  match self.go_package {
    Some(v) => json["goPackage"] = v.to_json()
    _ => ()
  }
  match self.cc_generic_services {
    Some(v) if v != false => json["ccGenericServices"] = v.to_json()
    _ => ()
  }
  match self.java_generic_services {
    Some(v) if v != false => json["javaGenericServices"] = v.to_json()
    _ => ()
  }
  match self.py_generic_services {
    Some(v) if v != false => json["pyGenericServices"] = v.to_json()
    _ => ()
  }
  match self.deprecated {
    Some(v) if v != false => json["deprecated"] = v.to_json()
    _ => ()
  }
  match self.cc_enable_arenas {
    Some(v) if v != true => json["ccEnableArenas"] = v.to_json()
    _ => ()
  }
  match self.objc_class_prefix {
    Some(v) => json["objcClassPrefix"] = v.to_json()
    _ => ()
  }
  match self.csharp_namespace {
    Some(v) => json["csharpNamespace"] = v.to_json()
    _ => ()
  }
  match self.swift_prefix {
    Some(v) => json["swiftPrefix"] = v.to_json()
    _ => ()
  }
  match self.php_class_prefix {
    Some(v) => json["phpClassPrefix"] = v.to_json()
    _ => ()
  }
  match self.php_namespace {
    Some(v) => json["phpNamespace"] = v.to_json()
    _ => ()
  }
  match self.php_metadata_namespace {
    Some(v) => json["phpMetadataNamespace"] = v.to_json()
    _ => ()
  }
  match self.ruby_package {
    Some(v) => json["rubyPackage"] = v.to_json()
    _ => ()
  }
  match self.features {
    Some(v) => json["features"] = v.to_json()
    _ => ()
  }
  if self.uninterpreted_option != Default::default() {
    json["uninterpretedOption"] = self.uninterpreted_option.to_json()
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for FileOptions with from_json(
  json : Json,
  path : @json.JsonPath
) -> FileOptions raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError((path, "Expected an object for FileOptions"))
  }
  let message = FileOptions::default()
  for key, value in obj {
    match (key, value) {
      ("javaPackage", value) =>
        message.java_package = Some(@json.from_json(value, path~))
      ("javaOuterClassname", value) =>
        message.java_outer_classname = Some(@json.from_json(value, path~))
      ("javaMultipleFiles", value) =>
        message.java_multiple_files = Some(@json.from_json(value, path~))
      ("javaGenerateEqualsAndHash", value) =>
        message.java_generate_equals_and_hash = Some(
          @json.from_json(value, path~),
        )
      ("javaStringCheckUtf8", value) =>
        message.java_string_check_utf8 = Some(@json.from_json(value, path~))
      ("optimizeFor", value) =>
        message.optimize_for = Some(@json.from_json(value, path~))
      ("goPackage", value) =>
        message.go_package = Some(@json.from_json(value, path~))
      ("ccGenericServices", value) =>
        message.cc_generic_services = Some(@json.from_json(value, path~))
      ("javaGenericServices", value) =>
        message.java_generic_services = Some(@json.from_json(value, path~))
      ("pyGenericServices", value) =>
        message.py_generic_services = Some(@json.from_json(value, path~))
      ("deprecated", value) =>
        message.deprecated = Some(@json.from_json(value, path~))
      ("ccEnableArenas", value) =>
        message.cc_enable_arenas = Some(@json.from_json(value, path~))
      ("objcClassPrefix", value) =>
        message.objc_class_prefix = Some(@json.from_json(value, path~))
      ("csharpNamespace", value) =>
        message.csharp_namespace = Some(@json.from_json(value, path~))
      ("swiftPrefix", value) =>
        message.swift_prefix = Some(@json.from_json(value, path~))
      ("phpClassPrefix", value) =>
        message.php_class_prefix = Some(@json.from_json(value, path~))
      ("phpNamespace", value) =>
        message.php_namespace = Some(@json.from_json(value, path~))
      ("phpMetadataNamespace", value) =>
        message.php_metadata_namespace = Some(@json.from_json(value, path~))
      ("rubyPackage", value) =>
        message.ruby_package = Some(@json.from_json(value, path~))
      ("features", value) =>
        message.features = Some(@json.from_json(value, path~))
      ("uninterpretedOption", Array(value)) =>
        message.uninterpreted_option = value.map(v => @json.from_json(v, path~))
      key => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub(all) struct MessageOptions {
  mut message_set_wire_format : Bool?
  mut no_standard_descriptor_accessor : Bool?
  mut deprecated : Bool?
  mut map_entry : Bool?
  mut deprecated_legacy_json_field_conflicts : Bool?
  mut features : FeatureSet?
  mut uninterpreted_option : Array[UninterpretedOption]
} derive(Eq, Show)

///|
pub impl @lib.Sized for MessageOptions with size_of(self) {
  let mut size = 0U
  match self.message_set_wire_format {
    Some(v) => size += 1U + @lib.size_of(v)
    None => ()
  }
  match self.no_standard_descriptor_accessor {
    Some(v) => size += 1U + @lib.size_of(v)
    None => ()
  }
  match self.deprecated {
    Some(v) => size += 1U + @lib.size_of(v)
    None => ()
  }
  match self.map_entry {
    Some(v) => size += 1U + @lib.size_of(v)
    None => ()
  }
  match self.deprecated_legacy_json_field_conflicts {
    Some(v) => size += 1U + @lib.size_of(v)
    None => ()
  }
  match self.features {
    Some(v) =>
      size += 1U +
        {
          let size = @lib.size_of(v)
          @lib.size_of(size) + size
        }
    None => ()
  }
  size += self.uninterpreted_option
    .iter()
    .map(@lib.size_of)
    .map(s => 2U + @lib.size_of(s) + s)
    .fold(init=0U, UInt::op_add)
  size
}

///|
pub impl Default for MessageOptions with default() -> MessageOptions {
  MessageOptions::{
    message_set_wire_format: Some(false),
    no_standard_descriptor_accessor: Some(false),
    deprecated: Some(false),
    map_entry: None,
    deprecated_legacy_json_field_conflicts: None,
    features: None,
    uninterpreted_option: [],
  }
}

///|
pub impl @lib.Read for MessageOptions with read(reader : &@lib.Reader) {
  let msg = MessageOptions::default()
  while not(reader |> @lib.is_eof()) {
    match (reader |> @lib.read_tag()) {
      (1, _) => msg.message_set_wire_format = reader |> @lib.read_bool() |> Some
      (2, _) =>
        msg.no_standard_descriptor_accessor = reader |> @lib.read_bool() |> Some
      (3, _) => msg.deprecated = reader |> @lib.read_bool() |> Some
      (7, _) => msg.map_entry = reader |> @lib.read_bool() |> Some
      (11, _) =>
        msg.deprecated_legacy_json_field_conflicts = reader
          |> @lib.read_bool()
          |> Some
      (12, _) =>
        msg.features = (reader |> @lib.read_message() : FeatureSet) |> Some
      (999, _) =>
        msg.uninterpreted_option.push(
          (reader |> @lib.read_message() : UninterpretedOption),
        )
      (_, wire) => reader |> @lib.read_unknown(wire)
    }
  }
  msg
}

///|
pub impl @lib.Write for MessageOptions with write(self, writer) {
  match self.message_set_wire_format {
    Some(v) => {
      writer |> @lib.write_varint(8UL)
      writer |> @lib.write_bool(v)
    }
    None => ()
  }
  match self.no_standard_descriptor_accessor {
    Some(v) => {
      writer |> @lib.write_varint(16UL)
      writer |> @lib.write_bool(v)
    }
    None => ()
  }
  match self.deprecated {
    Some(v) => {
      writer |> @lib.write_varint(24UL)
      writer |> @lib.write_bool(v)
    }
    None => ()
  }
  match self.map_entry {
    Some(v) => {
      writer |> @lib.write_varint(56UL)
      writer |> @lib.write_bool(v)
    }
    None => ()
  }
  match self.deprecated_legacy_json_field_conflicts {
    Some(v) => {
      writer |> @lib.write_varint(88UL)
      writer |> @lib.write_bool(v)
    }
    None => ()
  }
  match self.features {
    Some(v) => {
      writer |> @lib.write_varint(98UL)
      writer |> @lib.write_uint32(@lib.size_of(v))
      @lib.Write::write(v, writer)
    }
    None => ()
  }
  self.uninterpreted_option
  .iter()
  .each(fn(v) {
    writer |> @lib.write_varint(7994UL)
    writer |> @lib.write_uint32(@lib.size_of(v))
    @lib.Write::write(v, writer)
  })
}

///|
pub impl ToJson for MessageOptions with to_json(self) {
  let json : Map[String, Json] = {}
  match self.message_set_wire_format {
    Some(v) if v != false => json["messageSetWireFormat"] = v.to_json()
    _ => ()
  }
  match self.no_standard_descriptor_accessor {
    Some(v) if v != false => json["noStandardDescriptorAccessor"] = v.to_json()
    _ => ()
  }
  match self.deprecated {
    Some(v) if v != false => json["deprecated"] = v.to_json()
    _ => ()
  }
  match self.map_entry {
    Some(v) => json["mapEntry"] = v.to_json()
    _ => ()
  }
  match self.deprecated_legacy_json_field_conflicts {
    Some(v) => json["deprecatedLegacyJsonFieldConflicts"] = v.to_json()
    _ => ()
  }
  match self.features {
    Some(v) => json["features"] = v.to_json()
    _ => ()
  }
  if self.uninterpreted_option != Default::default() {
    json["uninterpretedOption"] = self.uninterpreted_option.to_json()
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for MessageOptions with from_json(
  json : Json,
  path : @json.JsonPath
) -> MessageOptions raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError((path, "Expected an object for MessageOptions"))
  }
  let message = MessageOptions::default()
  for key, value in obj {
    match (key, value) {
      ("messageSetWireFormat", value) =>
        message.message_set_wire_format = Some(@json.from_json(value, path~))
      ("noStandardDescriptorAccessor", value) =>
        message.no_standard_descriptor_accessor = Some(
          @json.from_json(value, path~),
        )
      ("deprecated", value) =>
        message.deprecated = Some(@json.from_json(value, path~))
      ("mapEntry", value) =>
        message.map_entry = Some(@json.from_json(value, path~))
      ("deprecatedLegacyJsonFieldConflicts", value) =>
        message.deprecated_legacy_json_field_conflicts = Some(
          @json.from_json(value, path~),
        )
      ("features", value) =>
        message.features = Some(@json.from_json(value, path~))
      ("uninterpretedOption", Array(value)) =>
        message.uninterpreted_option = value.map(v => @json.from_json(v, path~))
      key => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub(all) enum FieldOptions_CType {
  STRING
  CORD
  STRING_PIECE
} derive(Eq, Show)

///|
pub fn FieldOptions_CType::to_enum(self : FieldOptions_CType) -> @lib.Enum {
  match self {
    FieldOptions_CType::STRING => 0
    FieldOptions_CType::CORD => 1
    FieldOptions_CType::STRING_PIECE => 2
  }
}

///|
pub fn FieldOptions_CType::from_enum(i : @lib.Enum) -> FieldOptions_CType {
  match i.inner() {
    0 => FieldOptions_CType::STRING
    1 => FieldOptions_CType::CORD
    2 => FieldOptions_CType::STRING_PIECE
    _ => Default::default()
  }
}

///|
pub impl Default for FieldOptions_CType with default() -> FieldOptions_CType {
  FieldOptions_CType::STRING
}

///|
pub impl @lib.Sized for FieldOptions_CType with size_of(
  self : FieldOptions_CType
) {
  @lib.Sized::size_of(self.to_enum())
}

///|
pub impl @json.FromJson for FieldOptions_CType with from_json(
  json : Json,
  path : @json.JsonPath
) -> FieldOptions_CType raise {
  match json {
    String(s) if s == "STRING" => FieldOptions_CType::STRING
    String(s) if s == "CORD" => FieldOptions_CType::CORD
    String(s) if s == "STRING_PIECE" => FieldOptions_CType::STRING_PIECE
    Number(n) if n == 0 => FieldOptions_CType::STRING
    Number(n) if n == 1 => FieldOptions_CType::CORD
    Number(n) if n == 2 => FieldOptions_CType::STRING_PIECE
    _ =>
      raise @json.JsonDecodeError(
        (path, "Expected a number or string for enum"),
      )
  }
}

///|
pub impl ToJson for FieldOptions_CType with to_json(self : FieldOptions_CType) -> Json {
  match self {
    FieldOptions_CType::STRING => "STRING"
    FieldOptions_CType::CORD => "CORD"
    FieldOptions_CType::STRING_PIECE => "STRING_PIECE"
  }
}

///|
pub(all) enum FieldOptions_JSType {
  JS_NORMAL
  JS_STRING
  JS_NUMBER
} derive(Eq, Show)

///|
pub fn FieldOptions_JSType::to_enum(self : FieldOptions_JSType) -> @lib.Enum {
  match self {
    FieldOptions_JSType::JS_NORMAL => 0
    FieldOptions_JSType::JS_STRING => 1
    FieldOptions_JSType::JS_NUMBER => 2
  }
}

///|
pub fn FieldOptions_JSType::from_enum(i : @lib.Enum) -> FieldOptions_JSType {
  match i.inner() {
    0 => FieldOptions_JSType::JS_NORMAL
    1 => FieldOptions_JSType::JS_STRING
    2 => FieldOptions_JSType::JS_NUMBER
    _ => Default::default()
  }
}

///|
pub impl Default for FieldOptions_JSType with default() -> FieldOptions_JSType {
  FieldOptions_JSType::JS_NORMAL
}

///|
pub impl @lib.Sized for FieldOptions_JSType with size_of(
  self : FieldOptions_JSType
) {
  @lib.Sized::size_of(self.to_enum())
}

///|
pub impl @json.FromJson for FieldOptions_JSType with from_json(
  json : Json,
  path : @json.JsonPath
) -> FieldOptions_JSType raise {
  match json {
    String(s) if s == "JS_NORMAL" => FieldOptions_JSType::JS_NORMAL
    String(s) if s == "JS_STRING" => FieldOptions_JSType::JS_STRING
    String(s) if s == "JS_NUMBER" => FieldOptions_JSType::JS_NUMBER
    Number(n) if n == 0 => FieldOptions_JSType::JS_NORMAL
    Number(n) if n == 1 => FieldOptions_JSType::JS_STRING
    Number(n) if n == 2 => FieldOptions_JSType::JS_NUMBER
    _ =>
      raise @json.JsonDecodeError(
        (path, "Expected a number or string for enum"),
      )
  }
}

///|
pub impl ToJson for FieldOptions_JSType with to_json(self : FieldOptions_JSType) -> Json {
  match self {
    FieldOptions_JSType::JS_NORMAL => "JS_NORMAL"
    FieldOptions_JSType::JS_STRING => "JS_STRING"
    FieldOptions_JSType::JS_NUMBER => "JS_NUMBER"
  }
}

///|
pub(all) enum FieldOptions_OptionRetention {
  RETENTION_UNKNOWN
  RETENTION_RUNTIME
  RETENTION_SOURCE
} derive(Eq, Show)

///|
pub fn FieldOptions_OptionRetention::to_enum(
  self : FieldOptions_OptionRetention
) -> @lib.Enum {
  match self {
    FieldOptions_OptionRetention::RETENTION_UNKNOWN => 0
    FieldOptions_OptionRetention::RETENTION_RUNTIME => 1
    FieldOptions_OptionRetention::RETENTION_SOURCE => 2
  }
}

///|
pub fn FieldOptions_OptionRetention::from_enum(
  i : @lib.Enum
) -> FieldOptions_OptionRetention {
  match i.inner() {
    0 => FieldOptions_OptionRetention::RETENTION_UNKNOWN
    1 => FieldOptions_OptionRetention::RETENTION_RUNTIME
    2 => FieldOptions_OptionRetention::RETENTION_SOURCE
    _ => Default::default()
  }
}

///|
pub impl Default for FieldOptions_OptionRetention with default() -> FieldOptions_OptionRetention {
  FieldOptions_OptionRetention::RETENTION_UNKNOWN
}

///|
pub impl @lib.Sized for FieldOptions_OptionRetention with size_of(
  self : FieldOptions_OptionRetention
) {
  @lib.Sized::size_of(self.to_enum())
}

///|
pub impl @json.FromJson for FieldOptions_OptionRetention with from_json(
  json : Json,
  path : @json.JsonPath
) -> FieldOptions_OptionRetention raise {
  match json {
    String(s) if s == "RETENTION_UNKNOWN" =>
      FieldOptions_OptionRetention::RETENTION_UNKNOWN
    String(s) if s == "RETENTION_RUNTIME" =>
      FieldOptions_OptionRetention::RETENTION_RUNTIME
    String(s) if s == "RETENTION_SOURCE" =>
      FieldOptions_OptionRetention::RETENTION_SOURCE
    Number(n) if n == 0 => FieldOptions_OptionRetention::RETENTION_UNKNOWN
    Number(n) if n == 1 => FieldOptions_OptionRetention::RETENTION_RUNTIME
    Number(n) if n == 2 => FieldOptions_OptionRetention::RETENTION_SOURCE
    _ =>
      raise @json.JsonDecodeError(
        (path, "Expected a number or string for enum"),
      )
  }
}

///|
pub impl ToJson for FieldOptions_OptionRetention with to_json(
  self : FieldOptions_OptionRetention
) -> Json {
  match self {
    FieldOptions_OptionRetention::RETENTION_UNKNOWN => "RETENTION_UNKNOWN"
    FieldOptions_OptionRetention::RETENTION_RUNTIME => "RETENTION_RUNTIME"
    FieldOptions_OptionRetention::RETENTION_SOURCE => "RETENTION_SOURCE"
  }
}

///|
pub(all) enum FieldOptions_OptionTargetType {
  TARGET_TYPE_UNKNOWN
  TARGET_TYPE_FILE
  TARGET_TYPE_EXTENSION_RANGE
  TARGET_TYPE_MESSAGE
  TARGET_TYPE_FIELD
  TARGET_TYPE_ONEOF
  TARGET_TYPE_ENUM
  TARGET_TYPE_ENUM_ENTRY
  TARGET_TYPE_SERVICE
  TARGET_TYPE_METHOD
} derive(Eq, Show)

///|
pub fn FieldOptions_OptionTargetType::to_enum(
  self : FieldOptions_OptionTargetType
) -> @lib.Enum {
  match self {
    FieldOptions_OptionTargetType::TARGET_TYPE_UNKNOWN => 0
    FieldOptions_OptionTargetType::TARGET_TYPE_FILE => 1
    FieldOptions_OptionTargetType::TARGET_TYPE_EXTENSION_RANGE => 2
    FieldOptions_OptionTargetType::TARGET_TYPE_MESSAGE => 3
    FieldOptions_OptionTargetType::TARGET_TYPE_FIELD => 4
    FieldOptions_OptionTargetType::TARGET_TYPE_ONEOF => 5
    FieldOptions_OptionTargetType::TARGET_TYPE_ENUM => 6
    FieldOptions_OptionTargetType::TARGET_TYPE_ENUM_ENTRY => 7
    FieldOptions_OptionTargetType::TARGET_TYPE_SERVICE => 8
    FieldOptions_OptionTargetType::TARGET_TYPE_METHOD => 9
  }
}

///|
pub fn FieldOptions_OptionTargetType::from_enum(
  i : @lib.Enum
) -> FieldOptions_OptionTargetType {
  match i.inner() {
    0 => FieldOptions_OptionTargetType::TARGET_TYPE_UNKNOWN
    1 => FieldOptions_OptionTargetType::TARGET_TYPE_FILE
    2 => FieldOptions_OptionTargetType::TARGET_TYPE_EXTENSION_RANGE
    3 => FieldOptions_OptionTargetType::TARGET_TYPE_MESSAGE
    4 => FieldOptions_OptionTargetType::TARGET_TYPE_FIELD
    5 => FieldOptions_OptionTargetType::TARGET_TYPE_ONEOF
    6 => FieldOptions_OptionTargetType::TARGET_TYPE_ENUM
    7 => FieldOptions_OptionTargetType::TARGET_TYPE_ENUM_ENTRY
    8 => FieldOptions_OptionTargetType::TARGET_TYPE_SERVICE
    9 => FieldOptions_OptionTargetType::TARGET_TYPE_METHOD
    _ => Default::default()
  }
}

///|
pub impl Default for FieldOptions_OptionTargetType with default() -> FieldOptions_OptionTargetType {
  FieldOptions_OptionTargetType::TARGET_TYPE_UNKNOWN
}

///|
pub impl @lib.Sized for FieldOptions_OptionTargetType with size_of(
  self : FieldOptions_OptionTargetType
) {
  @lib.Sized::size_of(self.to_enum())
}

///|
pub impl @json.FromJson for FieldOptions_OptionTargetType with from_json(
  json : Json,
  path : @json.JsonPath
) -> FieldOptions_OptionTargetType raise {
  match json {
    String(s) if s == "TARGET_TYPE_UNKNOWN" =>
      FieldOptions_OptionTargetType::TARGET_TYPE_UNKNOWN
    String(s) if s == "TARGET_TYPE_FILE" =>
      FieldOptions_OptionTargetType::TARGET_TYPE_FILE
    String(s) if s == "TARGET_TYPE_EXTENSION_RANGE" =>
      FieldOptions_OptionTargetType::TARGET_TYPE_EXTENSION_RANGE
    String(s) if s == "TARGET_TYPE_MESSAGE" =>
      FieldOptions_OptionTargetType::TARGET_TYPE_MESSAGE
    String(s) if s == "TARGET_TYPE_FIELD" =>
      FieldOptions_OptionTargetType::TARGET_TYPE_FIELD
    String(s) if s == "TARGET_TYPE_ONEOF" =>
      FieldOptions_OptionTargetType::TARGET_TYPE_ONEOF
    String(s) if s == "TARGET_TYPE_ENUM" =>
      FieldOptions_OptionTargetType::TARGET_TYPE_ENUM
    String(s) if s == "TARGET_TYPE_ENUM_ENTRY" =>
      FieldOptions_OptionTargetType::TARGET_TYPE_ENUM_ENTRY
    String(s) if s == "TARGET_TYPE_SERVICE" =>
      FieldOptions_OptionTargetType::TARGET_TYPE_SERVICE
    String(s) if s == "TARGET_TYPE_METHOD" =>
      FieldOptions_OptionTargetType::TARGET_TYPE_METHOD
    Number(n) if n == 0 => FieldOptions_OptionTargetType::TARGET_TYPE_UNKNOWN
    Number(n) if n == 1 => FieldOptions_OptionTargetType::TARGET_TYPE_FILE
    Number(n) if n == 2 =>
      FieldOptions_OptionTargetType::TARGET_TYPE_EXTENSION_RANGE
    Number(n) if n == 3 => FieldOptions_OptionTargetType::TARGET_TYPE_MESSAGE
    Number(n) if n == 4 => FieldOptions_OptionTargetType::TARGET_TYPE_FIELD
    Number(n) if n == 5 => FieldOptions_OptionTargetType::TARGET_TYPE_ONEOF
    Number(n) if n == 6 => FieldOptions_OptionTargetType::TARGET_TYPE_ENUM
    Number(n) if n == 7 => FieldOptions_OptionTargetType::TARGET_TYPE_ENUM_ENTRY
    Number(n) if n == 8 => FieldOptions_OptionTargetType::TARGET_TYPE_SERVICE
    Number(n) if n == 9 => FieldOptions_OptionTargetType::TARGET_TYPE_METHOD
    _ =>
      raise @json.JsonDecodeError(
        (path, "Expected a number or string for enum"),
      )
  }
}

///|
pub impl ToJson for FieldOptions_OptionTargetType with to_json(
  self : FieldOptions_OptionTargetType
) -> Json {
  match self {
    FieldOptions_OptionTargetType::TARGET_TYPE_UNKNOWN => "TARGET_TYPE_UNKNOWN"
    FieldOptions_OptionTargetType::TARGET_TYPE_FILE => "TARGET_TYPE_FILE"
    FieldOptions_OptionTargetType::TARGET_TYPE_EXTENSION_RANGE =>
      "TARGET_TYPE_EXTENSION_RANGE"
    FieldOptions_OptionTargetType::TARGET_TYPE_MESSAGE => "TARGET_TYPE_MESSAGE"
    FieldOptions_OptionTargetType::TARGET_TYPE_FIELD => "TARGET_TYPE_FIELD"
    FieldOptions_OptionTargetType::TARGET_TYPE_ONEOF => "TARGET_TYPE_ONEOF"
    FieldOptions_OptionTargetType::TARGET_TYPE_ENUM => "TARGET_TYPE_ENUM"
    FieldOptions_OptionTargetType::TARGET_TYPE_ENUM_ENTRY =>
      "TARGET_TYPE_ENUM_ENTRY"
    FieldOptions_OptionTargetType::TARGET_TYPE_SERVICE => "TARGET_TYPE_SERVICE"
    FieldOptions_OptionTargetType::TARGET_TYPE_METHOD => "TARGET_TYPE_METHOD"
  }
}

///|
pub(all) struct FieldOptions_EditionDefault {
  mut edition : Edition?
  mut value : String?
} derive(Eq, Show)

///|
pub impl @lib.Sized for FieldOptions_EditionDefault with size_of(self) {
  let mut size = 0U
  match self.edition {
    Some(v) => size += 1U + @lib.size_of(v)
    None => ()
  }
  match self.value {
    Some(v) =>
      size += 1U +
        {
          let size = @lib.size_of(v)
          @lib.size_of(size) + size
        }
    None => ()
  }
  size
}

///|
pub impl Default for FieldOptions_EditionDefault with default() -> FieldOptions_EditionDefault {
  FieldOptions_EditionDefault::{ edition: None, value: None }
}

///|
pub impl @lib.Read for FieldOptions_EditionDefault with read(
  reader : &@lib.Reader
) {
  let msg = FieldOptions_EditionDefault::default()
  while not(reader |> @lib.is_eof()) {
    match (reader |> @lib.read_tag()) {
      (3, _) =>
        msg.edition = reader |> @lib.read_enum() |> Edition::from_enum |> Some
      (2, _) => msg.value = reader |> @lib.read_string() |> Some
      (_, wire) => reader |> @lib.read_unknown(wire)
    }
  }
  msg
}

///|
pub impl @lib.Write for FieldOptions_EditionDefault with write(self, writer) {
  match self.edition {
    Some(v) => {
      writer |> @lib.write_varint(24UL)
      writer |> @lib.write_enum(v.to_enum())
    }
    None => ()
  }
  match self.value {
    Some(v) => {
      writer |> @lib.write_varint(18UL)
      writer |> @lib.write_string(v)
    }
    None => ()
  }
}

///|
pub impl ToJson for FieldOptions_EditionDefault with to_json(self) {
  let json : Map[String, Json] = {}
  match self.edition {
    Some(v) => json["edition"] = v.to_json()
    _ => ()
  }
  match self.value {
    Some(v) => json["value"] = v.to_json()
    _ => ()
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for FieldOptions_EditionDefault with from_json(
  json : Json,
  path : @json.JsonPath
) -> FieldOptions_EditionDefault raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError(
      (path, "Expected an object for FieldOptions_EditionDefault"),
    )
  }
  let message = FieldOptions_EditionDefault::default()
  for key, value in obj {
    match (key, value) {
      ("edition", value) =>
        message.edition = Some(@json.from_json(value, path~))
      ("value", value) => message.value = Some(@json.from_json(value, path~))
      key => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub(all) struct FieldOptions_FeatureSupport {
  mut edition_introduced : Edition?
  mut edition_deprecated : Edition?
  mut deprecation_warning : String?
  mut edition_removed : Edition?
} derive(Eq, Show)

///|
pub impl @lib.Sized for FieldOptions_FeatureSupport with size_of(self) {
  let mut size = 0U
  match self.edition_introduced {
    Some(v) => size += 1U + @lib.size_of(v)
    None => ()
  }
  match self.edition_deprecated {
    Some(v) => size += 1U + @lib.size_of(v)
    None => ()
  }
  match self.deprecation_warning {
    Some(v) =>
      size += 1U +
        {
          let size = @lib.size_of(v)
          @lib.size_of(size) + size
        }
    None => ()
  }
  match self.edition_removed {
    Some(v) => size += 1U + @lib.size_of(v)
    None => ()
  }
  size
}

///|
pub impl Default for FieldOptions_FeatureSupport with default() -> FieldOptions_FeatureSupport {
  FieldOptions_FeatureSupport::{
    edition_introduced: None,
    edition_deprecated: None,
    deprecation_warning: None,
    edition_removed: None,
  }
}

///|
pub impl @lib.Read for FieldOptions_FeatureSupport with read(
  reader : &@lib.Reader
) {
  let msg = FieldOptions_FeatureSupport::default()
  while not(reader |> @lib.is_eof()) {
    match (reader |> @lib.read_tag()) {
      (1, _) =>
        msg.edition_introduced = reader
          |> @lib.read_enum()
          |> Edition::from_enum
          |> Some
      (2, _) =>
        msg.edition_deprecated = reader
          |> @lib.read_enum()
          |> Edition::from_enum
          |> Some
      (3, _) => msg.deprecation_warning = reader |> @lib.read_string() |> Some
      (4, _) =>
        msg.edition_removed = reader
          |> @lib.read_enum()
          |> Edition::from_enum
          |> Some
      (_, wire) => reader |> @lib.read_unknown(wire)
    }
  }
  msg
}

///|
pub impl @lib.Write for FieldOptions_FeatureSupport with write(self, writer) {
  match self.edition_introduced {
    Some(v) => {
      writer |> @lib.write_varint(8UL)
      writer |> @lib.write_enum(v.to_enum())
    }
    None => ()
  }
  match self.edition_deprecated {
    Some(v) => {
      writer |> @lib.write_varint(16UL)
      writer |> @lib.write_enum(v.to_enum())
    }
    None => ()
  }
  match self.deprecation_warning {
    Some(v) => {
      writer |> @lib.write_varint(26UL)
      writer |> @lib.write_string(v)
    }
    None => ()
  }
  match self.edition_removed {
    Some(v) => {
      writer |> @lib.write_varint(32UL)
      writer |> @lib.write_enum(v.to_enum())
    }
    None => ()
  }
}

///|
pub impl ToJson for FieldOptions_FeatureSupport with to_json(self) {
  let json : Map[String, Json] = {}
  match self.edition_introduced {
    Some(v) => json["editionIntroduced"] = v.to_json()
    _ => ()
  }
  match self.edition_deprecated {
    Some(v) => json["editionDeprecated"] = v.to_json()
    _ => ()
  }
  match self.deprecation_warning {
    Some(v) => json["deprecationWarning"] = v.to_json()
    _ => ()
  }
  match self.edition_removed {
    Some(v) => json["editionRemoved"] = v.to_json()
    _ => ()
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for FieldOptions_FeatureSupport with from_json(
  json : Json,
  path : @json.JsonPath
) -> FieldOptions_FeatureSupport raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError(
      (path, "Expected an object for FieldOptions_FeatureSupport"),
    )
  }
  let message = FieldOptions_FeatureSupport::default()
  for key, value in obj {
    match (key, value) {
      ("editionIntroduced", value) =>
        message.edition_introduced = Some(@json.from_json(value, path~))
      ("editionDeprecated", value) =>
        message.edition_deprecated = Some(@json.from_json(value, path~))
      ("deprecationWarning", value) =>
        message.deprecation_warning = Some(@json.from_json(value, path~))
      ("editionRemoved", value) =>
        message.edition_removed = Some(@json.from_json(value, path~))
      key => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub(all) struct FieldOptions {
  mut ctype : FieldOptions_CType?
  mut packed : Bool?
  mut jstype : FieldOptions_JSType?
  mut lazy : Bool?
  mut unverified_lazy : Bool?
  mut deprecated : Bool?
  mut weak : Bool?
  mut debug_redact : Bool?
  mut retention : FieldOptions_OptionRetention?
  mut targets : Array[FieldOptions_OptionTargetType]
  mut edition_defaults : Array[FieldOptions_EditionDefault]
  mut features : FeatureSet?
  mut feature_support : FieldOptions_FeatureSupport?
  mut uninterpreted_option : Array[UninterpretedOption]
} derive(Eq, Show)

///|
pub impl @lib.Sized for FieldOptions with size_of(self) {
  let mut size = 0U
  match self.ctype {
    Some(v) => size += 1U + @lib.size_of(v)
    None => ()
  }
  match self.packed {
    Some(v) => size += 1U + @lib.size_of(v)
    None => ()
  }
  match self.jstype {
    Some(v) => size += 1U + @lib.size_of(v)
    None => ()
  }
  match self.lazy {
    Some(v) => size += 1U + @lib.size_of(v)
    None => ()
  }
  match self.unverified_lazy {
    Some(v) => size += 1U + @lib.size_of(v)
    None => ()
  }
  match self.deprecated {
    Some(v) => size += 1U + @lib.size_of(v)
    None => ()
  }
  match self.weak {
    Some(v) => size += 1U + @lib.size_of(v)
    None => ()
  }
  match self.debug_redact {
    Some(v) => size += 2U + @lib.size_of(v)
    None => ()
  }
  match self.retention {
    Some(v) => size += 2U + @lib.size_of(v)
    None => ()
  }
  size += self.targets
    .iter()
    .map(@lib.size_of)
    .map(s => 2U + @lib.size_of(s) + s)
    .fold(init=0U, UInt::op_add)
  size += self.edition_defaults
    .iter()
    .map(@lib.size_of)
    .map(s => 2U + @lib.size_of(s) + s)
    .fold(init=0U, UInt::op_add)
  match self.features {
    Some(v) =>
      size += 2U +
        {
          let size = @lib.size_of(v)
          @lib.size_of(size) + size
        }
    None => ()
  }
  match self.feature_support {
    Some(v) =>
      size += 2U +
        {
          let size = @lib.size_of(v)
          @lib.size_of(size) + size
        }
    None => ()
  }
  size += self.uninterpreted_option
    .iter()
    .map(@lib.size_of)
    .map(s => 2U + @lib.size_of(s) + s)
    .fold(init=0U, UInt::op_add)
  size
}

///|
pub impl Default for FieldOptions with default() -> FieldOptions {
  FieldOptions::{
    ctype: Some(FieldOptions_CType::STRING),
    packed: None,
    jstype: Some(FieldOptions_JSType::JS_NORMAL),
    lazy: Some(false),
    unverified_lazy: Some(false),
    deprecated: Some(false),
    weak: Some(false),
    debug_redact: Some(false),
    retention: None,
    targets: [],
    edition_defaults: [],
    features: None,
    feature_support: None,
    uninterpreted_option: [],
  }
}

///|
pub impl @lib.Read for FieldOptions with read(reader : &@lib.Reader) {
  let msg = FieldOptions::default()
  while not(reader |> @lib.is_eof()) {
    match (reader |> @lib.read_tag()) {
      (1, _) =>
        msg.ctype = reader
          |> @lib.read_enum()
          |> FieldOptions_CType::from_enum
          |> Some
      (2, _) => msg.packed = reader |> @lib.read_bool() |> Some
      (6, _) =>
        msg.jstype = reader
          |> @lib.read_enum()
          |> FieldOptions_JSType::from_enum
          |> Some
      (5, _) => msg.lazy = reader |> @lib.read_bool() |> Some
      (15, _) => msg.unverified_lazy = reader |> @lib.read_bool() |> Some
      (3, _) => msg.deprecated = reader |> @lib.read_bool() |> Some
      (10, _) => msg.weak = reader |> @lib.read_bool() |> Some
      (16, _) => msg.debug_redact = reader |> @lib.read_bool() |> Some
      (17, _) =>
        msg.retention = reader
          |> @lib.read_enum()
          |> FieldOptions_OptionRetention::from_enum
          |> Some
      (19, _) =>
        msg.targets.push(
          reader |> @lib.read_enum() |> FieldOptions_OptionTargetType::from_enum,
        )
      (20, _) =>
        msg.edition_defaults.push(
          (reader |> @lib.read_message() : FieldOptions_EditionDefault),
        )
      (21, _) =>
        msg.features = (reader |> @lib.read_message() : FeatureSet) |> Some
      (22, _) =>
        msg.feature_support = (
            reader |> @lib.read_message() : FieldOptions_FeatureSupport)
          |> Some
      (999, _) =>
        msg.uninterpreted_option.push(
          (reader |> @lib.read_message() : UninterpretedOption),
        )
      (_, wire) => reader |> @lib.read_unknown(wire)
    }
  }
  msg
}

///|
pub impl @lib.Write for FieldOptions with write(self, writer) {
  match self.ctype {
    Some(v) => {
      writer |> @lib.write_varint(8UL)
      writer |> @lib.write_enum(v.to_enum())
    }
    None => ()
  }
  match self.packed {
    Some(v) => {
      writer |> @lib.write_varint(16UL)
      writer |> @lib.write_bool(v)
    }
    None => ()
  }
  match self.jstype {
    Some(v) => {
      writer |> @lib.write_varint(48UL)
      writer |> @lib.write_enum(v.to_enum())
    }
    None => ()
  }
  match self.lazy {
    Some(v) => {
      writer |> @lib.write_varint(40UL)
      writer |> @lib.write_bool(v)
    }
    None => ()
  }
  match self.unverified_lazy {
    Some(v) => {
      writer |> @lib.write_varint(120UL)
      writer |> @lib.write_bool(v)
    }
    None => ()
  }
  match self.deprecated {
    Some(v) => {
      writer |> @lib.write_varint(24UL)
      writer |> @lib.write_bool(v)
    }
    None => ()
  }
  match self.weak {
    Some(v) => {
      writer |> @lib.write_varint(80UL)
      writer |> @lib.write_bool(v)
    }
    None => ()
  }
  match self.debug_redact {
    Some(v) => {
      writer |> @lib.write_varint(128UL)
      writer |> @lib.write_bool(v)
    }
    None => ()
  }
  match self.retention {
    Some(v) => {
      writer |> @lib.write_varint(136UL)
      writer |> @lib.write_enum(v.to_enum())
    }
    None => ()
  }
  self.targets
  .iter()
  .each(fn(v) {
    writer |> @lib.write_varint(152UL)
    writer |> @lib.write_enum(v.to_enum())
  })
  self.edition_defaults
  .iter()
  .each(fn(v) {
    writer |> @lib.write_varint(162UL)
    writer |> @lib.write_uint32(@lib.size_of(v))
    @lib.Write::write(v, writer)
  })
  match self.features {
    Some(v) => {
      writer |> @lib.write_varint(170UL)
      writer |> @lib.write_uint32(@lib.size_of(v))
      @lib.Write::write(v, writer)
    }
    None => ()
  }
  match self.feature_support {
    Some(v) => {
      writer |> @lib.write_varint(178UL)
      writer |> @lib.write_uint32(@lib.size_of(v))
      @lib.Write::write(v, writer)
    }
    None => ()
  }
  self.uninterpreted_option
  .iter()
  .each(fn(v) {
    writer |> @lib.write_varint(7994UL)
    writer |> @lib.write_uint32(@lib.size_of(v))
    @lib.Write::write(v, writer)
  })
}

///|
pub impl ToJson for FieldOptions with to_json(self) {
  let json : Map[String, Json] = {}
  match self.ctype {
    Some(v) if v != FieldOptions_CType::STRING => json["ctype"] = v.to_json()
    _ => ()
  }
  match self.packed {
    Some(v) => json["packed"] = v.to_json()
    _ => ()
  }
  match self.jstype {
    Some(v) if v != FieldOptions_JSType::JS_NORMAL =>
      json["jstype"] = v.to_json()
    _ => ()
  }
  match self.lazy {
    Some(v) if v != false => json["lazy"] = v.to_json()
    _ => ()
  }
  match self.unverified_lazy {
    Some(v) if v != false => json["unverifiedLazy"] = v.to_json()
    _ => ()
  }
  match self.deprecated {
    Some(v) if v != false => json["deprecated"] = v.to_json()
    _ => ()
  }
  match self.weak {
    Some(v) if v != false => json["weak"] = v.to_json()
    _ => ()
  }
  match self.debug_redact {
    Some(v) if v != false => json["debugRedact"] = v.to_json()
    _ => ()
  }
  match self.retention {
    Some(v) => json["retention"] = v.to_json()
    _ => ()
  }
  if self.targets != Default::default() {
    json["targets"] = self.targets.to_json()
  }
  if self.edition_defaults != Default::default() {
    json["editionDefaults"] = self.edition_defaults.to_json()
  }
  match self.features {
    Some(v) => json["features"] = v.to_json()
    _ => ()
  }
  match self.feature_support {
    Some(v) => json["featureSupport"] = v.to_json()
    _ => ()
  }
  if self.uninterpreted_option != Default::default() {
    json["uninterpretedOption"] = self.uninterpreted_option.to_json()
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for FieldOptions with from_json(
  json : Json,
  path : @json.JsonPath
) -> FieldOptions raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError((path, "Expected an object for FieldOptions"))
  }
  let message = FieldOptions::default()
  for key, value in obj {
    match (key, value) {
      ("ctype", value) => message.ctype = Some(@json.from_json(value, path~))
      ("packed", value) => message.packed = Some(@json.from_json(value, path~))
      ("jstype", value) => message.jstype = Some(@json.from_json(value, path~))
      ("lazy", value) => message.lazy = Some(@json.from_json(value, path~))
      ("unverifiedLazy", value) =>
        message.unverified_lazy = Some(@json.from_json(value, path~))
      ("deprecated", value) =>
        message.deprecated = Some(@json.from_json(value, path~))
      ("weak", value) => message.weak = Some(@json.from_json(value, path~))
      ("debugRedact", value) =>
        message.debug_redact = Some(@json.from_json(value, path~))
      ("retention", value) =>
        message.retention = Some(@json.from_json(value, path~))
      ("targets", Array(value)) =>
        message.targets = value.map(v => @json.from_json(v, path~))
      ("editionDefaults", Array(value)) =>
        message.edition_defaults = value.map(v => @json.from_json(v, path~))
      ("features", value) =>
        message.features = Some(@json.from_json(value, path~))
      ("featureSupport", value) =>
        message.feature_support = Some(@json.from_json(value, path~))
      ("uninterpretedOption", Array(value)) =>
        message.uninterpreted_option = value.map(v => @json.from_json(v, path~))
      key => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub(all) struct OneofOptions {
  mut features : FeatureSet?
  mut uninterpreted_option : Array[UninterpretedOption]
} derive(Eq, Show)

///|
pub impl @lib.Sized for OneofOptions with size_of(self) {
  let mut size = 0U
  match self.features {
    Some(v) =>
      size += 1U +
        {
          let size = @lib.size_of(v)
          @lib.size_of(size) + size
        }
    None => ()
  }
  size += self.uninterpreted_option
    .iter()
    .map(@lib.size_of)
    .map(s => 2U + @lib.size_of(s) + s)
    .fold(init=0U, UInt::op_add)
  size
}

///|
pub impl Default for OneofOptions with default() -> OneofOptions {
  OneofOptions::{ features: None, uninterpreted_option: [] }
}

///|
pub impl @lib.Read for OneofOptions with read(reader : &@lib.Reader) {
  let msg = OneofOptions::default()
  while not(reader |> @lib.is_eof()) {
    match (reader |> @lib.read_tag()) {
      (1, _) =>
        msg.features = (reader |> @lib.read_message() : FeatureSet) |> Some
      (999, _) =>
        msg.uninterpreted_option.push(
          (reader |> @lib.read_message() : UninterpretedOption),
        )
      (_, wire) => reader |> @lib.read_unknown(wire)
    }
  }
  msg
}

///|
pub impl @lib.Write for OneofOptions with write(self, writer) {
  match self.features {
    Some(v) => {
      writer |> @lib.write_varint(10UL)
      writer |> @lib.write_uint32(@lib.size_of(v))
      @lib.Write::write(v, writer)
    }
    None => ()
  }
  self.uninterpreted_option
  .iter()
  .each(fn(v) {
    writer |> @lib.write_varint(7994UL)
    writer |> @lib.write_uint32(@lib.size_of(v))
    @lib.Write::write(v, writer)
  })
}

///|
pub impl ToJson for OneofOptions with to_json(self) {
  let json : Map[String, Json] = {}
  match self.features {
    Some(v) => json["features"] = v.to_json()
    _ => ()
  }
  if self.uninterpreted_option != Default::default() {
    json["uninterpretedOption"] = self.uninterpreted_option.to_json()
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for OneofOptions with from_json(
  json : Json,
  path : @json.JsonPath
) -> OneofOptions raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError((path, "Expected an object for OneofOptions"))
  }
  let message = OneofOptions::default()
  for key, value in obj {
    match (key, value) {
      ("features", value) =>
        message.features = Some(@json.from_json(value, path~))
      ("uninterpretedOption", Array(value)) =>
        message.uninterpreted_option = value.map(v => @json.from_json(v, path~))
      key => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub(all) struct EnumOptions {
  mut allow_alias : Bool?
  mut deprecated : Bool?
  mut deprecated_legacy_json_field_conflicts : Bool?
  mut features : FeatureSet?
  mut uninterpreted_option : Array[UninterpretedOption]
} derive(Eq, Show)

///|
pub impl @lib.Sized for EnumOptions with size_of(self) {
  let mut size = 0U
  match self.allow_alias {
    Some(v) => size += 1U + @lib.size_of(v)
    None => ()
  }
  match self.deprecated {
    Some(v) => size += 1U + @lib.size_of(v)
    None => ()
  }
  match self.deprecated_legacy_json_field_conflicts {
    Some(v) => size += 1U + @lib.size_of(v)
    None => ()
  }
  match self.features {
    Some(v) =>
      size += 1U +
        {
          let size = @lib.size_of(v)
          @lib.size_of(size) + size
        }
    None => ()
  }
  size += self.uninterpreted_option
    .iter()
    .map(@lib.size_of)
    .map(s => 2U + @lib.size_of(s) + s)
    .fold(init=0U, UInt::op_add)
  size
}

///|
pub impl Default for EnumOptions with default() -> EnumOptions {
  EnumOptions::{
    allow_alias: None,
    deprecated: Some(false),
    deprecated_legacy_json_field_conflicts: None,
    features: None,
    uninterpreted_option: [],
  }
}

///|
pub impl @lib.Read for EnumOptions with read(reader : &@lib.Reader) {
  let msg = EnumOptions::default()
  while not(reader |> @lib.is_eof()) {
    match (reader |> @lib.read_tag()) {
      (2, _) => msg.allow_alias = reader |> @lib.read_bool() |> Some
      (3, _) => msg.deprecated = reader |> @lib.read_bool() |> Some
      (6, _) =>
        msg.deprecated_legacy_json_field_conflicts = reader
          |> @lib.read_bool()
          |> Some
      (7, _) =>
        msg.features = (reader |> @lib.read_message() : FeatureSet) |> Some
      (999, _) =>
        msg.uninterpreted_option.push(
          (reader |> @lib.read_message() : UninterpretedOption),
        )
      (_, wire) => reader |> @lib.read_unknown(wire)
    }
  }
  msg
}

///|
pub impl @lib.Write for EnumOptions with write(self, writer) {
  match self.allow_alias {
    Some(v) => {
      writer |> @lib.write_varint(16UL)
      writer |> @lib.write_bool(v)
    }
    None => ()
  }
  match self.deprecated {
    Some(v) => {
      writer |> @lib.write_varint(24UL)
      writer |> @lib.write_bool(v)
    }
    None => ()
  }
  match self.deprecated_legacy_json_field_conflicts {
    Some(v) => {
      writer |> @lib.write_varint(48UL)
      writer |> @lib.write_bool(v)
    }
    None => ()
  }
  match self.features {
    Some(v) => {
      writer |> @lib.write_varint(58UL)
      writer |> @lib.write_uint32(@lib.size_of(v))
      @lib.Write::write(v, writer)
    }
    None => ()
  }
  self.uninterpreted_option
  .iter()
  .each(fn(v) {
    writer |> @lib.write_varint(7994UL)
    writer |> @lib.write_uint32(@lib.size_of(v))
    @lib.Write::write(v, writer)
  })
}

///|
pub impl ToJson for EnumOptions with to_json(self) {
  let json : Map[String, Json] = {}
  match self.allow_alias {
    Some(v) => json["allowAlias"] = v.to_json()
    _ => ()
  }
  match self.deprecated {
    Some(v) if v != false => json["deprecated"] = v.to_json()
    _ => ()
  }
  match self.deprecated_legacy_json_field_conflicts {
    Some(v) => json["deprecatedLegacyJsonFieldConflicts"] = v.to_json()
    _ => ()
  }
  match self.features {
    Some(v) => json["features"] = v.to_json()
    _ => ()
  }
  if self.uninterpreted_option != Default::default() {
    json["uninterpretedOption"] = self.uninterpreted_option.to_json()
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for EnumOptions with from_json(
  json : Json,
  path : @json.JsonPath
) -> EnumOptions raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError((path, "Expected an object for EnumOptions"))
  }
  let message = EnumOptions::default()
  for key, value in obj {
    match (key, value) {
      ("allowAlias", value) =>
        message.allow_alias = Some(@json.from_json(value, path~))
      ("deprecated", value) =>
        message.deprecated = Some(@json.from_json(value, path~))
      ("deprecatedLegacyJsonFieldConflicts", value) =>
        message.deprecated_legacy_json_field_conflicts = Some(
          @json.from_json(value, path~),
        )
      ("features", value) =>
        message.features = Some(@json.from_json(value, path~))
      ("uninterpretedOption", Array(value)) =>
        message.uninterpreted_option = value.map(v => @json.from_json(v, path~))
      key => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub(all) struct EnumValueOptions {
  mut deprecated : Bool?
  mut features : FeatureSet?
  mut debug_redact : Bool?
  mut feature_support : FieldOptions_FeatureSupport?
  mut uninterpreted_option : Array[UninterpretedOption]
} derive(Eq, Show)

///|
pub impl @lib.Sized for EnumValueOptions with size_of(self) {
  let mut size = 0U
  match self.deprecated {
    Some(v) => size += 1U + @lib.size_of(v)
    None => ()
  }
  match self.features {
    Some(v) =>
      size += 1U +
        {
          let size = @lib.size_of(v)
          @lib.size_of(size) + size
        }
    None => ()
  }
  match self.debug_redact {
    Some(v) => size += 1U + @lib.size_of(v)
    None => ()
  }
  match self.feature_support {
    Some(v) =>
      size += 1U +
        {
          let size = @lib.size_of(v)
          @lib.size_of(size) + size
        }
    None => ()
  }
  size += self.uninterpreted_option
    .iter()
    .map(@lib.size_of)
    .map(s => 2U + @lib.size_of(s) + s)
    .fold(init=0U, UInt::op_add)
  size
}

///|
pub impl Default for EnumValueOptions with default() -> EnumValueOptions {
  EnumValueOptions::{
    deprecated: Some(false),
    features: None,
    debug_redact: Some(false),
    feature_support: None,
    uninterpreted_option: [],
  }
}

///|
pub impl @lib.Read for EnumValueOptions with read(reader : &@lib.Reader) {
  let msg = EnumValueOptions::default()
  while not(reader |> @lib.is_eof()) {
    match (reader |> @lib.read_tag()) {
      (1, _) => msg.deprecated = reader |> @lib.read_bool() |> Some
      (2, _) =>
        msg.features = (reader |> @lib.read_message() : FeatureSet) |> Some
      (3, _) => msg.debug_redact = reader |> @lib.read_bool() |> Some
      (4, _) =>
        msg.feature_support = (
            reader |> @lib.read_message() : FieldOptions_FeatureSupport)
          |> Some
      (999, _) =>
        msg.uninterpreted_option.push(
          (reader |> @lib.read_message() : UninterpretedOption),
        )
      (_, wire) => reader |> @lib.read_unknown(wire)
    }
  }
  msg
}

///|
pub impl @lib.Write for EnumValueOptions with write(self, writer) {
  match self.deprecated {
    Some(v) => {
      writer |> @lib.write_varint(8UL)
      writer |> @lib.write_bool(v)
    }
    None => ()
  }
  match self.features {
    Some(v) => {
      writer |> @lib.write_varint(18UL)
      writer |> @lib.write_uint32(@lib.size_of(v))
      @lib.Write::write(v, writer)
    }
    None => ()
  }
  match self.debug_redact {
    Some(v) => {
      writer |> @lib.write_varint(24UL)
      writer |> @lib.write_bool(v)
    }
    None => ()
  }
  match self.feature_support {
    Some(v) => {
      writer |> @lib.write_varint(34UL)
      writer |> @lib.write_uint32(@lib.size_of(v))
      @lib.Write::write(v, writer)
    }
    None => ()
  }
  self.uninterpreted_option
  .iter()
  .each(fn(v) {
    writer |> @lib.write_varint(7994UL)
    writer |> @lib.write_uint32(@lib.size_of(v))
    @lib.Write::write(v, writer)
  })
}

///|
pub impl ToJson for EnumValueOptions with to_json(self) {
  let json : Map[String, Json] = {}
  match self.deprecated {
    Some(v) if v != false => json["deprecated"] = v.to_json()
    _ => ()
  }
  match self.features {
    Some(v) => json["features"] = v.to_json()
    _ => ()
  }
  match self.debug_redact {
    Some(v) if v != false => json["debugRedact"] = v.to_json()
    _ => ()
  }
  match self.feature_support {
    Some(v) => json["featureSupport"] = v.to_json()
    _ => ()
  }
  if self.uninterpreted_option != Default::default() {
    json["uninterpretedOption"] = self.uninterpreted_option.to_json()
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for EnumValueOptions with from_json(
  json : Json,
  path : @json.JsonPath
) -> EnumValueOptions raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError(
      (path, "Expected an object for EnumValueOptions"),
    )
  }
  let message = EnumValueOptions::default()
  for key, value in obj {
    match (key, value) {
      ("deprecated", value) =>
        message.deprecated = Some(@json.from_json(value, path~))
      ("features", value) =>
        message.features = Some(@json.from_json(value, path~))
      ("debugRedact", value) =>
        message.debug_redact = Some(@json.from_json(value, path~))
      ("featureSupport", value) =>
        message.feature_support = Some(@json.from_json(value, path~))
      ("uninterpretedOption", Array(value)) =>
        message.uninterpreted_option = value.map(v => @json.from_json(v, path~))
      key => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub(all) struct ServiceOptions {
  mut features : FeatureSet?
  mut deprecated : Bool?
  mut uninterpreted_option : Array[UninterpretedOption]
} derive(Eq, Show)

///|
pub impl @lib.Sized for ServiceOptions with size_of(self) {
  let mut size = 0U
  match self.features {
    Some(v) =>
      size += 2U +
        {
          let size = @lib.size_of(v)
          @lib.size_of(size) + size
        }
    None => ()
  }
  match self.deprecated {
    Some(v) => size += 2U + @lib.size_of(v)
    None => ()
  }
  size += self.uninterpreted_option
    .iter()
    .map(@lib.size_of)
    .map(s => 2U + @lib.size_of(s) + s)
    .fold(init=0U, UInt::op_add)
  size
}

///|
pub impl Default for ServiceOptions with default() -> ServiceOptions {
  ServiceOptions::{
    features: None,
    deprecated: Some(false),
    uninterpreted_option: [],
  }
}

///|
pub impl @lib.Read for ServiceOptions with read(reader : &@lib.Reader) {
  let msg = ServiceOptions::default()
  while not(reader |> @lib.is_eof()) {
    match (reader |> @lib.read_tag()) {
      (34, _) =>
        msg.features = (reader |> @lib.read_message() : FeatureSet) |> Some
      (33, _) => msg.deprecated = reader |> @lib.read_bool() |> Some
      (999, _) =>
        msg.uninterpreted_option.push(
          (reader |> @lib.read_message() : UninterpretedOption),
        )
      (_, wire) => reader |> @lib.read_unknown(wire)
    }
  }
  msg
}

///|
pub impl @lib.Write for ServiceOptions with write(self, writer) {
  match self.features {
    Some(v) => {
      writer |> @lib.write_varint(274UL)
      writer |> @lib.write_uint32(@lib.size_of(v))
      @lib.Write::write(v, writer)
    }
    None => ()
  }
  match self.deprecated {
    Some(v) => {
      writer |> @lib.write_varint(264UL)
      writer |> @lib.write_bool(v)
    }
    None => ()
  }
  self.uninterpreted_option
  .iter()
  .each(fn(v) {
    writer |> @lib.write_varint(7994UL)
    writer |> @lib.write_uint32(@lib.size_of(v))
    @lib.Write::write(v, writer)
  })
}

///|
pub impl ToJson for ServiceOptions with to_json(self) {
  let json : Map[String, Json] = {}
  match self.features {
    Some(v) => json["features"] = v.to_json()
    _ => ()
  }
  match self.deprecated {
    Some(v) if v != false => json["deprecated"] = v.to_json()
    _ => ()
  }
  if self.uninterpreted_option != Default::default() {
    json["uninterpretedOption"] = self.uninterpreted_option.to_json()
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for ServiceOptions with from_json(
  json : Json,
  path : @json.JsonPath
) -> ServiceOptions raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError((path, "Expected an object for ServiceOptions"))
  }
  let message = ServiceOptions::default()
  for key, value in obj {
    match (key, value) {
      ("features", value) =>
        message.features = Some(@json.from_json(value, path~))
      ("deprecated", value) =>
        message.deprecated = Some(@json.from_json(value, path~))
      ("uninterpretedOption", Array(value)) =>
        message.uninterpreted_option = value.map(v => @json.from_json(v, path~))
      key => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub(all) enum MethodOptions_IdempotencyLevel {
  IDEMPOTENCY_UNKNOWN
  NO_SIDE_EFFECTS
  IDEMPOTENT
} derive(Eq, Show)

///|
pub fn MethodOptions_IdempotencyLevel::to_enum(
  self : MethodOptions_IdempotencyLevel
) -> @lib.Enum {
  match self {
    MethodOptions_IdempotencyLevel::IDEMPOTENCY_UNKNOWN => 0
    MethodOptions_IdempotencyLevel::NO_SIDE_EFFECTS => 1
    MethodOptions_IdempotencyLevel::IDEMPOTENT => 2
  }
}

///|
pub fn MethodOptions_IdempotencyLevel::from_enum(
  i : @lib.Enum
) -> MethodOptions_IdempotencyLevel {
  match i.inner() {
    0 => MethodOptions_IdempotencyLevel::IDEMPOTENCY_UNKNOWN
    1 => MethodOptions_IdempotencyLevel::NO_SIDE_EFFECTS
    2 => MethodOptions_IdempotencyLevel::IDEMPOTENT
    _ => Default::default()
  }
}

///|
pub impl Default for MethodOptions_IdempotencyLevel with default() -> MethodOptions_IdempotencyLevel {
  MethodOptions_IdempotencyLevel::IDEMPOTENCY_UNKNOWN
}

///|
pub impl @lib.Sized for MethodOptions_IdempotencyLevel with size_of(
  self : MethodOptions_IdempotencyLevel
) {
  @lib.Sized::size_of(self.to_enum())
}

///|
pub impl @json.FromJson for MethodOptions_IdempotencyLevel with from_json(
  json : Json,
  path : @json.JsonPath
) -> MethodOptions_IdempotencyLevel raise {
  match json {
    String(s) if s == "IDEMPOTENCY_UNKNOWN" =>
      MethodOptions_IdempotencyLevel::IDEMPOTENCY_UNKNOWN
    String(s) if s == "NO_SIDE_EFFECTS" =>
      MethodOptions_IdempotencyLevel::NO_SIDE_EFFECTS
    String(s) if s == "IDEMPOTENT" => MethodOptions_IdempotencyLevel::IDEMPOTENT
    Number(n) if n == 0 => MethodOptions_IdempotencyLevel::IDEMPOTENCY_UNKNOWN
    Number(n) if n == 1 => MethodOptions_IdempotencyLevel::NO_SIDE_EFFECTS
    Number(n) if n == 2 => MethodOptions_IdempotencyLevel::IDEMPOTENT
    _ =>
      raise @json.JsonDecodeError(
        (path, "Expected a number or string for enum"),
      )
  }
}

///|
pub impl ToJson for MethodOptions_IdempotencyLevel with to_json(
  self : MethodOptions_IdempotencyLevel
) -> Json {
  match self {
    MethodOptions_IdempotencyLevel::IDEMPOTENCY_UNKNOWN => "IDEMPOTENCY_UNKNOWN"
    MethodOptions_IdempotencyLevel::NO_SIDE_EFFECTS => "NO_SIDE_EFFECTS"
    MethodOptions_IdempotencyLevel::IDEMPOTENT => "IDEMPOTENT"
  }
}

///|
pub(all) struct MethodOptions {
  mut deprecated : Bool?
  mut idempotency_level : MethodOptions_IdempotencyLevel?
  mut features : FeatureSet?
  mut uninterpreted_option : Array[UninterpretedOption]
} derive(Eq, Show)

///|
pub impl @lib.Sized for MethodOptions with size_of(self) {
  let mut size = 0U
  match self.deprecated {
    Some(v) => size += 2U + @lib.size_of(v)
    None => ()
  }
  match self.idempotency_level {
    Some(v) => size += 2U + @lib.size_of(v)
    None => ()
  }
  match self.features {
    Some(v) =>
      size += 2U +
        {
          let size = @lib.size_of(v)
          @lib.size_of(size) + size
        }
    None => ()
  }
  size += self.uninterpreted_option
    .iter()
    .map(@lib.size_of)
    .map(s => 2U + @lib.size_of(s) + s)
    .fold(init=0U, UInt::op_add)
  size
}

///|
pub impl Default for MethodOptions with default() -> MethodOptions {
  MethodOptions::{
    deprecated: Some(false),
    idempotency_level: Some(MethodOptions_IdempotencyLevel::IDEMPOTENCY_UNKNOWN),
    features: None,
    uninterpreted_option: [],
  }
}

///|
pub impl @lib.Read for MethodOptions with read(reader : &@lib.Reader) {
  let msg = MethodOptions::default()
  while not(reader |> @lib.is_eof()) {
    match (reader |> @lib.read_tag()) {
      (33, _) => msg.deprecated = reader |> @lib.read_bool() |> Some
      (34, _) =>
        msg.idempotency_level = reader
          |> @lib.read_enum()
          |> MethodOptions_IdempotencyLevel::from_enum
          |> Some
      (35, _) =>
        msg.features = (reader |> @lib.read_message() : FeatureSet) |> Some
      (999, _) =>
        msg.uninterpreted_option.push(
          (reader |> @lib.read_message() : UninterpretedOption),
        )
      (_, wire) => reader |> @lib.read_unknown(wire)
    }
  }
  msg
}

///|
pub impl @lib.Write for MethodOptions with write(self, writer) {
  match self.deprecated {
    Some(v) => {
      writer |> @lib.write_varint(264UL)
      writer |> @lib.write_bool(v)
    }
    None => ()
  }
  match self.idempotency_level {
    Some(v) => {
      writer |> @lib.write_varint(272UL)
      writer |> @lib.write_enum(v.to_enum())
    }
    None => ()
  }
  match self.features {
    Some(v) => {
      writer |> @lib.write_varint(282UL)
      writer |> @lib.write_uint32(@lib.size_of(v))
      @lib.Write::write(v, writer)
    }
    None => ()
  }
  self.uninterpreted_option
  .iter()
  .each(fn(v) {
    writer |> @lib.write_varint(7994UL)
    writer |> @lib.write_uint32(@lib.size_of(v))
    @lib.Write::write(v, writer)
  })
}

///|
pub impl ToJson for MethodOptions with to_json(self) {
  let json : Map[String, Json] = {}
  match self.deprecated {
    Some(v) if v != false => json["deprecated"] = v.to_json()
    _ => ()
  }
  match self.idempotency_level {
    Some(v) if v != MethodOptions_IdempotencyLevel::IDEMPOTENCY_UNKNOWN =>
      json["idempotencyLevel"] = v.to_json()
    _ => ()
  }
  match self.features {
    Some(v) => json["features"] = v.to_json()
    _ => ()
  }
  if self.uninterpreted_option != Default::default() {
    json["uninterpretedOption"] = self.uninterpreted_option.to_json()
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for MethodOptions with from_json(
  json : Json,
  path : @json.JsonPath
) -> MethodOptions raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError((path, "Expected an object for MethodOptions"))
  }
  let message = MethodOptions::default()
  for key, value in obj {
    match (key, value) {
      ("deprecated", value) =>
        message.deprecated = Some(@json.from_json(value, path~))
      ("idempotencyLevel", value) =>
        message.idempotency_level = Some(@json.from_json(value, path~))
      ("features", value) =>
        message.features = Some(@json.from_json(value, path~))
      ("uninterpretedOption", Array(value)) =>
        message.uninterpreted_option = value.map(v => @json.from_json(v, path~))
      key => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub(all) struct UninterpretedOption_NamePart {
  mut name_part : String
  mut is_extension : Bool
} derive(Eq, Show)

///|
pub impl @lib.Sized for UninterpretedOption_NamePart with size_of(self) {
  let mut size = 0U
  size += 1U +
    {
      let size = @lib.size_of(self.name_part)
      @lib.size_of(size) + size
    }
  size += 1U + @lib.size_of(self.is_extension)
  size
}

///|
pub impl Default for UninterpretedOption_NamePart with default() -> UninterpretedOption_NamePart {
  UninterpretedOption_NamePart::{
    name_part: String::default(),
    is_extension: Bool::default(),
  }
}

///|
pub impl @lib.Read for UninterpretedOption_NamePart with read(
  reader : &@lib.Reader
) {
  let msg = UninterpretedOption_NamePart::default()
  while not(reader |> @lib.is_eof()) {
    match (reader |> @lib.read_tag()) {
      (1, _) => msg.name_part = reader |> @lib.read_string()
      (2, _) => msg.is_extension = reader |> @lib.read_bool()
      (_, wire) => reader |> @lib.read_unknown(wire)
    }
  }
  msg
}

///|
pub impl @lib.Write for UninterpretedOption_NamePart with write(self, writer) {
  writer |> @lib.write_varint(10UL)
  writer |> @lib.write_string(self.name_part)
  writer |> @lib.write_varint(16UL)
  writer |> @lib.write_bool(self.is_extension)
}

///|
pub impl ToJson for UninterpretedOption_NamePart with to_json(self) {
  let json : Map[String, Json] = {}
  if self.name_part != Default::default() {
    json["namePart"] = self.name_part.to_json()
  }
  if self.is_extension != Default::default() {
    json["isExtension"] = self.is_extension.to_json()
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for UninterpretedOption_NamePart with from_json(
  json : Json,
  path : @json.JsonPath
) -> UninterpretedOption_NamePart raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError(
      (path, "Expected an object for UninterpretedOption_NamePart"),
    )
  }
  let message = UninterpretedOption_NamePart::default()
  for key, value in obj {
    match (key, value) {
      ("namePart", value) => message.name_part = @json.from_json(value, path~)
      ("isExtension", value) =>
        message.is_extension = @json.from_json(value, path~)
      key => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub(all) struct UninterpretedOption {
  mut name : Array[UninterpretedOption_NamePart]
  mut identifier_value : String?
  mut positive_int_value : UInt64?
  mut negative_int_value : Int64?
  mut double_value : Double?
  mut string_value : Bytes?
  mut aggregate_value : String?
} derive(Eq, Show)

///|
pub impl @lib.Sized for UninterpretedOption with size_of(self) {
  let mut size = 0U
  size += self.name
    .iter()
    .map(@lib.size_of)
    .map(s => 1U + @lib.size_of(s) + s)
    .fold(init=0U, UInt::op_add)
  match self.identifier_value {
    Some(v) =>
      size += 1U +
        {
          let size = @lib.size_of(v)
          @lib.size_of(size) + size
        }
    None => ()
  }
  match self.positive_int_value {
    Some(v) => size += 1U + @lib.size_of(v)
    None => ()
  }
  match self.negative_int_value {
    Some(v) => size += 1U + @lib.size_of(v)
    None => ()
  }
  match self.double_value {
    Some(v) => size += 1U + 8U
    None => ()
  }
  match self.string_value {
    Some(v) =>
      size += 1U +
        {
          let size = @lib.size_of(v)
          @lib.size_of(size) + size
        }
    None => ()
  }
  match self.aggregate_value {
    Some(v) =>
      size += 1U +
        {
          let size = @lib.size_of(v)
          @lib.size_of(size) + size
        }
    None => ()
  }
  size
}

///|
pub impl Default for UninterpretedOption with default() -> UninterpretedOption {
  UninterpretedOption::{
    name: [],
    identifier_value: None,
    positive_int_value: None,
    negative_int_value: None,
    double_value: None,
    string_value: None,
    aggregate_value: None,
  }
}

///|
pub impl @lib.Read for UninterpretedOption with read(reader : &@lib.Reader) {
  let msg = UninterpretedOption::default()
  while not(reader |> @lib.is_eof()) {
    match (reader |> @lib.read_tag()) {
      (2, _) =>
        msg.name.push(
          (reader |> @lib.read_message() : UninterpretedOption_NamePart),
        )
      (3, _) => msg.identifier_value = reader |> @lib.read_string() |> Some
      (4, _) => msg.positive_int_value = reader |> @lib.read_uint64() |> Some
      (5, _) => msg.negative_int_value = reader |> @lib.read_int64() |> Some
      (6, _) => msg.double_value = reader |> @lib.read_double() |> Some
      (7, _) => msg.string_value = reader |> @lib.read_bytes() |> Some
      (8, _) => msg.aggregate_value = reader |> @lib.read_string() |> Some
      (_, wire) => reader |> @lib.read_unknown(wire)
    }
  }
  msg
}

///|
pub impl @lib.Write for UninterpretedOption with write(self, writer) {
  self.name
  .iter()
  .each(fn(v) {
    writer |> @lib.write_varint(18UL)
    writer |> @lib.write_uint32(@lib.size_of(v))
    @lib.Write::write(v, writer)
  })
  match self.identifier_value {
    Some(v) => {
      writer |> @lib.write_varint(26UL)
      writer |> @lib.write_string(v)
    }
    None => ()
  }
  match self.positive_int_value {
    Some(v) => {
      writer |> @lib.write_varint(32UL)
      writer |> @lib.write_uint64(v)
    }
    None => ()
  }
  match self.negative_int_value {
    Some(v) => {
      writer |> @lib.write_varint(40UL)
      writer |> @lib.write_int64(v)
    }
    None => ()
  }
  match self.double_value {
    Some(v) => {
      writer |> @lib.write_varint(49UL)
      writer |> @lib.write_double(v)
    }
    None => ()
  }
  match self.string_value {
    Some(v) => {
      writer |> @lib.write_varint(58UL)
      writer |> @lib.write_bytes(v)
    }
    None => ()
  }
  match self.aggregate_value {
    Some(v) => {
      writer |> @lib.write_varint(66UL)
      writer |> @lib.write_string(v)
    }
    None => ()
  }
}

///|
pub impl ToJson for UninterpretedOption with to_json(self) {
  let json : Map[String, Json] = {}
  if self.name != Default::default() {
    json["name"] = self.name.to_json()
  }
  match self.identifier_value {
    Some(v) => json["identifierValue"] = v.to_json()
    _ => ()
  }
  match self.positive_int_value {
    Some(v) => json["positiveIntValue"] = v.to_json()
    _ => ()
  }
  match self.negative_int_value {
    Some(v) => json["negativeIntValue"] = v.to_json()
    _ => ()
  }
  match self.double_value {
    Some(v) => json["doubleValue"] = v.to_json()
    _ => ()
  }
  match self.string_value {
    Some(v) => json["stringValue"] = @lib.base64_encode(v).to_json()
    _ => ()
  }
  match self.aggregate_value {
    Some(v) => json["aggregateValue"] = v.to_json()
    _ => ()
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for UninterpretedOption with from_json(
  json : Json,
  path : @json.JsonPath
) -> UninterpretedOption raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError(
      (path, "Expected an object for UninterpretedOption"),
    )
  }
  let message = UninterpretedOption::default()
  for key, value in obj {
    match (key, value) {
      ("name", Array(value)) =>
        message.name = value.map(v => @json.from_json(v, path~))
      ("identifierValue", value) =>
        message.identifier_value = Some(@json.from_json(value, path~))
      ("positiveIntValue", value) =>
        message.positive_int_value = Some(@json.from_json(value, path~))
      ("negativeIntValue", value) =>
        message.negative_int_value = Some(@json.from_json(value, path~))
      ("doubleValue", value) =>
        message.double_value = Some(@json.from_json(value, path~))
      ("stringValue", String(value)) =>
        message.string_value = Some(@lib.base64_decode(value))
      ("aggregateValue", value) =>
        message.aggregate_value = Some(@json.from_json(value, path~))
      key => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub(all) enum FeatureSet_FieldPresence {
  FIELD_PRESENCE_UNKNOWN
  EXPLICIT
  IMPLICIT
  LEGACY_REQUIRED
} derive(Eq, Show)

///|
pub fn FeatureSet_FieldPresence::to_enum(
  self : FeatureSet_FieldPresence
) -> @lib.Enum {
  match self {
    FeatureSet_FieldPresence::FIELD_PRESENCE_UNKNOWN => 0
    FeatureSet_FieldPresence::EXPLICIT => 1
    FeatureSet_FieldPresence::IMPLICIT => 2
    FeatureSet_FieldPresence::LEGACY_REQUIRED => 3
  }
}

///|
pub fn FeatureSet_FieldPresence::from_enum(
  i : @lib.Enum
) -> FeatureSet_FieldPresence {
  match i.inner() {
    0 => FeatureSet_FieldPresence::FIELD_PRESENCE_UNKNOWN
    1 => FeatureSet_FieldPresence::EXPLICIT
    2 => FeatureSet_FieldPresence::IMPLICIT
    3 => FeatureSet_FieldPresence::LEGACY_REQUIRED
    _ => Default::default()
  }
}

///|
pub impl Default for FeatureSet_FieldPresence with default() -> FeatureSet_FieldPresence {
  FeatureSet_FieldPresence::FIELD_PRESENCE_UNKNOWN
}

///|
pub impl @lib.Sized for FeatureSet_FieldPresence with size_of(
  self : FeatureSet_FieldPresence
) {
  @lib.Sized::size_of(self.to_enum())
}

///|
pub impl @json.FromJson for FeatureSet_FieldPresence with from_json(
  json : Json,
  path : @json.JsonPath
) -> FeatureSet_FieldPresence raise {
  match json {
    String(s) if s == "FIELD_PRESENCE_UNKNOWN" =>
      FeatureSet_FieldPresence::FIELD_PRESENCE_UNKNOWN
    String(s) if s == "EXPLICIT" => FeatureSet_FieldPresence::EXPLICIT
    String(s) if s == "IMPLICIT" => FeatureSet_FieldPresence::IMPLICIT
    String(s) if s == "LEGACY_REQUIRED" =>
      FeatureSet_FieldPresence::LEGACY_REQUIRED
    Number(n) if n == 0 => FeatureSet_FieldPresence::FIELD_PRESENCE_UNKNOWN
    Number(n) if n == 1 => FeatureSet_FieldPresence::EXPLICIT
    Number(n) if n == 2 => FeatureSet_FieldPresence::IMPLICIT
    Number(n) if n == 3 => FeatureSet_FieldPresence::LEGACY_REQUIRED
    _ =>
      raise @json.JsonDecodeError(
        (path, "Expected a number or string for enum"),
      )
  }
}

///|
pub impl ToJson for FeatureSet_FieldPresence with to_json(
  self : FeatureSet_FieldPresence
) -> Json {
  match self {
    FeatureSet_FieldPresence::FIELD_PRESENCE_UNKNOWN => "FIELD_PRESENCE_UNKNOWN"
    FeatureSet_FieldPresence::EXPLICIT => "EXPLICIT"
    FeatureSet_FieldPresence::IMPLICIT => "IMPLICIT"
    FeatureSet_FieldPresence::LEGACY_REQUIRED => "LEGACY_REQUIRED"
  }
}

///|
pub(all) enum FeatureSet_EnumType {
  ENUM_TYPE_UNKNOWN
  OPEN
  CLOSED
} derive(Eq, Show)

///|
pub fn FeatureSet_EnumType::to_enum(self : FeatureSet_EnumType) -> @lib.Enum {
  match self {
    FeatureSet_EnumType::ENUM_TYPE_UNKNOWN => 0
    FeatureSet_EnumType::OPEN => 1
    FeatureSet_EnumType::CLOSED => 2
  }
}

///|
pub fn FeatureSet_EnumType::from_enum(i : @lib.Enum) -> FeatureSet_EnumType {
  match i.inner() {
    0 => FeatureSet_EnumType::ENUM_TYPE_UNKNOWN
    1 => FeatureSet_EnumType::OPEN
    2 => FeatureSet_EnumType::CLOSED
    _ => Default::default()
  }
}

///|
pub impl Default for FeatureSet_EnumType with default() -> FeatureSet_EnumType {
  FeatureSet_EnumType::ENUM_TYPE_UNKNOWN
}

///|
pub impl @lib.Sized for FeatureSet_EnumType with size_of(
  self : FeatureSet_EnumType
) {
  @lib.Sized::size_of(self.to_enum())
}

///|
pub impl @json.FromJson for FeatureSet_EnumType with from_json(
  json : Json,
  path : @json.JsonPath
) -> FeatureSet_EnumType raise {
  match json {
    String(s) if s == "ENUM_TYPE_UNKNOWN" =>
      FeatureSet_EnumType::ENUM_TYPE_UNKNOWN
    String(s) if s == "OPEN" => FeatureSet_EnumType::OPEN
    String(s) if s == "CLOSED" => FeatureSet_EnumType::CLOSED
    Number(n) if n == 0 => FeatureSet_EnumType::ENUM_TYPE_UNKNOWN
    Number(n) if n == 1 => FeatureSet_EnumType::OPEN
    Number(n) if n == 2 => FeatureSet_EnumType::CLOSED
    _ =>
      raise @json.JsonDecodeError(
        (path, "Expected a number or string for enum"),
      )
  }
}

///|
pub impl ToJson for FeatureSet_EnumType with to_json(self : FeatureSet_EnumType) -> Json {
  match self {
    FeatureSet_EnumType::ENUM_TYPE_UNKNOWN => "ENUM_TYPE_UNKNOWN"
    FeatureSet_EnumType::OPEN => "OPEN"
    FeatureSet_EnumType::CLOSED => "CLOSED"
  }
}

///|
pub(all) enum FeatureSet_RepeatedFieldEncoding {
  REPEATED_FIELD_ENCODING_UNKNOWN
  PACKED
  EXPANDED
} derive(Eq, Show)

///|
pub fn FeatureSet_RepeatedFieldEncoding::to_enum(
  self : FeatureSet_RepeatedFieldEncoding
) -> @lib.Enum {
  match self {
    FeatureSet_RepeatedFieldEncoding::REPEATED_FIELD_ENCODING_UNKNOWN => 0
    FeatureSet_RepeatedFieldEncoding::PACKED => 1
    FeatureSet_RepeatedFieldEncoding::EXPANDED => 2
  }
}

///|
pub fn FeatureSet_RepeatedFieldEncoding::from_enum(
  i : @lib.Enum
) -> FeatureSet_RepeatedFieldEncoding {
  match i.inner() {
    0 => FeatureSet_RepeatedFieldEncoding::REPEATED_FIELD_ENCODING_UNKNOWN
    1 => FeatureSet_RepeatedFieldEncoding::PACKED
    2 => FeatureSet_RepeatedFieldEncoding::EXPANDED
    _ => Default::default()
  }
}

///|
pub impl Default for FeatureSet_RepeatedFieldEncoding with default() -> FeatureSet_RepeatedFieldEncoding {
  FeatureSet_RepeatedFieldEncoding::REPEATED_FIELD_ENCODING_UNKNOWN
}

///|
pub impl @lib.Sized for FeatureSet_RepeatedFieldEncoding with size_of(
  self : FeatureSet_RepeatedFieldEncoding
) {
  @lib.Sized::size_of(self.to_enum())
}

///|
pub impl @json.FromJson for FeatureSet_RepeatedFieldEncoding with from_json(
  json : Json,
  path : @json.JsonPath
) -> FeatureSet_RepeatedFieldEncoding raise {
  match json {
    String(s) if s == "REPEATED_FIELD_ENCODING_UNKNOWN" =>
      FeatureSet_RepeatedFieldEncoding::REPEATED_FIELD_ENCODING_UNKNOWN
    String(s) if s == "PACKED" => FeatureSet_RepeatedFieldEncoding::PACKED
    String(s) if s == "EXPANDED" => FeatureSet_RepeatedFieldEncoding::EXPANDED
    Number(n) if n == 0 =>
      FeatureSet_RepeatedFieldEncoding::REPEATED_FIELD_ENCODING_UNKNOWN
    Number(n) if n == 1 => FeatureSet_RepeatedFieldEncoding::PACKED
    Number(n) if n == 2 => FeatureSet_RepeatedFieldEncoding::EXPANDED
    _ =>
      raise @json.JsonDecodeError(
        (path, "Expected a number or string for enum"),
      )
  }
}

///|
pub impl ToJson for FeatureSet_RepeatedFieldEncoding with to_json(
  self : FeatureSet_RepeatedFieldEncoding
) -> Json {
  match self {
    FeatureSet_RepeatedFieldEncoding::REPEATED_FIELD_ENCODING_UNKNOWN =>
      "REPEATED_FIELD_ENCODING_UNKNOWN"
    FeatureSet_RepeatedFieldEncoding::PACKED => "PACKED"
    FeatureSet_RepeatedFieldEncoding::EXPANDED => "EXPANDED"
  }
}

///|
pub(all) enum FeatureSet_Utf8Validation {
  UTF8_VALIDATION_UNKNOWN
  VERIFY
  NONE
} derive(Eq, Show)

///|
pub fn FeatureSet_Utf8Validation::to_enum(
  self : FeatureSet_Utf8Validation
) -> @lib.Enum {
  match self {
    FeatureSet_Utf8Validation::UTF8_VALIDATION_UNKNOWN => 0
    FeatureSet_Utf8Validation::VERIFY => 2
    FeatureSet_Utf8Validation::NONE => 3
  }
}

///|
pub fn FeatureSet_Utf8Validation::from_enum(
  i : @lib.Enum
) -> FeatureSet_Utf8Validation {
  match i.inner() {
    0 => FeatureSet_Utf8Validation::UTF8_VALIDATION_UNKNOWN
    2 => FeatureSet_Utf8Validation::VERIFY
    3 => FeatureSet_Utf8Validation::NONE
    _ => Default::default()
  }
}

///|
pub impl Default for FeatureSet_Utf8Validation with default() -> FeatureSet_Utf8Validation {
  FeatureSet_Utf8Validation::UTF8_VALIDATION_UNKNOWN
}

///|
pub impl @lib.Sized for FeatureSet_Utf8Validation with size_of(
  self : FeatureSet_Utf8Validation
) {
  @lib.Sized::size_of(self.to_enum())
}

///|
pub impl @json.FromJson for FeatureSet_Utf8Validation with from_json(
  json : Json,
  path : @json.JsonPath
) -> FeatureSet_Utf8Validation raise {
  match json {
    String(s) if s == "UTF8_VALIDATION_UNKNOWN" =>
      FeatureSet_Utf8Validation::UTF8_VALIDATION_UNKNOWN
    String(s) if s == "VERIFY" => FeatureSet_Utf8Validation::VERIFY
    String(s) if s == "NONE" => FeatureSet_Utf8Validation::NONE
    Number(n) if n == 0 => FeatureSet_Utf8Validation::UTF8_VALIDATION_UNKNOWN
    Number(n) if n == 2 => FeatureSet_Utf8Validation::VERIFY
    Number(n) if n == 3 => FeatureSet_Utf8Validation::NONE
    _ =>
      raise @json.JsonDecodeError(
        (path, "Expected a number or string for enum"),
      )
  }
}

///|
pub impl ToJson for FeatureSet_Utf8Validation with to_json(
  self : FeatureSet_Utf8Validation
) -> Json {
  match self {
    FeatureSet_Utf8Validation::UTF8_VALIDATION_UNKNOWN =>
      "UTF8_VALIDATION_UNKNOWN"
    FeatureSet_Utf8Validation::VERIFY => "VERIFY"
    FeatureSet_Utf8Validation::NONE => "NONE"
  }
}

///|
pub(all) enum FeatureSet_MessageEncoding {
  MESSAGE_ENCODING_UNKNOWN
  LENGTH_PREFIXED
  DELIMITED
} derive(Eq, Show)

///|
pub fn FeatureSet_MessageEncoding::to_enum(
  self : FeatureSet_MessageEncoding
) -> @lib.Enum {
  match self {
    FeatureSet_MessageEncoding::MESSAGE_ENCODING_UNKNOWN => 0
    FeatureSet_MessageEncoding::LENGTH_PREFIXED => 1
    FeatureSet_MessageEncoding::DELIMITED => 2
  }
}

///|
pub fn FeatureSet_MessageEncoding::from_enum(
  i : @lib.Enum
) -> FeatureSet_MessageEncoding {
  match i.inner() {
    0 => FeatureSet_MessageEncoding::MESSAGE_ENCODING_UNKNOWN
    1 => FeatureSet_MessageEncoding::LENGTH_PREFIXED
    2 => FeatureSet_MessageEncoding::DELIMITED
    _ => Default::default()
  }
}

///|
pub impl Default for FeatureSet_MessageEncoding with default() -> FeatureSet_MessageEncoding {
  FeatureSet_MessageEncoding::MESSAGE_ENCODING_UNKNOWN
}

///|
pub impl @lib.Sized for FeatureSet_MessageEncoding with size_of(
  self : FeatureSet_MessageEncoding
) {
  @lib.Sized::size_of(self.to_enum())
}

///|
pub impl @json.FromJson for FeatureSet_MessageEncoding with from_json(
  json : Json,
  path : @json.JsonPath
) -> FeatureSet_MessageEncoding raise {
  match json {
    String(s) if s == "MESSAGE_ENCODING_UNKNOWN" =>
      FeatureSet_MessageEncoding::MESSAGE_ENCODING_UNKNOWN
    String(s) if s == "LENGTH_PREFIXED" =>
      FeatureSet_MessageEncoding::LENGTH_PREFIXED
    String(s) if s == "DELIMITED" => FeatureSet_MessageEncoding::DELIMITED
    Number(n) if n == 0 => FeatureSet_MessageEncoding::MESSAGE_ENCODING_UNKNOWN
    Number(n) if n == 1 => FeatureSet_MessageEncoding::LENGTH_PREFIXED
    Number(n) if n == 2 => FeatureSet_MessageEncoding::DELIMITED
    _ =>
      raise @json.JsonDecodeError(
        (path, "Expected a number or string for enum"),
      )
  }
}

///|
pub impl ToJson for FeatureSet_MessageEncoding with to_json(
  self : FeatureSet_MessageEncoding
) -> Json {
  match self {
    FeatureSet_MessageEncoding::MESSAGE_ENCODING_UNKNOWN =>
      "MESSAGE_ENCODING_UNKNOWN"
    FeatureSet_MessageEncoding::LENGTH_PREFIXED => "LENGTH_PREFIXED"
    FeatureSet_MessageEncoding::DELIMITED => "DELIMITED"
  }
}

///|
pub(all) enum FeatureSet_JsonFormat {
  JSON_FORMAT_UNKNOWN
  ALLOW
  LEGACY_BEST_EFFORT
} derive(Eq, Show)

///|
pub fn FeatureSet_JsonFormat::to_enum(
  self : FeatureSet_JsonFormat
) -> @lib.Enum {
  match self {
    FeatureSet_JsonFormat::JSON_FORMAT_UNKNOWN => 0
    FeatureSet_JsonFormat::ALLOW => 1
    FeatureSet_JsonFormat::LEGACY_BEST_EFFORT => 2
  }
}

///|
pub fn FeatureSet_JsonFormat::from_enum(i : @lib.Enum) -> FeatureSet_JsonFormat {
  match i.inner() {
    0 => FeatureSet_JsonFormat::JSON_FORMAT_UNKNOWN
    1 => FeatureSet_JsonFormat::ALLOW
    2 => FeatureSet_JsonFormat::LEGACY_BEST_EFFORT
    _ => Default::default()
  }
}

///|
pub impl Default for FeatureSet_JsonFormat with default() -> FeatureSet_JsonFormat {
  FeatureSet_JsonFormat::JSON_FORMAT_UNKNOWN
}

///|
pub impl @lib.Sized for FeatureSet_JsonFormat with size_of(
  self : FeatureSet_JsonFormat
) {
  @lib.Sized::size_of(self.to_enum())
}

///|
pub impl @json.FromJson for FeatureSet_JsonFormat with from_json(
  json : Json,
  path : @json.JsonPath
) -> FeatureSet_JsonFormat raise {
  match json {
    String(s) if s == "JSON_FORMAT_UNKNOWN" =>
      FeatureSet_JsonFormat::JSON_FORMAT_UNKNOWN
    String(s) if s == "ALLOW" => FeatureSet_JsonFormat::ALLOW
    String(s) if s == "LEGACY_BEST_EFFORT" =>
      FeatureSet_JsonFormat::LEGACY_BEST_EFFORT
    Number(n) if n == 0 => FeatureSet_JsonFormat::JSON_FORMAT_UNKNOWN
    Number(n) if n == 1 => FeatureSet_JsonFormat::ALLOW
    Number(n) if n == 2 => FeatureSet_JsonFormat::LEGACY_BEST_EFFORT
    _ =>
      raise @json.JsonDecodeError(
        (path, "Expected a number or string for enum"),
      )
  }
}

///|
pub impl ToJson for FeatureSet_JsonFormat with to_json(
  self : FeatureSet_JsonFormat
) -> Json {
  match self {
    FeatureSet_JsonFormat::JSON_FORMAT_UNKNOWN => "JSON_FORMAT_UNKNOWN"
    FeatureSet_JsonFormat::ALLOW => "ALLOW"
    FeatureSet_JsonFormat::LEGACY_BEST_EFFORT => "LEGACY_BEST_EFFORT"
  }
}

///|
pub(all) struct FeatureSet {
  mut field_presence : FeatureSet_FieldPresence?
  mut enum_type : FeatureSet_EnumType?
  mut repeated_field_encoding : FeatureSet_RepeatedFieldEncoding?
  mut utf8_validation : FeatureSet_Utf8Validation?
  mut message_encoding : FeatureSet_MessageEncoding?
  mut json_format : FeatureSet_JsonFormat?
} derive(Eq, Show)

///|
pub impl @lib.Sized for FeatureSet with size_of(self) {
  let mut size = 0U
  match self.field_presence {
    Some(v) => size += 1U + @lib.size_of(v)
    None => ()
  }
  match self.enum_type {
    Some(v) => size += 1U + @lib.size_of(v)
    None => ()
  }
  match self.repeated_field_encoding {
    Some(v) => size += 1U + @lib.size_of(v)
    None => ()
  }
  match self.utf8_validation {
    Some(v) => size += 1U + @lib.size_of(v)
    None => ()
  }
  match self.message_encoding {
    Some(v) => size += 1U + @lib.size_of(v)
    None => ()
  }
  match self.json_format {
    Some(v) => size += 1U + @lib.size_of(v)
    None => ()
  }
  size
}

///|
pub impl Default for FeatureSet with default() -> FeatureSet {
  FeatureSet::{
    field_presence: None,
    enum_type: None,
    repeated_field_encoding: None,
    utf8_validation: None,
    message_encoding: None,
    json_format: None,
  }
}

///|
pub impl @lib.Read for FeatureSet with read(reader : &@lib.Reader) {
  let msg = FeatureSet::default()
  while not(reader |> @lib.is_eof()) {
    match (reader |> @lib.read_tag()) {
      (1, _) =>
        msg.field_presence = reader
          |> @lib.read_enum()
          |> FeatureSet_FieldPresence::from_enum
          |> Some
      (2, _) =>
        msg.enum_type = reader
          |> @lib.read_enum()
          |> FeatureSet_EnumType::from_enum
          |> Some
      (3, _) =>
        msg.repeated_field_encoding = reader
          |> @lib.read_enum()
          |> FeatureSet_RepeatedFieldEncoding::from_enum
          |> Some
      (4, _) =>
        msg.utf8_validation = reader
          |> @lib.read_enum()
          |> FeatureSet_Utf8Validation::from_enum
          |> Some
      (5, _) =>
        msg.message_encoding = reader
          |> @lib.read_enum()
          |> FeatureSet_MessageEncoding::from_enum
          |> Some
      (6, _) =>
        msg.json_format = reader
          |> @lib.read_enum()
          |> FeatureSet_JsonFormat::from_enum
          |> Some
      (_, wire) => reader |> @lib.read_unknown(wire)
    }
  }
  msg
}

///|
pub impl @lib.Write for FeatureSet with write(self, writer) {
  match self.field_presence {
    Some(v) => {
      writer |> @lib.write_varint(8UL)
      writer |> @lib.write_enum(v.to_enum())
    }
    None => ()
  }
  match self.enum_type {
    Some(v) => {
      writer |> @lib.write_varint(16UL)
      writer |> @lib.write_enum(v.to_enum())
    }
    None => ()
  }
  match self.repeated_field_encoding {
    Some(v) => {
      writer |> @lib.write_varint(24UL)
      writer |> @lib.write_enum(v.to_enum())
    }
    None => ()
  }
  match self.utf8_validation {
    Some(v) => {
      writer |> @lib.write_varint(32UL)
      writer |> @lib.write_enum(v.to_enum())
    }
    None => ()
  }
  match self.message_encoding {
    Some(v) => {
      writer |> @lib.write_varint(40UL)
      writer |> @lib.write_enum(v.to_enum())
    }
    None => ()
  }
  match self.json_format {
    Some(v) => {
      writer |> @lib.write_varint(48UL)
      writer |> @lib.write_enum(v.to_enum())
    }
    None => ()
  }
}

///|
pub impl ToJson for FeatureSet with to_json(self) {
  let json : Map[String, Json] = {}
  match self.field_presence {
    Some(v) => json["fieldPresence"] = v.to_json()
    _ => ()
  }
  match self.enum_type {
    Some(v) => json["enumType"] = v.to_json()
    _ => ()
  }
  match self.repeated_field_encoding {
    Some(v) => json["repeatedFieldEncoding"] = v.to_json()
    _ => ()
  }
  match self.utf8_validation {
    Some(v) => json["utf8Validation"] = v.to_json()
    _ => ()
  }
  match self.message_encoding {
    Some(v) => json["messageEncoding"] = v.to_json()
    _ => ()
  }
  match self.json_format {
    Some(v) => json["jsonFormat"] = v.to_json()
    _ => ()
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for FeatureSet with from_json(
  json : Json,
  path : @json.JsonPath
) -> FeatureSet raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError((path, "Expected an object for FeatureSet"))
  }
  let message = FeatureSet::default()
  for key, value in obj {
    match (key, value) {
      ("fieldPresence", value) =>
        message.field_presence = Some(@json.from_json(value, path~))
      ("enumType", value) =>
        message.enum_type = Some(@json.from_json(value, path~))
      ("repeatedFieldEncoding", value) =>
        message.repeated_field_encoding = Some(@json.from_json(value, path~))
      ("utf8Validation", value) =>
        message.utf8_validation = Some(@json.from_json(value, path~))
      ("messageEncoding", value) =>
        message.message_encoding = Some(@json.from_json(value, path~))
      ("jsonFormat", value) =>
        message.json_format = Some(@json.from_json(value, path~))
      key => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub(all) struct FeatureSetDefaults_FeatureSetEditionDefault {
  mut edition : Edition?
  mut overridable_features : FeatureSet?
  mut fixed_features : FeatureSet?
} derive(Eq, Show)

///|
pub impl @lib.Sized for FeatureSetDefaults_FeatureSetEditionDefault with size_of(
  self
) {
  let mut size = 0U
  match self.edition {
    Some(v) => size += 1U + @lib.size_of(v)
    None => ()
  }
  match self.overridable_features {
    Some(v) =>
      size += 1U +
        {
          let size = @lib.size_of(v)
          @lib.size_of(size) + size
        }
    None => ()
  }
  match self.fixed_features {
    Some(v) =>
      size += 1U +
        {
          let size = @lib.size_of(v)
          @lib.size_of(size) + size
        }
    None => ()
  }
  size
}

///|
pub impl Default for FeatureSetDefaults_FeatureSetEditionDefault with default() -> FeatureSetDefaults_FeatureSetEditionDefault {
  FeatureSetDefaults_FeatureSetEditionDefault::{
    edition: None,
    overridable_features: None,
    fixed_features: None,
  }
}

///|
pub impl @lib.Read for FeatureSetDefaults_FeatureSetEditionDefault with read(
  reader : &@lib.Reader
) {
  let msg = FeatureSetDefaults_FeatureSetEditionDefault::default()
  while not(reader |> @lib.is_eof()) {
    match (reader |> @lib.read_tag()) {
      (3, _) =>
        msg.edition = reader |> @lib.read_enum() |> Edition::from_enum |> Some
      (4, _) =>
        msg.overridable_features = (reader |> @lib.read_message() : FeatureSet)
          |> Some
      (5, _) =>
        msg.fixed_features = (reader |> @lib.read_message() : FeatureSet)
          |> Some
      (_, wire) => reader |> @lib.read_unknown(wire)
    }
  }
  msg
}

///|
pub impl @lib.Write for FeatureSetDefaults_FeatureSetEditionDefault with write(
  self,
  writer
) {
  match self.edition {
    Some(v) => {
      writer |> @lib.write_varint(24UL)
      writer |> @lib.write_enum(v.to_enum())
    }
    None => ()
  }
  match self.overridable_features {
    Some(v) => {
      writer |> @lib.write_varint(34UL)
      writer |> @lib.write_uint32(@lib.size_of(v))
      @lib.Write::write(v, writer)
    }
    None => ()
  }
  match self.fixed_features {
    Some(v) => {
      writer |> @lib.write_varint(42UL)
      writer |> @lib.write_uint32(@lib.size_of(v))
      @lib.Write::write(v, writer)
    }
    None => ()
  }
}

///|
pub impl ToJson for FeatureSetDefaults_FeatureSetEditionDefault with to_json(
  self
) {
  let json : Map[String, Json] = {}
  match self.edition {
    Some(v) => json["edition"] = v.to_json()
    _ => ()
  }
  match self.overridable_features {
    Some(v) => json["overridableFeatures"] = v.to_json()
    _ => ()
  }
  match self.fixed_features {
    Some(v) => json["fixedFeatures"] = v.to_json()
    _ => ()
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for FeatureSetDefaults_FeatureSetEditionDefault with from_json(
  json : Json,
  path : @json.JsonPath
) -> FeatureSetDefaults_FeatureSetEditionDefault raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError(
      (
        path, "Expected an object for FeatureSetDefaults_FeatureSetEditionDefault",
      ),
    )
  }
  let message = FeatureSetDefaults_FeatureSetEditionDefault::default()
  for key, value in obj {
    match (key, value) {
      ("edition", value) =>
        message.edition = Some(@json.from_json(value, path~))
      ("overridableFeatures", value) =>
        message.overridable_features = Some(@json.from_json(value, path~))
      ("fixedFeatures", value) =>
        message.fixed_features = Some(@json.from_json(value, path~))
      key => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub(all) struct FeatureSetDefaults {
  mut defaults : Array[FeatureSetDefaults_FeatureSetEditionDefault]
  mut minimum_edition : Edition?
  mut maximum_edition : Edition?
} derive(Eq, Show)

///|
pub impl @lib.Sized for FeatureSetDefaults with size_of(self) {
  let mut size = 0U
  size += self.defaults
    .iter()
    .map(@lib.size_of)
    .map(s => 1U + @lib.size_of(s) + s)
    .fold(init=0U, UInt::op_add)
  match self.minimum_edition {
    Some(v) => size += 1U + @lib.size_of(v)
    None => ()
  }
  match self.maximum_edition {
    Some(v) => size += 1U + @lib.size_of(v)
    None => ()
  }
  size
}

///|
pub impl Default for FeatureSetDefaults with default() -> FeatureSetDefaults {
  FeatureSetDefaults::{
    defaults: [],
    minimum_edition: None,
    maximum_edition: None,
  }
}

///|
pub impl @lib.Read for FeatureSetDefaults with read(reader : &@lib.Reader) {
  let msg = FeatureSetDefaults::default()
  while not(reader |> @lib.is_eof()) {
    match (reader |> @lib.read_tag()) {
      (1, _) =>
        msg.defaults.push(
          (
            reader |> @lib.read_message() :
            FeatureSetDefaults_FeatureSetEditionDefault),
        )
      (4, _) =>
        msg.minimum_edition = reader
          |> @lib.read_enum()
          |> Edition::from_enum
          |> Some
      (5, _) =>
        msg.maximum_edition = reader
          |> @lib.read_enum()
          |> Edition::from_enum
          |> Some
      (_, wire) => reader |> @lib.read_unknown(wire)
    }
  }
  msg
}

///|
pub impl @lib.Write for FeatureSetDefaults with write(self, writer) {
  self.defaults
  .iter()
  .each(fn(v) {
    writer |> @lib.write_varint(10UL)
    writer |> @lib.write_uint32(@lib.size_of(v))
    @lib.Write::write(v, writer)
  })
  match self.minimum_edition {
    Some(v) => {
      writer |> @lib.write_varint(32UL)
      writer |> @lib.write_enum(v.to_enum())
    }
    None => ()
  }
  match self.maximum_edition {
    Some(v) => {
      writer |> @lib.write_varint(40UL)
      writer |> @lib.write_enum(v.to_enum())
    }
    None => ()
  }
}

///|
pub impl ToJson for FeatureSetDefaults with to_json(self) {
  let json : Map[String, Json] = {}
  if self.defaults != Default::default() {
    json["defaults"] = self.defaults.to_json()
  }
  match self.minimum_edition {
    Some(v) => json["minimumEdition"] = v.to_json()
    _ => ()
  }
  match self.maximum_edition {
    Some(v) => json["maximumEdition"] = v.to_json()
    _ => ()
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for FeatureSetDefaults with from_json(
  json : Json,
  path : @json.JsonPath
) -> FeatureSetDefaults raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError(
      (path, "Expected an object for FeatureSetDefaults"),
    )
  }
  let message = FeatureSetDefaults::default()
  for key, value in obj {
    match (key, value) {
      ("defaults", Array(value)) =>
        message.defaults = value.map(v => @json.from_json(v, path~))
      ("minimumEdition", value) =>
        message.minimum_edition = Some(@json.from_json(value, path~))
      ("maximumEdition", value) =>
        message.maximum_edition = Some(@json.from_json(value, path~))
      key => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub(all) struct SourceCodeInfo_Location {
  mut path : Array[Int]
  mut span : Array[Int]
  mut leading_comments : String?
  mut trailing_comments : String?
  mut leading_detached_comments : Array[String]
} derive(Eq, Show)

///|
pub impl @lib.Sized for SourceCodeInfo_Location with size_of(self) {
  let mut size = 0U
  size += 1U +
    {
      let size = self.path.iter().map(@lib.size_of).fold(init=0U, UInt::op_add)
      @lib.size_of(size) + size
    }
  size += 1U +
    {
      let size = self.span.iter().map(@lib.size_of).fold(init=0U, UInt::op_add)
      @lib.size_of(size) + size
    }
  match self.leading_comments {
    Some(v) =>
      size += 1U +
        {
          let size = @lib.size_of(v)
          @lib.size_of(size) + size
        }
    None => ()
  }
  match self.trailing_comments {
    Some(v) =>
      size += 1U +
        {
          let size = @lib.size_of(v)
          @lib.size_of(size) + size
        }
    None => ()
  }
  size += self.leading_detached_comments
    .iter()
    .map(@lib.size_of)
    .map(s => 1U + @lib.size_of(s) + s)
    .fold(init=0U, UInt::op_add)
  size
}

///|
pub impl Default for SourceCodeInfo_Location with default() -> SourceCodeInfo_Location {
  SourceCodeInfo_Location::{
    path: [],
    span: [],
    leading_comments: None,
    trailing_comments: None,
    leading_detached_comments: [],
  }
}

///|
pub impl @lib.Read for SourceCodeInfo_Location with read(reader : &@lib.Reader) {
  let msg = SourceCodeInfo_Location::default()
  while not(reader |> @lib.is_eof()) {
    match (reader |> @lib.read_tag()) {
      (1, _) =>
        msg.path.push_iter(
          (reader |> @lib.read_packed(@lib.read_int32, None)).iter(),
        )
      (2, _) =>
        msg.span.push_iter(
          (reader |> @lib.read_packed(@lib.read_int32, None)).iter(),
        )
      (3, _) => msg.leading_comments = reader |> @lib.read_string() |> Some
      (4, _) => msg.trailing_comments = reader |> @lib.read_string() |> Some
      (6, _) => msg.leading_detached_comments.push(reader |> @lib.read_string())
      (_, wire) => reader |> @lib.read_unknown(wire)
    }
  }
  msg
}

///|
pub impl @lib.Write for SourceCodeInfo_Location with write(self, writer) {
  writer |> @lib.write_varint(10UL)
  let size = self.path.iter().map(@lib.size_of).fold(init=0U, UInt::op_add)
  writer |> @lib.write_uint32(size)
  self.path.iter().each(fn(v) { writer |> @lib.write_int32(v) })
  writer |> @lib.write_varint(18UL)
  let size = self.span.iter().map(@lib.size_of).fold(init=0U, UInt::op_add)
  writer |> @lib.write_uint32(size)
  self.span.iter().each(fn(v) { writer |> @lib.write_int32(v) })
  match self.leading_comments {
    Some(v) => {
      writer |> @lib.write_varint(26UL)
      writer |> @lib.write_string(v)
    }
    None => ()
  }
  match self.trailing_comments {
    Some(v) => {
      writer |> @lib.write_varint(34UL)
      writer |> @lib.write_string(v)
    }
    None => ()
  }
  self.leading_detached_comments
  .iter()
  .each(fn(v) {
    writer |> @lib.write_varint(50UL)
    writer |> @lib.write_string(v)
  })
}

///|
pub impl ToJson for SourceCodeInfo_Location with to_json(self) {
  let json : Map[String, Json] = {}
  if self.path != Default::default() {
    json["path"] = self.path.to_json()
  }
  if self.span != Default::default() {
    json["span"] = self.span.to_json()
  }
  match self.leading_comments {
    Some(v) => json["leadingComments"] = v.to_json()
    _ => ()
  }
  match self.trailing_comments {
    Some(v) => json["trailingComments"] = v.to_json()
    _ => ()
  }
  if self.leading_detached_comments != Default::default() {
    json["leadingDetachedComments"] = self.leading_detached_comments.to_json()
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for SourceCodeInfo_Location with from_json(
  json : Json,
  path : @json.JsonPath
) -> SourceCodeInfo_Location raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError(
      (path, "Expected an object for SourceCodeInfo_Location"),
    )
  }
  let message = SourceCodeInfo_Location::default()
  for key, value in obj {
    match (key, value) {
      ("path", Array(value)) =>
        message.path = value.map(v => @json.from_json(v, path~))
      ("span", Array(value)) =>
        message.span = value.map(v => @json.from_json(v, path~))
      ("leadingComments", value) =>
        message.leading_comments = Some(@json.from_json(value, path~))
      ("trailingComments", value) =>
        message.trailing_comments = Some(@json.from_json(value, path~))
      ("leadingDetachedComments", Array(value)) =>
        message.leading_detached_comments = value.map(v => @json.from_json(
          v,
          path~,
        ))
      key => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub(all) struct SourceCodeInfo {
  mut location : Array[SourceCodeInfo_Location]
} derive(Eq, Show)

///|
pub impl @lib.Sized for SourceCodeInfo with size_of(self) {
  let mut size = 0U
  size += self.location
    .iter()
    .map(@lib.size_of)
    .map(s => 1U + @lib.size_of(s) + s)
    .fold(init=0U, UInt::op_add)
  size
}

///|
pub impl Default for SourceCodeInfo with default() -> SourceCodeInfo {
  SourceCodeInfo::{ location: [] }
}

///|
pub impl @lib.Read for SourceCodeInfo with read(reader : &@lib.Reader) {
  let msg = SourceCodeInfo::default()
  while not(reader |> @lib.is_eof()) {
    match (reader |> @lib.read_tag()) {
      (1, _) =>
        msg.location.push(
          (reader |> @lib.read_message() : SourceCodeInfo_Location),
        )
      (_, wire) => reader |> @lib.read_unknown(wire)
    }
  }
  msg
}

///|
pub impl @lib.Write for SourceCodeInfo with write(self, writer) {
  self.location
  .iter()
  .each(fn(v) {
    writer |> @lib.write_varint(10UL)
    writer |> @lib.write_uint32(@lib.size_of(v))
    @lib.Write::write(v, writer)
  })
}

///|
pub impl ToJson for SourceCodeInfo with to_json(self) {
  let json : Map[String, Json] = {}
  if self.location != Default::default() {
    json["location"] = self.location.to_json()
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for SourceCodeInfo with from_json(
  json : Json,
  path : @json.JsonPath
) -> SourceCodeInfo raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError((path, "Expected an object for SourceCodeInfo"))
  }
  let message = SourceCodeInfo::default()
  for key, value in obj {
    match (key, value) {
      ("location", Array(value)) =>
        message.location = value.map(v => @json.from_json(v, path~))
      key => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub(all) enum GeneratedCodeInfo_Annotation_Semantic {
  NONE
  SET
  ALIAS
} derive(Eq, Show)

///|
pub fn GeneratedCodeInfo_Annotation_Semantic::to_enum(
  self : GeneratedCodeInfo_Annotation_Semantic
) -> @lib.Enum {
  match self {
    GeneratedCodeInfo_Annotation_Semantic::NONE => 0
    GeneratedCodeInfo_Annotation_Semantic::SET => 1
    GeneratedCodeInfo_Annotation_Semantic::ALIAS => 2
  }
}

///|
pub fn GeneratedCodeInfo_Annotation_Semantic::from_enum(
  i : @lib.Enum
) -> GeneratedCodeInfo_Annotation_Semantic {
  match i.inner() {
    0 => GeneratedCodeInfo_Annotation_Semantic::NONE
    1 => GeneratedCodeInfo_Annotation_Semantic::SET
    2 => GeneratedCodeInfo_Annotation_Semantic::ALIAS
    _ => Default::default()
  }
}

///|
pub impl Default for GeneratedCodeInfo_Annotation_Semantic with default() -> GeneratedCodeInfo_Annotation_Semantic {
  GeneratedCodeInfo_Annotation_Semantic::NONE
}

///|
pub impl @lib.Sized for GeneratedCodeInfo_Annotation_Semantic with size_of(
  self : GeneratedCodeInfo_Annotation_Semantic
) {
  @lib.Sized::size_of(self.to_enum())
}

///|
pub impl @json.FromJson for GeneratedCodeInfo_Annotation_Semantic with from_json(
  json : Json,
  path : @json.JsonPath
) -> GeneratedCodeInfo_Annotation_Semantic raise {
  match json {
    String(s) if s == "NONE" => GeneratedCodeInfo_Annotation_Semantic::NONE
    String(s) if s == "SET" => GeneratedCodeInfo_Annotation_Semantic::SET
    String(s) if s == "ALIAS" => GeneratedCodeInfo_Annotation_Semantic::ALIAS
    Number(n) if n == 0 => GeneratedCodeInfo_Annotation_Semantic::NONE
    Number(n) if n == 1 => GeneratedCodeInfo_Annotation_Semantic::SET
    Number(n) if n == 2 => GeneratedCodeInfo_Annotation_Semantic::ALIAS
    _ =>
      raise @json.JsonDecodeError(
        (path, "Expected a number or string for enum"),
      )
  }
}

///|
pub impl ToJson for GeneratedCodeInfo_Annotation_Semantic with to_json(
  self : GeneratedCodeInfo_Annotation_Semantic
) -> Json {
  match self {
    GeneratedCodeInfo_Annotation_Semantic::NONE => "NONE"
    GeneratedCodeInfo_Annotation_Semantic::SET => "SET"
    GeneratedCodeInfo_Annotation_Semantic::ALIAS => "ALIAS"
  }
}

///|
pub(all) struct GeneratedCodeInfo_Annotation {
  mut path : Array[Int]
  mut source_file : String?
  mut begin : Int?
  mut end : Int?
  mut semantic : GeneratedCodeInfo_Annotation_Semantic?
} derive(Eq, Show)

///|
pub impl @lib.Sized for GeneratedCodeInfo_Annotation with size_of(self) {
  let mut size = 0U
  size += 1U +
    {
      let size = self.path.iter().map(@lib.size_of).fold(init=0U, UInt::op_add)
      @lib.size_of(size) + size
    }
  match self.source_file {
    Some(v) =>
      size += 1U +
        {
          let size = @lib.size_of(v)
          @lib.size_of(size) + size
        }
    None => ()
  }
  match self.begin {
    Some(v) => size += 1U + @lib.size_of(v)
    None => ()
  }
  match self.end {
    Some(v) => size += 1U + @lib.size_of(v)
    None => ()
  }
  match self.semantic {
    Some(v) => size += 1U + @lib.size_of(v)
    None => ()
  }
  size
}

///|
pub impl Default for GeneratedCodeInfo_Annotation with default() -> GeneratedCodeInfo_Annotation {
  GeneratedCodeInfo_Annotation::{
    path: [],
    source_file: None,
    begin: None,
    end: None,
    semantic: None,
  }
}

///|
pub impl @lib.Read for GeneratedCodeInfo_Annotation with read(
  reader : &@lib.Reader
) {
  let msg = GeneratedCodeInfo_Annotation::default()
  while not(reader |> @lib.is_eof()) {
    match (reader |> @lib.read_tag()) {
      (1, _) =>
        msg.path.push_iter(
          (reader |> @lib.read_packed(@lib.read_int32, None)).iter(),
        )
      (2, _) => msg.source_file = reader |> @lib.read_string() |> Some
      (3, _) => msg.begin = reader |> @lib.read_int32() |> Some
      (4, _) => msg.end = reader |> @lib.read_int32() |> Some
      (5, _) =>
        msg.semantic = reader
          |> @lib.read_enum()
          |> GeneratedCodeInfo_Annotation_Semantic::from_enum
          |> Some
      (_, wire) => reader |> @lib.read_unknown(wire)
    }
  }
  msg
}

///|
pub impl @lib.Write for GeneratedCodeInfo_Annotation with write(self, writer) {
  writer |> @lib.write_varint(10UL)
  let size = self.path.iter().map(@lib.size_of).fold(init=0U, UInt::op_add)
  writer |> @lib.write_uint32(size)
  self.path.iter().each(fn(v) { writer |> @lib.write_int32(v) })
  match self.source_file {
    Some(v) => {
      writer |> @lib.write_varint(18UL)
      writer |> @lib.write_string(v)
    }
    None => ()
  }
  match self.begin {
    Some(v) => {
      writer |> @lib.write_varint(24UL)
      writer |> @lib.write_int32(v)
    }
    None => ()
  }
  match self.end {
    Some(v) => {
      writer |> @lib.write_varint(32UL)
      writer |> @lib.write_int32(v)
    }
    None => ()
  }
  match self.semantic {
    Some(v) => {
      writer |> @lib.write_varint(40UL)
      writer |> @lib.write_enum(v.to_enum())
    }
    None => ()
  }
}

///|
pub impl ToJson for GeneratedCodeInfo_Annotation with to_json(self) {
  let json : Map[String, Json] = {}
  if self.path != Default::default() {
    json["path"] = self.path.to_json()
  }
  match self.source_file {
    Some(v) => json["sourceFile"] = v.to_json()
    _ => ()
  }
  match self.begin {
    Some(v) => json["begin"] = v.to_json()
    _ => ()
  }
  match self.end {
    Some(v) => json["end"] = v.to_json()
    _ => ()
  }
  match self.semantic {
    Some(v) => json["semantic"] = v.to_json()
    _ => ()
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for GeneratedCodeInfo_Annotation with from_json(
  json : Json,
  path : @json.JsonPath
) -> GeneratedCodeInfo_Annotation raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError(
      (path, "Expected an object for GeneratedCodeInfo_Annotation"),
    )
  }
  let message = GeneratedCodeInfo_Annotation::default()
  for key, value in obj {
    match (key, value) {
      ("path", Array(value)) =>
        message.path = value.map(v => @json.from_json(v, path~))
      ("sourceFile", value) =>
        message.source_file = Some(@json.from_json(value, path~))
      ("begin", value) => message.begin = Some(@json.from_json(value, path~))
      ("end", value) => message.end = Some(@json.from_json(value, path~))
      ("semantic", value) =>
        message.semantic = Some(@json.from_json(value, path~))
      key => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub(all) struct GeneratedCodeInfo {
  mut annotation : Array[GeneratedCodeInfo_Annotation]
} derive(Eq, Show)

///|
pub impl @lib.Sized for GeneratedCodeInfo with size_of(self) {
  let mut size = 0U
  size += self.annotation
    .iter()
    .map(@lib.size_of)
    .map(s => 1U + @lib.size_of(s) + s)
    .fold(init=0U, UInt::op_add)
  size
}

///|
pub impl Default for GeneratedCodeInfo with default() -> GeneratedCodeInfo {
  GeneratedCodeInfo::{ annotation: [] }
}

///|
pub impl @lib.Read for GeneratedCodeInfo with read(reader : &@lib.Reader) {
  let msg = GeneratedCodeInfo::default()
  while not(reader |> @lib.is_eof()) {
    match (reader |> @lib.read_tag()) {
      (1, _) =>
        msg.annotation.push(
          (reader |> @lib.read_message() : GeneratedCodeInfo_Annotation),
        )
      (_, wire) => reader |> @lib.read_unknown(wire)
    }
  }
  msg
}

///|
pub impl @lib.Write for GeneratedCodeInfo with write(self, writer) {
  self.annotation
  .iter()
  .each(fn(v) {
    writer |> @lib.write_varint(10UL)
    writer |> @lib.write_uint32(@lib.size_of(v))
    @lib.Write::write(v, writer)
  })
}

///|
pub impl ToJson for GeneratedCodeInfo with to_json(self) {
  let json : Map[String, Json] = {}
  if self.annotation != Default::default() {
    json["annotation"] = self.annotation.to_json()
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for GeneratedCodeInfo with from_json(
  json : Json,
  path : @json.JsonPath
) -> GeneratedCodeInfo raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError(
      (path, "Expected an object for GeneratedCodeInfo"),
    )
  }
  let message = GeneratedCodeInfo::default()
  for key, value in obj {
    match (key, value) {
      ("annotation", Array(value)) =>
        message.annotation = value.map(v => @json.from_json(v, path~))
      key => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}
