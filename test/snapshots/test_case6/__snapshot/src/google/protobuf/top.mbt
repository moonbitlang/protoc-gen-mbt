pub(all) struct Timestamp {
  mut seconds : Int64
  mut nanos : Int
} derive(Eq, Debug)
pub impl @pb.Sized for Timestamp with size_of(self) {
  let mut size = 0U
  size += 1U + @pb.size_of(self.seconds)
  size += 1U + @pb.size_of(self.nanos)
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
pub impl @pb.Read for Timestamp with read_with_limit(reader : @pb.LimitedReader[&@pb.Reader]) -> Timestamp raise {
  let msg = Timestamp::default()
  try {
    for ;; {
      match (reader |> @pb.read_tag()) {
      (1, _) => msg.seconds = reader |> @pb.read_int64()
      (2, _) => msg.nanos = reader |> @pb.read_int32()
       (_, wire) => reader |> @pb.read_unknown(wire)
      }
    }
  } catch {
    @pb.EndOfStream => ()
    err => raise err
  }
  msg
}
pub impl @pb.Write for Timestamp with write(self: Timestamp, writer : &@pb.Writer) -> Unit raise {
  writer |> @pb.write_varint(8UL);
  writer |> @pb.write_int64(self.seconds)
  writer |> @pb.write_varint(16UL);
  writer |> @pb.write_int32(self.nanos)
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
pub impl @pb.AsyncRead for Timestamp with read_with_limit(reader : @pb.LimitedReader[&@pb.AsyncReader]) -> Timestamp raise {
  let msg = Timestamp::default()
  try {
    for ;; {
      match (reader |> @pb.async_read_tag()) {
      (1, _) => msg.seconds = reader |> @pb.async_read_int64()
      (2, _) => msg.nanos = reader |> @pb.async_read_int32()
       (_, wire) => reader |> @pb.async_read_unknown(wire)
      }
    }
  } catch {
    @pb.EndOfStream => ()
    err => raise err
  }
  msg
}
pub impl @pb.AsyncWrite for Timestamp with write(self: Timestamp, writer : &@pb.AsyncWriter) -> Unit raise {
  writer |> @pb.async_write_varint(8UL);
  writer |> @pb.async_write_int64(self.seconds)
  writer |> @pb.async_write_varint(16UL);
  writer |> @pb.async_write_int32(self.nanos)
}
