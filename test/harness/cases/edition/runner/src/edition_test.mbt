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
/// Implicit default values and empty packed fields should not be serialized.
test "edition default payload emits empty wire output" {
  let message = @edition.Payload::default()
  let writer = @buffer.Buffer::Buffer()
  @protobuf.Write::write(message, writer)
  @debug.assert_eq(writer.to_bytes(), b"")
  @debug.assert_eq(@protobuf.size_of(message), 0U)
}

///|
/// Edition presence features should decide whether generated fields use `?`.
test "edition field presence controls generated shape" {
  let message = @edition.Payload::new([], 7, [])
  @debug.assert_eq(message.implicit_value, 7)
  @debug.assert_eq(message.explicit_value, None)
  let with_explicit = @edition.Payload::new([], 7, [], explicit_value=9)
  @debug.assert_eq(with_explicit.explicit_value, Some(9))
}

///|
/// File-level presence features should be inherited by fields without overrides.
test "edition file inherited field presence controls generated shape" {
  let message = @file_inherited.FilePresence::new(7)
  @debug.assert_eq(message.scalar, 7)
  @debug.assert_eq(message.explicit_scalar, None)
  @debug.assert_eq(message.child, None)
  let child = @file_inherited.FileChild::new(1)
  let with_explicit = @file_inherited.FilePresence::new(
    7,
    explicit_scalar=9,
    child~,
  )
  @debug.assert_eq(with_explicit.explicit_scalar, Some(9))
  @debug.assert_eq(with_explicit.child, Some(child))
}

///|
/// File-level repeated encoding features should be inherited by repeated scalars.
test "edition file inherited repeated encoding writes expanded values" {
  let message = @file_inherited.FileRepeatedEncoding::default()
  message.values.push(1)
  message.values.push(150)
  let writer = @buffer.Buffer::Buffer()
  @protobuf.Write::write(message, writer)
  @debug.assert_eq(writer.to_bytes(), b"\x08\x01\x08\x96\x01")
}

///|
/// Open enum fields should preserve unknown numeric wire values.
test "edition open enum preserves unknown wire values" {
  let reader = @protobuf.BytesReader::from_bytes(b"\x08\x07")
  let message : @open_enum.OpenEnumPayload = @protobuf.Read::read(reader)
  @debug.assert_eq(
    message.state,
    Some(@open_enum.State::Unknown(@protobuf.Enum(7))),
  )
  let writer = @buffer.Buffer::Buffer()
  @protobuf.Write::write(message, writer)
  @debug.assert_eq(writer.to_bytes(), b"\x08\x07")
}

///|
/// Open enum JSON parsing should preserve unknown numeric values.
test "edition open enum preserves unknown json numbers" {
  let unknown = Json::number(7.0)
  let state : @open_enum.State = @json.from_json(unknown)
  @debug.assert_eq(state, @open_enum.State::Unknown(@protobuf.Enum(7)))
  @debug.assert_eq(state.to_json(), unknown)
}

///|
/// Open enum JSON parsing should reject fractional numeric enum values.
test "edition open enum rejects fractional json numbers" {
  try {
    let _ : @open_enum.State = @json.from_json(Json::number(7.5))
    fail("expected JsonDecodeError")
  } catch {
    @json.JsonDecodeError(_) => ()
    err => raise err
  }
}

///|
/// Enum-level CLOSED should override the Editions open-enum default.
test "edition closed enum override rejects unknown enum values" {
  @debug.assert_eq(
    @open_enum.ClosedState::from_enum(@protobuf.Enum(7)),
    @open_enum.ClosedState::CLOSED_STATE_UNSPECIFIED,
  )
}

///|
/// The synthetic open-enum unknown carrier should not collide with real values.
test "edition open enum unknown carrier avoids generated value name collision" {
  @debug.assert_eq(
    @open_enum.UnknownNameState::Unknown.to_enum(),
    @protobuf.Enum(0),
  )
  @debug.assert_eq(
    @open_enum.UnknownNameState::Unknown1.to_enum(),
    @protobuf.Enum(2),
  )
  let unknown = @open_enum.UnknownNameState::from_enum(@protobuf.Enum(7))
  @debug.assert_eq(
    unknown,
    @open_enum.UnknownNameState::Unknown2(@protobuf.Enum(7)),
  )
  @debug.assert_eq(unknown.to_json(), Json::number(7.0))
}

///|
/// DELIMITED message encoding should emit start/end group tags around the payload.
test "edition delimited message encoding writes group wire format" {
  let child = @delimited.Payload_Child::new(value=150)
  let message = @delimited.Payload::default()
  message.delimited_child = Some(child)
  let writer = @buffer.Buffer::Buffer()
  @protobuf.Write::write(message, writer)
  @debug.assert_eq(writer.to_bytes(), b"\x0b\x08\x96\x01\x0c")
  @debug.assert_eq(
    @protobuf.size_of(message),
    writer.to_bytes().length().reinterpret_as_uint(),
  )
}

