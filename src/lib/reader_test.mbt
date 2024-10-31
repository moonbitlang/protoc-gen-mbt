test "varint" {
  let r = @lib.BytesReader::from_bytes(b"\x96\x01") as @lib.Reader
  assert_eq!(r |> @lib.read_varint32!(), 150)
  assert_eq!(r.next_bytes!(0), None)
}

test "integer" {
  let r = @lib.BytesReader::from_bytes(
      b"\xFE\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x01",
    )
    as @lib.Reader
  assert_eq!(r |> @lib.read_int64!(), -2)
}

test "signed integer" {
  let r = @lib.BytesReader::from_bytes(b"\x00") as @lib.Reader
  assert_eq!(r |> @lib.read_sint32!(), 0)
  let r = @lib.BytesReader::from_bytes(b"\x01") as @lib.Reader
  assert_eq!(r |> @lib.read_sint32!(), -1)
  let r = @lib.BytesReader::from_bytes(b"\x02") as @lib.Reader
  assert_eq!(r |> @lib.read_sint32!(), 1)
  let r = @lib.BytesReader::from_bytes(b"\x03") as @lib.Reader
  assert_eq!(r |> @lib.read_sint32!(), -2)
}
