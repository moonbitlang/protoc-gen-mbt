pub(all) struct Timestamp {
  mut seconds : Int64
  mut nanos : Int
} derive(Eq, Debug)
pub impl @lib.Sized for Timestamp with fn size_of(self) {
  let mut size = 0U
  if self.seconds != Default::default() {
    size += 1U + @lib.size_of(self.seconds)
  }
  if self.nanos != Default::default() {
    size += 1U + @lib.size_of(self.nanos)
  }
  size
}
pub impl Default for Timestamp with fn default() -> Timestamp {
  Timestamp::{
    seconds : Int64::default(),
    nanos : Int::default(),
  }
}
pub fn Timestamp::new(seconds : Int64, nanos : Int) -> Timestamp {
  Timestamp::{
    seconds,
    nanos,
  }
}
pub impl @lib.Read for Timestamp with fn read_with_limit(reader : @lib.LimitedReader[&@lib.Reader]) -> Timestamp raise {
  let msg = Timestamp::default()
  reader |> @lib.read_message_fields(fn(field_number, wire) raise {
    match (field_number, wire) {
      (1, _) => { msg.seconds = reader |> @lib.read_int64(); true }
      (2, _) => { msg.nanos = reader |> @lib.read_int32(); true }
      _ => false
    }
  })
  msg
}
pub impl @lib.Write for Timestamp with fn write(self: Timestamp, writer : &@lib.Writer) -> Unit raise {
  if self.seconds != Default::default() {
  writer |> @lib.write_varint(8UL);
  writer |> @lib.write_int64(self.seconds)
  }
  if self.nanos != Default::default() {
  writer |> @lib.write_varint(16UL);
  writer |> @lib.write_int32(self.nanos)
  }
}
pub impl @lib.AsyncRead for Timestamp with fn read_with_limit(reader : @lib.LimitedReader[&@lib.AsyncReader]) -> Timestamp raise {
  let msg = Timestamp::default()
  reader |> @lib.async_read_message_fields(async fn(field_number, wire) {
    match (field_number, wire) {
      (1, _) => { msg.seconds = reader |> @lib.async_read_int64(); true }
      (2, _) => { msg.nanos = reader |> @lib.async_read_int32(); true }
      _ => false
    }
  })
  msg
}
pub impl @lib.AsyncWrite for Timestamp with fn write(self: Timestamp, writer : &@lib.AsyncWriter) -> Unit raise {
  if self.seconds != Default::default() {
  writer |> @lib.async_write_varint(8UL);
  writer |> @lib.async_write_int64(self.seconds)
  }
  if self.nanos != Default::default() {
  writer |> @lib.async_write_varint(16UL);
  writer |> @lib.async_write_int32(self.nanos)
  }
}
