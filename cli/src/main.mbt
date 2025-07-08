///|
fn main {
  @async.start(fn() {
    let result = generate(parse_request())
    let writer = @buffer.new()
    @lib.Write::write(result, writer)
    let bytes = writer.to_bytes()
    @async.stdout.write_bytes(bytes)
    @async.stdout.close()
  }) catch {
    e => println("Error: \{e}")
  }
}

///|
async fn parse_request() -> @compiler.CodeGeneratorRequest raise {
  let bytes = @async.stdin.read_bytes()
  let reader = @lib.BytesReader::from_bytes(bytes)
  let model = (@lib.Read::read(reader) : @compiler.CodeGeneratorRequest)
  return model
}

///|
async fn generate(
  request : @compiler.CodeGeneratorRequest
) -> @compiler.CodeGeneratorResponse {
  let generate_files = []
  for file in request.proto_file {
    if file.name is Some(filename) &&
      request.file_to_generate.contains(filename) {
      generate_files.push(Package::from(file))
    }
  }
  let generator = CodeGenerator::new(request)
  generator.gen_module()
  for file in generate_files {
    generator.gen_package(file)
  }
  return generator.build_response()
}
