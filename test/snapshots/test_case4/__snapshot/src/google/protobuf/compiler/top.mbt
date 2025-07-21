pub(all) struct Version {
  mut major : Int?
  mut minor : Int?
  mut patch : Int?
  mut suffix : String?
} derive(Eq, Show)
pub impl @lib.Sized for Version with size_of(self) {
  let mut size = 0U
  match self.major {
    Some(v) => size += 1U + @lib.size_of(v)
    None => ()
  }
  match self.minor {
    Some(v) => size += 1U + @lib.size_of(v)
    None => ()
  }
  match self.patch {
    Some(v) => size += 1U + @lib.size_of(v)
    None => ()
  }
  match self.suffix {
    Some(v) => size += 1U + { let size = @lib.size_of(v); @lib.size_of(size) + size }
    None => ()
  }
  size
}
pub impl Default for Version with default() -> Version {
  Version::{
    major : None,
    minor : None,
    patch : None,
    suffix : None,
  }
}
pub impl @lib.Read for Version with read(reader : &@lib.Reader) {
  let msg =   Version::default()

  while not(reader |> @lib.is_eof()) {
    match (reader |> @lib.read_tag()) {
      (1, _) => msg.major = reader |> @lib.read_int32() |> Some
      (2, _) => msg.minor = reader |> @lib.read_int32() |> Some
      (3, _) => msg.patch = reader |> @lib.read_int32() |> Some
      (4, _) => msg.suffix = reader |> @lib.read_string() |> Some
     (_, wire) => reader |> @lib.read_unknown(wire)
    }
  }
  msg
}
pub impl @lib.Write for Version with write(self, writer) {
  match self.major {
    Some(v) => {
      writer |> @lib.write_varint(8UL);writer |> @lib.write_int32(v)
    }
    None => ()
  }
  match self.minor {
    Some(v) => {
      writer |> @lib.write_varint(16UL);writer |> @lib.write_int32(v)
    }
    None => ()
  }
  match self.patch {
    Some(v) => {
      writer |> @lib.write_varint(24UL);writer |> @lib.write_int32(v)
    }
    None => ()
  }
  match self.suffix {
    Some(v) => {
      writer |> @lib.write_varint(34UL);writer |> @lib.write_string(v)
    }
    None => ()
  }
}
pub impl ToJson for Version with to_json(self) {

  let json: Map[String, Json] = {}
  match self.major {
      Some(v) => json["major"] = v.to_json()
      _ => ()
    }
  match self.minor {
      Some(v) => json["minor"] = v.to_json()
      _ => ()
    }
  match self.patch {
      Some(v) => json["patch"] = v.to_json()
      _ => ()
    }
  match self.suffix {
      Some(v) => json["suffix"] = v.to_json()
      _ => ()
    }
  Json::object(json)
}
pub impl @json.FromJson for Version with from_json(json: Json, path: @json.JsonPath) -> Version raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError((path, "Expected an object for Version"))
  }
  let message = Version::default()

  for key, value in obj {
    match (key, value) {
      ("major", value) => message.major = Some(@json.from_json(value, path~))
      ("minor", value) => message.minor = Some(@json.from_json(value, path~))
      ("patch", value) => message.patch = Some(@json.from_json(value, path~))
      ("suffix", value) => message.suffix = Some(@json.from_json(value, path~))
      key => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
      }
  }
  message
}
pub(all) struct CodeGeneratorRequest {
  mut file_to_generate : Array[String]
  mut parameter : String?
  mut proto_file : Array[@protobuf.FileDescriptorProto]
  mut source_file_descriptors : Array[@protobuf.FileDescriptorProto]
  mut compiler_version : Version?
} derive(Eq, Show)
pub impl @lib.Sized for CodeGeneratorRequest with size_of(self) {
  let mut size = 0U
  size += self.file_to_generate.iter().map(@lib.size_of).map(s => 1U + @lib.size_of(s) + s).fold(init=0U, UInt::op_add)
  match self.parameter {
    Some(v) => size += 1U + { let size = @lib.size_of(v); @lib.size_of(size) + size }
    None => ()
  }
  size += self.proto_file.iter().map(@lib.size_of).map(s => 1U + @lib.size_of(s) + s).fold(init=0U, UInt::op_add)
  size += self.source_file_descriptors.iter().map(@lib.size_of).map(s => 2U + @lib.size_of(s) + s).fold(init=0U, UInt::op_add)
  match self.compiler_version {
    Some(v) => size += 1U + { let size = @lib.size_of(v); @lib.size_of(size) + size }
    None => ()
  }
  size
}
pub impl Default for CodeGeneratorRequest with default() -> CodeGeneratorRequest {
  CodeGeneratorRequest::{
    file_to_generate : [],
    parameter : None,
    proto_file : [],
    source_file_descriptors : [],
    compiler_version : None,
  }
}
pub impl @lib.Read for CodeGeneratorRequest with read(reader : &@lib.Reader) {
  let msg =   CodeGeneratorRequest::default()

