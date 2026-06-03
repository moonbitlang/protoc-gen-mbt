///|
/// Unpacked repeated scalar size should match the bytes written by the Runtime.
test "sized matches writer for unpacked repeated scalar" {
  let message = @size.Payload::default()
  message.values.push(1)
  message.values.push(150)
  message.tail = "after"
  let writer = @buffer.Buffer::Buffer()
  @protobuf.Write::write(message, writer)
  @debug.assert_eq(
    @protobuf.size_of(message),
    writer.to_bytes().length().reinterpret_as_uint(),
  )
}

///|
/// Proto3 implicit defaults and empty packed repeated fields should not emit bytes.
test "proto3 default payload emits empty wire output" {
  let message = @size.Payload::default()
  let writer = @buffer.Buffer::Buffer()
  @protobuf.Write::write(message, writer)
  @debug.assert_eq(writer.to_bytes(), b"")
  @debug.assert_eq(@protobuf.size_of(message), 0U)
}
