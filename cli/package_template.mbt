///|
fn CodeGenerator::gen_package(
  self : CodeGenerator,
  filename : String,
  manifest : PackageManifestPlan,
) -> Unit {
  let content = StringBuilder::new()
  content.write_string("import {\n")
  for import_ in manifest.imports {
    match import_.import_alias {
      Some(import_alias) =>
        content.write_string("  \"\{import_.path}\" @\{import_alias},\n")
      None => content.write_string("  \"\{import_.path}\",\n")
    }
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
  self.gen_services(file.services, content)
  let file = File::from_builder(filename, content~)
  self.push_file(file)
}
