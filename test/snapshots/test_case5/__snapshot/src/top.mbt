pub(all) struct EmptyMessage {
} derive(Eq, Show)
pub impl @lib.Sized for EmptyMessage with size_of(self) {
  0
}
pub impl Default for EmptyMessage with default() -> EmptyMessage {
  EmptyMessage::{
  }
}
pub impl @lib.Read for EmptyMessage with read(reader : &@lib.Reader) {
  EmptyMessage::default()

}
pub impl @lib.Write for EmptyMessage with write(self, writer) {
}