  while not(reader |> @lib.is_eof()) {
    match (reader |> @lib.read_tag()) {
      (1, _) => msg.file_to_generate.push(reader |> @lib.read_string())
      (2, _) => msg.parameter = reader |> @lib.read_string() |> Some
      (15, _) => msg.proto_file.push(((reader |> @lib.read_message()) : @protobuf.FileDescriptorProto))
      (17, _) => msg.source_file_descriptors.push(((reader |> @lib.read_message()) : @protobuf.FileDescriptorProto))
      (3, _) => msg.compiler_version = ((reader |> @lib.read_message()) : Version) |> Some
     (_, wire) => reader |> @lib.read_unknown(wire)
    }
  }
  msg
}
pub impl @lib.Write for CodeGeneratorRequest with write(self, writer) {
  self.file_to_generate.iter().each(fn(v) {
    writer |> @lib.write_varint(10UL)
    writer |> @lib.write_string(v)
  })
  match self.parameter {
    Some(v) => {
      writer |> @lib.write_varint(18UL);writer |> @lib.write_string(v)
    }
    None => ()
  }
  self.proto_file.iter().each(fn(v) {
    writer |> @lib.write_varint(122UL)
    writer |> @lib.write_uint32(@lib.size_of(v)); @lib.Write::write(v, writer)
  })
  self.source_file_descriptors.iter().each(fn(v) {
    writer |> @lib.write_varint(138UL)
    writer |> @lib.write_uint32(@lib.size_of(v)); @lib.Write::write(v, writer)
  })
  match self.compiler_version {
    Some(v) => {
      writer |> @lib.write_varint(26UL);writer |> @lib.write_uint32(@lib.size_of(v)); @lib.Write::write(v, writer)
    }
    None => ()
  }
}
pub impl ToJson for CodeGeneratorRequest with to_json(self) {

