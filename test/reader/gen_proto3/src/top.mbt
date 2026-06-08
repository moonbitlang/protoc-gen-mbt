///|
pub(all) enum FooEnum {
  FIRST_VALUE
  SECOND_VALUE
  Unknown(@lib.Enum)
} derive(Eq, Debug)

///|
pub fn FooEnum::to_enum(self : FooEnum) -> @lib.Enum {
  match self {
    FooEnum::FIRST_VALUE => 0
    FooEnum::SECOND_VALUE => 2
    FooEnum::Unknown(value) => value
  }
}

///|
pub fn FooEnum::from_enum(i : @lib.Enum) -> FooEnum {
  match i.0 {
    0 => FooEnum::FIRST_VALUE
    2 => FooEnum::SECOND_VALUE
    _ => FooEnum::Unknown(i)
  }
}

///|
pub impl Default for FooEnum with fn default() -> FooEnum {
  FooEnum::FIRST_VALUE
}

///|
pub impl @lib.Sized for FooEnum with fn size_of(self : FooEnum) {
  @lib.Sized::size_of(self.to_enum())
}

///|
pub impl @json.FromJson for FooEnum with fn from_json(
  json : Json,
  path : @json.JsonPath,
) -> FooEnum raise {
  match json {
    String("FIRST_VALUE") => FooEnum::FIRST_VALUE
    String("SECOND_VALUE") => FooEnum::SECOND_VALUE
    Number(0, ..) => FooEnum::FIRST_VALUE
    Number(2, ..) => FooEnum::SECOND_VALUE
    Number(value, ..) =>
      if value.trunc() == value {
        FooEnum::Unknown(@lib.Enum(value.to_uint()))
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
pub impl ToJson for FooEnum with fn to_json(self : FooEnum) -> Json {
  match self {
    FooEnum::FIRST_VALUE => "FIRST_VALUE"
    FooEnum::SECOND_VALUE => "SECOND_VALUE"
    FooEnum::Unknown(value) => value.0.to_json()
  }
}

///|
pub(all) struct BarMessage {
  mut b_int32 : Int
} derive(Eq, Debug)

///|
pub impl @lib.Sized for BarMessage with fn size_of(self) {
  let mut size = 0U
  if self.b_int32 != Default::default() {
    size += @lib.size_of_field(1U, @lib.size_of(self.b_int32))
  }
  size
}

///|
pub impl Default for BarMessage with fn default() -> BarMessage {
  BarMessage::{ b_int32: Int::default() }
}

///|
pub fn BarMessage::new(b_int32 : Int) -> BarMessage {
  BarMessage::{ b_int32, }
}

///|
pub impl @lib.Read for BarMessage with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.Reader],
) -> BarMessage raise {
  let msg = BarMessage::default()
  while (reader |> @lib.read_next_message_field()) is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, _) => msg.b_int32 = reader |> @lib.read_int32()
      _ => reader |> @lib.skip_message_field(wire)
    }
  }
  msg
}

///|
pub impl @lib.Write for BarMessage with fn write(
  self : BarMessage,
  writer : &@lib.Writer,
) -> Unit raise {
  if self.b_int32 != Default::default() {
    writer |> @lib.write_varint(8UL)
    writer |> @lib.write_int32(self.b_int32)
  }
}

///|
pub impl ToJson for BarMessage with fn to_json(self) {
  let json : Map[String, Json] = {}
  if self.b_int32 != Default::default() {
    json["bInt32"] = self.b_int32.to_json()
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for BarMessage with fn from_json(
  json : Json,
  path : @json.JsonPath,
) -> BarMessage raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError((path, "Expected an object for BarMessage"))
  }
  let message = BarMessage::default()
  for key, value in obj {
    match (key, value) {
      ("bInt32", value) => message.b_int32 = @json.from_json(value, path~)
      (key, _) => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @lib.AsyncRead for BarMessage with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.AsyncReader],
) -> BarMessage raise {
  let msg = BarMessage::default()
  while (reader |> @lib.async_read_next_message_field())
        is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, _) => msg.b_int32 = reader |> @lib.async_read_int32()
      _ => reader |> @lib.async_skip_message_field(wire)
    }
  }
  msg
}

///|
pub impl @lib.AsyncWrite for BarMessage with fn write(
  self : BarMessage,
  writer : &@lib.AsyncWriter,
) -> Unit raise {
  if self.b_int32 != Default::default() {
    writer |> @lib.async_write_varint(8UL)
    writer |> @lib.async_write_int32(self.b_int32)
  }
}

///|
pub(all) struct FooMessage_FMapEntry {
  mut key : String
  mut value : Int
} derive(Eq, Debug)

///|
pub impl @lib.Sized for FooMessage_FMapEntry with fn size_of(self) {
  let mut size = 0U
  if self.key != Default::default() {
    size += @lib.size_of_length_delimited_field(1U, @lib.size_of(self.key))
  }
  if self.value != Default::default() {
    size += @lib.size_of_field(1U, @lib.size_of(self.value))
  }
  size
}

///|
pub impl Default for FooMessage_FMapEntry with fn default() -> FooMessage_FMapEntry {
  FooMessage_FMapEntry::{ key: String::default(), value: Int::default() }
}

///|
pub fn FooMessage_FMapEntry::new(
  key : String,
  value : Int,
) -> FooMessage_FMapEntry {
  FooMessage_FMapEntry::{ key, value }
}

///|
pub impl @lib.Read for FooMessage_FMapEntry with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.Reader],
) -> FooMessage_FMapEntry raise {
  let msg = FooMessage_FMapEntry::default()
  while (reader |> @lib.read_next_message_field()) is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, _) => msg.key = reader |> @lib.read_string()
      (2, _) => msg.value = reader |> @lib.read_int32()
      _ => reader |> @lib.skip_message_field(wire)
    }
  }
  msg
}

///|
pub impl @lib.Write for FooMessage_FMapEntry with fn write(
  self : FooMessage_FMapEntry,
  writer : &@lib.Writer,
) -> Unit raise {
  if self.key != Default::default() {
    writer |> @lib.write_varint(10UL)
    writer |> @lib.write_string(self.key)
  }
  if self.value != Default::default() {
    writer |> @lib.write_varint(16UL)
    writer |> @lib.write_int32(self.value)
  }
}

///|
pub impl ToJson for FooMessage_FMapEntry with fn to_json(self) {
  let json : Map[String, Json] = {}
  if self.key != Default::default() {
    json["key"] = self.key.to_json()
  }
  if self.value != Default::default() {
    json["value"] = self.value.to_json()
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for FooMessage_FMapEntry with fn from_json(
  json : Json,
  path : @json.JsonPath,
) -> FooMessage_FMapEntry raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError(
      (path, "Expected an object for FooMessage_FMapEntry"),
    )
  }
  let message = FooMessage_FMapEntry::default()
  for key, value in obj {
    match (key, value) {
      ("key", value) => message.key = @json.from_json(value, path~)
      ("value", value) => message.value = @json.from_json(value, path~)
      (key, _) => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @lib.AsyncRead for FooMessage_FMapEntry with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.AsyncReader],
) -> FooMessage_FMapEntry raise {
  let msg = FooMessage_FMapEntry::default()
  while (reader |> @lib.async_read_next_message_field())
        is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, _) => msg.key = reader |> @lib.async_read_string()
      (2, _) => msg.value = reader |> @lib.async_read_int32()
      _ => reader |> @lib.async_skip_message_field(wire)
    }
  }
  msg
}

///|
pub impl @lib.AsyncWrite for FooMessage_FMapEntry with fn write(
  self : FooMessage_FMapEntry,
  writer : &@lib.AsyncWriter,
) -> Unit raise {
  if self.key != Default::default() {
    writer |> @lib.async_write_varint(10UL)
    writer |> @lib.async_write_string(self.key)
  }
  if self.value != Default::default() {
    writer |> @lib.async_write_varint(16UL)
    writer |> @lib.async_write_int32(self.value)
  }
}

///|
pub(all) struct FooMessage {
  mut f_int32 : Int
  mut f_int64 : Int64
  mut f_uint32 : UInt
  mut f_uint64 : UInt64
  mut f_sint32 : Int
  mut f_sint64 : Int64
  mut f_bool : Bool
  mut f_foo_enum : FooEnum
  mut f_fixed64 : UInt64
  mut f_sfixed64 : Int64
  mut f_fixed32 : UInt
  mut f_sfixed32 : Int
  mut f_double : Double
  mut f_float : Float
  mut f_bytes : Bytes
  mut f_string : String
  mut f_bar_message : BarMessage?
  mut f_repeated_int32 : Array[Int]
  mut f_repeated_packed_int32 : Array[Int]
  mut f_repeated_packed_float : Array[Float]
  mut f_baz : BazMessage?
  mut f_nested : BazMessage_Nested?
  mut f_nested_enum : BazMessage_Nested_NestedEnum
  mut f_map : Map[String, Int]
  mut f_repeated_string : Array[String]
  mut f_repeated_baz_message : Array[BazMessage]
  mut f_optional_string : String?
  mut with_json_name : String
  mut f_repeated_packed_enum : Array[FooEnum]
  mut f_repeated_unpacked_enum : Array[FooEnum]
  mut f_timestamp : @protobuf.Timestamp?
  mut f_duration : @protobuf.Duration?
  mut test_oneof : FooMessage_TestOneof
} derive(Eq, Debug)

///|
pub(all) enum FooMessage_TestOneof {
  F1(Int)
  F2(Bool)
  F3(String)
  NotSet
} derive(Eq, Debug)

///|
pub impl Default for FooMessage_TestOneof with fn default() -> FooMessage_TestOneof {
  NotSet
}

