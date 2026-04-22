pub(all) struct Test {
  mut test_hello : @lib1.Hello 
} derive(Eq, Debug)
pub impl @lib.Sized for Test with size_of(self) {
  let mut size = 0U
  size += 1U + { let size = @lib.size_of(self.test_hello); @lib.size_of(size) + size }
  size
}
pub impl Default for Test with default() -> Test {
  Test::{
    test_hello : @lib1.Hello::default(),
  }
}
pub fn Test::new(test_hello : @lib1.Hello) -> Test {
  Test::{
    test_hello,
  }
}
pub impl @lib.Read for Test with read_with_limit(reader : @lib.LimitedReader[&@lib.Reader]) -> Test raise {
  let msg = Test::default()
  try {
    for ;; {
      match (reader |> @lib.read_tag()) {
      (1, _) => msg.test_hello = (reader |> @lib.read_message() : @lib1.Hello)
       (_, wire) => reader |> @lib.read_unknown(wire)
      }
    }
  } catch {
    @lib.EndOfStream => ()
    err => raise err
  }
  msg
}
pub impl @lib.Write for Test with write(self: Test, writer : &@lib.Writer) -> Unit raise {
  writer |> @lib.write_varint(10UL);
  writer |> @lib.write_uint32(@lib.size_of(self.test_hello)); @lib.Write::write(self.test_hello, writer)
}
pub impl ToJson for Test with to_json(self) {
  let json: Map[String, Json] = {}
  if self.test_hello != Default::default() {
  json["testHello"] = self.test_hello.to_json()
  }
  Json::object(json)
}
pub impl @json.FromJson for Test with from_json(json: Json, path: @json.JsonPath) -> Test raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError((path, "Expected an object for Test"))
  }
  let message = Test::default()
  for key, value in obj {
    match (key, value) {
      ("testHello", value) => message.test_hello = @json.from_json(value, path~)
      key => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}
pub impl @lib.AsyncRead for Test with read_with_limit(reader : @lib.LimitedReader[&@lib.AsyncReader]) -> Test raise {
  let msg = Test::default()
  try {
    for ;; {
      match (reader |> @lib.async_read_tag()) {
      (1, _) => msg.test_hello = (reader |> @lib.async_read_message() : @lib1.Hello)
       (_, wire) => reader |> @lib.async_read_unknown(wire)
      }
    }
  } catch {
    @lib.EndOfStream => ()
    err => raise err
  }
  msg
}
pub impl @lib.AsyncWrite for Test with write(self: Test, writer : &@lib.AsyncWriter) -> Unit raise {
  writer |> @lib.async_write_varint(10UL);
  writer |> @lib.async_write_uint32(@lib.size_of(self.test_hello)); @lib.AsyncWrite::write(self.test_hello, writer)
}
