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
fn service_descriptor_type_name(type_name : String) -> String {
  type_name.trim(char_set=".").to_owned()
}

///|
fn service_full_name(package_name : String, name : String) -> String {
  if package_name.is_empty() {
    name
  } else {
    "\{package_name}.\{name}"
  }
}

///|
fn CodeGenerator::service_method_shape(
  self : CodeGenerator,
  service : Service,
  rpc : Method,
) -> ServiceMethodShape raise {
  let parent_path = service.import_path
  let service_full_name = service_full_name(
    parent_path.package_name,
    service.name,
  )
  let method_full_name = "\{service_full_name}.\{rpc.name}"
  {
    method_name: rpc.name |> pascal_to_snake,
    descriptor_name: rpc.name,
    full_name: method_full_name,
    path: "/\{service_full_name}/\{rpc.name}",
    input_type: self.service_method_type_name(rpc.input_type, parent_path),
    output_type: self.service_method_type_name(rpc.output_type, parent_path),
    input_type_name: service_descriptor_type_name(rpc.input_type),
    output_type_name: service_descriptor_type_name(rpc.output_type),
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
    descriptor_name: "\{service.name |> pascal_to_snake}_service_descriptor",
    service_name: service.name,
    full_name: service_full_name(service.import_path.package_name, service.name),
    methods,
  }
}
