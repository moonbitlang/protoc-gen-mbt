///|
pub(all) enum Syntax {
  SYNTAX_PROTO2
  SYNTAX_PROTO3
  SYNTAX_EDITIONS
  Unknown(@lib.Enum)
} derive(Eq, Debug)

///|
pub fn Syntax::to_enum(self : Syntax) -> @lib.Enum {
  match self {
    Syntax::SYNTAX_PROTO2 => 0
    Syntax::SYNTAX_PROTO3 => 1
    Syntax::SYNTAX_EDITIONS => 2
    Syntax::Unknown(value) => value
  }
}

///|
pub fn Syntax::from_enum(i : @lib.Enum) -> Syntax {
  match i.0 {
    0 => Syntax::SYNTAX_PROTO2
    1 => Syntax::SYNTAX_PROTO3
    2 => Syntax::SYNTAX_EDITIONS
    _ => Syntax::Unknown(i)
  }
}

///|
pub impl Default for Syntax with fn default() -> Syntax {
  Syntax::SYNTAX_PROTO2
}

///|
pub impl @lib.Sized for Syntax with fn size_of(self : Syntax) {
  @lib.Sized::size_of(self.to_enum())
}

///|
pub impl @json.FromJson for Syntax with fn from_json(
  json : Json,
  path : @json.JsonPath,
) -> Syntax raise {
  match json {
    String("SYNTAX_PROTO2") => Syntax::SYNTAX_PROTO2
    String("SYNTAX_PROTO3") => Syntax::SYNTAX_PROTO3
    String("SYNTAX_EDITIONS") => Syntax::SYNTAX_EDITIONS
    Number(0, ..) => Syntax::SYNTAX_PROTO2
    Number(1, ..) => Syntax::SYNTAX_PROTO3
    Number(2, ..) => Syntax::SYNTAX_EDITIONS
    Number(value, ..) =>
      if value.trunc() == value {
        Syntax::Unknown(@lib.Enum(value.to_uint()))
      } else {
        raise @json.JsonDecodeError(
          (path, "Expected an integer number or string for enum"),
        )
      }
    _ =>
      raise @json.JsonDecodeError(
        (path, "Expected a number or string for enum"),
      )
  }
}

///|
pub impl ToJson for Syntax with fn to_json(self : Syntax) -> Json {
  match self {
    Syntax::SYNTAX_PROTO2 => "SYNTAX_PROTO2"
    Syntax::SYNTAX_PROTO3 => "SYNTAX_PROTO3"
    Syntax::SYNTAX_EDITIONS => "SYNTAX_EDITIONS"
    Syntax::Unknown(value) => value.0.to_json()
  }
}

///|
pub(all) struct Type {
  mut name : String
  mut fields : Array[Field]
  mut oneofs : Array[String]
  mut options : Array[Option]
  mut source_context : SourceContext?
  mut syntax : Syntax
  mut edition : String
} derive(Eq, Debug)

///|
pub impl @lib.Sized for Type with fn size_of(self) {
  let mut size = 0U
  if self.name != Default::default() {
    size += @lib.size_of_length_delimited_field(1U, @lib.size_of(self.name))
  }
  for s in self.fields {
    size += @lib.size_of_length_delimited_field(2U, @lib.size_of(s))
  }
  for s in self.oneofs {
    size += @lib.size_of_length_delimited_field(3U, @lib.size_of(s))
  }
  for s in self.options {
    size += @lib.size_of_length_delimited_field(4U, @lib.size_of(s))
  }
  if self.source_context is Some(v) {
    size += @lib.size_of_length_delimited_field(5U, @lib.size_of(v))
  }
  if self.syntax != Default::default() {
    size += @lib.size_of_field(6U, @lib.size_of(self.syntax))
  }
  if self.edition != Default::default() {
    size += @lib.size_of_length_delimited_field(7U, @lib.size_of(self.edition))
  }
  size
}

///|
pub impl Default for Type with fn default() -> Type {
  Type::{
    name: String::default(),
    fields: [],
    oneofs: [],
    options: [],
    source_context: None,
    syntax: Syntax::default(),
    edition: String::default(),
  }
}

///|
pub fn Type::new(
  name : String,
  fields : Array[Field],
  oneofs : Array[String],
  options : Array[Option],
  source_context? : SourceContext,
  syntax : Syntax,
  edition : String,
) -> Type {
  Type::{ name, fields, oneofs, options, source_context, syntax, edition }
}

