pub(all) struct Version {
  mut major : Int
  mut minor : Int
  mut patch : Int
  mut suffix : String
} derive(Eq, Show)
pub impl @lib.Sized for Version with size_of(self) {
  let mut size = 0U
  size += 1U + @lib.size_of(self.major)
  size += 1U + @lib.size_of(self.minor)
  size += 1U + @lib.size_of(self.patch)
  size += 1U + { let size = @lib.size_of(self.suffix); @lib.size_of(size) + size }
  size
}
pub impl Default for Version with default() -> Version {
  {
    major : Int::default(),
    minor : Int::default(),
    patch : Int::default(),
    suffix : String::default(),
  }
}
pub impl @lib.Read for Version with read(reader : &@lib.Reader) {
  let msg =   Version::default()

  while not(reader |> @lib.is_eof()) {
    match (reader |> @lib.read_tag()) {
      (1, _) => msg.major = reader |> @lib.read_int32()
      (2, _) => msg.minor = reader |> @lib.read_int32()
      (3, _) => msg.patch = reader |> @lib.read_int32()
      (4, _) => msg.suffix = reader |> @lib.read_string()
     (_, wire) => reader |> @lib.read_unknown(wire)
    }
  }
  msg
}
pub impl @lib.Write for Version with write(self, writer) {
  writer |> @lib.write_varint(8UL);writer |> @lib.write_int32(self.major)
  writer |> @lib.write_varint(16UL);writer |> @lib.write_int32(self.minor)
  writer |> @lib.write_varint(24UL);writer |> @lib.write_int32(self.patch)
  writer |> @lib.write_varint(34UL);writer |> @lib.write_string(self.suffix)
}
pub(all) struct CodeGeneratorRequest {
  mut file_to_generate : Array[String]
  mut parameter : String
  mut proto_file : Array[@protobuf.FileDescriptorProto]
  mut source_file_descriptors : Array[@protobuf.FileDescriptorProto]
  mut compiler_version :  Version 
} derive(Eq, Show)
pub impl @lib.Sized for CodeGeneratorRequest with size_of(self) {
  let mut size = 0U
  size += self.file_to_generate.iter().map(@lib.size_of).map(s => 1U + @lib.size_of(s) + s).fold(init=0U, UInt::op_add)
  size += 1U + { let size = @lib.size_of(self.parameter); @lib.size_of(size) + size }
  size += self.proto_file.iter().map(@lib.size_of).map(s => 1U + @lib.size_of(s) + s).fold(init=0U, UInt::op_add)
  size += self.source_file_descriptors.iter().map(@lib.size_of).map(s => 2U + @lib.size_of(s) + s).fold(init=0U, UInt::op_add)
  size += 1U + { let size = @lib.size_of(self.compiler_version); @lib.size_of(size) + size }
  size
}
pub impl Default for CodeGeneratorRequest with default() -> CodeGeneratorRequest {
  {
    file_to_generate : [],
    parameter : String::default(),
    proto_file : [],
    source_file_descriptors : [],
    compiler_version : Version::default(),
  }
}
pub impl @lib.Read for CodeGeneratorRequest with read(reader : &@lib.Reader) {
  let msg =   CodeGeneratorRequest::default()

