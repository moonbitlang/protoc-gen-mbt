pub(all) struct HelloRequest {
  mut name : String
} derive(Eq, Debug)
pub impl @lib.Sized for HelloRequest with fn size_of(self) {
  let mut size = 0U
  if self.name != Default::default() {
    size += @lib.size_of_length_delimited_field(1U, @lib.size_of(self.name))
  }
  size
}
pub impl Default for HelloRequest with fn default() -> HelloRequest {
  HelloRequest::{
    name : String::default(),
  }
}
pub fn HelloRequest::new(name : String) -> HelloRequest {
  HelloRequest::{
    name,
  }
}
pub impl @lib.Read for HelloRequest with fn read_with_limit(reader : @lib.LimitedReader[&@lib.Reader]) -> HelloRequest raise {
  let msg = HelloRequest::default()
  while (reader |> @lib.read_next_message_field()) is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, _) => msg.name = reader |> @lib.read_string()
      _ => reader |> @lib.skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}
pub impl @lib.Write for HelloRequest with fn write(self: HelloRequest, writer : &@lib.Writer) -> Unit raise {
  if self.name != Default::default() {
  writer |> @lib.write_varint(10UL);
  writer |> @lib.write_string(self.name)
  }
}
pub impl ToJson for HelloRequest with fn to_json(self) {
  let json: Map[String, Json] = {}
  if self.name != Default::default() {
  json["name"] = self.name.to_json()
  }
  Json::object(json)
}
pub impl @json.FromJson for HelloRequest with fn from_json(json: Json, path: @json.JsonPath) -> HelloRequest raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError((path, "Expected an object for HelloRequest"))
  }
  let message = HelloRequest::default()
  for key, value in obj {
    match (key, value) {
      ("name", value) => message.name = @json.from_json(value, path~)
      (key, _) => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}
pub impl @lib.AsyncRead for HelloRequest with fn read_with_limit(reader : @lib.LimitedReader[&@lib.AsyncReader]) -> HelloRequest raise {
  let msg = HelloRequest::default()
  while (reader |> @lib.async_read_next_message_field()) is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, _) => msg.name = reader |> @lib.async_read_string()
      _ => reader |> @lib.async_skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}
pub impl @lib.AsyncWrite for HelloRequest with fn write(self: HelloRequest, writer : &@lib.AsyncWriter) -> Unit raise {
  if self.name != Default::default() {
  writer |> @lib.async_write_varint(10UL);
  writer |> @lib.async_write_string(self.name)
  }
}
pub(all) struct HelloReply {
  mut message : String
} derive(Eq, Debug)
pub impl @lib.Sized for HelloReply with fn size_of(self) {
  let mut size = 0U
  if self.message != Default::default() {
    size += @lib.size_of_length_delimited_field(1U, @lib.size_of(self.message))
  }
  size
}
pub impl Default for HelloReply with fn default() -> HelloReply {
  HelloReply::{
    message : String::default(),
  }
}
pub fn HelloReply::new(message : String) -> HelloReply {
  HelloReply::{
    message,
  }
}
pub impl @lib.Read for HelloReply with fn read_with_limit(reader : @lib.LimitedReader[&@lib.Reader]) -> HelloReply raise {
  let msg = HelloReply::default()
  while (reader |> @lib.read_next_message_field()) is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, _) => msg.message = reader |> @lib.read_string()
      _ => reader |> @lib.skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}
pub impl @lib.Write for HelloReply with fn write(self: HelloReply, writer : &@lib.Writer) -> Unit raise {
  if self.message != Default::default() {
  writer |> @lib.write_varint(10UL);
  writer |> @lib.write_string(self.message)
  }
}
pub impl ToJson for HelloReply with fn to_json(self) {
  let json: Map[String, Json] = {}
  if self.message != Default::default() {
  json["message"] = self.message.to_json()
  }
  Json::object(json)
}
pub impl @json.FromJson for HelloReply with fn from_json(json: Json, path: @json.JsonPath) -> HelloReply raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError((path, "Expected an object for HelloReply"))
  }
  let message = HelloReply::default()
  for key, value in obj {
    match (key, value) {
      ("message", value) => message.message = @json.from_json(value, path~)
      (key, _) => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}
pub impl @lib.AsyncRead for HelloReply with fn read_with_limit(reader : @lib.LimitedReader[&@lib.AsyncReader]) -> HelloReply raise {
  let msg = HelloReply::default()
  while (reader |> @lib.async_read_next_message_field()) is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, _) => msg.message = reader |> @lib.async_read_string()
      _ => reader |> @lib.async_skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}
pub impl @lib.AsyncWrite for HelloReply with fn write(self: HelloReply, writer : &@lib.AsyncWriter) -> Unit raise {
  if self.message != Default::default() {
  writer |> @lib.async_write_varint(10UL);
  writer |> @lib.async_write_string(self.message)
  }
}
