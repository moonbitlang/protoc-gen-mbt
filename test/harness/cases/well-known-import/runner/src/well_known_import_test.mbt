///|
/// Well-known imports should resolve to the runtime google/protobuf package.
test "timestamp import uses runtime type" {
  let timestamp = @protobuf.Timestamp::new(Int64::from_int(123), 456)
  let event = @wkt.Event::new(created_at=timestamp)
  @debug.assert_eq(event.created_at, Some(timestamp))
}
