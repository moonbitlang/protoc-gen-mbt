///|
fn CodeGenerator::service_method_type_name(
  self : CodeGenerator,
  type_name : String,
  parent_path : ImportPath,
) -> String raise {
  if self.find_message(type_name) is Some(message) {
    let path = message.import_path
    if parent_path.package_name != path.package_name {
      return "@\{self.qualified_name(path)}.\{path.path() |> to_camel_case}"
    }
    return path.path() |> to_camel_case
  }
  raise @model.UnsupportedType("Service method type \{type_name} not found")
}

///|
fn CodeGenerator::service_method_shape(
  self : CodeGenerator,
  service : Service,
  rpc : Method,
) -> ServiceMethodShape raise {
  let parent_path = service.import_path
  {
    method_name: rpc.name |> pascal_to_snake,
    input_type: self.service_method_type_name(rpc.input_type, parent_path),
    output_type: self.service_method_type_name(rpc.output_type, parent_path),
    client_streaming: rpc.client_streaming,
    server_streaming: rpc.server_streaming,
  }
}

///|
fn CodeGenerator::service_shape(
  self : CodeGenerator,
  service : Service,
) -> ServiceShape raise {
  let methods = []
  for rpc in service.methods {
    methods.push(self.service_method_shape(service, rpc))
  }
  {
    trait_name: "\{service.import_path.path() |> to_camel_case}Service",
    methods,
  }
}
