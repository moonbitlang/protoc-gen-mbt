pub(all) struct EmptyMessage {
} derive(Eq, Debug)
pub impl @lib.Sized for EmptyMessage with fn size_of(_) {
  0
}
pub impl Default for EmptyMessage with fn default() -> EmptyMessage {
  EmptyMessage::{
  }
}
#alias(new, deprecated)
pub fn EmptyMessage::EmptyMessage() -> EmptyMessage {
  EmptyMessage::{
  }
}
pub impl @lib.Read for EmptyMessage with fn read_with_limit(_) -> EmptyMessage noraise {
  Default::default()
}
pub impl @lib.Write for EmptyMessage with fn write(_, _) -> Unit noraise {
}
pub impl ToJson for EmptyMessage with fn to_json(_) {
  {}
}
pub impl @json.FromJson for EmptyMessage with fn from_json(_, _) -> EmptyMessage noraise {
  Default::default()
}
pub impl @lib.AsyncRead for EmptyMessage with fn read_with_limit(_) -> EmptyMessage noraise {
  Default::default()
}
pub impl @lib.AsyncWrite for EmptyMessage with fn write(_, _) -> Unit noraise {
}
pub extend EmptyMessage with Eq::{not_equal, equal}
pub extend EmptyMessage with Debug::{to_repr}
pub extend EmptyMessage with Default::{default}
pub extend EmptyMessage with @lib.Sized::{size_of}
pub extend EmptyMessage with @lib.Read::{read, read_with_limit}
pub extend EmptyMessage with @lib.Write::{write}
pub extend EmptyMessage with ToJson::{to_json}
pub extend EmptyMessage with @json.FromJson::{from_json}
