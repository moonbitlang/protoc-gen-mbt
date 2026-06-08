///|
struct CodeGenerator {
  request : @compiler.CodeGeneratorRequest
  package_dictionary : Map[String, Package] // package name to Package
  filename_dictionary : Map[String, Package] // file name to Package
  parameter : Map[String, String]
  package_import : Map[String, String] // package name to import alias
  import_ns : ImportNameAlias
  generated_files : Array[@compiler.CodeGeneratorResponse_File]
  response : @compiler.CodeGeneratorResponse
  project_name : String
}

///|
struct GeneratedFilePlan {
  entries : Array[GeneratedFilePlanEntry]
}

///|
struct GeneratedFilePlanEntry {
  name : String
  kind : GeneratedFileKind
}

///|
enum GeneratedFileKind {
  MoonModFile
  MoonPkgFile(Package)
  MoonBitSourceFile(Package)
}

///|
struct ImportNameAlias(Map[String, Int])

///|
fn ImportNameAlias::new() -> ImportNameAlias {
  return { "lib": 1 }
}

///|
fn ImportNameAlias::insert(self : ImportNameAlias, name : String) -> String {
  if self.0.get(name) is Some(i) {
    self.0[name] = i + 1
    return "\{name}\{i}"
  } else {
    self.0[name] = 1
    return name
  }
}

///|
fn CodeGenerator::username(self : CodeGenerator) -> String {
  self.parameter.get_or_default("username", "username")
}

///|
fn CodeGenerator::support_json(self : CodeGenerator) -> Bool {
  self.parameter.get_or_default("json", "true") == "true"
}

///|
fn CodeGenerator::support_async(self : CodeGenerator) -> Bool {
  self.parameter.get_or_default("async", "true") == "true"
}

///|
fn CodeGenerator::emit_package_files(self : CodeGenerator) -> Bool {
  self.parameter.get_or_default("emit_package_files", "true") == "true"
}

///|
fn CodeGenerator::generate_runtime_wkt(self : CodeGenerator) -> Bool {
  self.parameter.get_or_default("generate_runtime_wkt", "false") == "true"
}

///|
fn CodeGenerator::source_dir(self : CodeGenerator) -> String {
  self.parameter.get_or_default("source_dir", "src")
}

///|
fn CodeGenerator::project_source_root(self : CodeGenerator) -> String {
  match self.source_dir() {
    "." => self.project_name
    source_dir => "\{self.project_name}/\{source_dir}"
  }
}

///|
fn CodeGenerator::has_multiple_generated_files_in_package(
  self : CodeGenerator,
  package_name : String,
) -> Bool {
  let mut count = 0
  for filename in self.request.file_to_generate {
    if self.filename_dictionary.get(filename) is Some(package_) &&
      package_.package_name == package_name {
      count += 1
      if count > 1 {
        return true
      }
    }
  }
  false
}

///|
fn push_package_dependency(
  dependencies : Array[Package],
  dep : Package,
  package_name : String,
) -> Unit {
  if dep.package_name == package_name {
    return
  }
  if !dependencies.any(existing => existing.package_name == dep.package_name) {
    dependencies.push(dep)
  }
}

///|
let support_derive_list : ArrayView[String] = [
  "Debug", "Eq", "Hash", "Compare", "Arbitrary",
]

///|
let runtime_wkt_proto_files : ArrayView[String] = [
  "any.proto", "api.proto", "descriptor.proto", "duration.proto", "empty.proto",
  "field_mask.proto", "source_context.proto", "struct.proto", "timestamp.proto",
  "type.proto", "wrappers.proto",
]

///|
fn Package::is_runtime_wkt_file(self : Package) -> Bool {
  if self.package_name != "google.protobuf" {
    return false
  }
  let basename = self.name
    .rev_find("/")
    .map_or(self.name, pos => self.name.view(start_offset=pos + 1).to_owned())
  runtime_wkt_proto_files.contains(basename)
}

///|
test "runtime wkt file detection" {
  let timestamp = @protobuf.FileDescriptorProto::default()
  timestamp.name = Some("google/protobuf/timestamp.proto")
  timestamp.package_ = Some("google.protobuf")
  inspect(Package::from(timestamp).is_runtime_wkt_file(), content="true")

  let local_timestamp = @protobuf.FileDescriptorProto::default()
  local_timestamp.name = Some("timestamp.proto")
  local_timestamp.package_ = Some("google.protobuf")
  inspect(Package::from(local_timestamp).is_runtime_wkt_file(), content="true")

  let event = @protobuf.FileDescriptorProto::default()
  event.name = Some("event.proto")
  event.package_ = Some("harness.wkt")
  inspect(Package::from(event).is_runtime_wkt_file(), content="false")
}

