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
  let generator = CodeGenerator::new(request)
  return generator.generate()
}
