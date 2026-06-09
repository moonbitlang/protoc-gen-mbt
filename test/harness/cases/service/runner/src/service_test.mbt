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

///|
/// Service descriptors should include all methods, including streaming RPCs.
test "service descriptor includes method metadata" {
  let descriptor = @greeter.greeter_service_descriptor
  @debug.assert_eq(descriptor.name, "Greeter")
  @debug.assert_eq(descriptor.full_name, "harness.service.greeter.Greeter")
  @debug.assert_eq(descriptor.methods.length(), 4)
  let unary = descriptor.methods[0]
  @debug.assert_eq(unary.name, "SayHello")
  @debug.assert_eq(
    unary.full_name,
    "harness.service.greeter.Greeter.SayHello",
  )
  @debug.assert_eq(unary.path, "/harness.service.greeter.Greeter/SayHello")
  @debug.assert_eq(unary.input_type_name, "harness.service.messages.HelloRequest")
  @debug.assert_eq(unary.output_type_name, "harness.service.messages.HelloReply")
  @debug.assert_eq(unary.client_streaming, false)
  @debug.assert_eq(unary.server_streaming, false)
  let server_streaming = descriptor.methods[2]
  @debug.assert_eq(server_streaming.name, "StreamHello")
  @debug.assert_eq(server_streaming.client_streaming, false)
  @debug.assert_eq(server_streaming.server_streaming, true)
  let bidi = descriptor.methods[3]
  @debug.assert_eq(bidi.name, "Chat")
  @debug.assert_eq(bidi.client_streaming, true)
  @debug.assert_eq(bidi.server_streaming, true)
}

///|
/// Empty services should still get a trait and an empty descriptor.
test "empty service descriptor is generated" {
  @debug.assert_eq(@greeter.empty_service_descriptor.name, "Empty")
  @debug.assert_eq(@greeter.empty_service_descriptor.methods.length(), 0)
}
