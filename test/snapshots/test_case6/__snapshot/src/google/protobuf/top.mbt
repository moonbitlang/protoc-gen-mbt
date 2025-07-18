pub(all) struct Timestamp {
  mut seconds : Int64
  mut nanos : Int
} derive(Eq, Show)
pub impl @lib.Sized for Timestamp with size_of(self) {
  let mut size = 0U
  size += 1U + @lib.size_of(self.seconds)
  size += 1U + @lib.size_of(self.nanos)
  size
}
pub impl Default for Timestamp with default() -> Timestamp {
  Timestamp::{
    seconds : Int64::default(),
    nanos : Int::default(),
  }
}
pub impl @lib.Read for Timestamp with read(reader : &@lib.Reader) {
  let msg =   Timestamp::default()

  while not(reader |> @lib.is_eof()) {
    match (reader |> @lib.read_tag()) {
      (1, _) => msg.seconds = reader |> @lib.read_int64()
      (2, _) => msg.nanos = reader |> @lib.read_int32()
     (_, wire) => reader |> @lib.read_unknown(wire)
    }
  }
  msg
}
pub impl @lib.Write for Timestamp with write(self, writer) {
  writer |> @lib.write_varint(8UL);writer |> @lib.write_int64(self.seconds)
  writer |> @lib.write_varint(16UL);writer |> @lib.write_int32(self.nanos)
}
