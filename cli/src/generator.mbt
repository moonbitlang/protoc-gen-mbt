///|
struct CodeGenerator {
  request : @compiler.CodeGeneratorRequest
  packages_map : Map[String, Package] // file name to file descriptor
  package_descriptions : Map[String, Package] // package name to file descriptor
  parameter : Map[String, String]
  generated_files : Array[@compiler.CodeGeneratorResponse_File]
  response : @compiler.CodeGeneratorResponse
  project_name : String
}

///|
fn CodeGenerator::find_enum(self : CodeGenerator, type_name : String) -> Enum? {
  for name, pkg in self.package_descriptions {
    let name = name.trim_start(".")
    let type_name = type_name.trim(".")
    if type_name.has_prefix(name) {
      let path = pkg.import_path.append(
        type_name.charcodes(start=name.length()).to_string(),
      )
      if pkg.find_enum(path) is Some(enum_) {
        return enum_ |> Some
      }
    }
  }
  None
}

///|
fn CodeGenerator::find_message(
  self : CodeGenerator,
  type_name : String
) -> Message? {
  for pkg_name, pkg in self.package_descriptions {
    let pkg_name = pkg_name.trim(".")
    if type_name.trim(".").has_prefix(pkg_name) {
      let path = pkg.import_path.append(
        type_name.trim(".").charcodes(start=pkg_name.length()).to_string(),
      )
      if pkg.find_message(path) is Some(message) {
        return message |> Some
      }
    }
  }
  None
}

///|
fn CodeGenerator::new(
  request : @compiler.CodeGeneratorRequest
) -> CodeGenerator {
  let packages_map = {}
  for file in request.proto_file {
    // if request.file_to_generate.contains(file.name) {
    packages_map[file.name.unwrap()] = Package::from(file)
    // }
  }
  let args = convert_args(request.parameter.unwrap())
  let package_descriptions = {}
  for file in request.source_file_descriptors {
    package_descriptions[file.package.unwrap_or_default()] = Package::from(
      file,
      file_descriptors_map=packages_map,
    )
  }
  return {
    request,
    packages_map,
    package_descriptions,
    parameter: convert_args(request.parameter.unwrap()),
    generated_files: [],
    response: @compiler.CodeGeneratorResponse::default(),
    project_name: args.get("project_name").unwrap_or("protoc-gen-mbt"),
  }
}

///|
pub fn CodeGenerator::generate(
  self : CodeGenerator
) -> @compiler.CodeGeneratorResponse {
  self.gen_module()
  for file in self.request.proto_file {
    if file.name is Some(filename) &&
      self.request.file_to_generate.contains(filename) {
      self.gen_package(Package::from(file))
    }
  }
  for file in self.generated_files {
    self.response.file.push(file)
  }
  self.response.supported_features = Some(1)
  self.response.minimum_edition = Some(
    @protobuf.Edition::Edition_EDITION_UNKNOWN
    .to_enum()
    .inner()
    .reinterpret_as_int(),
  )
  self.response.maximum_edition = Some(
    @protobuf.Edition::Edition_EDITION_MAX
    .to_enum()
    .inner()
    .reinterpret_as_int(),
  )
  // println("Response: \{self.response}")

  return self.response
}

///|
fn CodeGenerator::push_file(self : CodeGenerator, file : File) -> Unit {
  let gen_file = @compiler.CodeGeneratorResponse_File::default()
  gen_file.name = Some(file.name)
  gen_file.content = Some(file.content.to_string())
  self.generated_files.push(gen_file)
}

///|
struct File {
  name : String
  content : StringBuilder
}

///|
fn File::new(name : String, content~ : String) -> File {
  let file = { name, content: StringBuilder::new() }
  file.content.write_string(content)
  return file
}

///|
fn File::from_builder(name : String, content~ : StringBuilder) -> File {
  { name, content }
}
