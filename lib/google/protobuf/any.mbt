///|
pub(all) struct Any {
  mut type_url : String
  mut value : Bytes
} derive(Eq, Debug)

///|
pub impl @lib.Sized for Any with fn size_of(self) {
  let mut size = 0U
  if self.type_url != Default::default() {
    size += @lib.size_of_length_delimited_field(1U, @lib.size_of(self.type_url))
  }
  if self.value != Default::default() {
    size += @lib.size_of_length_delimited_field(1U, @lib.size_of(self.value))
  }
  size
}

///|
pub impl Default for Any with fn default() -> Any {
  Any::{ type_url: String::default(), value: Bytes::default() }
}

///|
pub fn Any::new(type_url : String, value : Bytes) -> Any {
  Any::{ type_url, value }
}

///|
pub impl @lib.Read for Any with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.Reader],
) -> Any raise {
  let msg = Any::default()
  while (reader |> @lib.read_next_message_field()) is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, _) => msg.type_url = reader |> @lib.read_string()
      (2, _) => msg.value = reader |> @lib.read_bytes()
      _ => reader |> @lib.skip_message_field(wire)
    }
  }
  msg
}

///|
pub impl @lib.Write for Any with fn write(self : Any, writer : &@lib.Writer) -> Unit raise {
  if self.type_url != Default::default() {
    writer |> @lib.write_varint(10UL)
    writer |> @lib.write_string(self.type_url)
  }
  if self.value != Default::default() {
    writer |> @lib.write_varint(18UL)
    writer |> @lib.write_bytes(self.value)
  }
}

///|
pub impl ToJson for Any with fn to_json(self) {
  let json : Map[String, Json] = {}
  if self.type_url != Default::default() {
    json["typeUrl"] = self.type_url.to_json()
  }
  if self.value != Default::default() {
    json["value"] = @lib.base64_encode(self.value).to_json()
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for Any with fn from_json(
  json : Json,
  path : @json.JsonPath,
) -> Any raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError((path, "Expected an object for Any"))
  }
  let message = Any::default()
  for key, value in obj {
    match (key, value) {
      ("typeUrl", value) => message.type_url = @json.from_json(value, path~)
      ("value", String(value)) =>
        message.value = @lib.base64_decode(value) catch {
          _ => raise @json.JsonDecodeError((path, "Invalid base64 encoding"))
        }
      (key, _) => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @lib.AsyncRead for Any with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.AsyncReader],
) -> Any raise {
  let msg = Any::default()
  while (reader |> @lib.async_read_next_message_field())
        is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, _) => msg.type_url = reader |> @lib.async_read_string()
      (2, _) => msg.value = reader |> @lib.async_read_bytes()
      _ => reader |> @lib.async_skip_message_field(wire)
    }
  }
  msg
}

///|
pub impl @lib.AsyncWrite for Any with fn write(
  self : Any,
  writer : &@lib.AsyncWriter,
) -> Unit raise {
  if self.type_url != Default::default() {
    writer |> @lib.async_write_varint(10UL)
    writer |> @lib.async_write_string(self.type_url)
  }
  if self.value != Default::default() {
    writer |> @lib.async_write_varint(18UL)
    writer |> @lib.async_write_bytes(self.value)
  }
}
