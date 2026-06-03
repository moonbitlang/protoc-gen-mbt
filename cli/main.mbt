///|
async fn main {
  output_response(parse_request()) catch {
    e => println("Error: \{e}")
  }
}

///|
struct Stdin(@stdio.Input)

///|
struct Stdout(@stdio.Output)

///|
impl @lib.AsyncReader for Stdin with fn read(
  self,
  bytes : FixedArray[Byte],
  offset~ : Int,
  max_length~ : Int,
) -> Int? raise {
  let len = self.0.read(bytes, offset~, max_len=max_length)
  if len == 0 {
    return None
  } else {
    Some(len)
  }
}

///|
impl @lib.AsyncWriter for Stdout with fn write(self, bytes : BytesView) -> Unit raise {
  self.0.write(bytes)
}

///|
async fn parse_request() -> @compiler.CodeGeneratorResponse noraise {
  let reader = Stdin(@stdio.stdin) as &@lib.AsyncReader
  let request = @lib.AsyncRead::read(reader) catch {
    err => {
      let response = @compiler.CodeGeneratorResponse::default()
      set_code_generator_capabilities(response)
      response.error = Some("Error reading CodeGeneratorRequest: \{err}")
      return response
    }
  }
  let generator = CodeGenerator::new(request)
  let gen = generator.generate()
  gen
}

///|
async fn output_response(response : @compiler.CodeGeneratorResponse) -> Unit {
  let stdout = Stdout(@stdio.stdout) as &@lib.AsyncWriter
  @lib.AsyncWrite::write(response, stdout)
}