///|
fn test_file_descriptor(
  name : String,
  package_name : String,
) -> @protobuf.FileDescriptorProto {
  let file = @protobuf.FileDescriptorProto::default()
  file.name = Some(name)
  file.package_ = Some(package_name)
  file
}

///|
test "generated file plan groups package manifest before package sources" {
  let request = @compiler.CodeGeneratorRequest::default()
  request.file_to_generate = ["demo/first.proto", "demo/second.proto"]
  request.parameter = Some("username=moon,project_name=demo")
  request.proto_file = [
    test_file_descriptor("demo/first.proto", "demo.pkg"),
    test_file_descriptor("demo/second.proto", "demo.pkg"),
  ]
  let plan = CodeGenerator::new(request).plan_generated_files()
  inspect(
    plan.entries.map(entry => entry.name).join("\n"),
    content="demo/moon.mod.json\ndemo/src/demo/pkg/moon.pkg\ndemo/src/demo/pkg/first.mbt\ndemo/src/demo/pkg/second.mbt",
  )
}

///|
test "generated file plan skips runtime WKT sources by default" {
  let request = @compiler.CodeGeneratorRequest::default()
  request.file_to_generate = ["google/protobuf/timestamp.proto"]
  request.parameter = Some("project_name=demo")
  request.proto_file = [
    test_file_descriptor("google/protobuf/timestamp.proto", "google.protobuf"),
  ]
  let plan = CodeGenerator::new(request).plan_generated_files()
  inspect(
    plan.entries.map(entry => entry.name).join("\n"),
    content="demo/moon.mod.json",
  )
}

///|
test "generated file plan supports source only output" {
  let request = @compiler.CodeGeneratorRequest::default()
  request.file_to_generate = ["demo/only.proto"]
  request.parameter = Some(
    "project_name=demo,emit_package_files=false,source_dir=.",
  )
  request.proto_file = [test_file_descriptor("demo/only.proto", "demo.pkg")]
  let plan = CodeGenerator::new(request).plan_generated_files()
  inspect(
    plan.entries.map(entry => entry.name).join("\n"),
    content="demo/demo/pkg/top.mbt",
  )
}

///|
fn CodeGenerator::derive_list(self : CodeGenerator) -> Array[String] {
  let args = self.parameter
    .get_or_default("derive", "Eq,Debug")
    .split(",")
    .filter_map(arg => {
      let arg = arg.trim(char_set=" ").to_owned()
      if support_derive_list.contains(arg) {
        return Some(arg)
      } else {
        return None
      }
    })
    .collect()
  args.sort()
  args
}

