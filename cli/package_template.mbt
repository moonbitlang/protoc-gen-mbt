///|
fn CodeGenerator::gen_package(
  self : CodeGenerator,
  filename : String,
  package_ : Package,
) -> Unit {
  let content = StringBuilder::new()
  content.write_string("import {\n")
  content.write_string("  \"moonbitlang/protobuf\" @lib,\n")
  content.write_string("  \"moonbitlang/core/json\",\n")
  if self.derive_list().contains("Arbitrary") {
    content.write_string("  \"moonbitlang/core/quickcheck\",\n")
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
fn CodeGenerator::gen_module(self : CodeGenerator, filename : String) -> Unit {
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
fn CodeGenerator::gen_file(
  self : CodeGenerator,
  filename : String,
  file : Package,
) -> Unit raise {
  let content = StringBuilder::new()
  for enum_ in file.enums {
    self.gen_enum(enum_, content)
  }
  self.gen_messages(file.message_type, content)
  let file = File::from_builder(filename, content~)
  self.push_file(file)
}