///|
pub impl @json.FromJson for FooMessage_TestOneof with fn from_json(
  json : Json,
  path : @json.JsonPath,
) -> FooMessage_TestOneof raise {
  try FooMessage_TestOneof::F1(json |> @json.from_json(path~)) catch {
    _ => ()
  } noraise {
    v => return v
  }
  try FooMessage_TestOneof::F2(json |> @json.from_json(path~)) catch {
    _ => ()
  } noraise {
    v => return v
  }
  try FooMessage_TestOneof::F3(json |> @json.from_json(path~)) catch {
    _ => ()
  } noraise {
    v => return v
  }
  FooMessage_TestOneof::NotSet
}

///|
pub impl ToJson for FooMessage_TestOneof with fn to_json(
  self : FooMessage_TestOneof,
) -> Json {
  match self {
    FooMessage_TestOneof::F1(v) => v.to_json()
    FooMessage_TestOneof::F2(v) => v.to_json()
    FooMessage_TestOneof::F3(v) => v.to_json()
    FooMessage_TestOneof::NotSet => Json::null()
  }
}

///|
pub impl @lib.Sized for FooMessage with fn size_of(self) {
  let mut size = 0U
  if self.f_int32 != Default::default() {
    size += @lib.size_of_field(1U, @lib.size_of(self.f_int32))
  }
  if self.f_int64 != Default::default() {
    size += @lib.size_of_field(1U, @lib.size_of(self.f_int64))
  }
  if self.f_uint32 != Default::default() {
    size += @lib.size_of_field(1U, @lib.size_of(self.f_uint32))
  }
  if self.f_uint64 != Default::default() {
    size += @lib.size_of_field(1U, @lib.size_of(self.f_uint64))
  }
  if self.f_sint32 != Default::default() {
    size += @lib.size_of_field(1U, @lib.size_of(self.f_sint32))
  }
  if self.f_sint64 != Default::default() {
    size += @lib.size_of_field(1U, @lib.size_of(self.f_sint64))
  }
  if self.f_bool != Default::default() {
    size += @lib.size_of_field(1U, @lib.size_of(self.f_bool))
  }
  if self.f_foo_enum != Default::default() {
    size += @lib.size_of_field(1U, @lib.size_of(self.f_foo_enum))
  }
  if self.f_fixed64 != Default::default() {
    size += @lib.size_of_field(1U, 8U)
  }
  if self.f_sfixed64 != Default::default() {
    size += @lib.size_of_field(1U, 8U)
  }
  if self.f_fixed32 != Default::default() {
    size += @lib.size_of_field(1U, 4U)
  }
  if self.f_sfixed32 != Default::default() {
    size += @lib.size_of_field(1U, 4U)
  }
  if self.f_double != Default::default() {
    size += @lib.size_of_field(1U, 8U)
  }
  if self.f_float != Default::default() {
    size += @lib.size_of_field(1U, 4U)
  }
  if self.f_bytes != Default::default() {
    size += @lib.size_of_length_delimited_field(1U, @lib.size_of(self.f_bytes))
  }
  if self.f_string != Default::default() {
    size += @lib.size_of_length_delimited_field(2U, @lib.size_of(self.f_string))
  }
  if self.f_bar_message is Some(v) {
    size += @lib.size_of_length_delimited_field(2U, @lib.size_of(v))
  }
  if !self.f_repeated_int32.is_empty() {
    size += @lib.size_of_length_delimited_field(
      2U,
      self.f_repeated_int32.iter().map(@lib.size_of).fold(init=0U, UInt::add),
    )
  }
  if !self.f_repeated_packed_int32.is_empty() {
    size += @lib.size_of_length_delimited_field(
      2U,
      self.f_repeated_packed_int32
      .iter()
      .map(@lib.size_of)
      .fold(init=0U, UInt::add),
    )
  }
  if !self.f_repeated_packed_float.is_empty() {
    size += @lib.size_of_length_delimited_field(
      2U,
      self.f_repeated_packed_float.length().reinterpret_as_uint() * 4,
    )
  }
  if self.f_baz is Some(v) {
    size += @lib.size_of_length_delimited_field(2U, @lib.size_of(v))
  }
  if self.f_nested is Some(v) {
    size += @lib.size_of_length_delimited_field(2U, @lib.size_of(v))
  }
  if self.f_nested_enum != Default::default() {
    size += @lib.size_of_field(2U, @lib.size_of(self.f_nested_enum))
  }
  for k, v in self.f_map {
    let key_size = @lib.size_of_length_delimited_field(1U, @lib.size_of(k))
    let value_size = @lib.size_of_field(1U, @lib.size_of(v))
    size += @lib.size_of_length_delimited_field(2U, key_size + value_size)
  }
  for s in self.f_repeated_string {
    size += @lib.size_of_length_delimited_field(2U, @lib.size_of(s))
  }
  for s in self.f_repeated_baz_message {
    size += @lib.size_of_length_delimited_field(2U, @lib.size_of(s))
  }
  if self.f_optional_string is Some(v) {
    size += @lib.size_of_length_delimited_field(2U, @lib.size_of(v))
  }
  if self.with_json_name != Default::default() {
    size += @lib.size_of_length_delimited_field(
      2U,
      @lib.size_of(self.with_json_name),
    )
  }
  if !self.f_repeated_packed_enum.is_empty() {
    size += @lib.size_of_length_delimited_field(
      2U,
      self.f_repeated_packed_enum
      .iter()
      .map(@lib.size_of)
      .fold(init=0U, UInt::add),
    )
  }
  for s in self.f_repeated_unpacked_enum {
    size += @lib.size_of_field(2U, @lib.size_of(s))
  }
  if self.f_timestamp is Some(v) {
    size += @lib.size_of_length_delimited_field(2U, @lib.size_of(v))
  }
  if self.f_duration is Some(v) {
    size += @lib.size_of_length_delimited_field(2U, @lib.size_of(v))
  }
  match self.test_oneof {
    F1(v) => size += @lib.size_of_field(2U, @lib.size_of(v))
    F2(v) => size += @lib.size_of_field(2U, @lib.size_of(v))
    F3(v) => size += @lib.size_of_length_delimited_field(2U, @lib.size_of(v))
    NotSet => ()
  }
  size
}

///|
pub impl Default for FooMessage with fn default() -> FooMessage {
  FooMessage::{
    f_int32: Int::default(),
    f_int64: Int64::default(),
    f_uint32: UInt::default(),
    f_uint64: UInt64::default(),
    f_sint32: Int::default(),
    f_sint64: Int64::default(),
    f_bool: Bool::default(),
    f_foo_enum: FooEnum::default(),
    f_fixed64: UInt64::default(),
    f_sfixed64: Int64::default(),
    f_fixed32: UInt::default(),
    f_sfixed32: Int::default(),
    f_double: Double::default(),
    f_float: Float::default(),
    f_bytes: Bytes::default(),
    f_string: String::default(),
    f_bar_message: None,
    f_repeated_int32: [],
    f_repeated_packed_int32: [],
    f_repeated_packed_float: [],
    f_baz: None,
    f_nested: None,
    f_nested_enum: BazMessage_Nested_NestedEnum::default(),
    f_map: {},
    f_repeated_string: [],
    f_repeated_baz_message: [],
    f_optional_string: None,
    with_json_name: String::default(),
    f_repeated_packed_enum: [],
    f_repeated_unpacked_enum: [],
    f_timestamp: None,
    f_duration: None,
    test_oneof: FooMessage_TestOneof::NotSet,
  }
}

///|
pub fn FooMessage::new(
  f_int32 : Int,
  f_int64 : Int64,
  f_uint32 : UInt,
  f_uint64 : UInt64,
  f_sint32 : Int,
  f_sint64 : Int64,
  f_bool : Bool,
  f_foo_enum : FooEnum,
  f_fixed64 : UInt64,
  f_sfixed64 : Int64,
  f_fixed32 : UInt,
  f_sfixed32 : Int,
  f_double : Double,
  f_float : Float,
  f_bytes : Bytes,
  f_string : String,
  f_bar_message? : BarMessage,
  f_repeated_int32 : Array[Int],
  f_repeated_packed_int32 : Array[Int],
  f_repeated_packed_float : Array[Float],
  f_baz? : BazMessage,
  f_nested? : BazMessage_Nested,
  f_nested_enum : BazMessage_Nested_NestedEnum,
  f_map : Map[String, Int],
  f_repeated_string : Array[String],
  f_repeated_baz_message : Array[BazMessage],
  f_optional_string? : String,
  with_json_name : String,
  f_repeated_packed_enum : Array[FooEnum],
  f_repeated_unpacked_enum : Array[FooEnum],
  f_timestamp? : @protobuf.Timestamp,
  f_duration? : @protobuf.Duration,
  test_oneof? : FooMessage_TestOneof = FooMessage_TestOneof::NotSet,
) -> FooMessage {
  FooMessage::{
    f_int32,
    f_int64,
    f_uint32,
    f_uint64,
    f_sint32,
    f_sint64,
    f_bool,
    f_foo_enum,
    f_fixed64,
    f_sfixed64,
    f_fixed32,
    f_sfixed32,
    f_double,
    f_float,
    f_bytes,
    f_string,
    f_bar_message,
    f_repeated_int32,
    f_repeated_packed_int32,
    f_repeated_packed_float,
    f_baz,
    f_nested,
    f_nested_enum,
    f_map,
    f_repeated_string,
    f_repeated_baz_message,
    f_optional_string,
    with_json_name,
    f_repeated_packed_enum,
    f_repeated_unpacked_enum,
    f_timestamp,
    f_duration,
    test_oneof,
  }
}

