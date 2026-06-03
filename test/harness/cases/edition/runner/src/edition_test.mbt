///|
/// Expanded repeated numeric fields should be sized like the writer emits them.
test "edition expanded repeated scalar size matches writer" {
  let message = @edition.Payload::default()
  message.values.push(1)
  message.values.push(150)
  message.implicit_value = 7
  let writer = @buffer.Buffer::Buffer()
  @protobuf.Write::write(message, writer)
  @debug.assert_eq(
    @protobuf.size_of(message),
    writer.to_bytes().length().reinterpret_as_uint(),
  )
}

///|
/// Edition presence features should decide whether generated fields use `?`.
test "edition field presence controls generated shape" {
  let message = @edition.Payload::new([], 7)
  @debug.assert_eq(message.implicit_value, 7)
  @debug.assert_eq(message.explicit_value, None)
  let with_explicit = @edition.Payload::new([], 7, explicit_value=9)
  @debug.assert_eq(with_explicit.explicit_value, Some(9))
}
