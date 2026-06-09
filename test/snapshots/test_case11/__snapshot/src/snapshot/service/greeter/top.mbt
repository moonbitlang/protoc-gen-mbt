pub(open) trait GreeterService {
  fn say_hello(Self, @messages.HelloRequest) -> @messages.HelloReply raise
  // client_hello is streaming and not generated yet.
  // stream_hello is streaming and not generated yet.
  // chat is streaming and not generated yet.
}
pub(open) trait EmptyService {
}
