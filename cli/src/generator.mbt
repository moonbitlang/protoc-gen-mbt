///|
struct CodeGenerator {
  request : @compiler.CodeGeneratorRequest
  package_dictionary : Map[String, Package] // package name to Package
  filename_dictionary : Map[String, Package] // file name to Package
  parameter : Map[String, String]
  package_import : Map[String, String] // package name to import alias
  import_ns : ImportNameAlias
  files_to_generate : Array[@compiler.CodeGeneratorResponse_File]
  generated_files : Array[@compiler.CodeGeneratorResponse_File]
  response : @compiler.CodeGeneratorResponse
  project_name : String
}

///|
struct ImportNameAlias {
  defined : Set[String]
  mut tmp : Int
}

///|
fn ImportNameAlias::new() -> ImportNameAlias {
  return { defined: Set::new(), tmp: 0 }
}

///|
fn ImportNameAlias::insert(self : ImportNameAlias, name : String) -> String {
  let mut name = name
  while self.defined.contains(name) {
    self.tmp += 1
    name = "\{name}\{self.tmp}"
  }
  self.defined.add(name)
  return name
}

///|
fn CodeGenerator::find_enum(self : CodeGenerator, type_name : String) -> Enum? {
  for name, pkg in self.package_dictionary {
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
  for pkg_name, pkg in self.package_dictionary {
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
  let filename_dictionary = {}
  let package_dictionary = {}
  for file in request.proto_file {
    let package_ = Package::from(file, file_descriptors_map=filename_dictionary)
    filename_dictionary[file.name.unwrap()] = package_
    package_dictionary[file.package.unwrap_or_default()] = package_
  }
  let args = convert_args(request.parameter.unwrap())
  return {
    request,
    filename_dictionary,
    package_dictionary,
    parameter: convert_args(request.parameter.unwrap()),
    package_import: {},
    import_ns: ImportNameAlias::new(),
    files_to_generate: [],
    generated_files: [],
    response: @compiler.CodeGeneratorResponse::default(),
    project_name: args.get("project_name").unwrap_or("protoc-gen-mbt"),
  }
}

///|
fn CodeGenerator::qualified_name(
  self : CodeGenerator,
  path : ImportPath
) -> String {
  let package_name = path.package_name
  let import_name = package_name
    .rev_find(".")
    .map_or(package_name, pos => package_name
      .charcodes(start=pos + 1)
      .to_string())

  if self.package_import.contains(package_name) {
    return self.package_import.get(package_name).unwrap()
  } else {
    let name = self.import_ns.insert(import_name)
    self.package_import[package_name] = name
    return name
  }
}

///|
pub fn CodeGenerator::generate(
  self : CodeGenerator,
) -> @compiler.CodeGeneratorResponse {
  self.gen_module()
  for file in self.request.proto_file {
    let filename = file.name.unwrap()
    if self.request.file_to_generate.contains(filename) {
      let package_ = self.filename_dictionary.get(filename).unwrap()
      self.gen_package(package_)
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
