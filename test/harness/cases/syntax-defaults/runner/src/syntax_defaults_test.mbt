///|
/// Proto2 required and optional field labels should keep distinct generated shapes.
test "proto2 field labels control generated presence" {
  let message = @proto2.Proto2Presence::new(
    7,
    [],
    optional_value=9,
    state=@proto2.Proto2State::PROTO2_STATE_READY,
  )
  @debug.assert_eq(message.required_value, 7)
  @debug.assert_eq(message.optional_value, Some(9))
  @debug.assert_eq(message.state, Some(@proto2.Proto2State::PROTO2_STATE_READY))
}

///|
/// Proto2 required fields have explicit presence, so even a default value is emitted.
test "proto2 required default value still writes" {
  let message = @proto2.Proto2Presence::new(0, [])
  let writer = @buffer.Buffer::Buffer()
  @protobuf.Write::write(message, writer)
  @debug.assert_eq(writer.to_bytes(), b"\x08\x00")
  @debug.assert_eq(@protobuf.size_of(message), 2U)
}

///|
/// Proto2 repeated scalar fields default to expanded encoding.
test "proto2 repeated scalar writes expanded values by default" {
  let message = @proto2.Proto2Presence::new(7, [1, 150])
  let writer = @buffer.Buffer::Buffer()
  @protobuf.Write::write(message, writer)
  @debug.assert_eq(writer.to_bytes(), b"\x08\x07\x18\x01\x18\x96\x01")
}

///|
/// Proto2 enums are closed by default and reject unknown numeric values.
test "proto2 enum is closed by default" {
  @debug.assert_eq(
    @proto2.Proto2State::from_enum(@protobuf.Enum(7)),
    @proto2.Proto2State::PROTO2_STATE_UNSPECIFIED,
  )
}

///|
/// Proto2 groups should lower to nested message values with group wire encoding.
test "proto2 group writes group wire format" {
  let child = @proto2.Proto2Groups_OptionalGroup::new(value=150)
  let message = @proto2.Proto2Groups::new([], optionalgroup=child)
  let writer = @buffer.Buffer::Buffer()
  @protobuf.Write::write(message, writer)
  @debug.assert_eq(writer.to_bytes(), b"\x0b\x10\x96\x01\x0c")
  @debug.assert_eq(
    @protobuf.size_of(message),
    writer.to_bytes().length().reinterpret_as_uint(),
  )
}

///|
/// Proto2 group readers should accept start/end group tags as one nested message.
test "proto2 group reads group wire format" {
  let reader = @protobuf.BytesReader::from_bytes(b"\x0b\x10\x96\x01\x0c")
  let message : @proto2.Proto2Groups = @protobuf.Read::read(reader)
  @debug.assert_eq(
    message.optionalgroup,
    Some(@proto2.Proto2Groups_OptionalGroup::new(value=150)),
  )
}

///|
/// Repeated proto2 groups should parse each group envelope as one array item.
test "proto2 repeated groups use repeated group envelopes" {
  let child = @proto2.Proto2Groups_RepeatedGroup::new(value=150)
  let message = @proto2.Proto2Groups::new([child])
  let writer = @buffer.Buffer::Buffer()
  @protobuf.Write::write(message, writer)
  @debug.assert_eq(writer.to_bytes(), b"\x1b\x20\x96\x01\x1c")
  let reader = @protobuf.BytesReader::from_bytes(writer.to_bytes())
  let parsed : @proto2.Proto2Groups = @protobuf.Read::read(reader)
  @debug.assert_eq(parsed.repeatedgroup, [child])
}

///|
/// Unknown group fields need field-number-aware skipping to find the matching end tag.
test "proto2 unknown group fields are skipped" {
  let reader = @protobuf.BytesReader::from_bytes(b"\x33\x08\x63\x34\x28\x07")
  let message : @proto2.Proto2Groups = @protobuf.Read::read(reader)
  @debug.assert_eq(message.after, Some(7))
}

///|
/// Async generated codecs should use the same proto2 group wire format.
async test "proto2 group async codecs" {
  let child = @proto2.Proto2Groups_OptionalGroup::new(value=150)
  let message = @proto2.Proto2Groups::new([], optionalgroup=child)
  let writer = @buffer.Buffer::Buffer()
  @protobuf.AsyncWrite::write(message, writer)
  @debug.assert_eq(writer.to_bytes(), b"\x0b\x10\x96\x01\x0c")
  let reader = @protobuf.BytesReader::from_bytes(writer.to_bytes())
  let parsed : @proto2.Proto2Groups = @protobuf.AsyncRead::read(reader)
  @debug.assert_eq(parsed.optionalgroup, Some(child))
}

///|
/// Proto3 optional and implicit fields should keep distinct generated shapes.
test "proto3 optional field controls generated presence" {
  let message = @proto3.Proto3Defaults::new(
    0,
    [],
    @proto3.Proto3State::PROTO3_STATE_UNSPECIFIED,
    explicit_value=9,
  )
  @debug.assert_eq(message.implicit_value, 0)
  @debug.assert_eq(message.explicit_value, Some(9))
}

///|
/// Proto3 repeated scalar fields default to packed encoding.
test "proto3 repeated scalar writes packed values by default" {
  let message = @proto3.Proto3Defaults::new(
    0,
    [1, 150],
    @proto3.Proto3State::PROTO3_STATE_UNSPECIFIED,
  )
  let writer = @buffer.Buffer::Buffer()
  @protobuf.Write::write(message, writer)
  @debug.assert_eq(writer.to_bytes(), b"\x1a\x03\x01\x96\x01")
}

///|
/// Proto3 enums are open by default and preserve unknown numeric values.
test "proto3 enum is open by default" {
  @debug.assert_eq(
    @proto3.Proto3State::from_enum(@protobuf.Enum(7)),
    @proto3.Proto3State::Unknown(@protobuf.Enum(7)),
  )
}
