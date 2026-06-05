///|
struct ChunkedReader {
  data : Bytes
  max_chunk : Int
  read_calls : Array[Int]
  mut start : Int
}

///|
fn ChunkedReader::from_bytes(
  data : Bytes,
  max_chunk~ : Int,
  read_calls~ : Array[Int],
) -> ChunkedReader {
  { data, max_chunk, read_calls, start: 0 }
}

///|
pub impl @protobuf.Reader for ChunkedReader with fn read(
  self,
  bytes : FixedArray[Byte],
  offset~ : Int,
  max_length~ : Int,
) -> Int? {
  if offset >= bytes.length() ||
    max_length <= 0 ||
    self.start >= self.data.length() {
    return None
  }
  self.read_calls[0] = self.read_calls[0] + 1
  let read_length = @cmp.minimum(
    self.max_chunk,
    @cmp.minimum(
      bytes.length() - offset,
      @cmp.minimum(max_length, self.data.length() - self.start),
    ),
  )
  bytes.blit_from_bytes(offset, self.data, self.start, read_length)
  self.start += read_length
  Some(read_length)
}

///|
test "BufferedReader batches upstream reads for varints" {
  let writer = Buffer()
  for i in 0..<32 {
    writer |> @protobuf.write_varint(i.to_uint64())
  }
  let read_calls = [0]
  let source = ChunkedReader::from_bytes(
    writer.to_bytes(),
    max_chunk=16,
    read_calls~,
  )
  let reader = @protobuf.BufferedReader::new(source, capacity=16)
    as &@protobuf.Reader
  for i in 0..<32 {
    @test.assert_eq(
      reader |> @protobuf.read_varint32(),
      i.reinterpret_as_uint(),
    )
  }
  @test.assert_eq(read_calls[0], 2)
}

///|
test "BufferedReader preserves bytes read past a limited reader" {
  let packed_writer = Buffer()
  packed_writer |> @protobuf.write_sint32(1)
  packed_writer |> @protobuf.write_sint32(2)
  packed_writer |> @protobuf.write_sint32(3)
  let writer = Buffer()
  writer |> @protobuf.write_tag((1U, 2U))
  writer |> @protobuf.write_bytes(packed_writer.to_bytes())
  writer |> @protobuf.write_tag((2U, 0U))
  writer |> @protobuf.write_int32(150)
  let read_calls = [0]
  let source = ChunkedReader::from_bytes(
    writer.to_bytes(),
    max_chunk=16,
    read_calls~,
  )
  let reader = @protobuf.BufferedReader::new(source, capacity=16)
    as &@protobuf.Reader
  let (tag, wire_type) = reader |> @protobuf.read_tag()
  @test.assert_eq(tag, 1U)
  @test.assert_eq(wire_type, 2U)
  let packed = @protobuf.read_packed(
    reader,
    fn(reader) raise { reader |> @protobuf.read_sint32() },
    None,
  )
  let values : Array[Int] = []
  for value in packed {
    values.push(value.0)
  }
  @test.assert_eq(values, [1, 2, 3])
  let (tag, wire_type) = reader |> @protobuf.read_tag()
  @test.assert_eq(tag, 2U)
  @test.assert_eq(wire_type, 0U)
  @test.assert_eq(reader |> @protobuf.read_int32(), 150)
}
