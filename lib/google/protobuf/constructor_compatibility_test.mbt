///|
#warnings("-deprecated")
test "legacy constructors preserve positional and optional arguments" {
  let timestamp = @protobuf.Timestamp::new(123L, 456)
  assert_eq(timestamp.seconds, 123L)
  assert_eq(timestamp.nanos, 456)
  let value = @protobuf.Value::new(kind=@protobuf.Value_Kind::NumberValue(42.0))
  assert_true(value.kind is NumberValue(42.0))
  assert_true(@protobuf.Value::new().kind is NotSet)
}
