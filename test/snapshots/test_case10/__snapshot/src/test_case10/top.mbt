pub(all) struct Test {
  mut test_hello : @lib1.Hello?
} derive(Eq, Debug)
pub impl @lib.Sized for Test with fn size_of(self) {
  let mut size = 0U
  if self.test_hello is Some(v) {
    size += @lib.size_of_length_delimited_field(1U, @lib.size_of(v))
  }
  size
}
pub impl Default for Test with fn default() -> Test {
  Test::{
    test_hello : None,
  }
}
pub fn Test::new(test_hello? : @lib1.Hello) -> Test {
  Test::{
    test_hello,
  }
}
pub impl @lib.Read for Test with fn read_with_limit(reader : @lib.LimitedReader[&@lib.Reader]) -> Test raise {
  let msg = Test::default()
  while (reader |> @lib.read_next_message_field()) is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, _) => msg.test_hello = (reader |> @lib.read_message() : @lib1.Hello) |> Some
      _ => reader |> @lib.skip_message_field(wire)
    }
  }
  msg
}
pub impl @lib.Write for Test with fn write(self: Test, writer : &@lib.Writer) -> Unit raise {
  if self.test_hello is Some(v) {
    writer |> @lib.write_varint(10UL);
    writer |> @lib.write_message(v)

  }
}
pub impl ToJson for Test with fn to_json(self) {
  let json: Map[String, Json] = {}
  match self.test_hello {
      Some(v) => json["testHello"] = v.to_json()
      _ => ()
    }
  Json::object(json)
}
pub impl @json.FromJson for Test with fn from_json(json: Json, path: @json.JsonPath) -> Test raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError((path, "Expected an object for Test"))
  }
  let message = Test::default()
  for key, value in obj {
    match (key, value) {
      ("testHello", value) => message.test_hello = Some(@json.from_json(value, path~))
      (key, _) => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}
pub impl @lib.AsyncRead for Test with fn read_with_limit(reader : @lib.LimitedReader[&@lib.AsyncReader]) -> Test raise {
  let msg = Test::default()
  while (reader |> @lib.async_read_next_message_field()) is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, _) => msg.test_hello = (reader |> @lib.async_read_message() : @lib1.Hello) |> Some
      _ => reader |> @lib.async_skip_message_field(wire)
    }
  }
  msg
}
pub impl @lib.AsyncWrite for Test with fn write(self: Test, writer : &@lib.AsyncWriter) -> Unit raise {
  if self.test_hello is Some(v) {
    writer |> @lib.async_write_varint(10UL);
    writer |> @lib.async_write_message(v)

  }
}
