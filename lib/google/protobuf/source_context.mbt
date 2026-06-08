///|
pub(all) struct SourceContext {
  mut file_name : String
} derive(Eq, Debug)

///|
pub impl @lib.Sized for SourceContext with fn size_of(self) {
  let mut size = 0U
  if self.file_name != Default::default() {
    size += @lib.size_of_length_delimited_field(
      1U,
      @lib.size_of(self.file_name),
    )
  }
  size
}

///|
pub impl Default for SourceContext with fn default() -> SourceContext {
  SourceContext::{ file_name: String::default() }
}

///|
pub fn SourceContext::new(file_name : String) -> SourceContext {
  SourceContext::{ file_name, }
}

///|
pub impl @lib.Read for SourceContext with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.Reader],
) -> SourceContext raise {
  let msg = SourceContext::default()
  while (reader |> @lib.read_next_message_field()) is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, _) => msg.file_name = reader |> @lib.read_string()
      _ => reader |> @lib.skip_message_field(wire)
    }
  }
  msg
}

///|
pub impl @lib.Write for SourceContext with fn write(
  self : SourceContext,
  writer : &@lib.Writer,
) -> Unit raise {
  if self.file_name != Default::default() {
    writer |> @lib.write_varint(10UL)
    writer |> @lib.write_string(self.file_name)
  }
}

///|
pub impl ToJson for SourceContext with fn to_json(self) {
  let json : Map[String, Json] = {}
  if self.file_name != Default::default() {
    json["fileName"] = self.file_name.to_json()
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for SourceContext with fn from_json(
  json : Json,
  path : @json.JsonPath,
) -> SourceContext raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError((path, "Expected an object for SourceContext"))
  }
  let message = SourceContext::default()
  for key, value in obj {
    match (key, value) {
      ("fileName", value) => message.file_name = @json.from_json(value, path~)
      (key, _) => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @lib.AsyncRead for SourceContext with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.AsyncReader],
) -> SourceContext raise {
  let msg = SourceContext::default()
  while (reader |> @lib.async_read_next_message_field())
        is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, _) => msg.file_name = reader |> @lib.async_read_string()
      _ => reader |> @lib.async_skip_message_field(wire)
    }
  }
  msg
}

///|
pub impl @lib.AsyncWrite for SourceContext with fn write(
  self : SourceContext,
  writer : &@lib.AsyncWriter,
) -> Unit raise {
  if self.file_name != Default::default() {
    writer |> @lib.async_write_varint(10UL)
    writer |> @lib.async_write_string(self.file_name)
  }
}
