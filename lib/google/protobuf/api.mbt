///|
pub(all) struct Api {
  mut name : String
  mut methods : Array[Method]
  mut options : Array[Option]
  mut version : String
  mut source_context : SourceContext?
  mut mixins : Array[Mixin]
  mut syntax : Syntax
} derive(Eq, Debug)

///|
pub impl @lib.Sized for Api with fn size_of(self) {
  let mut size = 0U
  if self.name != Default::default() {
    size += @lib.size_of_length_delimited_field(1U, @lib.size_of(self.name))
  }
  for s in self.methods {
    size += @lib.size_of_length_delimited_field(2U, @lib.size_of(s))
  }
  for s in self.options {
    size += @lib.size_of_length_delimited_field(3U, @lib.size_of(s))
  }
  if self.version != Default::default() {
    size += @lib.size_of_length_delimited_field(4U, @lib.size_of(self.version))
  }
  if self.source_context is Some(v) {
    size += @lib.size_of_length_delimited_field(5U, @lib.size_of(v))
  }
  for s in self.mixins {
    size += @lib.size_of_length_delimited_field(6U, @lib.size_of(s))
  }
  if self.syntax != Default::default() {
    size += @lib.size_of_field(7U, @lib.size_of(self.syntax))
  }
  size
}

///|
pub impl Default for Api with fn default() -> Api {
  Api::{
    name: Default::default(),
    methods: [],
    options: [],
    version: Default::default(),
    source_context: None,
    mixins: [],
    syntax: Default::default(),
  }
}

///|
pub fn Api::Api(
  name : String,
  methods : Array[Method],
  options : Array[Option],
  version : String,
  source_context? : SourceContext,
  mixins : Array[Mixin],
  syntax : Syntax,
) -> Api {
  Api::{ name, methods, options, version, source_context, mixins, syntax, }
}

