test "varint" {
  let writer = @buffer.Buffer::new()
  writer |> @lib.write_varint(150)
  assert_eq!(writer.to_bytes(), b"\x96\x01")
}

test "integer" {
  let writer = @buffer.Buffer::new()
  writer |> @lib.write_int64(-2)
  assert_eq!(writer.to_bytes(), b"\xFE\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x01")
}

test "signed integer" {
  let writer = @buffer.Buffer::new()
  writer |> @lib.write_sint32(0)
  writer |> @lib.write_sint32(-1)
  writer |> @lib.write_sint32(1)
  writer |> @lib.write_sint32(-2)
  assert_eq!(writer.to_bytes(), b"\x00\x01\x02\x03")
}

test "string" {
  let writer = @buffer.Buffer::new()
  writer |> @lib.write_string("ab")
  writer |> @lib.write_string("中文")
  assert_eq!(writer.to_bytes(), b"\x02\x61\x62\x06\xE4\xB8\xAD\xE6\x96\x87")
}
