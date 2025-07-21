pub(all) struct Test {
  mut created_at :  @lib1.Hello 
} derive(Eq, Show)
pub impl @lib.Sized for Test with size_of(self) {
  let mut size = 0U
  size += 1U + { let size = @lib.size_of(self.created_at); @lib.size_of(size) + size }
  size
}
pub impl Default for Test with default() -> Test {
  Test::{
    created_at : @lib1.Hello::default(),
  }
}
pub impl @lib.Read for Test with read(reader : &@lib.Reader) {
  let msg =   Test::default()

  while not(reader |> @lib.is_eof()) {
    match (reader |> @lib.read_tag()) {
      (1, _) => msg.created_at = ((reader |> @lib.read_message()) : @lib1.Hello)
     (_, wire) => reader |> @lib.read_unknown(wire)
    }
  }
  msg
}
pub impl @lib.Write for Test with write(self, writer) {
  writer |> @lib.write_varint(10UL);writer |> @lib.write_uint32(@lib.size_of(self.created_at)); @lib.Write::write(self.created_at, writer)
}