///|
pub impl @lib.Read for FooMessage with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.Reader],
) -> FooMessage raise {
  let msg = FooMessage::default()
  while (reader |> @lib.read_next_message_field()) is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, _) => msg.f_int32 = reader |> @lib.read_int32()
      (2, _) => msg.f_int64 = reader |> @lib.read_int64()
      (3, _) => msg.f_uint32 = reader |> @lib.read_uint32()
      (4, _) => msg.f_uint64 = reader |> @lib.read_uint64()
      (5, _) => msg.f_sint32 = (reader |> @lib.read_sint32()).0
      (6, _) => msg.f_sint64 = (reader |> @lib.read_sint64()).0
      (7, _) => msg.f_bool = reader |> @lib.read_bool()
      (8, _) =>
        msg.f_foo_enum = reader |> @lib.read_enum() |> FooEnum::from_enum
      (9, _) => msg.f_fixed64 = reader |> @lib.read_fixed64()
      (10, _) => msg.f_sfixed64 = reader |> @lib.read_sfixed64()
      (11, _) => msg.f_fixed32 = reader |> @lib.read_fixed32()
      (12, _) => msg.f_sfixed32 = reader |> @lib.read_sfixed32()
      (13, _) => msg.f_double = reader |> @lib.read_double()
      (14, _) => msg.f_float = reader |> @lib.read_float()
      (15, _) => msg.f_bytes = reader |> @lib.read_bytes()
      (16, _) => msg.f_string = reader |> @lib.read_string()
      (18, _) =>
        msg.f_bar_message = (reader |> @lib.read_message() : BarMessage) |> Some
      (19, 2) =>
        msg.f_repeated_int32.push_iter(
          (reader |> @lib.read_packed(@lib.read_int32, None)).iter(),
        )
      (19, 0) => msg.f_repeated_int32.push(reader |> @lib.read_int32())
      (20, 2) =>
        msg.f_repeated_packed_int32.push_iter(
          (reader |> @lib.read_packed(@lib.read_int32, None)).iter(),
        )
      (20, 0) => msg.f_repeated_packed_int32.push(reader |> @lib.read_int32())
      (21, 2) =>
        msg.f_repeated_packed_float.push_iter(
          (reader |> @lib.read_packed(@lib.read_float, Some(4))).iter(),
        )
      (21, 5) => msg.f_repeated_packed_float.push(reader |> @lib.read_float())
      (23, _) =>
        msg.f_baz = (reader |> @lib.read_message() : BazMessage) |> Some
      (24, _) =>
        msg.f_nested = (reader |> @lib.read_message() : BazMessage_Nested)
          |> Some
      (25, _) =>
        msg.f_nested_enum = reader
          |> @lib.read_enum()
          |> BazMessage_Nested_NestedEnum::from_enum
      (26, _) => {
        let { key, value } = (
          reader |> @lib.read_message() : FooMessage_FMapEntry)
        msg.f_map[key] = value
      }
      (30, _) => msg.f_repeated_string.push(reader |> @lib.read_string())
      (31, _) =>
        msg.f_repeated_baz_message.push(
          (reader |> @lib.read_message() : BazMessage),
        )
      (32, _) => msg.f_optional_string = reader |> @lib.read_string() |> Some
      (33, _) => msg.with_json_name = reader |> @lib.read_string()
      (34, 2) => {
        let packed = reader |> @lib.read_packed(@lib.read_enum, None)
        for item in packed {
          msg.f_repeated_packed_enum.push(FooEnum::from_enum(item))
        }
      }
      (34, 0) =>
        msg.f_repeated_packed_enum.push(
          reader |> @lib.read_enum() |> FooEnum::from_enum,
        )
      (35, 2) => {
        let packed = reader |> @lib.read_packed(@lib.read_enum, None)
        for item in packed {
          msg.f_repeated_unpacked_enum.push(FooEnum::from_enum(item))
        }
      }
      (35, 0) =>
        msg.f_repeated_unpacked_enum.push(
          reader |> @lib.read_enum() |> FooEnum::from_enum,
        )
      (36, _) =>
        msg.f_timestamp = (reader |> @lib.read_message() : @protobuf.Timestamp)
          |> Some
      (37, _) =>
        msg.f_duration = (reader |> @lib.read_message() : @protobuf.Duration)
          |> Some
      (27, _) =>
        msg.test_oneof = reader |> @lib.read_int32() |> FooMessage_TestOneof::F1
      (28, _) =>
        msg.test_oneof = reader |> @lib.read_bool() |> FooMessage_TestOneof::F2
      (29, _) =>
        msg.test_oneof = reader
          |> @lib.read_string()
          |> FooMessage_TestOneof::F3
      _ => reader |> @lib.skip_message_field(wire)
    }
  }
  msg
}

///|
pub impl @lib.Write for FooMessage with fn write(
  self : FooMessage,
  writer : &@lib.Writer,
) -> Unit raise {
  if self.f_int32 != Default::default() {
    writer |> @lib.write_varint(8UL)
    writer |> @lib.write_int32(self.f_int32)
  }
  if self.f_int64 != Default::default() {
    writer |> @lib.write_varint(16UL)
    writer |> @lib.write_int64(self.f_int64)
  }
  if self.f_uint32 != Default::default() {
    writer |> @lib.write_varint(24UL)
    writer |> @lib.write_uint32(self.f_uint32)
  }
  if self.f_uint64 != Default::default() {
    writer |> @lib.write_varint(32UL)
    writer |> @lib.write_uint64(self.f_uint64)
  }
  if self.f_sint32 != Default::default() {
    writer |> @lib.write_varint(40UL)
    writer |> @lib.write_sint32(self.f_sint32)
  }
  if self.f_sint64 != Default::default() {
    writer |> @lib.write_varint(48UL)
    writer |> @lib.write_sint64(self.f_sint64)
  }
  if self.f_bool != Default::default() {
    writer |> @lib.write_varint(56UL)
    writer |> @lib.write_bool(self.f_bool)
  }
  if self.f_foo_enum != Default::default() {
    writer |> @lib.write_varint(64UL)
    writer |> @lib.write_enum(self.f_foo_enum.to_enum())
  }
  if self.f_fixed64 != Default::default() {
    writer |> @lib.write_varint(73UL)
    writer |> @lib.write_fixed64(self.f_fixed64)
  }
  if self.f_sfixed64 != Default::default() {
    writer |> @lib.write_varint(81UL)
    writer |> @lib.write_sfixed64(self.f_sfixed64)
  }
  if self.f_fixed32 != Default::default() {
    writer |> @lib.write_varint(93UL)
    writer |> @lib.write_fixed32(self.f_fixed32)
  }
  if self.f_sfixed32 != Default::default() {
    writer |> @lib.write_varint(101UL)
    writer |> @lib.write_sfixed32(self.f_sfixed32)
  }
  if self.f_double != Default::default() {
    writer |> @lib.write_varint(105UL)
    writer |> @lib.write_double(self.f_double)
  }
  if self.f_float != Default::default() {
    writer |> @lib.write_varint(117UL)
    writer |> @lib.write_float(self.f_float)
  }
  if self.f_bytes != Default::default() {
    writer |> @lib.write_varint(122UL)
    writer |> @lib.write_bytes(self.f_bytes)
  }
  if self.f_string != Default::default() {
    writer |> @lib.write_varint(130UL)
    writer |> @lib.write_string(self.f_string)
  }
  if self.f_bar_message is Some(v) {
    writer |> @lib.write_varint(146UL)
    writer |> @lib.write_message(v)
  }
  if !self.f_repeated_int32.is_empty() {
    writer |> @lib.write_varint(154UL)
    let size = self.f_repeated_int32
      .iter()
      .map(@lib.size_of)
      .fold(init=0U, UInt::add)
    writer |> @lib.write_uint32(size)
    for item in self.f_repeated_int32 {
      writer |> @lib.write_int32(item)
    }
  }
  if !self.f_repeated_packed_int32.is_empty() {
    writer |> @lib.write_varint(162UL)
    let size = self.f_repeated_packed_int32
      .iter()
      .map(@lib.size_of)
      .fold(init=0U, UInt::add)
    writer |> @lib.write_uint32(size)
    for item in self.f_repeated_packed_int32 {
      writer |> @lib.write_int32(item)
    }
  }
  if !self.f_repeated_packed_float.is_empty() {
    writer |> @lib.write_varint(170UL)
    let size = self.f_repeated_packed_float.length().reinterpret_as_uint() * 4
    writer |> @lib.write_uint32(size)
    for item in self.f_repeated_packed_float {
      writer |> @lib.write_float(item)
    }
  }
  if self.f_baz is Some(v) {
    writer |> @lib.write_varint(186UL)
    writer |> @lib.write_message(v)
  }
  if self.f_nested is Some(v) {
    writer |> @lib.write_varint(194UL)
    writer |> @lib.write_message(v)
  }
  if self.f_nested_enum != Default::default() {
    writer |> @lib.write_varint(200UL)
    writer |> @lib.write_enum(self.f_nested_enum.to_enum())
  }
  let keys = self.f_map.keys().collect()
  for i in 0..<keys.length() {
    let k = keys[i]
    let v = self.f_map.get(k).unwrap()
    writer |> @lib.write_varint(210UL)
    let key_size = @lib.size_of_length_delimited_field(1U, @lib.size_of(k))
    let value_size = @lib.size_of_field(1U, @lib.size_of(v))
    writer |> @lib.write_uint32(key_size + value_size)
    writer |> @lib.write_varint(10UL)
    writer |> @lib.write_string(k)

    writer |> @lib.write_varint(16UL)
    writer |> @lib.write_int32(v)
  }
  for item in self.f_repeated_string {
    writer |> @lib.write_varint(242UL)
    writer |> @lib.write_string(item)
  }
  for item in self.f_repeated_baz_message {
    writer |> @lib.write_varint(250UL)
    writer |> @lib.write_message(item)
  }
  if self.f_optional_string is Some(v) {
    writer |> @lib.write_varint(258UL)
    writer |> @lib.write_string(v)
  }
  if self.with_json_name != Default::default() {
    writer |> @lib.write_varint(266UL)
    writer |> @lib.write_string(self.with_json_name)
  }
  if !self.f_repeated_packed_enum.is_empty() {
    writer |> @lib.write_varint(274UL)
    let size = self.f_repeated_packed_enum
      .iter()
      .map(@lib.size_of)
      .fold(init=0U, UInt::add)
    writer |> @lib.write_uint32(size)
    for item in self.f_repeated_packed_enum {
      writer |> @lib.write_enum(item.to_enum())
    }
  }
  for item in self.f_repeated_unpacked_enum {
    writer |> @lib.write_varint(280UL)
    writer |> @lib.write_enum(item.to_enum())
  }
  if self.f_timestamp is Some(v) {
    writer |> @lib.write_varint(290UL)
    writer |> @lib.write_message(v)
  }
  if self.f_duration is Some(v) {
    writer |> @lib.write_varint(298UL)
    writer |> @lib.write_message(v)
  }
  match self.test_oneof {
    FooMessage_TestOneof::F1(v) => {
      writer |> @lib.write_varint(216UL)
      writer |> @lib.write_int32(v)
    }
    FooMessage_TestOneof::F2(v) => {
      writer |> @lib.write_varint(224UL)
      writer |> @lib.write_bool(v)
    }
    FooMessage_TestOneof::F3(v) => {
      writer |> @lib.write_varint(234UL)
      writer |> @lib.write_string(v)
    }
    FooMessage_TestOneof::NotSet => ()
  }
}

