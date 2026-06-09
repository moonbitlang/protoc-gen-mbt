///|
fn CodeGenerator::gen_services(
  self : CodeGenerator,
  services : Array[Service],
  content : StringBuilder,
) -> Unit raise {
  for service in services {
    self.gen_service(self.service_shape(service), content)
  }
}

///|
fn CodeGenerator::gen_service(
  self : CodeGenerator,
  shape : ServiceShape,
  content : StringBuilder,
) -> Unit {
  self.gen_service_trait(shape, content)
  self.gen_service_descriptor(shape, content)
}

///|
fn CodeGenerator::gen_service_trait(
  _ : CodeGenerator,
  shape : ServiceShape,
  content : StringBuilder,
) -> Unit {
  content.write_string("pub(open) trait \{shape.trait_name} {\n")
  for rpc in shape.methods {
    if rpc.client_streaming || rpc.server_streaming {
      content.write_string(
        "  // \{rpc.method_name} is streaming and descriptor-only for now.\n",
      )
      continue
    }
    content.write_string(
      "  fn \{rpc.method_name}(Self, \{rpc.input_type}) -> \{rpc.output_type} raise\n",
    )
  }
  content.write_string("}\n")
}

///|
fn CodeGenerator::gen_service_descriptor(
  _ : CodeGenerator,
  shape : ServiceShape,
  content : StringBuilder,
) -> Unit {
  content.write_string(
    (
      $|pub let \{shape.descriptor_name} : @lib.ServiceDescriptor = {
      $|  name: "\{shape.service_name}",
      $|  full_name: "\{shape.full_name}",
      $|  methods: [
      $|
    ),
  )
  for rpc in shape.methods {
    content.write_string(
      (
        $|    {
        $|      name: "\{rpc.descriptor_name}",
        $|      full_name: "\{rpc.full_name}",
        $|      path: "\{rpc.path}",
        $|      input_type_name: "\{rpc.input_type_name}",
        $|      output_type_name: "\{rpc.output_type_name}",
        $|      client_streaming: \{rpc.client_streaming},
        $|      server_streaming: \{rpc.server_streaming},
        $|    },
        $|
      ),
    )
  }
  content.write_string(
    (
      #|  ],
      #|}
      #|
    ),
  )
}