  let json: Map[String, Json] = {}
  if self.file_to_generate != Default::default() {
  json["fileToGenerate"] = self.file_to_generate.to_json()
  }
  match self.parameter {
      Some(v) => json["parameter"] = v.to_json()
      _ => ()
    }
  if self.proto_file != Default::default() {
  json["protoFile"] = self.proto_file.to_json()
  }
  if self.source_file_descriptors != Default::default() {
  json["sourceFileDescriptors"] = self.source_file_descriptors.to_json()
  }
  match self.compiler_version {
      Some(v) => json["compilerVersion"] = v.to_json()
      _ => ()
    }
  Json::object(json)
}
pub impl @json.FromJson for CodeGeneratorRequest with from_json(json: Json, path: @json.JsonPath) -> CodeGeneratorRequest raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError((path, "Expected an object for CodeGeneratorRequest"))
  }
  let message = CodeGeneratorRequest::default()

  for key, value in obj {
    match (key, value) {
      ("fileToGenerate", Array(value)) => message.file_to_generate = value.map(v => 
@json.from_json(v, path~))
      ("parameter", value) => message.parameter = Some(@json.from_json(value, path~))
      ("protoFile", Array(value)) => message.proto_file = value.map(v => 
@json.from_json(v, path~))
      ("sourceFileDescriptors", Array(value)) => message.source_file_descriptors = value.map(v => 
@json.from_json(v, path~))
      ("compilerVersion", value) => message.compiler_version = Some(@json.from_json(value, path~))
      key => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
      }
  }
  message
}
pub(all) enum CodeGeneratorResponse_Feature {
  FEATURE_NONE
  FEATURE_PROTO3_OPTIONAL
  FEATURE_SUPPORTS_EDITIONS
} derive(Eq, Show)
pub fn CodeGeneratorResponse_Feature::to_enum(self : CodeGeneratorResponse_Feature) -> @lib.Enum {
  match self {
    CodeGeneratorResponse_Feature::FEATURE_NONE => 0
    CodeGeneratorResponse_Feature::FEATURE_PROTO3_OPTIONAL => 1
    CodeGeneratorResponse_Feature::FEATURE_SUPPORTS_EDITIONS => 2
  }
}
pub fn CodeGeneratorResponse_Feature::from_enum(i : @lib.Enum) -> CodeGeneratorResponse_Feature {
  match i.inner() {
    0 => CodeGeneratorResponse_Feature::FEATURE_NONE
    1 => CodeGeneratorResponse_Feature::FEATURE_PROTO3_OPTIONAL
    2 => CodeGeneratorResponse_Feature::FEATURE_SUPPORTS_EDITIONS
    _ => Default::default()
  }
}
pub impl Default for CodeGeneratorResponse_Feature with default() -> CodeGeneratorResponse_Feature {
  CodeGeneratorResponse_Feature::FEATURE_NONE
}
pub impl @lib.Sized for CodeGeneratorResponse_Feature with size_of(self : CodeGeneratorResponse_Feature) {
  @lib.Sized::size_of(self.to_enum())
}
pub impl @json.FromJson for CodeGeneratorResponse_Feature with from_json(json: Json, path: @json.JsonPath) -> CodeGeneratorResponse_Feature raise {
  match json {
    String(s) if s == "FEATURE_NONE" => CodeGeneratorResponse_Feature::FEATURE_NONE
    String(s) if s == "FEATURE_PROTO3_OPTIONAL" => CodeGeneratorResponse_Feature::FEATURE_PROTO3_OPTIONAL
    String(s) if s == "FEATURE_SUPPORTS_EDITIONS" => CodeGeneratorResponse_Feature::FEATURE_SUPPORTS_EDITIONS
    Number(n) if n == 0 => CodeGeneratorResponse_Feature::FEATURE_NONE
    Number(n) if n == 1 => CodeGeneratorResponse_Feature::FEATURE_PROTO3_OPTIONAL
    Number(n) if n == 2 => CodeGeneratorResponse_Feature::FEATURE_SUPPORTS_EDITIONS
    _ =>  raise @json.JsonDecodeError((path, "Expected a number or string for enum"))
  }
}
pub impl ToJson for CodeGeneratorResponse_Feature with to_json(self : CodeGeneratorResponse_Feature) -> Json {
  match self {
    CodeGeneratorResponse_Feature::FEATURE_NONE => "FEATURE_NONE"
    CodeGeneratorResponse_Feature::FEATURE_PROTO3_OPTIONAL => "FEATURE_PROTO3_OPTIONAL"
    CodeGeneratorResponse_Feature::FEATURE_SUPPORTS_EDITIONS => "FEATURE_SUPPORTS_EDITIONS"
  }
}
pub(all) struct CodeGeneratorResponse_File {
  mut name : String?
  mut insertion_point : String?
  mut content : String?
  mut generated_code_info : @protobuf.GeneratedCodeInfo?
} derive(Eq, Show)
pub impl @lib.Sized for CodeGeneratorResponse_File with size_of(self) {
  let mut size = 0U
  match self.name {
    Some(v) => size += 1U + { let size = @lib.size_of(v); @lib.size_of(size) + size }
    None => ()
  }
  match self.insertion_point {
    Some(v) => size += 1U + { let size = @lib.size_of(v); @lib.size_of(size) + size }
    None => ()
  }
  match self.content {
    Some(v) => size += 1U + { let size = @lib.size_of(v); @lib.size_of(size) + size }
    None => ()
  }
  match self.generated_code_info {
    Some(v) => size += 2U + { let size = @lib.size_of(v); @lib.size_of(size) + size }
    None => ()
  }
  size
}
pub impl Default for CodeGeneratorResponse_File with default() -> CodeGeneratorResponse_File {
  CodeGeneratorResponse_File::{
    name : None,
    insertion_point : None,
    content : None,
    generated_code_info : None,
  }
}
pub impl @lib.Read for CodeGeneratorResponse_File with read(reader : &@lib.Reader) {
  let msg =   CodeGeneratorResponse_File::default()

