///|
pub(all) struct Api {
  mut name : String
  mut methods : Array[Method]
  mut options : Array[Option]
  mut version : String
  mut source_context : SourceContext?
  mut mixins : Array[Mixin]
  mut syntax : Syntax
  mut edition : String
} derive(Eq, Debug)

///|
pub impl @lib.Sized for Api with fn size_of(self) {
  let mut size = 0U
  if self.name != Default::default() {
    size += 1U +
      ({
        let size = @lib.size_of(self.name)
        @lib.size_of(size) + size
      })
  }
  for s in self.methods {
    size += 1U +
      ({
        let size = @lib.size_of(s)
        @lib.size_of(size) + size
      })
  }
  for s in self.options {
    size += 1U +
      ({
        let size = @lib.size_of(s)
        @lib.size_of(size) + size
      })
  }
  if self.version != Default::default() {
    size += 1U +
      ({
        let size = @lib.size_of(self.version)
        @lib.size_of(size) + size
      })
  }
  if self.source_context is Some(v) {
    size += 1U +
      ({
        let size = @lib.size_of(v)
        @lib.size_of(size) + size
      })
  }
  for s in self.mixins {
    size += 1U +
      ({
        let size = @lib.size_of(s)
        @lib.size_of(size) + size
      })
  }
  if self.syntax != Default::default() {
    size += 1U + @lib.size_of(self.syntax)
  }
  if self.edition != Default::default() {
    size += 1U +
      ({
        let size = @lib.size_of(self.edition)
        @lib.size_of(size) + size
      })
  }
  size
}

///|
pub impl Default for Api with fn default() -> Api {
  Api::{
    name: String::default(),
    methods: [],
    options: [],
    version: String::default(),
    source_context: None,
    mixins: [],
    syntax: Syntax::default(),
    edition: String::default(),
  }
}

///|
pub fn Api::new(
  name : String,
  methods : Array[Method],
  options : Array[Option],
  version : String,
  source_context? : SourceContext,
  mixins : Array[Mixin],
  syntax : Syntax,
  edition : String,
) -> Api {
  Api::{
    name,
    methods,
    options,
    version,
    source_context,
    mixins,
    syntax,
    edition,
  }
}

///|
pub impl @lib.Read for Api with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.Reader],
) -> Api raise {
  let msg = Api::default()
  while (reader |> @lib.read_next_message_field()) is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, _) => msg.name = reader |> @lib.read_string()
      (2, _) => msg.methods.push((reader |> @lib.read_message() : Method))
      (3, _) => msg.options.push((reader |> @lib.read_message() : Option))
      (4, _) => msg.version = reader |> @lib.read_string()
      (5, _) =>
        msg.source_context = (reader |> @lib.read_message() : SourceContext)
          |> Some
      (6, _) => msg.mixins.push((reader |> @lib.read_message() : Mixin))
      (7, _) => msg.syntax = reader |> @lib.read_enum() |> Syntax::from_enum
      (8, _) => msg.edition = reader |> @lib.read_string()
      _ => reader |> @lib.skip_message_field(wire)
    }
  }
  msg
}

///|
pub impl @lib.Write for Api with fn write(self : Api, writer : &@lib.Writer) -> Unit raise {
  if self.name != Default::default() {
    writer |> @lib.write_varint(10UL)
    writer |> @lib.write_string(self.name)
  }
  for item in self.methods {
    writer |> @lib.write_varint(18UL)
    writer |> @lib.write_message(item)
  }
  for item in self.options {
    writer |> @lib.write_varint(26UL)
    writer |> @lib.write_message(item)
  }
  if self.version != Default::default() {
    writer |> @lib.write_varint(34UL)
    writer |> @lib.write_string(self.version)
  }
  if self.source_context is Some(v) {
    writer |> @lib.write_varint(42UL)
    writer |> @lib.write_message(v)
  }
  for item in self.mixins {
    writer |> @lib.write_varint(50UL)
    writer |> @lib.write_message(item)
  }
  if self.syntax != Default::default() {
    writer |> @lib.write_varint(56UL)
    writer |> @lib.write_enum(self.syntax.to_enum())
  }
  if self.edition != Default::default() {
    writer |> @lib.write_varint(66UL)
    writer |> @lib.write_string(self.edition)
  }
}

