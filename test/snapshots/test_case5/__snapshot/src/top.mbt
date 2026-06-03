pub(all) struct EmptyMessage {
} derive(Eq, Debug)
pub impl @lib.Sized for EmptyMessage with fn size_of(_) {
  0
}
pub impl Default for EmptyMessage with fn default() -> EmptyMessage {
  EmptyMessage::{
  }
}
pub fn EmptyMessage::new() -> EmptyMessage {
  EmptyMessage::{
  }
}
pub impl @lib.Read for EmptyMessage with fn read_with_limit(_) -> EmptyMessage noraise {
  EmptyMessage::default()
}
pub impl @lib.Write for EmptyMessage with fn write(_, _) -> Unit noraise {
}
pub impl ToJson for EmptyMessage with fn to_json(_) {
  {}
}
pub impl @json.FromJson for EmptyMessage with fn from_json(_, _) -> EmptyMessage noraise {
  EmptyMessage::default()
}
pub impl @lib.AsyncRead for EmptyMessage with fn read_with_limit(_) -> EmptyMessage noraise {
  EmptyMessage::default()
}
pub impl @lib.AsyncWrite for EmptyMessage with fn write(_, _) -> Unit noraise {
}
