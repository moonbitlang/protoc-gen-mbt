struct OneByteReader {
  data : Bytes
  len : Int
  mut start : Int
}

fn OneByteReader::from_bytes(data : Bytes) -> OneByteReader {
  { data, len: data.length(), start: 0 }
}

pub impl @protobuf.Reader for OneByteReader with read(
  self,
  bytes : FixedArray[Byte],
  offset~ : Int,
  max_length~ : Int,
) -> Int? {
  if offset >= bytes.length() || max_length <= 0 || self.start >= self.len {
    return None
  }
  let offset = offset % bytes.length()
  let read_length = @cmp.minimum(
    1,
    @cmp.minimum(bytes.length() - offset, @cmp.minimum(max_length, self.len - self.start)),
  )
  bytes.blit_from_bytes(offset, self.data, self.start, read_length)
  self.start += read_length
  Some(read_length)
}

///|
test "chunked-reader/one-byte" {
  let writer = @buffer.new()
  writer |> @protobuf.write_tag((1U, 5U))
  writer |> @protobuf.write_fixed32(0xAABBCCDDU)
  writer |> @protobuf.write_tag((2U, 1U))
  writer |> @protobuf.write_fixed64(0x1122334455667788UL)
  writer |> @protobuf.write_tag((3U, 2U))
  let emoji = "😀"
  writer |> @protobuf.write_string(emoji)
  writer |> @protobuf.write_tag((4U, 2U))
  let payload = b"\x00\x01\x02\x03"
  writer |> @protobuf.write_bytes(payload)
  let bytes = writer.to_bytes()
  let reader = OneByteReader::from_bytes(bytes) as &@protobuf.Reader

  let (tag, wire_type) = reader |> @protobuf.read_tag()
  assert_eq(tag, 1U)
  assert_eq(wire_type, 5U)
  assert_eq(reader |> @protobuf.read_fixed32(), 0xAABBCCDDU)

  let (tag, wire_type) = reader |> @protobuf.read_tag()
  assert_eq(tag, 2U)
  assert_eq(wire_type, 1U)
  assert_eq(reader |> @protobuf.read_fixed64(), 0x1122334455667788UL)

  let (tag, wire_type) = reader |> @protobuf.read_tag()
  assert_eq(tag, 3U)
  assert_eq(wire_type, 2U)
  assert_eq(reader |> @protobuf.read_string(), emoji)

  let (tag, wire_type) = reader |> @protobuf.read_tag()
  assert_eq(tag, 4U)
  assert_eq(wire_type, 2U)
  assert_eq(reader |> @protobuf.read_bytes(), payload)
}
