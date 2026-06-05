///|
pub(all) struct FieldMask {
  mut paths : Array[String]
} derive(Eq, Debug)

///|
pub impl @lib.Sized for FieldMask with fn size_of(self) {
  let mut size = 0U
  for s in self.paths {
    size += 1U +
      ({
        let size = @lib.size_of(s)
        @lib.size_of(size) + size
      })
  }
  size
}

///|
pub impl Default for FieldMask with fn default() -> FieldMask {
  FieldMask::{ paths: [] }
}

///|
pub fn FieldMask::new(paths : Array[String]) -> FieldMask {
  FieldMask::{ paths, }
}

///|
pub impl @lib.Read for FieldMask with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.Reader],
) -> FieldMask raise {
  let msg = FieldMask::default()
  for ;; {
    match (reader |> @lib.read_next_message_field()) {
      Some((field_number, wire)) =>
        match (field_number, wire) {
          (1, _) => msg.paths.push(reader |> @lib.read_string())
          _ => reader |> @lib.skip_message_field(wire)
        }
      None => break
    }
  }
  msg
}

///|
pub impl @lib.Write for FieldMask with fn write(
  self : FieldMask,
  writer : &@lib.Writer,
) -> Unit raise {
  for item in self.paths {
    writer |> @lib.write_varint(10UL)
    writer |> @lib.write_string(item)
  }
}

///|
pub impl ToJson for FieldMask with fn to_json(self) {
  let json : Map[String, Json] = {}
  if self.paths != Default::default() {
    json["paths"] = self.paths.to_json()
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for FieldMask with fn from_json(
  json : Json,
  path : @json.JsonPath,
) -> FieldMask raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError((path, "Expected an object for FieldMask"))
  }
  let message = FieldMask::default()
  for key, value in obj {
    match (key, value) {
      ("paths", Array(value)) =>
        message.paths = value.map(v => @json.from_json(v, path~))
      (key, _) => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @lib.AsyncRead for FieldMask with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.AsyncReader],
) -> FieldMask raise {
  let msg = FieldMask::default()
  for ;; {
    match (reader |> @lib.async_read_next_message_field()) {
      Some((field_number, wire)) =>
        match (field_number, wire) {
          (1, _) => msg.paths.push(reader |> @lib.async_read_string())
          _ => reader |> @lib.async_skip_message_field(wire)
        }
      None => break
    }
  }
  msg
}

///|
pub impl @lib.AsyncWrite for FieldMask with fn write(
  self : FieldMask,
  writer : &@lib.AsyncWriter,
) -> Unit raise {
  for item in self.paths {
    writer |> @lib.async_write_varint(10UL)
    writer |> @lib.async_write_string(item)
  }
}
