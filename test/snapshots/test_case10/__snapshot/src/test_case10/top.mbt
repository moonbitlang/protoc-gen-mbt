pub(all) struct Test {
  mut test_hello :  @lib1.Hello 
} derive(Eq, Show)
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
pub impl @lib.Read for Test with read(reader : &@lib.Reader) {
  let msg =   Test::default()

  while not(reader |> @lib.is_eof()) {
    match (reader |> @lib.read_tag()) {
      (1, _) => msg.test_hello = ((reader |> @lib.read_message()) : @lib1.Hello)
     (_, wire) => reader |> @lib.read_unknown(wire)
    }
  }
  msg
}
pub impl @lib.Write for Test with write(self, writer) {
  writer |> @lib.write_varint(10UL);writer |> @lib.write_uint32(@lib.size_of(self.test_hello)); @lib.Write::write(self.test_hello, writer)
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