///|
pub impl ToJson for FooMessage with fn to_json(self) {
  let json : Map[String, Json] = {}
  if self.f_int32 != Default::default() {
    json["fInt32"] = self.f_int32.to_json()
  }
  if self.f_int64 != Default::default() {
    json["fInt64"] = self.f_int64.to_json()
  }
  if self.f_uint32 != Default::default() {
    json["fUint32"] = self.f_uint32.to_json()
  }
  if self.f_uint64 != Default::default() {
    json["fUint64"] = self.f_uint64.to_json()
  }
  if self.f_sint32 != Default::default() {
    json["fSint32"] = self.f_sint32.to_json()
  }
  if self.f_sint64 != Default::default() {
    json["fSint64"] = self.f_sint64.to_json()
  }
  if self.f_bool != Default::default() {
    json["fBool"] = self.f_bool.to_json()
  }
  if self.f_foo_enum != Default::default() {
    json["fFooEnum"] = self.f_foo_enum.to_json()
  }
  if self.f_fixed64 != Default::default() {
    json["fFixed64"] = self.f_fixed64.to_json()
  }
  if self.f_sfixed64 != Default::default() {
    json["fSfixed64"] = self.f_sfixed64.to_json()
  }
  if self.f_fixed32 != Default::default() {
    json["fFixed32"] = self.f_fixed32.to_json()
  }
  if self.f_sfixed32 != Default::default() {
    json["fSfixed32"] = self.f_sfixed32.to_json()
  }
  if self.f_double != Default::default() {
    json["fDouble"] = self.f_double.to_json()
  }
  if self.f_float != Default::default() {
    json["fFloat"] = self.f_float.to_json()
  }
  if self.f_bytes != Default::default() {
    json["fBytes"] = @lib.base64_encode(self.f_bytes).to_json()
  }
  if self.f_string != Default::default() {
    json["fString"] = self.f_string.to_json()
  }
  match self.f_bar_message {
    Some(v) => json["fBarMessage"] = v.to_json()
    _ => ()
  }
  if self.f_repeated_int32 != Default::default() {
    json["fRepeatedInt32"] = self.f_repeated_int32.to_json()
  }
  if self.f_repeated_packed_int32 != Default::default() {
    json["fRepeatedPackedInt32"] = self.f_repeated_packed_int32.to_json()
  }
  if self.f_repeated_packed_float != Default::default() {
    json["fRepeatedPackedFloat"] = self.f_repeated_packed_float.to_json()
  }
  match self.f_baz {
    Some(v) => json["fBaz"] = v.to_json()
    _ => ()
  }
  match self.f_nested {
    Some(v) => json["fNested"] = v.to_json()
    _ => ()
  }
  if self.f_nested_enum != Default::default() {
    json["fNestedEnum"] = self.f_nested_enum.to_json()
  }
  if self.f_map != Default::default() {
    json["fMap"] = self.f_map.to_json()
  }
  if self.f_repeated_string != Default::default() {
    json["fRepeatedString"] = self.f_repeated_string.to_json()
  }
  if self.f_repeated_baz_message != Default::default() {
    json["fRepeatedBazMessage"] = self.f_repeated_baz_message.to_json()
  }
  match self.f_optional_string {
    Some(v) => json["fOptionalString"] = v.to_json()
    _ => ()
  }
  if self.with_json_name != Default::default() {
    json["wjn"] = self.with_json_name.to_json()
  }
  if self.f_repeated_packed_enum != Default::default() {
    json["fRepeatedPackedEnum"] = self.f_repeated_packed_enum.to_json()
  }
  if self.f_repeated_unpacked_enum != Default::default() {
    json["fRepeatedUnpackedEnum"] = self.f_repeated_unpacked_enum.to_json()
  }
  match self.f_timestamp {
    Some(v) => json["fTimestamp"] = v.to_json()
    _ => ()
  }
  match self.f_duration {
    Some(v) => json["fDuration"] = v.to_json()
    _ => ()
  }
  match self.test_oneof {
    NotSet => ()
    F1(v) => json["f1"] = v.to_json()
    F2(v) => json["f2"] = v.to_json()
    F3(v) => json["f3"] = v.to_json()
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for FooMessage with fn from_json(
  json : Json,
  path : @json.JsonPath,
) -> FooMessage raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError((path, "Expected an object for FooMessage"))
  }
  let message = FooMessage::default()
  for key, value in obj {
    match (key, value) {
      ("fInt32", value) => message.f_int32 = @json.from_json(value, path~)
      ("fInt64", value) => message.f_int64 = @json.from_json(value, path~)
      ("fUint32", value) => message.f_uint32 = @json.from_json(value, path~)
      ("fUint64", value) => message.f_uint64 = @json.from_json(value, path~)
      ("fSint32", value) => message.f_sint32 = @json.from_json(value, path~)
      ("fSint64", value) => message.f_sint64 = @json.from_json(value, path~)
      ("fBool", value) => message.f_bool = @json.from_json(value, path~)
      ("fFooEnum", value) => message.f_foo_enum = @json.from_json(value, path~)
      ("fFixed64", value) => message.f_fixed64 = @json.from_json(value, path~)
      ("fSfixed64", value) => message.f_sfixed64 = @json.from_json(value, path~)
      ("fFixed32", value) => message.f_fixed32 = @json.from_json(value, path~)
      ("fSfixed32", value) => message.f_sfixed32 = @json.from_json(value, path~)
      ("fDouble", value) => message.f_double = @json.from_json(value, path~)
      ("fFloat", Number(value, ..)) =>
        message.f_float = Float::from_double(value)
      ("fBytes", String(value)) =>
        message.f_bytes = @lib.base64_decode(value) catch {
          _ => raise @json.JsonDecodeError((path, "Invalid base64 encoding"))
        }
      ("fString", value) => message.f_string = @json.from_json(value, path~)
      ("fBarMessage", value) =>
        message.f_bar_message = Some(@json.from_json(value, path~))
      ("fRepeatedInt32", Array(value)) =>
        message.f_repeated_int32 = value.map(v => @json.from_json(v, path~))
      ("fRepeatedPackedInt32", Array(value)) =>
        message.f_repeated_packed_int32 = value.map(v => {
          @json.from_json(v, path~)
        })
      ("fRepeatedPackedFloat", Array(value)) =>
        message.f_repeated_packed_float = value.map(v => {
          Float::from_double(@json.from_json(v, path~))
        })
      ("fBaz", value) => message.f_baz = Some(@json.from_json(value, path~))
      ("fNested", value) =>
        message.f_nested = Some(@json.from_json(value, path~))
      ("fNestedEnum", value) =>
        message.f_nested_enum = @json.from_json(value, path~)
      ("fMap", _) => message.f_map = @json.from_json(value, path~)
      ("fRepeatedString", Array(value)) =>
        message.f_repeated_string = value.map(v => @json.from_json(v, path~))
      ("fRepeatedBazMessage", Array(value)) =>
        message.f_repeated_baz_message = value.map(v => {
          @json.from_json(v, path~)
        })
      ("fOptionalString", value) =>
        message.f_optional_string = Some(@json.from_json(value, path~))
      ("wjn", value) => message.with_json_name = @json.from_json(value, path~)
      ("fRepeatedPackedEnum", Array(value)) =>
        message.f_repeated_packed_enum = value.map(v => {
          @json.from_json(v, path~)
        })
      ("fRepeatedUnpackedEnum", Array(value)) =>
        message.f_repeated_unpacked_enum = value.map(v => {
          @json.from_json(v, path~)
        })
      ("fTimestamp", value) =>
        message.f_timestamp = Some(@json.from_json(value, path~))
      ("fDuration", value) =>
        message.f_duration = Some(@json.from_json(value, path~))
      ("f1", value) => message.test_oneof = @json.from_json(value, path~)
      ("f2", value) => message.test_oneof = @json.from_json(value, path~)
      ("f3", value) => message.test_oneof = @json.from_json(value, path~)
      (key, _) => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @lib.AsyncRead for FooMessage with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.AsyncReader],
) -> FooMessage raise {
  let msg = FooMessage::default()
  while (reader |> @lib.async_read_next_message_field())
        is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, _) => msg.f_int32 = reader |> @lib.async_read_int32()
      (2, _) => msg.f_int64 = reader |> @lib.async_read_int64()
      (3, _) => msg.f_uint32 = reader |> @lib.async_read_uint32()
      (4, _) => msg.f_uint64 = reader |> @lib.async_read_uint64()
      (5, _) => msg.f_sint32 = (reader |> @lib.async_read_sint32()).0
      (6, _) => msg.f_sint64 = (reader |> @lib.async_read_sint64()).0
      (7, _) => msg.f_bool = reader |> @lib.async_read_bool()
      (8, _) =>
        msg.f_foo_enum = reader |> @lib.async_read_enum() |> FooEnum::from_enum
      (9, _) => msg.f_fixed64 = reader |> @lib.async_read_fixed64()
      (10, _) => msg.f_sfixed64 = reader |> @lib.async_read_sfixed64()
      (11, _) => msg.f_fixed32 = reader |> @lib.async_read_fixed32()
      (12, _) => msg.f_sfixed32 = reader |> @lib.async_read_sfixed32()
      (13, _) => msg.f_double = reader |> @lib.async_read_double()
      (14, _) => msg.f_float = reader |> @lib.async_read_float()
      (15, _) => msg.f_bytes = reader |> @lib.async_read_bytes()
      (16, _) => msg.f_string = reader |> @lib.async_read_string()
      (18, _) =>
        msg.f_bar_message = (reader |> @lib.async_read_message() : BarMessage)
          |> Some
      (19, 2) =>
        msg.f_repeated_int32.push_iter(
          (reader |> @lib.async_read_packed(@lib.async_read_int32, None)).iter(),
        )
      (19, 0) => msg.f_repeated_int32.push(reader |> @lib.async_read_int32())
      (20, 2) =>
        msg.f_repeated_packed_int32.push_iter(
          (reader |> @lib.async_read_packed(@lib.async_read_int32, None)).iter(),
        )
      (20, 0) =>
        msg.f_repeated_packed_int32.push(reader |> @lib.async_read_int32())
      (21, 2) =>
        msg.f_repeated_packed_float.push_iter(
          (reader |> @lib.async_read_packed(@lib.async_read_float, Some(4))).iter(),
        )
      (21, 5) =>
        msg.f_repeated_packed_float.push(reader |> @lib.async_read_float())
      (23, _) =>
        msg.f_baz = (reader |> @lib.async_read_message() : BazMessage) |> Some
      (24, _) =>
        msg.f_nested = (reader |> @lib.async_read_message() : BazMessage_Nested)
          |> Some
      (25, _) =>
        msg.f_nested_enum = reader
          |> @lib.async_read_enum()
          |> BazMessage_Nested_NestedEnum::from_enum
      (26, _) => {
        let { key, value } = (
          reader |> @lib.async_read_message() : FooMessage_FMapEntry)
        msg.f_map[key] = value
      }
      (30, _) => msg.f_repeated_string.push(reader |> @lib.async_read_string())
      (31, _) =>
        msg.f_repeated_baz_message.push(
          (reader |> @lib.async_read_message() : BazMessage),
        )
      (32, _) =>
        msg.f_optional_string = reader |> @lib.async_read_string() |> Some
      (33, _) => msg.with_json_name = reader |> @lib.async_read_string()
      (34, 2) => {
        let packed = reader
          |> @lib.async_read_packed(@lib.async_read_enum, None)
        for item in packed {
          msg.f_repeated_packed_enum.push(FooEnum::from_enum(item))
        }
      }
      (34, 0) =>
        msg.f_repeated_packed_enum.push(
          reader |> @lib.async_read_enum() |> FooEnum::from_enum,
        )
      (35, 2) => {
        let packed = reader
          |> @lib.async_read_packed(@lib.async_read_enum, None)
        for item in packed {
          msg.f_repeated_unpacked_enum.push(FooEnum::from_enum(item))
        }
      }
      (35, 0) =>
        msg.f_repeated_unpacked_enum.push(
          reader |> @lib.async_read_enum() |> FooEnum::from_enum,
        )
      (36, _) =>
        msg.f_timestamp = (
            reader |> @lib.async_read_message() : @protobuf.Timestamp)
          |> Some
      (37, _) =>
        msg.f_duration = (
            reader |> @lib.async_read_message() : @protobuf.Duration)
          |> Some
      (27, _) =>
        msg.test_oneof = reader
          |> @lib.async_read_int32()
          |> FooMessage_TestOneof::F1
      (28, _) =>
        msg.test_oneof = reader
          |> @lib.async_read_bool()
          |> FooMessage_TestOneof::F2
      (29, _) =>
        msg.test_oneof = reader
          |> @lib.async_read_string()
          |> FooMessage_TestOneof::F3
      _ => reader |> @lib.async_skip_message_field(wire)
    }
  }
  msg
}

