///|
/// Imported enum fields should stay qualified when a local enum has the same name.
test "constructor accepts imported enum type when local name collides" {
  let message = @use.UsesImportedEnum::new(
    @shared.SharedState::SHARED_STATE_READY,
  )
  @debug.assert_eq(message.state, @shared.SharedState::SHARED_STATE_READY)
}
