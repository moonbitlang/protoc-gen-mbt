test "varint" {
  let data : Bytes = Bytes::from_array([0x96, 0x01])
  let r = @lib.from_bytes(data)
  assert_eq!(r.read_varint32!(data), 150)
  assert_eq!(r.is_eof(), true)
}
