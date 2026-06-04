///|
fn CodeGenerator::gen_package(self : CodeGenerator, package_ : Package) -> Unit {
  let package_name = package_.package_name.replace_all(old=".", new="/")
  let filename = "\{self.project_source_root()}/\{package_name}/moon.pkg"
  let content = StringBuilder::new()
  content.write_string("import {\n")
  content.write_string("  \"moonbitlang/protobuf\" @lib,\n")
  content.write_string("   \"moonbitlang/core/json\",")
  if self.derive_list().contains("Arbitrary") {
    content.write_string("\n  \"moonbitlang/core/quickcheck\",")
  }
  for dep in package_.dependency {
    let import_alias = self.qualified_name(dep.import_path)
    let import_path = dep.import_path.package_name.replace_all(old=".", new="/")
    let package_prefix = if dep.name.has_prefix("google/protobuf/") {
      "moonbitlang/protobuf"
    } else {
      "\{self.username()}/\{self.project_name}"
    }
    content.write_string(
      "  \"\{package_prefix}/\{import_path}\" @\{import_alias},\n",
    )
  }
  content.write_string("}\n")
  let file = File::new(filename, content=content.to_string())
  self.push_file(file)
}

///|
fn CodeGenerator::gen_module(self : CodeGenerator) -> Unit {
  let filename = "\{self.project_name}/moon.mod.json"
  let content : Json = {
    "name": "\{self.username()}/\{self.project_name}",
    "version": "0.1.0",
    "readme": "",
    "repository": "",
    "license": "",
    "keywords": [],
    "description": "",
    "source": self.source_dir(),
    "deps": { "moonbitlang/protobuf": "0.1.3" },
  }
  let file = File::new(filename, content=content.stringify(indent=2))
  self.push_file(file)
}

///|
fn CodeGenerator::gen_file(self : CodeGenerator, file : Package) -> Unit raise {
  let package_name = file.package_name.replace_all(old=".", new="/")
  let mut file_stem = "top"
  if self.has_multiple_generated_files_in_package(file.package_name) {
    let basename = file.name
      .rev_find("/")
      .map_or(file.name, pos => file.name.view(start_offset=pos + 1).to_owned())
    file_stem = basename
      .strip_suffix(".proto")
      .map_or(basename, stem => stem.to_owned())
  }
  let filename = "\{self.project_source_root()}/\{package_name}/\{file_stem}.mbt"
  let content = StringBuilder::new()
  for enum_ in file.enums {
    self.gen_enum(enum_, content)
  }
  self.gen_messages(file.message_type, content)
  let file = File::from_builder(filename, content~)
  self.push_file(file)
}