///|
pub impl @lib.AsyncWrite for FooMessage with fn write(
  self : FooMessage,
  writer : &@lib.AsyncWriter,
) -> Unit raise {
  if self.f_int32 != Default::default() {
    writer |> @lib.async_write_varint(8UL)
    writer |> @lib.async_write_int32(self.f_int32)
  }
  if self.f_int64 != Default::default() {
    writer |> @lib.async_write_varint(16UL)
    writer |> @lib.async_write_int64(self.f_int64)
  }
  if self.f_uint32 != Default::default() {
    writer |> @lib.async_write_varint(24UL)
    writer |> @lib.async_write_uint32(self.f_uint32)
  }
  if self.f_uint64 != Default::default() {
    writer |> @lib.async_write_varint(32UL)
    writer |> @lib.async_write_uint64(self.f_uint64)
  }
  if self.f_sint32 != Default::default() {
    writer |> @lib.async_write_varint(40UL)
    writer |> @lib.async_write_sint32(self.f_sint32)
  }
  if self.f_sint64 != Default::default() {
    writer |> @lib.async_write_varint(48UL)
    writer |> @lib.async_write_sint64(self.f_sint64)
  }
  if self.f_bool != Default::default() {
    writer |> @lib.async_write_varint(56UL)
    writer |> @lib.async_write_bool(self.f_bool)
  }
  if self.f_foo_enum != Default::default() {
    writer |> @lib.async_write_varint(64UL)
    writer |> @lib.async_write_enum(self.f_foo_enum.to_enum())
  }
  if self.f_fixed64 != Default::default() {
    writer |> @lib.async_write_varint(73UL)
    writer |> @lib.async_write_fixed64(self.f_fixed64)
  }
  if self.f_sfixed64 != Default::default() {
    writer |> @lib.async_write_varint(81UL)
    writer |> @lib.async_write_sfixed64(self.f_sfixed64)
  }
  if self.f_fixed32 != Default::default() {
    writer |> @lib.async_write_varint(93UL)
    writer |> @lib.async_write_fixed32(self.f_fixed32)
  }
  if self.f_sfixed32 != Default::default() {
    writer |> @lib.async_write_varint(101UL)
    writer |> @lib.async_write_sfixed32(self.f_sfixed32)
  }
  if self.f_double != Default::default() {
    writer |> @lib.async_write_varint(105UL)
    writer |> @lib.async_write_double(self.f_double)
  }
  if self.f_float != Default::default() {
    writer |> @lib.async_write_varint(117UL)
    writer |> @lib.async_write_float(self.f_float)
  }
  if self.f_bytes != Default::default() {
    writer |> @lib.async_write_varint(122UL)
    writer |> @lib.async_write_bytes(self.f_bytes)
  }
  if self.f_string != Default::default() {
    writer |> @lib.async_write_varint(130UL)
    writer |> @lib.async_write_string(self.f_string)
  }
  if self.f_bar_message is Some(v) {
    writer |> @lib.async_write_varint(146UL)
    writer |> @lib.async_write_message(v)
  }
  if !self.f_repeated_int32.is_empty() {
    writer |> @lib.async_write_varint(154UL)
    let size = self.f_repeated_int32
      .iter()
      .map(@lib.size_of)
      .fold(init=0U, UInt::add)
    writer |> @lib.async_write_uint32(size)
    for item in self.f_repeated_int32 {
      writer |> @lib.async_write_int32(item)
    }
  }
  if !self.f_repeated_packed_int32.is_empty() {
    writer |> @lib.async_write_varint(162UL)
    let size = self.f_repeated_packed_int32
      .iter()
      .map(@lib.size_of)
      .fold(init=0U, UInt::add)
    writer |> @lib.async_write_uint32(size)
    for item in self.f_repeated_packed_int32 {
      writer |> @lib.async_write_int32(item)
    }
  }
  if !self.f_repeated_packed_float.is_empty() {
    writer |> @lib.async_write_varint(170UL)
    let size = self.f_repeated_packed_float.length().reinterpret_as_uint() * 4
    writer |> @lib.async_write_uint32(size)
    for item in self.f_repeated_packed_float {
      writer |> @lib.async_write_float(item)
    }
  }
  if self.f_baz is Some(v) {
    writer |> @lib.async_write_varint(186UL)
    writer |> @lib.async_write_message(v)
  }
  if self.f_nested is Some(v) {
    writer |> @lib.async_write_varint(194UL)
    writer |> @lib.async_write_message(v)
  }
  if self.f_nested_enum != Default::default() {
    writer |> @lib.async_write_varint(200UL)
    writer |> @lib.async_write_enum(self.f_nested_enum.to_enum())
  }
  let keys = self.f_map.keys().collect()
  for i in 0..<keys.length() {
    let k = keys[i]
    let v = self.f_map.get(k).unwrap()
    writer |> @lib.async_write_varint(210UL)
    let key_size = @lib.size_of_length_delimited_field(1U, @lib.size_of(k))
    let value_size = @lib.size_of_field(1U, @lib.size_of(v))
    writer |> @lib.async_write_uint32(key_size + value_size)
    writer |> @lib.async_write_varint(10UL)
    writer |> @lib.async_write_string(k)

    writer |> @lib.async_write_varint(16UL)
    writer |> @lib.async_write_int32(v)
  }
  for item in self.f_repeated_string {
    writer |> @lib.async_write_varint(242UL)
    writer |> @lib.async_write_string(item)
  }
  for item in self.f_repeated_baz_message {
    writer |> @lib.async_write_varint(250UL)
    writer |> @lib.async_write_message(item)
  }
  if self.f_optional_string is Some(v) {
    writer |> @lib.async_write_varint(258UL)
    writer |> @lib.async_write_string(v)
  }
  if self.with_json_name != Default::default() {
    writer |> @lib.async_write_varint(266UL)
    writer |> @lib.async_write_string(self.with_json_name)
  }
  if !self.f_repeated_packed_enum.is_empty() {
    writer |> @lib.async_write_varint(274UL)
    let size = self.f_repeated_packed_enum
      .iter()
      .map(@lib.size_of)
      .fold(init=0U, UInt::add)
    writer |> @lib.async_write_uint32(size)
    for item in self.f_repeated_packed_enum {
      writer |> @lib.async_write_enum(item.to_enum())
    }
  }
  for item in self.f_repeated_unpacked_enum {
    writer |> @lib.async_write_varint(280UL)
    writer |> @lib.async_write_enum(item.to_enum())
  }
  if self.f_timestamp is Some(v) {
    writer |> @lib.async_write_varint(290UL)
    writer |> @lib.async_write_message(v)
  }
  if self.f_duration is Some(v) {
    writer |> @lib.async_write_varint(298UL)
    writer |> @lib.async_write_message(v)
  }
  match self.test_oneof {
    FooMessage_TestOneof::F1(v) => {
      writer |> @lib.async_write_varint(216UL)
      writer |> @lib.async_write_int32(v)
    }
    FooMessage_TestOneof::F2(v) => {
      writer |> @lib.async_write_varint(224UL)
      writer |> @lib.async_write_bool(v)
    }
    FooMessage_TestOneof::F3(v) => {
      writer |> @lib.async_write_varint(234UL)
      writer |> @lib.async_write_string(v)
    }
    FooMessage_TestOneof::NotSet => ()
  }
}

