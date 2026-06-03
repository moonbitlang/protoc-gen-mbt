///|
fn CodeGenerator::gen_package(
  self : CodeGenerator,
  package_ : Package,
) -> Unit raise {
  self.gen_file(package_)
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
    content.write_string(
      "  \"\{self.username()}/\{self.project_name}/\{import_path}\" @\{import_alias},\n",
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
    "deps": { "moonbitlang/protobuf": "0.1.2" },
  }
  let file = File::new(filename, content=content.stringify(indent=2))
  self.push_file(file)
}

///|
fn CodeGenerator::gen_file(self : CodeGenerator, file : Package) -> Unit raise {
  let package_name = file.package_name.replace_all(old=".", new="/")
  let filename = "\{self.project_source_root()}/\{package_name}/top.mbt"
  let content = StringBuilder::new()
  for enum_ in file.enums {
    self.gen_enum(enum_, content)
  }
  self.gen_messages(file.message_type, content)
  let file = File::from_builder(filename, content~)
  self.push_file(file)
}
