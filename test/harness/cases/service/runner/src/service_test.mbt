///|
struct Handler {
}

///|
impl @greeter.GreeterService for Handler with fn say_hello(
  _,
  request : @messages.HelloRequest,
) -> @messages.HelloReply raise {
  @messages.HelloReply::new("Hello, \{request.name}")
}

///|
/// Generated unary service traits should be implementable by user code.
test "service unary trait compiles" {
  let response = @greeter.GreeterService::say_hello(
    Handler::{},
    @messages.HelloRequest::new("MoonBit"),
  )
  @debug.assert_eq(response.message, "Hello, MoonBit")
}
