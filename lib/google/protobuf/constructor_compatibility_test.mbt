///|
#warnings("-deprecated")
test "legacy constructors preserve positional and optional arguments" {
  let timestamp = Timestamp::new(123L, 456)
  assert_eq(timestamp.seconds, 123L)
  assert_eq(timestamp.nanos, 456)
  let value = Value::new(kind=Value_Kind::NumberValue(42.0))
  assert_true(value.kind is NumberValue(42.0))
  assert_true(Value::new().kind is NotSet)
}