///|
pub impl ToJson for Api with fn to_json(self) {
  let json : Map[String, Json] = {}
  if self.name != Default::default() {
    json["name"] = self.name.to_json()
  }
  if self.methods != Default::default() {
    json["methods"] = self.methods.to_json()
  }
  if self.options != Default::default() {
    json["options"] = self.options.to_json()
  }
  if self.version != Default::default() {
    json["version"] = self.version.to_json()
  }
  match self.source_context {
    Some(v) => json["sourceContext"] = v.to_json()
    _ => ()
  }
  if self.mixins != Default::default() {
    json["mixins"] = self.mixins.to_json()
  }
  if self.syntax != Default::default() {
    json["syntax"] = self.syntax.to_json()
  }
  if self.edition != Default::default() {
    json["edition"] = self.edition.to_json()
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for Api with fn from_json(
  json : Json,
  path : @json.JsonPath,
) -> Api raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError((path, "Expected an object for Api"))
  }
  let message = Api::default()
  for key, value in obj {
    match (key, value) {
      ("name", value) => message.name = @json.from_json(value, path~)
      ("methods", Array(value)) =>
        message.methods = value.map(v => @json.from_json(v, path~))
      ("options", Array(value)) =>
        message.options = value.map(v => @json.from_json(v, path~))
      ("version", value) => message.version = @json.from_json(value, path~)
      ("sourceContext", value) =>
        message.source_context = Some(@json.from_json(value, path~))
      ("mixins", Array(value)) =>
        message.mixins = value.map(v => @json.from_json(v, path~))
      ("syntax", value) => message.syntax = @json.from_json(value, path~)
      ("edition", value) => message.edition = @json.from_json(value, path~)
      (key, _) => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @lib.AsyncRead for Api with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.AsyncReader],
) -> Api raise {
  let msg = Api::default()
  while (reader |> @lib.async_read_next_message_field())
        is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, _) => msg.name = reader |> @lib.async_read_string()
      (2, _) => msg.methods.push((reader |> @lib.async_read_message() : Method))
      (3, _) => msg.options.push((reader |> @lib.async_read_message() : Option))
      (4, _) => msg.version = reader |> @lib.async_read_string()
      (5, _) =>
        msg.source_context = (
            reader |> @lib.async_read_message() : SourceContext)
          |> Some
      (6, _) => msg.mixins.push((reader |> @lib.async_read_message() : Mixin))
      (7, _) =>
        msg.syntax = reader |> @lib.async_read_enum() |> Syntax::from_enum
      (8, _) => msg.edition = reader |> @lib.async_read_string()
      _ => reader |> @lib.async_skip_message_field(wire)
    }
  }
  msg
}

///|
pub impl @lib.AsyncWrite for Api with fn write(
  self : Api,
  writer : &@lib.AsyncWriter,
) -> Unit raise {
  if self.name != Default::default() {
    writer |> @lib.async_write_varint(10UL)
    writer |> @lib.async_write_string(self.name)
  }
  for item in self.methods {
    writer |> @lib.async_write_varint(18UL)
    writer |> @lib.async_write_message(item)
  }
  for item in self.options {
    writer |> @lib.async_write_varint(26UL)
    writer |> @lib.async_write_message(item)
  }
  if self.version != Default::default() {
    writer |> @lib.async_write_varint(34UL)
    writer |> @lib.async_write_string(self.version)
  }
  if self.source_context is Some(v) {
    writer |> @lib.async_write_varint(42UL)
    writer |> @lib.async_write_message(v)
  }
  for item in self.mixins {
    writer |> @lib.async_write_varint(50UL)
    writer |> @lib.async_write_message(item)
  }
  if self.syntax != Default::default() {
    writer |> @lib.async_write_varint(56UL)
    writer |> @lib.async_write_enum(self.syntax.to_enum())
  }
  if self.edition != Default::default() {
    writer |> @lib.async_write_varint(66UL)
    writer |> @lib.async_write_string(self.edition)
  }
}

