pub(all) struct HelloRequest {
  mut name : String
} derive(Eq, Show)
pub impl @protobuf.Sized for HelloRequest with size_of(self) {
  let mut size = 0U
  size += 1U + { let size = @protobuf.size_of(self.name); @protobuf.size_of(size) + size }
  size
}
pub impl Default for HelloRequest with default() -> HelloRequest {
  HelloRequest::{
    name : String::default(),
  }
}
pub fn HelloRequest::new(name : String) -> HelloRequest {
  HelloRequest::{
    name,
  }
}
pub impl @protobuf.Read for HelloRequest with read_with_limit(reader : @protobuf.LimitedReader[&@protobuf.Reader]) -> HelloRequest raise {
  let msg = HelloRequest::default()
  try {
    for {
      match (reader |> @protobuf.read_tag()) {
      (1, _) => msg.name = reader |> @protobuf.read_string()
       (_, wire) => reader |> @protobuf.read_unknown(wire)
      }
    }
  } catch {
    @protobuf.EndOfStream => ()
    err => raise err
  }
  msg
}
pub impl @protobuf.Write for HelloRequest with write(self: HelloRequest, writer : &@protobuf.Writer) -> Unit raise {
  writer |> @protobuf.write_varint(10UL);
  writer |> @protobuf.write_string(self.name)
}
pub impl ToJson for HelloRequest with to_json(self) {
  let json: Map[String, Json] = {}
  if self.name != Default::default() {
  json["name"] = self.name.to_json()
  }
  Json::object(json)
}
pub impl @json.FromJson for HelloRequest with from_json(json: Json, path: @json.JsonPath) -> HelloRequest raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError((path, "Expected an object for HelloRequest"))
  }
  let message = HelloRequest::default()
  for key, value in obj {
    match (key, value) {
      ("name", value) => message.name = @json.from_json(value, path~)
      key => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}
pub impl @protobuf.AsyncRead for HelloRequest with read_with_limit(reader : @protobuf.LimitedReader[&@protobuf.AsyncReader]) -> HelloRequest raise {
  let msg = HelloRequest::default()
  try {
    for {
      match (reader |> @protobuf.async_read_tag()) {
      (1, _) => msg.name = reader |> @protobuf.async_read_string()
       (_, wire) => reader |> @protobuf.async_read_unknown(wire)
      }
    }
  } catch {
    @protobuf.EndOfStream => ()
    err => raise err
  }
  msg
}
pub impl @protobuf.AsyncWrite for HelloRequest with write(self: HelloRequest, writer : &@protobuf.AsyncWriter) -> Unit raise {
  writer |> @protobuf.async_write_varint(10UL);
  writer |> @protobuf.async_write_string(self.name)
}
pub(all) struct HelloReply {
  mut message : String
} derive(Eq, Show)
pub impl @protobuf.Sized for HelloReply with size_of(self) {
  let mut size = 0U
  size += 1U + { let size = @protobuf.size_of(self.message); @protobuf.size_of(size) + size }
  size
}
pub impl Default for HelloReply with default() -> HelloReply {
  HelloReply::{
    message : String::default(),
  }
}
pub fn HelloReply::new(message : String) -> HelloReply {
  HelloReply::{
    message,
  }
}
pub impl @protobuf.Read for HelloReply with read_with_limit(reader : @protobuf.LimitedReader[&@protobuf.Reader]) -> HelloReply raise {
  let msg = HelloReply::default()
  try {
    for {
      match (reader |> @protobuf.read_tag()) {
      (1, _) => msg.message = reader |> @protobuf.read_string()
       (_, wire) => reader |> @protobuf.read_unknown(wire)
      }
    }
  } catch {
    @protobuf.EndOfStream => ()
    err => raise err
  }
  msg
}
pub impl @protobuf.Write for HelloReply with write(self: HelloReply, writer : &@protobuf.Writer) -> Unit raise {
  writer |> @protobuf.write_varint(10UL);
  writer |> @protobuf.write_string(self.message)
}
pub impl ToJson for HelloReply with to_json(self) {
  let json: Map[String, Json] = {}
  if self.message != Default::default() {
  json["message"] = self.message.to_json()
  }
  Json::object(json)
}
pub impl @json.FromJson for HelloReply with from_json(json: Json, path: @json.JsonPath) -> HelloReply raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError((path, "Expected an object for HelloReply"))
  }
  let message = HelloReply::default()
  for key, value in obj {
    match (key, value) {
      ("message", value) => message.message = @json.from_json(value, path~)
      key => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}
pub impl @protobuf.AsyncRead for HelloReply with read_with_limit(reader : @protobuf.LimitedReader[&@protobuf.AsyncReader]) -> HelloReply raise {
  let msg = HelloReply::default()
  try {
    for {
      match (reader |> @protobuf.async_read_tag()) {
      (1, _) => msg.message = reader |> @protobuf.async_read_string()
       (_, wire) => reader |> @protobuf.async_read_unknown(wire)
      }
    }
  } catch {
    @protobuf.EndOfStream => ()
    err => raise err
  }
  msg
}
pub impl @protobuf.AsyncWrite for HelloReply with write(self: HelloReply, writer : &@protobuf.AsyncWriter) -> Unit raise {
  writer |> @protobuf.async_write_varint(10UL);
  writer |> @protobuf.async_write_string(self.message)
}
pub(open) trait GreeterService {
  say_hello(Self, HelloRequest) -> HelloReply raise
  // stream_hello is a server streaming method and is not included in the trait
}
pub let greeter_service_descriptor : @protobuf.ServiceDescriptor = {
  name: "Greeter",
  full_name: "greet.Greeter",
  methods: [
    {
      name: "SayHello",
      full_name: "/greet.Greeter/SayHello",
      client_streaming: false,
      server_streaming: false,
    },
    {
      name: "StreamHello",
      full_name: "/greet.Greeter/StreamHello",
      client_streaming: false,
      server_streaming: true,
    },
  ],
}
pub(open) trait EmptyService {
}
pub let empty_service_descriptor : @protobuf.ServiceDescriptor = {
  name: "Empty",
  full_name: "greet.Empty",
  methods: [
  ],
}