  while not(reader |> @lib.is_eof()) {
    match (reader |> @lib.read_tag()) {
      (1, _) => msg.name = reader |> @lib.read_string() |> Some
      (2, _) => msg.insertion_point = reader |> @lib.read_string() |> Some
      (15, _) => msg.content = reader |> @lib.read_string() |> Some
      (16, _) => msg.generated_code_info = ((reader |> @lib.read_message()) : @protobuf.GeneratedCodeInfo) |> Some
     (_, wire) => reader |> @lib.read_unknown(wire)
    }
  }
  msg
}
pub impl @lib.Write for CodeGeneratorResponse_File with write(self, writer) {
  match self.name {
    Some(v) => {
      writer |> @lib.write_varint(10UL);writer |> @lib.write_string(v)
    }
    None => ()
  }
  match self.insertion_point {
    Some(v) => {
      writer |> @lib.write_varint(18UL);writer |> @lib.write_string(v)
    }
    None => ()
  }
  match self.content {
    Some(v) => {
      writer |> @lib.write_varint(122UL);writer |> @lib.write_string(v)
    }
    None => ()
  }
  match self.generated_code_info {
    Some(v) => {
      writer |> @lib.write_varint(130UL);writer |> @lib.write_uint32(@lib.size_of(v)); @lib.Write::write(v, writer)
    }
    None => ()
  }
}
pub impl ToJson for CodeGeneratorResponse_File with to_json(self) {

  let json: Map[String, Json] = {}
  match self.name {
      Some(v) => json["name"] = v.to_json()
      _ => ()
    }
  match self.insertion_point {
      Some(v) => json["insertionPoint"] = v.to_json()
      _ => ()
    }
  match self.content {
      Some(v) => json["content"] = v.to_json()
      _ => ()
    }
  match self.generated_code_info {
      Some(v) => json["generatedCodeInfo"] = v.to_json()
      _ => ()
    }
  Json::object(json)
}
pub impl @json.FromJson for CodeGeneratorResponse_File with from_json(json: Json, path: @json.JsonPath) -> CodeGeneratorResponse_File raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError((path, "Expected an object for CodeGeneratorResponse_File"))
  }
  let message = CodeGeneratorResponse_File::default()

  for key, value in obj {
    match (key, value) {
      ("name", value) => message.name = Some(@json.from_json(value, path~))
      ("insertionPoint", value) => message.insertion_point = Some(@json.from_json(value, path~))
      ("content", value) => message.content = Some(@json.from_json(value, path~))
      ("generatedCodeInfo", value) => message.generated_code_info = Some(@json.from_json(value, path~))
      key => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
      }
  }
  message
}
pub(all) struct CodeGeneratorResponse {
  mut error : String?
  mut supported_features : UInt64?
  mut minimum_edition : Int?
  mut maximum_edition : Int?
  mut file : Array[CodeGeneratorResponse_File]
} derive(Eq, Show)
pub impl @lib.Sized for CodeGeneratorResponse with size_of(self) {
  let mut size = 0U
  match self.error {
    Some(v) => size += 1U + { let size = @lib.size_of(v); @lib.size_of(size) + size }
    None => ()
  }
  match self.supported_features {
    Some(v) => size += 1U + @lib.size_of(v)
    None => ()
  }
  match self.minimum_edition {
    Some(v) => size += 1U + @lib.size_of(v)
    None => ()
  }
  match self.maximum_edition {
    Some(v) => size += 1U + @lib.size_of(v)
    None => ()
  }
  size += self.file.iter().map(@lib.size_of).map(s => 1U + @lib.size_of(s) + s).fold(init=0U, UInt::op_add)
  size
}
pub impl Default for CodeGeneratorResponse with default() -> CodeGeneratorResponse {
  CodeGeneratorResponse::{
    error : None,
    supported_features : None,
    minimum_edition : None,
    maximum_edition : None,
    file : [],
  }
}
pub impl @lib.Read for CodeGeneratorResponse with read(reader : &@lib.Reader) {
  let msg =   CodeGeneratorResponse::default()