///|
pub(all) struct Method {
  mut name : String
  mut request_type_url : String
  mut request_streaming : Bool
  mut response_type_url : String
  mut response_streaming : Bool
  mut options : Array[Option]
  mut syntax : Syntax
  mut edition : String
} derive(Eq, Debug)

///|
pub impl @lib.Sized for Method with fn size_of(self) {
  let mut size = 0U
  if self.name != Default::default() {
    size += 1U +
      ({
        let size = @lib.size_of(self.name)
        @lib.size_of(size) + size
      })
  }
  if self.request_type_url != Default::default() {
    size += 1U +
      ({
        let size = @lib.size_of(self.request_type_url)
        @lib.size_of(size) + size
      })
  }
  if self.request_streaming != Default::default() {
    size += 1U + @lib.size_of(self.request_streaming)
  }
  if self.response_type_url != Default::default() {
    size += 1U +
      ({
        let size = @lib.size_of(self.response_type_url)
        @lib.size_of(size) + size
      })
  }
  if self.response_streaming != Default::default() {
    size += 1U + @lib.size_of(self.response_streaming)
  }
  for s in self.options {
    size += 1U +
      ({
        let size = @lib.size_of(s)
        @lib.size_of(size) + size
      })
  }
  if self.syntax != Default::default() {
    size += 1U + @lib.size_of(self.syntax)
  }
  if self.edition != Default::default() {
    size += 1U +
      ({
        let size = @lib.size_of(self.edition)
        @lib.size_of(size) + size
      })
  }
  size
}

///|
pub impl Default for Method with fn default() -> Method {
  Method::{
    name: String::default(),
    request_type_url: String::default(),
    request_streaming: Bool::default(),
    response_type_url: String::default(),
    response_streaming: Bool::default(),
    options: [],
    syntax: Syntax::default(),
    edition: String::default(),
  }
}

///|
pub fn Method::new(
  name : String,
  request_type_url : String,
  request_streaming : Bool,
  response_type_url : String,
  response_streaming : Bool,
  options : Array[Option],
  syntax : Syntax,
  edition : String,
) -> Method {
  Method::{
    name,
    request_type_url,
    request_streaming,
    response_type_url,
    response_streaming,
    options,
    syntax,
    edition,
  }
}

///|
pub impl @lib.Read for Method with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.Reader],
) -> Method raise {
  let msg = Method::default()
  while (reader |> @lib.read_next_message_field()) is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, _) => msg.name = reader |> @lib.read_string()
      (2, _) => msg.request_type_url = reader |> @lib.read_string()
      (3, _) => msg.request_streaming = reader |> @lib.read_bool()
      (4, _) => msg.response_type_url = reader |> @lib.read_string()
      (5, _) => msg.response_streaming = reader |> @lib.read_bool()
      (6, _) => msg.options.push((reader |> @lib.read_message() : Option))
      (7, _) => msg.syntax = reader |> @lib.read_enum() |> Syntax::from_enum
      (8, _) => msg.edition = reader |> @lib.read_string()
      _ => reader |> @lib.skip_message_field(wire)
    }
  }
  msg
}

