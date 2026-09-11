///|
test "descriptor reader skips unknown group fields" {
  let source = @lib.BytesReader::from_bytes(b"\x0b\x08\x96\x01\x0c")
    as &@lib.Reader
  let message : FileDescriptorSet = @lib.Read::read(source)
  if !message.file.is_empty() {
    fail("expected unknown group to be skipped")
  }
}

///|
test "empty delimited message consumes end group" {
  let source = @lib.BytesReader::from_bytes(b"\x0c\x96\x01") as &@lib.Reader
  let reader = @lib.LimitedReader(source)
  let _ : Empty = reader |> @lib.read_delimited_message(1U)
  if (reader |> @lib.read_varint32()) != 150U {
    fail("expected reader to continue after end group")
  }
}

///|
test "empty delimited message skips unknown payload fields" {
  let source = @lib.BytesReader::from_bytes(b"\x10\x96\x01\x0c\x96\x01")
    as &@lib.Reader
  let reader = @lib.LimitedReader(source)
  let _ : Empty = reader |> @lib.read_delimited_message(1U)
  if (reader |> @lib.read_varint32()) != 150U {
    fail("expected reader to continue after unknown group payload")
  }
}