  while not(reader |> @lib.is_eof()) {
    match (reader |> @lib.read_tag()) {
      (1, _) => msg.error = reader |> @lib.read_string() |> Some
      (2, _) => msg.supported_features = reader |> @lib.read_uint64() |> Some
      (3, _) => msg.minimum_edition = reader |> @lib.read_int32() |> Some
      (4, _) => msg.maximum_edition = reader |> @lib.read_int32() |> Some
      (15, _) => msg.file.push(((reader |> @lib.read_message()) : CodeGeneratorResponse_File))
     (_, wire) => reader |> @lib.read_unknown(wire)
    }
  }
  msg
}
pub impl @lib.Write for CodeGeneratorResponse with write(self, writer) {
  match self.error {
    Some(v) => {
      writer |> @lib.write_varint(10UL);writer |> @lib.write_string(v)
    }
    None => ()
  }
  match self.supported_features {
    Some(v) => {
      writer |> @lib.write_varint(16UL);writer |> @lib.write_uint64(v)
    }
    None => ()
  }
  match self.minimum_edition {
    Some(v) => {
      writer |> @lib.write_varint(24UL);writer |> @lib.write_int32(v)
    }
    None => ()
  }
  match self.maximum_edition {
    Some(v) => {
      writer |> @lib.write_varint(32UL);writer |> @lib.write_int32(v)
    }
    None => ()
  }
  self.file.iter().each(fn(v) {
    writer |> @lib.write_varint(122UL)
    writer |> @lib.write_uint32(@lib.size_of(v)); @lib.Write::write(v, writer)
  })
}
pub impl ToJson for CodeGeneratorResponse with to_json(self) {

  let json: Map[String, Json] = {}
  match self.error {
      Some(v) => json["error"] = v.to_json()
      _ => ()
    }
  match self.supported_features {
      Some(v) => json["supportedFeatures"] = v.to_json()
      _ => ()
    }
  match self.minimum_edition {
      Some(v) => json["minimumEdition"] = v.to_json()
      _ => ()
    }
  match self.maximum_edition {
      Some(v) => json["maximumEdition"] = v.to_json()
      _ => ()
    }
  if self.file != Default::default() {
  json["file"] = self.file.to_json()
  }
  Json::object(json)
}
pub impl @json.FromJson for CodeGeneratorResponse with from_json(json: Json, path: @json.JsonPath) -> CodeGeneratorResponse raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError((path, "Expected an object for CodeGeneratorResponse"))
  }
  let message = CodeGeneratorResponse::default()

  for key, value in obj {
    match (key, value) {
      ("error", value) => message.error = Some(@json.from_json(value, path~))
      ("supportedFeatures", value) => message.supported_features = Some(@json.from_json(value, path~))
      ("minimumEdition", value) => message.minimum_edition = Some(@json.from_json(value, path~))
      ("maximumEdition", value) => message.maximum_edition = Some(@json.from_json(value, path~))
      ("file", Array(value)) => message.file = value.map(v => 
@json.from_json(v, path~))
      key => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
      }
  }
  message
}