///|
pub impl @lib.Write for Method with fn write(
  self : Method,
  writer : &@lib.Writer,
) -> Unit raise {
  if self.name != Default::default() {
    writer |> @lib.write_varint(10UL)
    writer |> @lib.write_string(self.name)
  }
  if self.request_type_url != Default::default() {
    writer |> @lib.write_varint(18UL)
    writer |> @lib.write_string(self.request_type_url)
  }
  if self.request_streaming != Default::default() {
    writer |> @lib.write_varint(24UL)
    writer |> @lib.write_bool(self.request_streaming)
  }
  if self.response_type_url != Default::default() {
    writer |> @lib.write_varint(34UL)
    writer |> @lib.write_string(self.response_type_url)
  }
  if self.response_streaming != Default::default() {
    writer |> @lib.write_varint(40UL)
    writer |> @lib.write_bool(self.response_streaming)
  }
  for item in self.options {
    writer |> @lib.write_varint(50UL)
    writer |> @lib.write_message(item)
  }
  if self.syntax != Default::default() {
    writer |> @lib.write_varint(56UL)
    writer |> @lib.write_enum(self.syntax.to_enum())
  }
  if self.edition != Default::default() {
    writer |> @lib.write_varint(66UL)
    writer |> @lib.write_string(self.edition)
  }
}

///|
pub impl ToJson for Method with fn to_json(self) {
  let json : Map[String, Json] = {}
  if self.name != Default::default() {
    json["name"] = self.name.to_json()
  }
  if self.request_type_url != Default::default() {
    json["requestTypeUrl"] = self.request_type_url.to_json()
  }
  if self.request_streaming != Default::default() {
    json["requestStreaming"] = self.request_streaming.to_json()
  }
  if self.response_type_url != Default::default() {
    json["responseTypeUrl"] = self.response_type_url.to_json()
  }
  if self.response_streaming != Default::default() {
    json["responseStreaming"] = self.response_streaming.to_json()
  }
  if self.options != Default::default() {
    json["options"] = self.options.to_json()
  }
  if self.syntax != Default::default() {
    json["syntax"] = self.syntax.to_json()
  }
  if self.edition != Default::default() {
    json["edition"] = self.edition.to_json()
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for Method with fn from_json(
  json : Json,
  path : @json.JsonPath,
) -> Method raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError((path, "Expected an object for Method"))
  }
  let message = Method::default()
  for key, value in obj {
    match (key, value) {
      ("name", value) => message.name = @json.from_json(value, path~)
      ("requestTypeUrl", value) =>
        message.request_type_url = @json.from_json(value, path~)
      ("requestStreaming", value) =>
        message.request_streaming = @json.from_json(value, path~)
      ("responseTypeUrl", value) =>
        message.response_type_url = @json.from_json(value, path~)
      ("responseStreaming", value) =>
        message.response_streaming = @json.from_json(value, path~)
      ("options", Array(value)) =>
        message.options = value.map(v => @json.from_json(v, path~))
      ("syntax", value) => message.syntax = @json.from_json(value, path~)
      ("edition", value) => message.edition = @json.from_json(value, path~)
      (key, _) => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @lib.AsyncRead for Method with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.AsyncReader],
) -> Method raise {
  let msg = Method::default()
  while (reader |> @lib.async_read_next_message_field())
        is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, _) => msg.name = reader |> @lib.async_read_string()
      (2, _) => msg.request_type_url = reader |> @lib.async_read_string()
      (3, _) => msg.request_streaming = reader |> @lib.async_read_bool()
      (4, _) => msg.response_type_url = reader |> @lib.async_read_string()
      (5, _) => msg.response_streaming = reader |> @lib.async_read_bool()
      (6, _) => msg.options.push((reader |> @lib.async_read_message() : Option))
      (7, _) =>
        msg.syntax = reader |> @lib.async_read_enum() |> Syntax::from_enum
      (8, _) => msg.edition = reader |> @lib.async_read_string()
      _ => reader |> @lib.async_skip_message_field(wire)
    }
  }
  msg
}

