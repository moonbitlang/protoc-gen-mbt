///|
/// Open enum unknown carriers should remain compilable with requested derives.
test "open enum supports requested arbitrary derive" {
  let generated : @enum_derive.DerivedState = @quickcheck.gen(size=4)
  let roundtrip = @enum_derive.DerivedState::from_enum(generated.to_enum())
  @debug.assert_eq(roundtrip.to_enum(), generated.to_enum())
}