///|
pub(all) enum BazMessage_Nested_NestedEnum {
  Foo
  Bar
  Baz
  Unknown(@lib.Enum)
} derive(Eq, Debug)

///|
pub fn BazMessage_Nested_NestedEnum::to_enum(
  self : BazMessage_Nested_NestedEnum,
) -> @lib.Enum {
  match self {
    BazMessage_Nested_NestedEnum::Foo => 0
    BazMessage_Nested_NestedEnum::Bar => 1
    BazMessage_Nested_NestedEnum::Baz => 2
    BazMessage_Nested_NestedEnum::Unknown(value) => value
  }
}

///|
pub fn BazMessage_Nested_NestedEnum::from_enum(
  i : @lib.Enum,
) -> BazMessage_Nested_NestedEnum {
  match i.0 {
    0 => BazMessage_Nested_NestedEnum::Foo
    1 => BazMessage_Nested_NestedEnum::Bar
    2 => BazMessage_Nested_NestedEnum::Baz
    _ => BazMessage_Nested_NestedEnum::Unknown(i)
  }
}

///|
pub impl Default for BazMessage_Nested_NestedEnum with fn default() -> BazMessage_Nested_NestedEnum {
  BazMessage_Nested_NestedEnum::Foo
}

///|
pub impl @lib.Sized for BazMessage_Nested_NestedEnum with fn size_of(
  self : BazMessage_Nested_NestedEnum,
) {
  @lib.Sized::size_of(self.to_enum())
}

///|
pub impl @json.FromJson for BazMessage_Nested_NestedEnum with fn from_json(
  json : Json,
  path : @json.JsonPath,
) -> BazMessage_Nested_NestedEnum raise {
  match json {
    String("Foo") => BazMessage_Nested_NestedEnum::Foo
    String("Bar") => BazMessage_Nested_NestedEnum::Bar
    String("Baz") => BazMessage_Nested_NestedEnum::Baz
    Number(0, ..) => BazMessage_Nested_NestedEnum::Foo
    Number(1, ..) => BazMessage_Nested_NestedEnum::Bar
    Number(2, ..) => BazMessage_Nested_NestedEnum::Baz
    Number(value, ..) =>
      if value.trunc() == value {
        BazMessage_Nested_NestedEnum::Unknown(@lib.Enum(value.to_uint()))
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
pub impl ToJson for BazMessage_Nested_NestedEnum with fn to_json(
  self : BazMessage_Nested_NestedEnum,
) -> Json {
  match self {
    BazMessage_Nested_NestedEnum::Foo => "Foo"
    BazMessage_Nested_NestedEnum::Bar => "Bar"
    BazMessage_Nested_NestedEnum::Baz => "Baz"
    BazMessage_Nested_NestedEnum::Unknown(value) => value.0.to_json()
  }
}

///|
pub(all) struct BazMessage_Nested_NestedMessage {
  mut f_nested : Int
} derive(Eq, Debug)

///|
pub impl @lib.Sized for BazMessage_Nested_NestedMessage with fn size_of(self) {
  let mut size = 0U
  if self.f_nested != Default::default() {
    size += @lib.size_of_field(1U, @lib.size_of(self.f_nested))
  }
  size
}

///|
pub impl Default for BazMessage_Nested_NestedMessage with fn default() -> BazMessage_Nested_NestedMessage {
  BazMessage_Nested_NestedMessage::{ f_nested: Int::default() }
}

///|
pub fn BazMessage_Nested_NestedMessage::new(
  f_nested : Int,
) -> BazMessage_Nested_NestedMessage {
  BazMessage_Nested_NestedMessage::{ f_nested, }
}

///|
pub impl @lib.Read for BazMessage_Nested_NestedMessage with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.Reader],
) -> BazMessage_Nested_NestedMessage raise {
  let msg = BazMessage_Nested_NestedMessage::default()
  while (reader |> @lib.read_next_message_field()) is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, _) => msg.f_nested = reader |> @lib.read_int32()
      _ => reader |> @lib.skip_message_field(wire)
    }
  }
  msg
}

///|
pub impl @lib.Write for BazMessage_Nested_NestedMessage with fn write(
  self : BazMessage_Nested_NestedMessage,
  writer : &@lib.Writer,
) -> Unit raise {
  if self.f_nested != Default::default() {
    writer |> @lib.write_varint(8UL)
    writer |> @lib.write_int32(self.f_nested)
  }
}

///|
pub impl ToJson for BazMessage_Nested_NestedMessage with fn to_json(self) {
  let json : Map[String, Json] = {}
  if self.f_nested != Default::default() {
    json["fNested"] = self.f_nested.to_json()
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for BazMessage_Nested_NestedMessage with fn from_json(
  json : Json,
  path : @json.JsonPath,
) -> BazMessage_Nested_NestedMessage raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError(
      (path, "Expected an object for BazMessage_Nested_NestedMessage"),
    )
  }
  let message = BazMessage_Nested_NestedMessage::default()
  for key, value in obj {
    match (key, value) {
      ("fNested", value) => message.f_nested = @json.from_json(value, path~)
      (key, _) => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @lib.AsyncRead for BazMessage_Nested_NestedMessage with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.AsyncReader],
) -> BazMessage_Nested_NestedMessage raise {
  let msg = BazMessage_Nested_NestedMessage::default()
  while (reader |> @lib.async_read_next_message_field())
        is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, _) => msg.f_nested = reader |> @lib.async_read_int32()
      _ => reader |> @lib.async_skip_message_field(wire)
    }
  }
  msg
}

///|
pub impl @lib.AsyncWrite for BazMessage_Nested_NestedMessage with fn write(
  self : BazMessage_Nested_NestedMessage,
  writer : &@lib.AsyncWriter,
) -> Unit raise {
  if self.f_nested != Default::default() {
    writer |> @lib.async_write_varint(8UL)
    writer |> @lib.async_write_int32(self.f_nested)
  }
}

///|
pub(all) struct BazMessage_Nested {
  mut f_nested : BazMessage_Nested_NestedMessage?
} derive(Eq, Debug)

///|
pub impl @lib.Sized for BazMessage_Nested with fn size_of(self) {
  let mut size = 0U
  if self.f_nested is Some(v) {
    size += @lib.size_of_length_delimited_field(1U, @lib.size_of(v))
  }
  size
}

///|
pub impl Default for BazMessage_Nested with fn default() -> BazMessage_Nested {
  BazMessage_Nested::{ f_nested: None }
}

///|
pub fn BazMessage_Nested::new(
  f_nested? : BazMessage_Nested_NestedMessage,
) -> BazMessage_Nested {
  BazMessage_Nested::{ f_nested, }
}

///|
pub impl @lib.Read for BazMessage_Nested with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.Reader],
) -> BazMessage_Nested raise {
  let msg = BazMessage_Nested::default()
  while (reader |> @lib.read_next_message_field()) is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, _) =>
        msg.f_nested = (
            reader |> @lib.read_message() : BazMessage_Nested_NestedMessage)
          |> Some
      _ => reader |> @lib.skip_message_field(wire)
    }
  }
  msg
}

///|
pub impl @lib.Write for BazMessage_Nested with fn write(
  self : BazMessage_Nested,
  writer : &@lib.Writer,
) -> Unit raise {
  if self.f_nested is Some(v) {
    writer |> @lib.write_varint(10UL)
    writer |> @lib.write_message(v)
  }
}