///|
pub impl @lib.AsyncWrite for Method with fn write(
  self : Method,
  writer : &@lib.AsyncWriter,
) -> Unit raise {
  if self.name != Default::default() {
    writer |> @lib.async_write_varint(10UL)
    writer |> @lib.async_write_string(self.name)
  }
  if self.request_type_url != Default::default() {
    writer |> @lib.async_write_varint(18UL)
    writer |> @lib.async_write_string(self.request_type_url)
  }
  if self.request_streaming != Default::default() {
    writer |> @lib.async_write_varint(24UL)
    writer |> @lib.async_write_bool(self.request_streaming)
  }
  if self.response_type_url != Default::default() {
    writer |> @lib.async_write_varint(34UL)
    writer |> @lib.async_write_string(self.response_type_url)
  }
  if self.response_streaming != Default::default() {
    writer |> @lib.async_write_varint(40UL)
    writer |> @lib.async_write_bool(self.response_streaming)
  }
  for item in self.options {
    writer |> @lib.async_write_varint(50UL)
    writer |> @lib.async_write_message(item)
  }
  if self.syntax != Default::default() {
    writer |> @lib.async_write_varint(56UL)
    writer |> @lib.async_write_enum(self.syntax.to_enum())
  }
  if self.edition != Default::default() {
    writer |> @lib.async_write_varint(66UL)
    writer |> @lib.async_write_string(self.edition)
  }
}

///|
pub(all) struct Mixin {
  mut name : String
  mut root : String
} derive(Eq, Debug)

///|
pub impl @lib.Sized for Mixin with fn size_of(self) {
  let mut size = 0U
  if self.name != Default::default() {
    size += 1U +
      ({
        let size = @lib.size_of(self.name)
        @lib.size_of(size) + size
      })
  }
  if self.root != Default::default() {
    size += 1U +
      ({
        let size = @lib.size_of(self.root)
        @lib.size_of(size) + size
      })
  }
  size
}

///|
pub impl Default for Mixin with fn default() -> Mixin {
  Mixin::{ name: String::default(), root: String::default() }
}

///|
pub fn Mixin::new(name : String, root : String) -> Mixin {
  Mixin::{ name, root }
}

///|
pub impl @lib.Read for Mixin with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.Reader],
) -> Mixin raise {
  let msg = Mixin::default()
  while (reader |> @lib.read_next_message_field()) is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, _) => msg.name = reader |> @lib.read_string()
      (2, _) => msg.root = reader |> @lib.read_string()
      _ => reader |> @lib.skip_message_field(wire)
    }
  }
  msg
}

///|
pub impl @lib.Write for Mixin with fn write(self : Mixin, writer : &@lib.Writer) -> Unit raise {
  if self.name != Default::default() {
    writer |> @lib.write_varint(10UL)
    writer |> @lib.write_string(self.name)
  }
  if self.root != Default::default() {
    writer |> @lib.write_varint(18UL)
    writer |> @lib.write_string(self.root)
  }
}

///|
pub impl ToJson for Mixin with fn to_json(self) {
  let json : Map[String, Json] = {}
  if self.name != Default::default() {
    json["name"] = self.name.to_json()
  }
  if self.root != Default::default() {
    json["root"] = self.root.to_json()
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for Mixin with fn from_json(
  json : Json,
  path : @json.JsonPath,
) -> Mixin raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError((path, "Expected an object for Mixin"))
  }
  let message = Mixin::default()
  for key, value in obj {
    match (key, value) {
      ("name", value) => message.name = @json.from_json(value, path~)
      ("root", value) => message.root = @json.from_json(value, path~)
      (key, _) => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @lib.AsyncRead for Mixin with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.AsyncReader],
) -> Mixin raise {
  let msg = Mixin::default()
  while (reader |> @lib.async_read_next_message_field())
        is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, _) => msg.name = reader |> @lib.async_read_string()
      (2, _) => msg.root = reader |> @lib.async_read_string()
      _ => reader |> @lib.async_skip_message_field(wire)
    }
  }
  msg
}

///|
pub impl @lib.AsyncWrite for Mixin with fn write(
  self : Mixin,
  writer : &@lib.AsyncWriter,
) -> Unit raise {
  if self.name != Default::default() {
    writer |> @lib.async_write_varint(10UL)
    writer |> @lib.async_write_string(self.name)
  }
  if self.root != Default::default() {
    writer |> @lib.async_write_varint(18UL)
    writer |> @lib.async_write_string(self.root)
  }
}
