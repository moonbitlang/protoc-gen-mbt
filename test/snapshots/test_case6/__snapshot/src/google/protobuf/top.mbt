pub(all) struct Timestamp {
  mut seconds : Int64
  mut nanos : Int
} derive(Eq, Debug)
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
pub fn Timestamp::new(seconds : Int64, nanos : Int) -> Timestamp {
  Timestamp::{
    seconds,
    nanos,
  }
}
pub impl @lib.Read for Timestamp with read_with_limit(reader : @lib.LimitedReader[&@lib.Reader]) -> Timestamp raise {
  let msg = Timestamp::default()
  try {
    for ;; {
      match (reader |> @lib.read_tag()) {
      (1, _) => msg.seconds = reader |> @lib.read_int64()
      (2, _) => msg.nanos = reader |> @lib.read_int32()
       (_, wire) => reader |> @lib.read_unknown(wire)
      }
    }
  } catch {
    @lib.EndOfStream => ()
    err => raise err
  }
  msg
}
pub impl @lib.Write for Timestamp with write(self: Timestamp, writer : &@lib.Writer) -> Unit raise {
  writer |> @lib.write_varint(8UL);
  writer |> @lib.write_int64(self.seconds)
  writer |> @lib.write_varint(16UL);
  writer |> @lib.write_int32(self.nanos)
}
pub impl ToJson for Timestamp with to_json(self) {
  let json: Map[String, Json] = {}
  if self.seconds != Default::default() {
  json["seconds"] = self.seconds.to_json()
  }
  if self.nanos != Default::default() {
  json["nanos"] = self.nanos.to_json()
  }
  Json::object(json)
}
pub impl @json.FromJson for Timestamp with from_json(json: Json, path: @json.JsonPath) -> Timestamp raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError((path, "Expected an object for Timestamp"))
  }
  let message = Timestamp::default()
  for key, value in obj {
    match (key, value) {
      ("seconds", value) => message.seconds = @json.from_json(value, path~)
      ("nanos", value) => message.nanos = @json.from_json(value, path~)
      key => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}
pub impl @lib.AsyncRead for Timestamp with read_with_limit(reader : @lib.LimitedReader[&@lib.AsyncReader]) -> Timestamp raise {
  let msg = Timestamp::default()
  try {
    for ;; {
      match (reader |> @lib.async_read_tag()) {
      (1, _) => msg.seconds = reader |> @lib.async_read_int64()
      (2, _) => msg.nanos = reader |> @lib.async_read_int32()
       (_, wire) => reader |> @lib.async_read_unknown(wire)
      }
    }
  } catch {
    @lib.EndOfStream => ()
    err => raise err
  }
  msg
}
pub impl @lib.AsyncWrite for Timestamp with write(self: Timestamp, writer : &@lib.AsyncWriter) -> Unit raise {
  writer |> @lib.async_write_varint(8UL);
  writer |> @lib.async_write_int64(self.seconds)
  writer |> @lib.async_write_varint(16UL);
  writer |> @lib.async_write_int32(self.nanos)
}