///|
pub impl ToJson for BazMessage_Nested with fn to_json(self) {
  let json : Map[String, Json] = {}
  match self.f_nested {
    Some(v) => json["fNested"] = v.to_json()
    _ => ()
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for BazMessage_Nested with fn from_json(
  json : Json,
  path : @json.JsonPath,
) -> BazMessage_Nested raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError(
      (path, "Expected an object for BazMessage_Nested"),
    )
  }
  let message = BazMessage_Nested::default()
  for key, value in obj {
    match (key, value) {
      ("fNested", value) =>
        message.f_nested = Some(@json.from_json(value, path~))
      (key, _) => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @lib.AsyncRead for BazMessage_Nested with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.AsyncReader],
) -> BazMessage_Nested raise {
  let msg = BazMessage_Nested::default()
  while (reader |> @lib.async_read_next_message_field())
        is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, _) =>
        msg.f_nested = (
            reader |> @lib.async_read_message() :
            BazMessage_Nested_NestedMessage)
          |> Some
      _ => reader |> @lib.async_skip_message_field(wire)
    }
  }
  msg
}

///|
pub impl @lib.AsyncWrite for BazMessage_Nested with fn write(
  self : BazMessage_Nested,
  writer : &@lib.AsyncWriter,
) -> Unit raise {
  if self.f_nested is Some(v) {
    writer |> @lib.async_write_varint(10UL)
    writer |> @lib.async_write_message(v)
  }
}

///|
pub(all) struct BazMessage {
  mut nested : BazMessage_Nested?
  mut b_int64 : Int64
  mut b_string : String
} derive(Eq, Debug)

///|
pub impl @lib.Sized for BazMessage with fn size_of(self) {
  let mut size = 0U
  if self.nested is Some(v) {
    size += @lib.size_of_length_delimited_field(1U, @lib.size_of(v))
  }
  if self.b_int64 != Default::default() {
    size += @lib.size_of_field(1U, @lib.size_of(self.b_int64))
  }
  if self.b_string != Default::default() {
    size += @lib.size_of_length_delimited_field(1U, @lib.size_of(self.b_string))
  }
  size
}

///|
pub impl Default for BazMessage with fn default() -> BazMessage {
  BazMessage::{
    nested: None,
    b_int64: Int64::default(),
    b_string: String::default(),
  }
}

///|
pub fn BazMessage::new(
  nested? : BazMessage_Nested,
  b_int64 : Int64,
  b_string : String,
) -> BazMessage {
  BazMessage::{ nested, b_int64, b_string }
}

///|
pub impl @lib.Read for BazMessage with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.Reader],
) -> BazMessage raise {
  let msg = BazMessage::default()
  while (reader |> @lib.read_next_message_field()) is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, _) =>
        msg.nested = (reader |> @lib.read_message() : BazMessage_Nested) |> Some
      (2, _) => msg.b_int64 = reader |> @lib.read_int64()
      (3, _) => msg.b_string = reader |> @lib.read_string()
      _ => reader |> @lib.skip_message_field(wire)
    }
  }
  msg
}

///|
pub impl @lib.Write for BazMessage with fn write(
  self : BazMessage,
  writer : &@lib.Writer,
) -> Unit raise {
  if self.nested is Some(v) {
    writer |> @lib.write_varint(10UL)
    writer |> @lib.write_message(v)
  }
  if self.b_int64 != Default::default() {
    writer |> @lib.write_varint(16UL)
    writer |> @lib.write_int64(self.b_int64)
  }
  if self.b_string != Default::default() {
    writer |> @lib.write_varint(26UL)
    writer |> @lib.write_string(self.b_string)
  }
}

///|
pub impl ToJson for BazMessage with fn to_json(self) {
  let json : Map[String, Json] = {}
  match self.nested {
    Some(v) => json["nested"] = v.to_json()
    _ => ()
  }
  if self.b_int64 != Default::default() {
    json["bInt64"] = self.b_int64.to_json()
  }
  if self.b_string != Default::default() {
    json["bString"] = self.b_string.to_json()
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for BazMessage with fn from_json(
  json : Json,
  path : @json.JsonPath,
) -> BazMessage raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError((path, "Expected an object for BazMessage"))
  }
  let message = BazMessage::default()
  for key, value in obj {
    match (key, value) {
      ("nested", value) => message.nested = Some(@json.from_json(value, path~))
      ("bInt64", value) => message.b_int64 = @json.from_json(value, path~)
      ("bString", value) => message.b_string = @json.from_json(value, path~)
      (key, _) => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @lib.AsyncRead for BazMessage with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.AsyncReader],
) -> BazMessage raise {
  let msg = BazMessage::default()
  while (reader |> @lib.async_read_next_message_field())
        is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, _) =>
        msg.nested = (reader |> @lib.async_read_message() : BazMessage_Nested)
          |> Some
      (2, _) => msg.b_int64 = reader |> @lib.async_read_int64()
      (3, _) => msg.b_string = reader |> @lib.async_read_string()
      _ => reader |> @lib.async_skip_message_field(wire)
    }
  }
  msg
}

///|
pub impl @lib.AsyncWrite for BazMessage with fn write(
  self : BazMessage,
  writer : &@lib.AsyncWriter,
) -> Unit raise {
  if self.nested is Some(v) {
    writer |> @lib.async_write_varint(10UL)
    writer |> @lib.async_write_message(v)
  }
  if self.b_int64 != Default::default() {
    writer |> @lib.async_write_varint(16UL)
    writer |> @lib.async_write_int64(self.b_int64)
  }
  if self.b_string != Default::default() {
    writer |> @lib.async_write_varint(26UL)
    writer |> @lib.async_write_string(self.b_string)
  }
}

///|
pub(all) struct RepeatedMessage {
  mut bar_message : Array[BarMessage]
} derive(Eq, Debug)

///|
pub impl @lib.Sized for RepeatedMessage with fn size_of(self) {
  let mut size = 0U
  for s in self.bar_message {
    size += @lib.size_of_length_delimited_field(1U, @lib.size_of(s))
  }
  size
}

///|
pub impl Default for RepeatedMessage with fn default() -> RepeatedMessage {
  RepeatedMessage::{ bar_message: [] }
}

///|
pub fn RepeatedMessage::new(bar_message : Array[BarMessage]) -> RepeatedMessage {
  RepeatedMessage::{ bar_message, }
}

///|
pub impl @lib.Read for RepeatedMessage with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.Reader],
) -> RepeatedMessage raise {
  let msg = RepeatedMessage::default()
  while (reader |> @lib.read_next_message_field()) is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, _) =>
        msg.bar_message.push((reader |> @lib.read_message() : BarMessage))
      _ => reader |> @lib.skip_message_field(wire)
    }
  }
  msg
}

///|
pub impl @lib.Write for RepeatedMessage with fn write(
  self : RepeatedMessage,
  writer : &@lib.Writer,
) -> Unit raise {
  for item in self.bar_message {
    writer |> @lib.write_varint(10UL)
    writer |> @lib.write_message(item)
  }
}

///|
pub impl ToJson for RepeatedMessage with fn to_json(self) {
  let json : Map[String, Json] = {}
  if self.bar_message != Default::default() {
    json["barMessage"] = self.bar_message.to_json()
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for RepeatedMessage with fn from_json(
  json : Json,
  path : @json.JsonPath,
) -> RepeatedMessage raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError(
      (path, "Expected an object for RepeatedMessage"),
    )
  }
  let message = RepeatedMessage::default()
  for key, value in obj {
    match (key, value) {
      ("barMessage", Array(value)) =>
        message.bar_message = value.map(v => @json.from_json(v, path~))
      (key, _) => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @lib.AsyncRead for RepeatedMessage with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.AsyncReader],
) -> RepeatedMessage raise {
  let msg = RepeatedMessage::default()
  while (reader |> @lib.async_read_next_message_field())
        is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, _) =>
        msg.bar_message.push((reader |> @lib.async_read_message() : BarMessage))
      _ => reader |> @lib.async_skip_message_field(wire)
    }
  }
  msg
}

///|
pub impl @lib.AsyncWrite for RepeatedMessage with fn write(
  self : RepeatedMessage,
  writer : &@lib.AsyncWriter,
) -> Unit raise {
  for item in self.bar_message {
    writer |> @lib.async_write_varint(10UL)
    writer |> @lib.async_write_message(item)
  }
}

///|
pub(all) struct EmptyMessage {
  mut field : Int
} derive(Eq, Debug)

///|
pub impl @lib.Sized for EmptyMessage with fn size_of(self) {
  let mut size = 0U
  if self.field != Default::default() {
    size += @lib.size_of_field(1U, @lib.size_of(self.field))
  }
  size
}

///|
pub impl Default for EmptyMessage with fn default() -> EmptyMessage {
  EmptyMessage::{ field: Int::default() }
}

///|
pub fn EmptyMessage::new(field : Int) -> EmptyMessage {
  EmptyMessage::{ field, }
}

///|
pub impl @lib.Read for EmptyMessage with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.Reader],
) -> EmptyMessage raise {
  let msg = EmptyMessage::default()
  while (reader |> @lib.read_next_message_field()) is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, _) => msg.field = reader |> @lib.read_int32()
      _ => reader |> @lib.skip_message_field(wire)
    }
  }
  msg
}

///|
pub impl @lib.Write for EmptyMessage with fn write(
  self : EmptyMessage,
  writer : &@lib.Writer,
) -> Unit raise {
  if self.field != Default::default() {
    writer |> @lib.write_varint(8UL)
    writer |> @lib.write_int32(self.field)
  }
}

///|
pub impl ToJson for EmptyMessage with fn to_json(self) {
  let json : Map[String, Json] = {}
  if self.field != Default::default() {
    json["field"] = self.field.to_json()
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for EmptyMessage with fn from_json(
  json : Json,
  path : @json.JsonPath,
) -> EmptyMessage raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError((path, "Expected an object for EmptyMessage"))
  }
  let message = EmptyMessage::default()
  for key, value in obj {
    match (key, value) {
      ("field", value) => message.field = @json.from_json(value, path~)
      (key, _) => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @lib.AsyncRead for EmptyMessage with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.AsyncReader],
) -> EmptyMessage raise {
  let msg = EmptyMessage::default()
  while (reader |> @lib.async_read_next_message_field())
        is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, _) => msg.field = reader |> @lib.async_read_int32()
      _ => reader |> @lib.async_skip_message_field(wire)
    }
  }
  msg
}