///|
/// Readers should accept DELIMITED message fields written as groups.
test "edition delimited message encoding reads group wire format" {
  let reader = @protobuf.BytesReader::from_bytes(b"\x0b\x08\x96\x01\x0c")
  let message : @delimited.Payload = @protobuf.Read::read(reader)
  @debug.assert_eq(
    message.delimited_child,
    Some(@delimited.Payload_Child::new(value=150)),
  )
}

///|
/// Repeated DELIMITED message fields should parse each group as one element.
test "edition repeated delimited messages use repeated groups" {
  let child = @delimited.Payload_Child::new(value=150)
  let message = @delimited.Payload::default()
  message.delimited_children.push(child)
  let writer = @buffer.Buffer::Buffer()
  @protobuf.Write::write(message, writer)
  @debug.assert_eq(writer.to_bytes(), b"\x1b\x08\x96\x01\x1c")
  let reader = @protobuf.BytesReader::from_bytes(writer.to_bytes())
  let parsed : @delimited.Payload = @protobuf.Read::read(reader)
  @debug.assert_eq(parsed.delimited_children, [child])
}

///|
/// Empty DELIMITED message fields should consume their end-group tag.
test "edition empty delimited message consumes end group" {
  let reader = @protobuf.BytesReader::from_bytes(b"\x23\x24\x28\x07")
  let message : @delimited.Payload = @protobuf.Read::read(reader)
  @debug.assert_eq(
    message.empty_delimited,
    Some(@delimited.Payload_Empty::default()),
  )
  @debug.assert_eq(message.after_empty, Some(7))
}

///|
/// Empty DELIMITED message fields should skip unknown payload fields.
test "edition empty delimited message skips unknown payload fields" {
  let reader = @protobuf.BytesReader::from_bytes(b"\x23\x08\x96\x01\x24")
  let message : @delimited.Payload = @protobuf.Read::read(reader)
  @debug.assert_eq(
    message.empty_delimited,
    Some(@delimited.Payload_Empty::default()),
  )
}

///|
/// Ordinary edition message fields should stay length-prefixed.
test "edition ordinary message encoding stays length prefixed" {
  let child = @delimited.Payload_Child::new(value=150)
  let message = @delimited.Payload::default()
  message.length_prefixed_child = Some(child)
  let writer = @buffer.Buffer::Buffer()
  @protobuf.Write::write(message, writer)
  @debug.assert_eq(writer.to_bytes(), b"\x12\x03\x08\x96\x01")
}

///|
/// File-level DELIMITED defaults should not change map-entry wire encoding.
test "edition file delimited maps stay length prefixed" {
  let child = @file_delimited.Child::new(value=150)
  let message = @file_delimited.Payload::default()
  message.default_child = Some(child)
  message.children_by_name["a"] = child
  let writer = @buffer.Buffer::Buffer()
  @protobuf.Write::write(message, writer)
  @debug.assert_eq(
    writer.to_bytes(),
    b"\x0b\x08\x96\x01\x0c\x32\x08\x0a\x01a\x12\x03\x08\x96\x01",
  )
  let reader = @protobuf.BytesReader::from_bytes(
    b"\x32\x08\x0a\x01a\x12\x03\x08\x96\x01",
  )
  let parsed : @file_delimited.Payload = @protobuf.Read::read(reader)
  @debug.assert_eq(parsed.children_by_name.get("a"), Some(child))
}

///|
/// Async generated codecs should use the same DELIMITED message wire format.
async test "edition delimited message encoding async codecs" {
  let child = @delimited.Payload_Child::new(value=150)
  let message = @delimited.Payload::default()
  message.delimited_child = Some(child)
  let writer = @buffer.Buffer::Buffer()
  @protobuf.AsyncWrite::write(message, writer)
  @debug.assert_eq(writer.to_bytes(), b"\x0b\x08\x96\x01\x0c")
  let reader = @protobuf.BytesReader::from_bytes(writer.to_bytes())
  let parsed : @delimited.Payload = @protobuf.AsyncRead::read(reader)
  @debug.assert_eq(parsed.delimited_child, Some(child))
}

///|
/// Async empty DELIMITED message fields should consume their end-group tag.
async test "edition empty delimited message async consumes end group" {
  let reader = @protobuf.BytesReader::from_bytes(b"\x23\x24\x28\x07")
  let message : @delimited.Payload = @protobuf.AsyncRead::read(reader)
  @debug.assert_eq(
    message.empty_delimited,
    Some(@delimited.Payload_Empty::default()),
  )
  @debug.assert_eq(message.after_empty, Some(7))
}
