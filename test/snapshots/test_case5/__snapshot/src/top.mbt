pub(all) struct EmptyMessage {
} derive(Eq, Show)
pub impl @protobuf.Sized for EmptyMessage with size_of(self) {
  0
}
pub impl Default for EmptyMessage with default() -> EmptyMessage {
  EmptyMessage::{
  }
}
pub async fn[R: @protobuf.AsyncReader] EmptyMessage::read(reader : R) -> EmptyMessage raise {
  let reader = @protobuf.LimitedReader::new(reader)
  EmptyMessage::read_with_limit(reader)
}
pub async fn[R: @protobuf.AsyncReader] EmptyMessage::read_with_limit(reader : @protobuf.LimitedReader[R], limit ?: Int) -> EmptyMessage raise {
  let new_limit = if reader.limit is Some(l) && limit is Some(limit) {
    if l < limit { raise @protobuf.EndOfStream }
    Some(l - limit)
  } else { None }
  reader.limit = limit
  let msg = EmptyMessage::default()

  reader.limit = new_limit
  msg
}
pub async fn[W: @protobuf.AsyncWriter] EmptyMessage::write(self:Self, writer : W) -> Unit raise {
}
pub impl ToJson for EmptyMessage with to_json(self) {

  let json: Map[String, Json] = {}
  Json::object(json)
}
pub impl @json.FromJson for EmptyMessage with from_json(json: Json, path: @json.JsonPath) -> EmptyMessage raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError((path, "Expected an object for EmptyMessage"))
  }
  let message = EmptyMessage::default()

  for key, value in obj {
    match (key, value) {
      key => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
      }
  }
  message
}