///|
pub impl @lib.Read for Type with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.Reader],
) -> Type raise {
  let msg = Type::default()
  while (reader |> @lib.read_next_message_field()) is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, _) => msg.name = reader |> @lib.read_string()
      (2, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.fields.push((reader |> @lib.read_message() : Field))
      (3, _) => msg.oneofs.push(reader |> @lib.read_string())
      (4, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.options.push((reader |> @lib.read_message() : Option))
      (5, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.source_context = (reader |> @lib.read_message() : SourceContext)
          |> Some
      (6, _) => msg.syntax = reader |> @lib.read_enum() |> Syntax::from_enum
      (7, _) => msg.edition = reader |> @lib.read_string()
      _ => reader |> @lib.skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.Write for Type with fn write(self : Type, writer : &@lib.Writer) -> Unit raise {
  if self.name != Default::default() {
    writer |> @lib.write_varint(10UL)
    writer |> @lib.write_string(self.name)
  }
  for item in self.fields {
    writer |> @lib.write_varint(18UL)
    writer |> @lib.write_message(item)
  }
  for item in self.oneofs {
    writer |> @lib.write_varint(26UL)
    writer |> @lib.write_string(item)
  }
  for item in self.options {
    writer |> @lib.write_varint(34UL)
    writer |> @lib.write_message(item)
  }
  if self.source_context is Some(v) {
    writer |> @lib.write_varint(42UL)
    writer |> @lib.write_message(v)
  }
  if self.syntax != Default::default() {
    writer |> @lib.write_varint(48UL)
    writer |> @lib.write_enum(self.syntax.to_enum())
  }
  if self.edition != Default::default() {
    writer |> @lib.write_varint(58UL)
    writer |> @lib.write_string(self.edition)
  }
}

///|
pub impl ToJson for Type with fn to_json(self) {
  let json : Map[String, Json] = {}
  if self.name != Default::default() {
    json["name"] = self.name.to_json()
  }
  if self.fields != Default::default() {
    json["fields"] = self.fields.to_json()
  }
  if self.oneofs != Default::default() {
    json["oneofs"] = self.oneofs.to_json()
  }
  if self.options != Default::default() {
    json["options"] = self.options.to_json()
  }
  match self.source_context {
    Some(v) => json["sourceContext"] = v.to_json()
    _ => ()
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
pub impl @json.FromJson for Type with fn from_json(
  json : Json,
  path : @json.JsonPath,
) -> Type raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError((path, "Expected an object for Type"))
  }
  let message = Type::default()
  for key, value in obj {
    match (key, value) {
      ("name", value) => message.name = @json.from_json(value, path~)
      ("fields", Array(value)) =>
        message.fields = value.map(v => @json.from_json(v, path~))
      ("oneofs", Array(value)) =>
        message.oneofs = value.map(v => @json.from_json(v, path~))
      ("options", Array(value)) =>
        message.options = value.map(v => @json.from_json(v, path~))
      ("sourceContext", value) =>
        message.source_context = Some(@json.from_json(value, path~))
      ("syntax", value) => message.syntax = @json.from_json(value, path~)
      ("edition", value) => message.edition = @json.from_json(value, path~)
      (key, _) => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @lib.AsyncRead for Type with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.AsyncReader],
) -> Type raise {
  let msg = Type::default()
  while (reader |> @lib.async_read_next_message_field())
        is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, _) => msg.name = reader |> @lib.async_read_string()
      (2, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.fields.push((reader |> @lib.async_read_message() : Field))
      (3, _) => msg.oneofs.push(reader |> @lib.async_read_string())
      (4, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.options.push((reader |> @lib.async_read_message() : Option))
      (5, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.source_context = (
            reader |> @lib.async_read_message() : SourceContext)
          |> Some
      (6, _) =>
        msg.syntax = reader |> @lib.async_read_enum() |> Syntax::from_enum
      (7, _) => msg.edition = reader |> @lib.async_read_string()
      _ => reader |> @lib.async_skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.AsyncWrite for Type with fn write(
  self : Type,
  writer : &@lib.AsyncWriter,
) -> Unit raise {
  if self.name != Default::default() {
    writer |> @lib.async_write_varint(10UL)
    writer |> @lib.async_write_string(self.name)
  }
  for item in self.fields {
    writer |> @lib.async_write_varint(18UL)
    writer |> @lib.async_write_message(item)
  }
  for item in self.oneofs {
    writer |> @lib.async_write_varint(26UL)
    writer |> @lib.async_write_string(item)
  }
  for item in self.options {
    writer |> @lib.async_write_varint(34UL)
    writer |> @lib.async_write_message(item)
  }
  if self.source_context is Some(v) {
    writer |> @lib.async_write_varint(42UL)
    writer |> @lib.async_write_message(v)
  }
  if self.syntax != Default::default() {
    writer |> @lib.async_write_varint(48UL)
    writer |> @lib.async_write_enum(self.syntax.to_enum())
  }
  if self.edition != Default::default() {
    writer |> @lib.async_write_varint(58UL)
    writer |> @lib.async_write_string(self.edition)
  }
}

///|
pub(all) enum Field_Kind {
  TYPE_UNKNOWN
  TYPE_DOUBLE
  TYPE_FLOAT
  TYPE_INT64
  TYPE_UINT64
  TYPE_INT32
  TYPE_FIXED64
  TYPE_FIXED32
  TYPE_BOOL
  TYPE_STRING
  TYPE_GROUP
  TYPE_MESSAGE
  TYPE_BYTES
  TYPE_UINT32
  TYPE_ENUM
  TYPE_SFIXED32
  TYPE_SFIXED64
  TYPE_SINT32
  TYPE_SINT64
  Unknown(@lib.Enum)
} derive(Eq, Debug)

///|
pub fn Field_Kind::to_enum(self : Field_Kind) -> @lib.Enum {
  match self {
    Field_Kind::TYPE_UNKNOWN => 0
    Field_Kind::TYPE_DOUBLE => 1
    Field_Kind::TYPE_FLOAT => 2
    Field_Kind::TYPE_INT64 => 3
    Field_Kind::TYPE_UINT64 => 4
    Field_Kind::TYPE_INT32 => 5
    Field_Kind::TYPE_FIXED64 => 6
    Field_Kind::TYPE_FIXED32 => 7
    Field_Kind::TYPE_BOOL => 8
    Field_Kind::TYPE_STRING => 9
    Field_Kind::TYPE_GROUP => 10
    Field_Kind::TYPE_MESSAGE => 11
    Field_Kind::TYPE_BYTES => 12
    Field_Kind::TYPE_UINT32 => 13
    Field_Kind::TYPE_ENUM => 14
    Field_Kind::TYPE_SFIXED32 => 15
    Field_Kind::TYPE_SFIXED64 => 16
    Field_Kind::TYPE_SINT32 => 17
    Field_Kind::TYPE_SINT64 => 18
    Field_Kind::Unknown(value) => value
  }
}

///|
pub fn Field_Kind::from_enum(i : @lib.Enum) -> Field_Kind {
  match i.0 {
    0 => Field_Kind::TYPE_UNKNOWN
    1 => Field_Kind::TYPE_DOUBLE
    2 => Field_Kind::TYPE_FLOAT
    3 => Field_Kind::TYPE_INT64
    4 => Field_Kind::TYPE_UINT64
    5 => Field_Kind::TYPE_INT32
    6 => Field_Kind::TYPE_FIXED64
    7 => Field_Kind::TYPE_FIXED32
    8 => Field_Kind::TYPE_BOOL
    9 => Field_Kind::TYPE_STRING
    10 => Field_Kind::TYPE_GROUP
    11 => Field_Kind::TYPE_MESSAGE
    12 => Field_Kind::TYPE_BYTES
    13 => Field_Kind::TYPE_UINT32
    14 => Field_Kind::TYPE_ENUM
    15 => Field_Kind::TYPE_SFIXED32
    16 => Field_Kind::TYPE_SFIXED64
    17 => Field_Kind::TYPE_SINT32
    18 => Field_Kind::TYPE_SINT64
    _ => Field_Kind::Unknown(i)
  }
}

///|
pub impl Default for Field_Kind with fn default() -> Field_Kind {
  Field_Kind::TYPE_UNKNOWN
}

///|
pub impl @lib.Sized for Field_Kind with fn size_of(self : Field_Kind) {
  @lib.Sized::size_of(self.to_enum())
}

///|
pub impl @json.FromJson for Field_Kind with fn from_json(
  json : Json,
  path : @json.JsonPath,
) -> Field_Kind raise {
  match json {
    String("TYPE_UNKNOWN") => Field_Kind::TYPE_UNKNOWN
    String("TYPE_DOUBLE") => Field_Kind::TYPE_DOUBLE
    String("TYPE_FLOAT") => Field_Kind::TYPE_FLOAT
    String("TYPE_INT64") => Field_Kind::TYPE_INT64
    String("TYPE_UINT64") => Field_Kind::TYPE_UINT64
    String("TYPE_INT32") => Field_Kind::TYPE_INT32
    String("TYPE_FIXED64") => Field_Kind::TYPE_FIXED64
    String("TYPE_FIXED32") => Field_Kind::TYPE_FIXED32
    String("TYPE_BOOL") => Field_Kind::TYPE_BOOL
    String("TYPE_STRING") => Field_Kind::TYPE_STRING
    String("TYPE_GROUP") => Field_Kind::TYPE_GROUP
    String("TYPE_MESSAGE") => Field_Kind::TYPE_MESSAGE
    String("TYPE_BYTES") => Field_Kind::TYPE_BYTES
    String("TYPE_UINT32") => Field_Kind::TYPE_UINT32
    String("TYPE_ENUM") => Field_Kind::TYPE_ENUM
    String("TYPE_SFIXED32") => Field_Kind::TYPE_SFIXED32
    String("TYPE_SFIXED64") => Field_Kind::TYPE_SFIXED64
    String("TYPE_SINT32") => Field_Kind::TYPE_SINT32
    String("TYPE_SINT64") => Field_Kind::TYPE_SINT64
    Number(0, ..) => Field_Kind::TYPE_UNKNOWN
    Number(1, ..) => Field_Kind::TYPE_DOUBLE
    Number(2, ..) => Field_Kind::TYPE_FLOAT
    Number(3, ..) => Field_Kind::TYPE_INT64
    Number(4, ..) => Field_Kind::TYPE_UINT64
    Number(5, ..) => Field_Kind::TYPE_INT32
    Number(6, ..) => Field_Kind::TYPE_FIXED64
    Number(7, ..) => Field_Kind::TYPE_FIXED32
    Number(8, ..) => Field_Kind::TYPE_BOOL
    Number(9, ..) => Field_Kind::TYPE_STRING
    Number(10, ..) => Field_Kind::TYPE_GROUP
    Number(11, ..) => Field_Kind::TYPE_MESSAGE
    Number(12, ..) => Field_Kind::TYPE_BYTES
    Number(13, ..) => Field_Kind::TYPE_UINT32
    Number(14, ..) => Field_Kind::TYPE_ENUM
    Number(15, ..) => Field_Kind::TYPE_SFIXED32
    Number(16, ..) => Field_Kind::TYPE_SFIXED64
    Number(17, ..) => Field_Kind::TYPE_SINT32
    Number(18, ..) => Field_Kind::TYPE_SINT64
    Number(value, ..) =>
      if value.trunc() == value {
        Field_Kind::Unknown(@lib.Enum(value.to_uint()))
      } else {
        raise @json.JsonDecodeError(
          (path, "Expected an integer number or string for enum"),
        )
      }
    _ =>
      raise @json.JsonDecodeError(
        (path, "Expected a number or string for enum"),
      )
  }
}

///|
pub impl ToJson for Field_Kind with fn to_json(self : Field_Kind) -> Json {
  match self {
    Field_Kind::TYPE_UNKNOWN => "TYPE_UNKNOWN"
    Field_Kind::TYPE_DOUBLE => "TYPE_DOUBLE"
    Field_Kind::TYPE_FLOAT => "TYPE_FLOAT"
    Field_Kind::TYPE_INT64 => "TYPE_INT64"
    Field_Kind::TYPE_UINT64 => "TYPE_UINT64"
    Field_Kind::TYPE_INT32 => "TYPE_INT32"
    Field_Kind::TYPE_FIXED64 => "TYPE_FIXED64"
    Field_Kind::TYPE_FIXED32 => "TYPE_FIXED32"
    Field_Kind::TYPE_BOOL => "TYPE_BOOL"
    Field_Kind::TYPE_STRING => "TYPE_STRING"
    Field_Kind::TYPE_GROUP => "TYPE_GROUP"
    Field_Kind::TYPE_MESSAGE => "TYPE_MESSAGE"
    Field_Kind::TYPE_BYTES => "TYPE_BYTES"
    Field_Kind::TYPE_UINT32 => "TYPE_UINT32"
    Field_Kind::TYPE_ENUM => "TYPE_ENUM"
    Field_Kind::TYPE_SFIXED32 => "TYPE_SFIXED32"
    Field_Kind::TYPE_SFIXED64 => "TYPE_SFIXED64"
    Field_Kind::TYPE_SINT32 => "TYPE_SINT32"
    Field_Kind::TYPE_SINT64 => "TYPE_SINT64"
    Field_Kind::Unknown(value) => value.0.to_json()
  }
}

///|
pub(all) enum Field_Cardinality {
  CARDINALITY_UNKNOWN
  CARDINALITY_OPTIONAL
  CARDINALITY_REQUIRED
  CARDINALITY_REPEATED
  Unknown(@lib.Enum)
} derive(Eq, Debug)

///|
pub fn Field_Cardinality::to_enum(self : Field_Cardinality) -> @lib.Enum {
  match self {
    Field_Cardinality::CARDINALITY_UNKNOWN => 0
    Field_Cardinality::CARDINALITY_OPTIONAL => 1
    Field_Cardinality::CARDINALITY_REQUIRED => 2
    Field_Cardinality::CARDINALITY_REPEATED => 3
    Field_Cardinality::Unknown(value) => value
  }
}

///|
pub fn Field_Cardinality::from_enum(i : @lib.Enum) -> Field_Cardinality {
  match i.0 {
    0 => Field_Cardinality::CARDINALITY_UNKNOWN
    1 => Field_Cardinality::CARDINALITY_OPTIONAL
    2 => Field_Cardinality::CARDINALITY_REQUIRED
    3 => Field_Cardinality::CARDINALITY_REPEATED
    _ => Field_Cardinality::Unknown(i)
  }
}

///|
pub impl Default for Field_Cardinality with fn default() -> Field_Cardinality {
  Field_Cardinality::CARDINALITY_UNKNOWN
}

///|
pub impl @lib.Sized for Field_Cardinality with fn size_of(
  self : Field_Cardinality,
) {
  @lib.Sized::size_of(self.to_enum())
}

///|
pub impl @json.FromJson for Field_Cardinality with fn from_json(
  json : Json,
  path : @json.JsonPath,
) -> Field_Cardinality raise {
  match json {
    String("CARDINALITY_UNKNOWN") => Field_Cardinality::CARDINALITY_UNKNOWN
    String("CARDINALITY_OPTIONAL") => Field_Cardinality::CARDINALITY_OPTIONAL
    String("CARDINALITY_REQUIRED") => Field_Cardinality::CARDINALITY_REQUIRED
    String("CARDINALITY_REPEATED") => Field_Cardinality::CARDINALITY_REPEATED
    Number(0, ..) => Field_Cardinality::CARDINALITY_UNKNOWN
    Number(1, ..) => Field_Cardinality::CARDINALITY_OPTIONAL
    Number(2, ..) => Field_Cardinality::CARDINALITY_REQUIRED
    Number(3, ..) => Field_Cardinality::CARDINALITY_REPEATED
    Number(value, ..) =>
      if value.trunc() == value {
        Field_Cardinality::Unknown(@lib.Enum(value.to_uint()))
      } else {
        raise @json.JsonDecodeError(
          (path, "Expected an integer number or string for enum"),
        )
      }
    _ =>
      raise @json.JsonDecodeError(
        (path, "Expected a number or string for enum"),
      )
  }
}

///|
pub impl ToJson for Field_Cardinality with fn to_json(self : Field_Cardinality) -> Json {
  match self {
    Field_Cardinality::CARDINALITY_UNKNOWN => "CARDINALITY_UNKNOWN"
    Field_Cardinality::CARDINALITY_OPTIONAL => "CARDINALITY_OPTIONAL"
    Field_Cardinality::CARDINALITY_REQUIRED => "CARDINALITY_REQUIRED"
    Field_Cardinality::CARDINALITY_REPEATED => "CARDINALITY_REPEATED"
    Field_Cardinality::Unknown(value) => value.0.to_json()
  }
}

///|
pub(all) struct Field {
  mut kind : Field_Kind
  mut cardinality : Field_Cardinality
  mut number : Int
  mut name : String
  mut type_url : String
  mut oneof_index : Int
  mut packed : Bool
  mut options : Array[Option]
  mut json_name : String
  mut default_value : String
} derive(Eq, Debug)

///|
pub impl @lib.Sized for Field with fn size_of(self) {
  let mut size = 0U
  if self.kind != Default::default() {
    size += @lib.size_of_field(1U, @lib.size_of(self.kind))
  }
  if self.cardinality != Default::default() {
    size += @lib.size_of_field(2U, @lib.size_of(self.cardinality))
  }
  if self.number != Default::default() {
    size += @lib.size_of_field(3U, @lib.size_of(self.number))
  }
  if self.name != Default::default() {
    size += @lib.size_of_length_delimited_field(4U, @lib.size_of(self.name))
  }
  if self.type_url != Default::default() {
    size += @lib.size_of_length_delimited_field(6U, @lib.size_of(self.type_url))
  }
  if self.oneof_index != Default::default() {
    size += @lib.size_of_field(7U, @lib.size_of(self.oneof_index))
  }
  if self.packed != Default::default() {
    size += @lib.size_of_field(8U, @lib.size_of(self.packed))
  }
  for s in self.options {
    size += @lib.size_of_length_delimited_field(9U, @lib.size_of(s))
  }
  if self.json_name != Default::default() {
    size += @lib.size_of_length_delimited_field(
      10U,
      @lib.size_of(self.json_name),
    )
  }
  if self.default_value != Default::default() {
    size += @lib.size_of_length_delimited_field(
      11U,
      @lib.size_of(self.default_value),
    )
  }
  size
}

///|
pub impl Default for Field with fn default() -> Field {
  Field::{
    kind: Field_Kind::default(),
    cardinality: Field_Cardinality::default(),
    number: Int::default(),
    name: String::default(),
    type_url: String::default(),
    oneof_index: Int::default(),
    packed: Bool::default(),
    options: [],
    json_name: String::default(),
    default_value: String::default(),
  }
}

///|
pub fn Field::new(
  kind : Field_Kind,
  cardinality : Field_Cardinality,
  number : Int,
  name : String,
  type_url : String,
  oneof_index : Int,
  packed : Bool,
  options : Array[Option],
  json_name : String,
  default_value : String,
) -> Field {
  Field::{
    kind,
    cardinality,
    number,
    name,
    type_url,
    oneof_index,
    packed,
    options,
    json_name,
    default_value,
  }
}

///|
pub impl @lib.Read for Field with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.Reader],
) -> Field raise {
  let msg = Field::default()
  while (reader |> @lib.read_next_message_field()) is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, _) => msg.kind = reader |> @lib.read_enum() |> Field_Kind::from_enum
      (2, _) =>
        msg.cardinality = reader
          |> @lib.read_enum()
          |> Field_Cardinality::from_enum
      (3, _) => msg.number = reader |> @lib.read_int32()
      (4, _) => msg.name = reader |> @lib.read_string()
      (6, _) => msg.type_url = reader |> @lib.read_string()
      (7, _) => msg.oneof_index = reader |> @lib.read_int32()
      (8, _) => msg.packed = reader |> @lib.read_bool()
      (9, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.options.push((reader |> @lib.read_message() : Option))
      (10, _) => msg.json_name = reader |> @lib.read_string()
      (11, _) => msg.default_value = reader |> @lib.read_string()
      _ => reader |> @lib.skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.Write for Field with fn write(self : Field, writer : &@lib.Writer) -> Unit raise {
  if self.kind != Default::default() {
    writer |> @lib.write_varint(8UL)
    writer |> @lib.write_enum(self.kind.to_enum())
  }
  if self.cardinality != Default::default() {
    writer |> @lib.write_varint(16UL)
    writer |> @lib.write_enum(self.cardinality.to_enum())
  }
  if self.number != Default::default() {
    writer |> @lib.write_varint(24UL)
    writer |> @lib.write_int32(self.number)
  }
  if self.name != Default::default() {
    writer |> @lib.write_varint(34UL)
    writer |> @lib.write_string(self.name)
  }
  if self.type_url != Default::default() {
    writer |> @lib.write_varint(50UL)
    writer |> @lib.write_string(self.type_url)
  }
  if self.oneof_index != Default::default() {
    writer |> @lib.write_varint(56UL)
    writer |> @lib.write_int32(self.oneof_index)
  }
  if self.packed != Default::default() {
    writer |> @lib.write_varint(64UL)
    writer |> @lib.write_bool(self.packed)
  }
  for item in self.options {
    writer |> @lib.write_varint(74UL)
    writer |> @lib.write_message(item)
  }
  if self.json_name != Default::default() {
    writer |> @lib.write_varint(82UL)
    writer |> @lib.write_string(self.json_name)
  }
  if self.default_value != Default::default() {
    writer |> @lib.write_varint(90UL)
    writer |> @lib.write_string(self.default_value)
  }
}

///|
pub impl ToJson for Field with fn to_json(self) {
  let json : Map[String, Json] = {}
  if self.kind != Default::default() {
    json["kind"] = self.kind.to_json()
  }
  if self.cardinality != Default::default() {
    json["cardinality"] = self.cardinality.to_json()
  }
  if self.number != Default::default() {
    json["number"] = self.number.to_json()
  }
  if self.name != Default::default() {
    json["name"] = self.name.to_json()
  }
  if self.type_url != Default::default() {
    json["typeUrl"] = self.type_url.to_json()
  }
  if self.oneof_index != Default::default() {
    json["oneofIndex"] = self.oneof_index.to_json()
  }
  if self.packed != Default::default() {
    json["packed"] = self.packed.to_json()
  }
  if self.options != Default::default() {
    json["options"] = self.options.to_json()
  }
  if self.json_name != Default::default() {
    json["jsonName"] = self.json_name.to_json()
  }
  if self.default_value != Default::default() {
    json["defaultValue"] = self.default_value.to_json()
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for Field with fn from_json(
  json : Json,
  path : @json.JsonPath,
) -> Field raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError((path, "Expected an object for Field"))
  }
  let message = Field::default()
  for key, value in obj {
    match (key, value) {
      ("kind", value) => message.kind = @json.from_json(value, path~)
      ("cardinality", value) =>
        message.cardinality = @json.from_json(value, path~)
      ("number", value) => message.number = @json.from_json(value, path~)
      ("name", value) => message.name = @json.from_json(value, path~)
      ("typeUrl", value) => message.type_url = @json.from_json(value, path~)
      ("oneofIndex", value) =>
        message.oneof_index = @json.from_json(value, path~)
      ("packed", value) => message.packed = @json.from_json(value, path~)
      ("options", Array(value)) =>
        message.options = value.map(v => @json.from_json(v, path~))
      ("jsonName", value) => message.json_name = @json.from_json(value, path~)
      ("defaultValue", value) =>
        message.default_value = @json.from_json(value, path~)
      (key, _) => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @lib.AsyncRead for Field with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.AsyncReader],
) -> Field raise {
  let msg = Field::default()
  while (reader |> @lib.async_read_next_message_field())
        is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, _) =>
        msg.kind = reader |> @lib.async_read_enum() |> Field_Kind::from_enum
      (2, _) =>
        msg.cardinality = reader
          |> @lib.async_read_enum()
          |> Field_Cardinality::from_enum
      (3, _) => msg.number = reader |> @lib.async_read_int32()
      (4, _) => msg.name = reader |> @lib.async_read_string()
      (6, _) => msg.type_url = reader |> @lib.async_read_string()
      (7, _) => msg.oneof_index = reader |> @lib.async_read_int32()
      (8, _) => msg.packed = reader |> @lib.async_read_bool()
      (9, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.options.push((reader |> @lib.async_read_message() : Option))
      (10, _) => msg.json_name = reader |> @lib.async_read_string()
      (11, _) => msg.default_value = reader |> @lib.async_read_string()
      _ => reader |> @lib.async_skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.AsyncWrite for Field with fn write(
  self : Field,
  writer : &@lib.AsyncWriter,
) -> Unit raise {
  if self.kind != Default::default() {
    writer |> @lib.async_write_varint(8UL)
    writer |> @lib.async_write_enum(self.kind.to_enum())
  }
  if self.cardinality != Default::default() {
    writer |> @lib.async_write_varint(16UL)
    writer |> @lib.async_write_enum(self.cardinality.to_enum())
  }
  if self.number != Default::default() {
    writer |> @lib.async_write_varint(24UL)
    writer |> @lib.async_write_int32(self.number)
  }
  if self.name != Default::default() {
    writer |> @lib.async_write_varint(34UL)
    writer |> @lib.async_write_string(self.name)
  }
  if self.type_url != Default::default() {
    writer |> @lib.async_write_varint(50UL)
    writer |> @lib.async_write_string(self.type_url)
  }
  if self.oneof_index != Default::default() {
    writer |> @lib.async_write_varint(56UL)
    writer |> @lib.async_write_int32(self.oneof_index)
  }
  if self.packed != Default::default() {
    writer |> @lib.async_write_varint(64UL)
    writer |> @lib.async_write_bool(self.packed)
  }
  for item in self.options {
    writer |> @lib.async_write_varint(74UL)
    writer |> @lib.async_write_message(item)
  }
  if self.json_name != Default::default() {
    writer |> @lib.async_write_varint(82UL)
    writer |> @lib.async_write_string(self.json_name)
  }
  if self.default_value != Default::default() {
    writer |> @lib.async_write_varint(90UL)
    writer |> @lib.async_write_string(self.default_value)
  }
}

///|
pub(all) struct Enum {
  mut name : String
  mut enumvalue : Array[EnumValue]
  mut options : Array[Option]
  mut source_context : SourceContext?
  mut syntax : Syntax
  mut edition : String
} derive(Eq, Debug)

///|
pub impl @lib.Sized for Enum with fn size_of(self) {
  let mut size = 0U
  if self.name != Default::default() {
    size += @lib.size_of_length_delimited_field(1U, @lib.size_of(self.name))
  }
  for s in self.enumvalue {
    size += @lib.size_of_length_delimited_field(2U, @lib.size_of(s))
  }
  for s in self.options {
    size += @lib.size_of_length_delimited_field(3U, @lib.size_of(s))
  }
  if self.source_context is Some(v) {
    size += @lib.size_of_length_delimited_field(4U, @lib.size_of(v))
  }
  if self.syntax != Default::default() {
    size += @lib.size_of_field(5U, @lib.size_of(self.syntax))
  }
  if self.edition != Default::default() {
    size += @lib.size_of_length_delimited_field(6U, @lib.size_of(self.edition))
  }
  size
}

///|
pub impl Default for Enum with fn default() -> Enum {
  Enum::{
    name: String::default(),
    enumvalue: [],
    options: [],
    source_context: None,
    syntax: Syntax::default(),
    edition: String::default(),
  }
}

///|
pub fn Enum::new(
  name : String,
  enumvalue : Array[EnumValue],
  options : Array[Option],
  source_context? : SourceContext,
  syntax : Syntax,
  edition : String,
) -> Enum {
  Enum::{ name, enumvalue, options, source_context, syntax, edition }
}

///|
pub impl @lib.Read for Enum with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.Reader],
) -> Enum raise {
  let msg = Enum::default()
  while (reader |> @lib.read_next_message_field()) is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, _) => msg.name = reader |> @lib.read_string()
      (2, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.enumvalue.push((reader |> @lib.read_message() : EnumValue))
      (3, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.options.push((reader |> @lib.read_message() : Option))
      (4, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.source_context = (reader |> @lib.read_message() : SourceContext)
          |> Some
      (5, _) => msg.syntax = reader |> @lib.read_enum() |> Syntax::from_enum
      (6, _) => msg.edition = reader |> @lib.read_string()
      _ => reader |> @lib.skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.Write for Enum with fn write(self : Enum, writer : &@lib.Writer) -> Unit raise {
  if self.name != Default::default() {
    writer |> @lib.write_varint(10UL)
    writer |> @lib.write_string(self.name)
  }
  for item in self.enumvalue {
    writer |> @lib.write_varint(18UL)
    writer |> @lib.write_message(item)
  }
  for item in self.options {
    writer |> @lib.write_varint(26UL)
    writer |> @lib.write_message(item)
  }
  if self.source_context is Some(v) {
    writer |> @lib.write_varint(34UL)
    writer |> @lib.write_message(v)
  }
  if self.syntax != Default::default() {
    writer |> @lib.write_varint(40UL)
    writer |> @lib.write_enum(self.syntax.to_enum())
  }
  if self.edition != Default::default() {
    writer |> @lib.write_varint(50UL)
    writer |> @lib.write_string(self.edition)
  }
}

///|
pub impl ToJson for Enum with fn to_json(self) {
  let json : Map[String, Json] = {}
  if self.name != Default::default() {
    json["name"] = self.name.to_json()
  }
  if self.enumvalue != Default::default() {
    json["enumvalue"] = self.enumvalue.to_json()
  }
  if self.options != Default::default() {
    json["options"] = self.options.to_json()
  }
  match self.source_context {
    Some(v) => json["sourceContext"] = v.to_json()
    _ => ()
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
pub impl @json.FromJson for Enum with fn from_json(
  json : Json,
  path : @json.JsonPath,
) -> Enum raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError((path, "Expected an object for Enum"))
  }
  let message = Enum::default()
  for key, value in obj {
    match (key, value) {
      ("name", value) => message.name = @json.from_json(value, path~)
      ("enumvalue", Array(value)) =>
        message.enumvalue = value.map(v => @json.from_json(v, path~))
      ("options", Array(value)) =>
        message.options = value.map(v => @json.from_json(v, path~))
      ("sourceContext", value) =>
        message.source_context = Some(@json.from_json(value, path~))
      ("syntax", value) => message.syntax = @json.from_json(value, path~)
      ("edition", value) => message.edition = @json.from_json(value, path~)
      (key, _) => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @lib.AsyncRead for Enum with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.AsyncReader],
) -> Enum raise {
  let msg = Enum::default()
  while (reader |> @lib.async_read_next_message_field())
        is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, _) => msg.name = reader |> @lib.async_read_string()
      (2, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.enumvalue.push((reader |> @lib.async_read_message() : EnumValue))
      (3, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.options.push((reader |> @lib.async_read_message() : Option))
      (4, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.source_context = (
            reader |> @lib.async_read_message() : SourceContext)
          |> Some
      (5, _) =>
        msg.syntax = reader |> @lib.async_read_enum() |> Syntax::from_enum
      (6, _) => msg.edition = reader |> @lib.async_read_string()
      _ => reader |> @lib.async_skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.AsyncWrite for Enum with fn write(
  self : Enum,
  writer : &@lib.AsyncWriter,
) -> Unit raise {
  if self.name != Default::default() {
    writer |> @lib.async_write_varint(10UL)
    writer |> @lib.async_write_string(self.name)
  }
  for item in self.enumvalue {
    writer |> @lib.async_write_varint(18UL)
    writer |> @lib.async_write_message(item)
  }
  for item in self.options {
    writer |> @lib.async_write_varint(26UL)
    writer |> @lib.async_write_message(item)
  }
  if self.source_context is Some(v) {
    writer |> @lib.async_write_varint(34UL)
    writer |> @lib.async_write_message(v)
  }
  if self.syntax != Default::default() {
    writer |> @lib.async_write_varint(40UL)
    writer |> @lib.async_write_enum(self.syntax.to_enum())
  }
  if self.edition != Default::default() {
    writer |> @lib.async_write_varint(50UL)
    writer |> @lib.async_write_string(self.edition)
  }
}

///|
pub(all) struct EnumValue {
  mut name : String
  mut number : Int
  mut options : Array[Option]
} derive(Eq, Debug)

///|
pub impl @lib.Sized for EnumValue with fn size_of(self) {
  let mut size = 0U
  if self.name != Default::default() {
    size += @lib.size_of_length_delimited_field(1U, @lib.size_of(self.name))
  }
  if self.number != Default::default() {
    size += @lib.size_of_field(2U, @lib.size_of(self.number))
  }
  for s in self.options {
    size += @lib.size_of_length_delimited_field(3U, @lib.size_of(s))
  }
  size
}

///|
pub impl Default for EnumValue with fn default() -> EnumValue {
  EnumValue::{ name: String::default(), number: Int::default(), options: [] }
}

///|
pub fn EnumValue::new(
  name : String,
  number : Int,
  options : Array[Option],
) -> EnumValue {
  EnumValue::{ name, number, options }
}

///|
pub impl @lib.Read for EnumValue with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.Reader],
) -> EnumValue raise {
  let msg = EnumValue::default()
  while (reader |> @lib.read_next_message_field()) is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, _) => msg.name = reader |> @lib.read_string()
      (2, _) => msg.number = reader |> @lib.read_int32()
      (3, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.options.push((reader |> @lib.read_message() : Option))
      _ => reader |> @lib.skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.Write for EnumValue with fn write(
  self : EnumValue,
  writer : &@lib.Writer,
) -> Unit raise {
  if self.name != Default::default() {
    writer |> @lib.write_varint(10UL)
    writer |> @lib.write_string(self.name)
  }
  if self.number != Default::default() {
    writer |> @lib.write_varint(16UL)
    writer |> @lib.write_int32(self.number)
  }
  for item in self.options {
    writer |> @lib.write_varint(26UL)
    writer |> @lib.write_message(item)
  }
}

///|
pub impl ToJson for EnumValue with fn to_json(self) {
  let json : Map[String, Json] = {}
  if self.name != Default::default() {
    json["name"] = self.name.to_json()
  }
  if self.number != Default::default() {
    json["number"] = self.number.to_json()
  }
  if self.options != Default::default() {
    json["options"] = self.options.to_json()
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for EnumValue with fn from_json(
  json : Json,
  path : @json.JsonPath,
) -> EnumValue raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError((path, "Expected an object for EnumValue"))
  }
  let message = EnumValue::default()
  for key, value in obj {
    match (key, value) {
      ("name", value) => message.name = @json.from_json(value, path~)
      ("number", value) => message.number = @json.from_json(value, path~)
      ("options", Array(value)) =>
        message.options = value.map(v => @json.from_json(v, path~))
      (key, _) => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @lib.AsyncRead for EnumValue with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.AsyncReader],
) -> EnumValue raise {
  let msg = EnumValue::default()
  while (reader |> @lib.async_read_next_message_field())
        is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, _) => msg.name = reader |> @lib.async_read_string()
      (2, _) => msg.number = reader |> @lib.async_read_int32()
      (3, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.options.push((reader |> @lib.async_read_message() : Option))
      _ => reader |> @lib.async_skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.AsyncWrite for EnumValue with fn write(
  self : EnumValue,
  writer : &@lib.AsyncWriter,
) -> Unit raise {
  if self.name != Default::default() {
    writer |> @lib.async_write_varint(10UL)
    writer |> @lib.async_write_string(self.name)
  }
  if self.number != Default::default() {
    writer |> @lib.async_write_varint(16UL)
    writer |> @lib.async_write_int32(self.number)
  }
  for item in self.options {
    writer |> @lib.async_write_varint(26UL)
    writer |> @lib.async_write_message(item)
  }
}

///|
pub(all) struct Option {
  mut name : String
  mut value : Any?
} derive(Eq, Debug)

///|
pub impl @lib.Sized for Option with fn size_of(self) {
  let mut size = 0U
  if self.name != Default::default() {
    size += @lib.size_of_length_delimited_field(1U, @lib.size_of(self.name))
  }
  if self.value is Some(v) {
    size += @lib.size_of_length_delimited_field(2U, @lib.size_of(v))
  }
  size
}

///|
pub impl Default for Option with fn default() -> Option {
  Option::{ name: String::default(), value: None }
}

///|
pub fn Option::new(name : String, value? : Any) -> Option {
  Option::{ name, value }
}

///|
pub impl @lib.Read for Option with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.Reader],
) -> Option raise {
  let msg = Option::default()
  while (reader |> @lib.read_next_message_field()) is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, _) => msg.name = reader |> @lib.read_string()
      (2, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.value = (reader |> @lib.read_message() : Any) |> Some
      _ => reader |> @lib.skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.Write for Option with fn write(
  self : Option,
  writer : &@lib.Writer,
) -> Unit raise {
  if self.name != Default::default() {
    writer |> @lib.write_varint(10UL)
    writer |> @lib.write_string(self.name)
  }
  if self.value is Some(v) {
    writer |> @lib.write_varint(18UL)
    writer |> @lib.write_message(v)
  }
}

///|
pub impl ToJson for Option with fn to_json(self) {
  let json : Map[String, Json] = {}
  if self.name != Default::default() {
    json["name"] = self.name.to_json()
  }
  match self.value {
    Some(v) => json["value"] = v.to_json()
    _ => ()
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for Option with fn from_json(
  json : Json,
  path : @json.JsonPath,
) -> Option raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError((path, "Expected an object for Option"))
  }
  let message = Option::default()
  for key, value in obj {
    match (key, value) {
      ("name", value) => message.name = @json.from_json(value, path~)
      ("value", value) => message.value = Some(@json.from_json(value, path~))
      (key, _) => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @lib.AsyncRead for Option with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.AsyncReader],
) -> Option raise {
  let msg = Option::default()
  while (reader |> @lib.async_read_next_message_field())
        is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, _) => msg.name = reader |> @lib.async_read_string()
      (2, @lib.WIRE_TYPE_LENGTH_DELIMITED) =>
        msg.value = (reader |> @lib.async_read_message() : Any) |> Some
      _ => reader |> @lib.async_skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}

///|
pub impl @lib.AsyncWrite for Option with fn write(
  self : Option,
  writer : &@lib.AsyncWriter,
) -> Unit raise {
  if self.name != Default::default() {
    writer |> @lib.async_write_varint(10UL)
    writer |> @lib.async_write_string(self.name)
  }
  if self.value is Some(v) {
    writer |> @lib.async_write_varint(18UL)
    writer |> @lib.async_write_message(v)
  }
}