///|
pub impl @lib.AsyncWrite for EmptyMessage with fn write(
  self : EmptyMessage,
  writer : &@lib.AsyncWriter,
) -> Unit raise {
  if self.field != Default::default() {
    writer |> @lib.async_write_varint(8UL)
    writer |> @lib.async_write_int32(self.field)
  }
}

///|
pub(all) struct EmptyMessageWithField {
  mut empty_message : EmptyMessage?
} derive(Eq, Debug)

///|
pub impl @lib.Sized for EmptyMessageWithField with fn size_of(self) {
  let mut size = 0U
  if self.empty_message is Some(v) {
    size += @lib.size_of_length_delimited_field(1U, @lib.size_of(v))
  }
  size
}

///|
pub impl Default for EmptyMessageWithField with fn default() -> EmptyMessageWithField {
  EmptyMessageWithField::{ empty_message: None }
}

///|
pub fn EmptyMessageWithField::new(
  empty_message? : EmptyMessage,
) -> EmptyMessageWithField {
  EmptyMessageWithField::{ empty_message, }
}

///|
pub impl @lib.Read for EmptyMessageWithField with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.Reader],
) -> EmptyMessageWithField raise {
  let msg = EmptyMessageWithField::default()
  while (reader |> @lib.read_next_message_field()) is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, _) =>
        msg.empty_message = (reader |> @lib.read_message() : EmptyMessage)
          |> Some
      _ => reader |> @lib.skip_message_field(wire)
    }
  }
  msg
}

///|
pub impl @lib.Write for EmptyMessageWithField with fn write(
  self : EmptyMessageWithField,
  writer : &@lib.Writer,
) -> Unit raise {
  if self.empty_message is Some(v) {
    writer |> @lib.write_varint(10UL)
    writer |> @lib.write_message(v)
  }
}

///|
pub impl ToJson for EmptyMessageWithField with fn to_json(self) {
  let json : Map[String, Json] = {}
  match self.empty_message {
    Some(v) => json["emptyMessage"] = v.to_json()
    _ => ()
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for EmptyMessageWithField with fn from_json(
  json : Json,
  path : @json.JsonPath,
) -> EmptyMessageWithField raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError(
      (path, "Expected an object for EmptyMessageWithField"),
    )
  }
  let message = EmptyMessageWithField::default()
  for key, value in obj {
    match (key, value) {
      ("emptyMessage", value) =>
        message.empty_message = Some(@json.from_json(value, path~))
      (key, _) => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @lib.AsyncRead for EmptyMessageWithField with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.AsyncReader],
) -> EmptyMessageWithField raise {
  let msg = EmptyMessageWithField::default()
  while (reader |> @lib.async_read_next_message_field())
        is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, _) =>
        msg.empty_message = (reader |> @lib.async_read_message() : EmptyMessage)
          |> Some
      _ => reader |> @lib.async_skip_message_field(wire)
    }
  }
  msg
}

///|
pub impl @lib.AsyncWrite for EmptyMessageWithField with fn write(
  self : EmptyMessageWithField,
  writer : &@lib.AsyncWriter,
) -> Unit raise {
  if self.empty_message is Some(v) {
    writer |> @lib.async_write_varint(10UL)
    writer |> @lib.async_write_message(v)
  }
}

///|
pub(all) struct OnlyOneOfField {
  mut test_oneof : OnlyOneOfField_TestOneof
} derive(Eq, Debug)

///|
pub(all) enum OnlyOneOfField_TestOneof {
  F1(Int)
  F2(Bool)
  F3(String)
  NotSet
} derive(Eq, Debug)

///|
pub impl Default for OnlyOneOfField_TestOneof with fn default() -> OnlyOneOfField_TestOneof {
  NotSet
}

///|
pub impl @json.FromJson for OnlyOneOfField_TestOneof with fn from_json(
  json : Json,
  path : @json.JsonPath,
) -> OnlyOneOfField_TestOneof raise {
  try OnlyOneOfField_TestOneof::F1(json |> @json.from_json(path~)) catch {
    _ => ()
  } noraise {
    v => return v
  }
  try OnlyOneOfField_TestOneof::F2(json |> @json.from_json(path~)) catch {
    _ => ()
  } noraise {
    v => return v
  }
  try OnlyOneOfField_TestOneof::F3(json |> @json.from_json(path~)) catch {
    _ => ()
  } noraise {
    v => return v
  }
  OnlyOneOfField_TestOneof::NotSet
}

///|
pub impl ToJson for OnlyOneOfField_TestOneof with fn to_json(
  self : OnlyOneOfField_TestOneof,
) -> Json {
  match self {
    OnlyOneOfField_TestOneof::F1(v) => v.to_json()
    OnlyOneOfField_TestOneof::F2(v) => v.to_json()
    OnlyOneOfField_TestOneof::F3(v) => v.to_json()
    OnlyOneOfField_TestOneof::NotSet => Json::null()
  }
}

///|
pub impl @lib.Sized for OnlyOneOfField with fn size_of(self) {
  let mut size = 0U
  match self.test_oneof {
    F1(v) => size += @lib.size_of_field(1U, @lib.size_of(v))
    F2(v) => size += @lib.size_of_field(1U, @lib.size_of(v))
    F3(v) => size += @lib.size_of_length_delimited_field(1U, @lib.size_of(v))
    NotSet => ()
  }
  size
}

///|
pub impl Default for OnlyOneOfField with fn default() -> OnlyOneOfField {
  OnlyOneOfField::{ test_oneof: OnlyOneOfField_TestOneof::NotSet }
}

///|
pub fn OnlyOneOfField::new(
  test_oneof? : OnlyOneOfField_TestOneof = OnlyOneOfField_TestOneof::NotSet,
) -> OnlyOneOfField {
  OnlyOneOfField::{ test_oneof, }
}

///|
pub impl @lib.Read for OnlyOneOfField with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.Reader],
) -> OnlyOneOfField raise {
  let msg = OnlyOneOfField::default()
  while (reader |> @lib.read_next_message_field()) is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, _) =>
        msg.test_oneof = reader
          |> @lib.read_int32()
          |> OnlyOneOfField_TestOneof::F1
      (2, _) =>
        msg.test_oneof = reader
          |> @lib.read_bool()
          |> OnlyOneOfField_TestOneof::F2
      (3, _) =>
        msg.test_oneof = reader
          |> @lib.read_string()
          |> OnlyOneOfField_TestOneof::F3
      _ => reader |> @lib.skip_message_field(wire)
    }
  }
  msg
}

///|
pub impl @lib.Write for OnlyOneOfField with fn write(
  self : OnlyOneOfField,
  writer : &@lib.Writer,
) -> Unit raise {
  match self.test_oneof {
    OnlyOneOfField_TestOneof::F1(v) => {
      writer |> @lib.write_varint(8UL)
      writer |> @lib.write_int32(v)
    }
    OnlyOneOfField_TestOneof::F2(v) => {
      writer |> @lib.write_varint(16UL)
      writer |> @lib.write_bool(v)
    }
    OnlyOneOfField_TestOneof::F3(v) => {
      writer |> @lib.write_varint(26UL)
      writer |> @lib.write_string(v)
    }
    OnlyOneOfField_TestOneof::NotSet => ()
  }
}

///|
pub impl ToJson for OnlyOneOfField with fn to_json(self) {
  let json : Map[String, Json] = {}
  match self.test_oneof {
    NotSet => ()
    F1(v) => json["f1"] = v.to_json()
    F2(v) => json["f2"] = v.to_json()
    F3(v) => json["f3"] = v.to_json()
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for OnlyOneOfField with fn from_json(
  json : Json,
  path : @json.JsonPath,
) -> OnlyOneOfField raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError((path, "Expected an object for OnlyOneOfField"))
  }
  let message = OnlyOneOfField::default()
  for key, value in obj {
    match (key, value) {
      ("f1", value) => message.test_oneof = @json.from_json(value, path~)
      ("f2", value) => message.test_oneof = @json.from_json(value, path~)
      ("f3", value) => message.test_oneof = @json.from_json(value, path~)
      (key, _) => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @lib.AsyncRead for OnlyOneOfField with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.AsyncReader],
) -> OnlyOneOfField raise {
  let msg = OnlyOneOfField::default()
  while (reader |> @lib.async_read_next_message_field())
        is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, _) =>
        msg.test_oneof = reader
          |> @lib.async_read_int32()
          |> OnlyOneOfField_TestOneof::F1
      (2, _) =>
        msg.test_oneof = reader
          |> @lib.async_read_bool()
          |> OnlyOneOfField_TestOneof::F2
      (3, _) =>
        msg.test_oneof = reader
          |> @lib.async_read_string()
          |> OnlyOneOfField_TestOneof::F3
      _ => reader |> @lib.async_skip_message_field(wire)
    }
  }
  msg
}

///|
pub impl @lib.AsyncWrite for OnlyOneOfField with fn write(
  self : OnlyOneOfField,
  writer : &@lib.AsyncWriter,
) -> Unit raise {
  match self.test_oneof {
    OnlyOneOfField_TestOneof::F1(v) => {
      writer |> @lib.async_write_varint(8UL)
      writer |> @lib.async_write_int32(v)
    }
    OnlyOneOfField_TestOneof::F2(v) => {
      writer |> @lib.async_write_varint(16UL)
      writer |> @lib.async_write_bool(v)
    }
    OnlyOneOfField_TestOneof::F3(v) => {
      writer |> @lib.async_write_varint(26UL)
      writer |> @lib.async_write_string(v)
    }
    OnlyOneOfField_TestOneof::NotSet => ()
  }
}
