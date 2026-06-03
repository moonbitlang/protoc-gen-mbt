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