///|
fn CodeGenerator::find_enum(self : CodeGenerator, type_name : String) -> Enum? {
  for name, pkg in self.package_dictionary {
    let name = name.trim_start(char_set=".")
    let type_name = type_name.trim(char_set=".")
    if type_name.has_prefix(name) {
      let path = pkg.import_path.append(
        type_name.view(start_offset=name.length()).to_owned(),
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
  type_name : String,
) -> Message? {
  for pkg_name, pkg in self.package_dictionary {
    let pkg_name = pkg_name.trim(char_set=".")
    if type_name.trim(char_set=".").has_prefix(pkg_name) {
      let path = pkg.import_path.append(
        type_name
        .trim(char_set=".")
        .view(start_offset=pkg_name.length())
        .to_owned(),
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
  request : @compiler.CodeGeneratorRequest,
) -> CodeGenerator {
  let filename_dictionary = {}
  for file in request.proto_file {
    let package_ = Package::from(file)
    filename_dictionary[file.name.unwrap()] = package_
  }
  for file in request.proto_file {
    let package_ = filename_dictionary.get(file.name.unwrap()).unwrap()
    for dep in file.dependency {
      if filename_dictionary.get(dep) is Some(dep_package) {
        push_package_dependency(
          package_.dependency,
          dep_package,
          package_.package_name,
        )
      }
    }
  }
  let package_dictionary : Map[String, Package] = {}
  for file in request.proto_file {
    let package_ = filename_dictionary.get(file.name.unwrap()).unwrap()
    if package_dictionary.get(package_.package_name) is Some(existing) {
      existing.message_type.push_iter(package_.message_type.iter())
      existing.enums.push_iter(package_.enums.iter())
      for dep in package_.dependency {
        push_package_dependency(existing.dependency, dep, existing.package_name)
      }
    } else {
      package_dictionary[package_.package_name] = {
        desc: package_.desc,
        message_type: package_.message_type.copy(),
        enums: package_.enums.copy(),
        name: package_.name,
        package_name: package_.package_name,
        import_path: package_.import_path,
        options: package_.options,
        dependency: package_.dependency.copy(),
        syntax: package_.syntax,
      }
    }
  }
  let args = convert_args(request.parameter.unwrap())
  return {
    request,
    filename_dictionary,
    package_dictionary,
    parameter: args,
    package_import: {},
    import_ns: ImportNameAlias::new(),
    generated_files: [],
    response: @compiler.CodeGeneratorResponse::default(),
    project_name: args.get("project_name").unwrap_or("protoc-gen-mbt"),
  }
}

///|
fn CodeGenerator::plan_generated_files(
  self : CodeGenerator,
) -> GeneratedFilePlan {
  let entries = []
  let emit_package_files = self.emit_package_files()
  if emit_package_files {
    entries.push({
      name: "\{self.project_name}/moon.mod.json",
      kind: GeneratedFileKind::MoonModFile,
    })
  }
  let generated_package_files : Map[String, Bool] = {}
  for file in self.request.proto_file {
    let filename = file.name.unwrap()
    if !self.request.file_to_generate.contains(filename) {
      continue
    }
    let package_ = self.filename_dictionary.get(filename).unwrap()
    if package_.is_runtime_wkt_file() && !self.generate_runtime_wkt() {
      continue
    }
    let package_path = package_.package_name.replace_all(old=".", new="/")
    if emit_package_files &&
      !generated_package_files.contains(package_.package_name) {
      let package_manifest = self.package_dictionary
        .get(package_.package_name)
        .unwrap_or(package_)
      entries.push({
        name: "\{self.project_source_root()}/\{package_path}/moon.pkg",
        kind: GeneratedFileKind::MoonPkgFile(package_manifest),
      })
      generated_package_files[package_.package_name] = true
    }
    let mut file_stem = "top"
    if self.has_multiple_generated_files_in_package(package_.package_name) {
      let basename = package_.name
        .rev_find("/")
        .map_or(package_.name, pos => {
          package_.name.view(start_offset=pos + 1).to_owned()
        })
      file_stem = basename
        .strip_suffix(".proto")
        .map_or(basename, stem => stem.to_owned())
    }
    entries.push({
      name: "\{self.project_source_root()}/\{package_path}/\{file_stem}.mbt",
      kind: GeneratedFileKind::MoonBitSourceFile(package_),
    })
  }
  { entries, }
}

///|
fn CodeGenerator::emit_planned_file(
  self : CodeGenerator,
  entry : GeneratedFilePlanEntry,
) -> Unit raise {
  match entry.kind {
    GeneratedFileKind::MoonModFile => self.gen_module(entry.name)
    GeneratedFileKind::MoonPkgFile(package_) =>
      self.gen_package(entry.name, package_)
    GeneratedFileKind::MoonBitSourceFile(package_) =>
      self.gen_file(entry.name, package_)
  }
}

///|
fn set_code_generator_capabilities(
  response : @compiler.CodeGeneratorResponse,
) -> Unit {
  response.supported_features = Some(3)
  response.minimum_edition = Some(
    @protobuf.Edition::EDITION_2023.to_enum().0.reinterpret_as_int(),
  )
  response.maximum_edition = Some(
    @protobuf.Edition::EDITION_2024.to_enum().0.reinterpret_as_int(),
  )
}

///|
fn CodeGenerator::qualified_name(
  self : CodeGenerator,
  path : ImportPath,
) -> String {
  let package_name = path.package_name
  let import_name = package_name
    .rev_find(".")
    .map_or(package_name, pos => {
      package_name.view(start_offset=pos + 1).to_owned()
    })
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
  try {
    let plan = self.plan_generated_files()
    for entry in plan.entries {
      self.emit_planned_file(entry)
    }
    for file in self.generated_files {
      self.response.file.push(file)
    }
    set_code_generator_capabilities(self.response)
  } catch {
    err => self.response.error = Some("Error generating code: \{err}")
  }
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