  while not(reader |> @lib.is_eof()) {
    match (reader |> @lib.read_tag()) {
      (1, _) => msg.file_to_generate.push(reader |> @lib.read_string())
      (2, _) => msg.parameter = reader |> @lib.read_string()
      (15, _) => msg.proto_file.push(((reader |> @lib.read_message()) : @protobuf.FileDescriptorProto))
      (17, _) => msg.source_file_descriptors.push(((reader |> @lib.read_message()) : @protobuf.FileDescriptorProto))
      (3, _) => msg.compiler_version = ((reader |> @lib.read_message()) : Version)
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
  writer |> @lib.write_varint(18UL);writer |> @lib.write_string(self.parameter)
  self.proto_file.iter().each(fn(v) {
    writer |> @lib.write_varint(122UL)
    writer |> @lib.write_uint32(@lib.size_of(v)); @lib.Write::write(v, writer)
  })
  self.source_file_descriptors.iter().each(fn(v) {
    writer |> @lib.write_varint(138UL)
    writer |> @lib.write_uint32(@lib.size_of(v)); @lib.Write::write(v, writer)
  })
  writer |> @lib.write_varint(26UL);writer |> @lib.write_uint32(@lib.size_of(self.compiler_version)); @lib.Write::write(self.compiler_version, writer)
}
pub(all) enum CodeGeneratorResponse_Feature {
  FEATURE_NONE
  FEATURE_PROTO3_OPTIONAL
  FEATURE_SUPPORTS_EDITIONS
} derive(Eq, Show)
fn CodeGeneratorResponse_Feature::to_enum(self : CodeGeneratorResponse_Feature) -> @lib.Enum {
  match self {
    CodeGeneratorResponse_Feature::FEATURE_NONE => 0
    CodeGeneratorResponse_Feature::FEATURE_PROTO3_OPTIONAL => 1
    CodeGeneratorResponse_Feature::FEATURE_SUPPORTS_EDITIONS => 2
  }
}
fn CodeGeneratorResponse_Feature::from_enum(i : @lib.Enum) -> CodeGeneratorResponse_Feature {
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
pub(all) struct CodeGeneratorResponse_File {
  mut name : String
  mut insertion_point : String
  mut content : String
  mut generated_code_info :  @protobuf.GeneratedCodeInfo 
} derive(Eq, Show)
pub impl @lib.Sized for CodeGeneratorResponse_File with size_of(self) {
  let mut size = 0U
  size += 1U + { let size = @lib.size_of(self.name); @lib.size_of(size) + size }
  size += 1U + { let size = @lib.size_of(self.insertion_point); @lib.size_of(size) + size }
  size += 1U + { let size = @lib.size_of(self.content); @lib.size_of(size) + size }
  size += 2U + { let size = @lib.size_of(self.generated_code_info); @lib.size_of(size) + size }
  size
}
pub impl Default for CodeGeneratorResponse_File with default() -> CodeGeneratorResponse_File {
  {
    name : String::default(),
    insertion_point : String::default(),
    content : String::default(),
    generated_code_info : @protobuf.GeneratedCodeInfo::default(),
  }
}
pub impl @lib.Read for CodeGeneratorResponse_File with read(reader : &@lib.Reader) {
  let msg =   CodeGeneratorResponse_File::default()

  while not(reader |> @lib.is_eof()) {
    match (reader |> @lib.read_tag()) {
      (1, _) => msg.name = reader |> @lib.read_string()
      (2, _) => msg.insertion_point = reader |> @lib.read_string()
      (15, _) => msg.content = reader |> @lib.read_string()
      (16, _) => msg.generated_code_info = ((reader |> @lib.read_message()) : @protobuf.GeneratedCodeInfo)
     (_, wire) => reader |> @lib.read_unknown(wire)
    }
  }
  msg
}
pub impl @lib.Write for CodeGeneratorResponse_File with write(self, writer) {
  writer |> @lib.write_varint(10UL);writer |> @lib.write_string(self.name)
  writer |> @lib.write_varint(18UL);writer |> @lib.write_string(self.insertion_point)
  writer |> @lib.write_varint(122UL);writer |> @lib.write_string(self.content)
  writer |> @lib.write_varint(130UL);writer |> @lib.write_uint32(@lib.size_of(self.generated_code_info)); @lib.Write::write(self.generated_code_info, writer)
}
pub(all) struct CodeGeneratorResponse {
  mut error : String
  mut supported_features : UInt64
  mut minimum_edition : Int
  mut maximum_edition : Int
  mut file : Array[CodeGeneratorResponse_File]
} derive(Eq, Show)
pub impl @lib.Sized for CodeGeneratorResponse with size_of(self) {
  let mut size = 0U
  size += 1U + { let size = @lib.size_of(self.error); @lib.size_of(size) + size }
  size += 1U + @lib.size_of(self.supported_features)
  size += 1U + @lib.size_of(self.minimum_edition)
  size += 1U + @lib.size_of(self.maximum_edition)
  size += self.file.iter().map(@lib.size_of).map(s => 1U + @lib.size_of(s) + s).fold(init=0U, UInt::op_add)
  size
}
pub impl Default for CodeGeneratorResponse with default() -> CodeGeneratorResponse {
  {
    error : String::default(),
    supported_features : UInt64::default(),
    minimum_edition : Int::default(),
    maximum_edition : Int::default(),
    file : [],
  }
}
pub impl @lib.Read for CodeGeneratorResponse with read(reader : &@lib.Reader) {
  let msg =   CodeGeneratorResponse::default()

  while not(reader |> @lib.is_eof()) {
    match (reader |> @lib.read_tag()) {
      (1, _) => msg.error = reader |> @lib.read_string()
      (2, _) => msg.supported_features = reader |> @lib.read_uint64()
      (3, _) => msg.minimum_edition = reader |> @lib.read_int32()
      (4, _) => msg.maximum_edition = reader |> @lib.read_int32()
      (15, _) => msg.file.push(((reader |> @lib.read_message()) : CodeGeneratorResponse_File))
     (_, wire) => reader |> @lib.read_unknown(wire)
    }
  }
  msg
}
pub impl @lib.Write for CodeGeneratorResponse with write(self, writer) {
  writer |> @lib.write_varint(10UL);writer |> @lib.write_string(self.error)
  writer |> @lib.write_varint(16UL);writer |> @lib.write_uint64(self.supported_features)
  writer |> @lib.write_varint(24UL);writer |> @lib.write_int32(self.minimum_edition)
  writer |> @lib.write_varint(32UL);writer |> @lib.write_int32(self.maximum_edition)
  self.file.iter().each(fn(v) {
    writer |> @lib.write_varint(122UL)
    writer |> @lib.write_uint32(@lib.size_of(v)); @lib.Write::write(v, writer)
  })
}