///|
pub impl @lib.Read for Api with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.Reader],
) -> Api raise {
  let msg : Api = Default::default()
  while (reader |> @lib.read_next_message_field()) is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, _) => msg.name = reader |> @lib.read_string()
      (2, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.methods.push((reader |> @lib.read_message() : Method))
      (3, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.options.push((reader |> @lib.read_message() : Option))
      (4, _) => msg.version = reader |> @lib.read_string()
      (5, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.source_context = (reader |> @lib.read_message() : SourceContext)
          |> Some
      (6, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.mixins.push((reader |> @lib.read_message() : Mixin))
      (7, _) => msg.syntax = reader |> @lib.read_enum() |> Syntax::from_enum
      _ => reader |> @lib.skip_message_field_by_number(field_number, wire)
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
}

///|
pub impl ToJson for Api with fn to_json(self) {
  let json : Map[String, Json] = Map([])
  if self.name != Default::default() {
    json["name"] = ToJson::to_json(self.name)
  }
  if self.methods != Default::default() {
    json["methods"] = ToJson::to_json(self.methods)
  }
  if self.options != Default::default() {
    json["options"] = ToJson::to_json(self.options)
  }
  if self.version != Default::default() {
    json["version"] = ToJson::to_json(self.version)
  }
  match self.source_context {
    Some(v) => json["sourceContext"] = ToJson::to_json(v)
    _ => ()
  }
  if self.mixins != Default::default() {
    json["mixins"] = ToJson::to_json(self.mixins)
  }
  if self.syntax != Default::default() {
    json["syntax"] = ToJson::to_json(self.syntax)
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
  let message : Api = Default::default()
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
      (key, _) => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @lib.AsyncRead for Api with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.AsyncReader],
) -> Api raise {
  let msg : Api = Default::default()
  while (reader |> @lib.async_read_next_message_field())
        is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, _) => msg.name = reader |> @lib.async_read_string()
      (2, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.methods.push((reader |> @lib.async_read_message() : Method))
      (3, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.options.push((reader |> @lib.async_read_message() : Option))
      (4, _) => msg.version = reader |> @lib.async_read_string()
      (5, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.source_context = (
            reader |> @lib.async_read_message() : SourceContext)
          |> Some
      (6, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.mixins.push((reader |> @lib.async_read_message() : Mixin))
      (7, _) =>
        msg.syntax = reader |> @lib.async_read_enum() |> Syntax::from_enum
      _ => reader |> @lib.async_skip_message_field_by_number(field_number, wire)
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
} derive(Eq, Debug)

///|
pub impl @lib.Sized for Method with fn size_of(self) {
  let mut size = 0U
  if self.name != Default::default() {
    size += @lib.size_of_length_delimited_field(1U, @lib.size_of(self.name))
  }
  if self.request_type_url != Default::default() {
    size += @lib.size_of_length_delimited_field(
      2U,
      @lib.size_of(self.request_type_url),
    )
  }
  if self.request_streaming != Default::default() {
    size += @lib.size_of_field(3U, @lib.size_of(self.request_streaming))
  }
  if self.response_type_url != Default::default() {
    size += @lib.size_of_length_delimited_field(
      4U,
      @lib.size_of(self.response_type_url),
    )
  }
  if self.response_streaming != Default::default() {
    size += @lib.size_of_field(5U, @lib.size_of(self.response_streaming))
  }
  for s in self.options {
    size += @lib.size_of_length_delimited_field(6U, @lib.size_of(s))
  }
  if self.syntax != Default::default() {
    size += @lib.size_of_field(7U, @lib.size_of(self.syntax))
  }
  size
}

///|
pub impl Default for Method with fn default() -> Method {
  Method::{
    name: Default::default(),
    request_type_url: Default::default(),
    request_streaming: Default::default(),
    response_type_url: Default::default(),
    response_streaming: Default::default(),
    options: [],
    syntax: Default::default(),
  }
}

///|
pub fn Method::Method(
  name : String,
  request_type_url : String,
  request_streaming : Bool,
  response_type_url : String,
  response_streaming : Bool,
  options : Array[Option],
  syntax : Syntax,
) -> Method {
  Method::{
    name,
    request_type_url,
    request_streaming,
    response_type_url,
    response_streaming,
    options,
    syntax,
  }
}

///|
pub impl @lib.Read for Method with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.Reader],
) -> Method raise {
  let msg : Method = Default::default()
  while (reader |> @lib.read_next_message_field()) is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, _) => msg.name = reader |> @lib.read_string()
      (2, _) => msg.request_type_url = reader |> @lib.read_string()
      (3, _) => msg.request_streaming = reader |> @lib.read_bool()
      (4, _) => msg.response_type_url = reader |> @lib.read_string()
      (5, _) => msg.response_streaming = reader |> @lib.read_bool()
      (6, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.options.push((reader |> @lib.read_message() : Option))
      (7, _) => msg.syntax = reader |> @lib.read_enum() |> Syntax::from_enum
      _ => reader |> @lib.skip_message_field_by_number(field_number, wire)
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
}

///|
pub impl ToJson for Method with fn to_json(self) {
  let json : Map[String, Json] = Map([])
  if self.name != Default::default() {
    json["name"] = ToJson::to_json(self.name)
  }
  if self.request_type_url != Default::default() {
    json["requestTypeUrl"] = ToJson::to_json(self.request_type_url)
  }
  if self.request_streaming != Default::default() {
    json["requestStreaming"] = ToJson::to_json(self.request_streaming)
  }
  if self.response_type_url != Default::default() {
    json["responseTypeUrl"] = ToJson::to_json(self.response_type_url)
  }
  if self.response_streaming != Default::default() {
    json["responseStreaming"] = ToJson::to_json(self.response_streaming)
  }
  if self.options != Default::default() {
    json["options"] = ToJson::to_json(self.options)
  }
  if self.syntax != Default::default() {
    json["syntax"] = ToJson::to_json(self.syntax)
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
  let message : Method = Default::default()
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
      (key, _) => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @lib.AsyncRead for Method with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.AsyncReader],
) -> Method raise {
  let msg : Method = Default::default()
  while (reader |> @lib.async_read_next_message_field())
        is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, _) => msg.name = reader |> @lib.async_read_string()
      (2, _) => msg.request_type_url = reader |> @lib.async_read_string()
      (3, _) => msg.request_streaming = reader |> @lib.async_read_bool()
      (4, _) => msg.response_type_url = reader |> @lib.async_read_string()
      (5, _) => msg.response_streaming = reader |> @lib.async_read_bool()
      (6, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.options.push((reader |> @lib.async_read_message() : Option))
      (7, _) =>
        msg.syntax = reader |> @lib.async_read_enum() |> Syntax::from_enum
      _ => reader |> @lib.async_skip_message_field_by_number(field_number, wire)
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
    size += @lib.size_of_length_delimited_field(1U, @lib.size_of(self.name))
  }
  if self.root != Default::default() {
    size += @lib.size_of_length_delimited_field(2U, @lib.size_of(self.root))
  }
  size
}

///|
pub impl Default for Mixin with fn default() -> Mixin {
  Mixin::{ name: Default::default(), root: Default::default(), }
}

///|
pub fn Mixin::Mixin(name : String, root : String) -> Mixin {
  Mixin::{ name, root, }
}

///|
pub impl @lib.Read for Mixin with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.Reader],
) -> Mixin raise {
  let msg : Mixin = Default::default()
  while (reader |> @lib.read_next_message_field()) is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, _) => msg.name = reader |> @lib.read_string()
      (2, _) => msg.root = reader |> @lib.read_string()
      _ => reader |> @lib.skip_message_field_by_number(field_number, wire)
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
  let json : Map[String, Json] = Map([])
  if self.name != Default::default() {
    json["name"] = ToJson::to_json(self.name)
  }
  if self.root != Default::default() {
    json["root"] = ToJson::to_json(self.root)
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
  let message : Mixin = Default::default()
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
  let msg : Mixin = Default::default()
  while (reader |> @lib.async_read_next_message_field())
        is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, _) => msg.name = reader |> @lib.async_read_string()
      (2, _) => msg.root = reader |> @lib.async_read_string()
      _ => reader |> @lib.async_skip_message_field_by_number(field_number, wire)
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
