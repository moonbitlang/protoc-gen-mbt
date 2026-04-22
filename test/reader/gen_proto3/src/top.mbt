///|
pub(all) enum FooEnum {
  FIRST_VALUE
  SECOND_VALUE
} derive(Eq, Debug)

///|
pub fn FooEnum::to_enum(self : FooEnum) -> @lib.Enum {
  match self {
    FooEnum::FIRST_VALUE => 0
    FooEnum::SECOND_VALUE => 2
  }
}

///|
pub fn FooEnum::from_enum(i : @lib.Enum) -> FooEnum {
  match i.0 {
    0 => FooEnum::FIRST_VALUE
    2 => FooEnum::SECOND_VALUE
    _ => Default::default()
  }
}

///|
pub impl Default for FooEnum with default() -> FooEnum {
  FooEnum::FIRST_VALUE
}

///|
pub impl @lib.Sized for FooEnum with size_of(self : FooEnum) {
  @lib.Sized::size_of(self.to_enum())
}

///|
pub impl @json.FromJson for FooEnum with from_json(
  json : Json,
  path : @json.JsonPath,
) -> FooEnum raise {
  match json {
    String("FIRST_VALUE") => FooEnum::FIRST_VALUE
    String("SECOND_VALUE") => FooEnum::SECOND_VALUE
    Number(0, ..) => FooEnum::FIRST_VALUE
    Number(2, ..) => FooEnum::SECOND_VALUE
    _ =>
      raise @json.JsonDecodeError(
        (path, "Expected a number or string for enum"),
      )
  }
}

///|
pub impl ToJson for FooEnum with to_json(self : FooEnum) -> Json {
  match self {
    FooEnum::FIRST_VALUE => "FIRST_VALUE"
    FooEnum::SECOND_VALUE => "SECOND_VALUE"
  }
}

///|
pub(all) struct BarMessage {
  mut b_int32 : Int
} derive(Eq, Debug)

///|
pub impl @lib.Sized for BarMessage with size_of(self) {
  let mut size = 0U
  size += 1U + @lib.size_of(self.b_int32)
  size
}

///|
pub impl Default for BarMessage with default() -> BarMessage {
  BarMessage::{ b_int32: Int::default() }
}

///|
pub fn BarMessage::new(b_int32 : Int) -> BarMessage {
  BarMessage::{ b_int32, }
}

///|
pub impl @lib.Read for BarMessage with read_with_limit(
  reader : @lib.LimitedReader[&@lib.Reader],
) -> BarMessage raise {
  let msg = BarMessage::default()
  try {
    for ;; {
      match (reader |> @lib.read_tag()) {
        (1, _) => msg.b_int32 = reader |> @lib.read_int32()
        (_, wire) => reader |> @lib.read_unknown(wire)
      }
    }
  } catch {
    @lib.EndOfStream => ()
    err => raise err
  }
  msg
}

///|
pub impl @lib.Write for BarMessage with write(
  self : BarMessage,
  writer : &@lib.Writer,
) -> Unit raise {
  writer |> @lib.write_varint(8UL)
  writer |> @lib.write_int32(self.b_int32)
}

///|
pub impl ToJson for BarMessage with to_json(self) {
  let json : Map[String, Json] = {}
  if self.b_int32 != Default::default() {
    json["bInt32"] = self.b_int32.to_json()
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for BarMessage with from_json(
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
      key => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @lib.AsyncRead for BarMessage with read_with_limit(
  reader : @lib.LimitedReader[&@lib.AsyncReader],
) -> BarMessage raise {
  let msg = BarMessage::default()
  try {
    for ;; {
      match (reader |> @lib.async_read_tag()) {
        (1, _) => msg.b_int32 = reader |> @lib.async_read_int32()
        (_, wire) => reader |> @lib.async_read_unknown(wire)
      }
    }
  } catch {
    @lib.EndOfStream => ()
    err => raise err
  }
  msg
}

///|
pub impl @lib.AsyncWrite for BarMessage with write(
  self : BarMessage,
  writer : &@lib.AsyncWriter,
) -> Unit raise {
  writer |> @lib.async_write_varint(8UL)
  writer |> @lib.async_write_int32(self.b_int32)
}

///|
pub(all) struct FooMessage_FMapEntry {
  mut key : String
  mut value : Int
} derive(Eq, Debug)

///|
pub impl @lib.Sized for FooMessage_FMapEntry with size_of(self) {
  let mut size = 0U
  size += 1U +
    ({
      let size = @lib.size_of(self.key)
      @lib.size_of(size) + size
    })
  size += 1U + @lib.size_of(self.value)
  size
}

///|
pub impl Default for FooMessage_FMapEntry with default() -> FooMessage_FMapEntry {
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
pub impl @lib.Read for FooMessage_FMapEntry with read_with_limit(
  reader : @lib.LimitedReader[&@lib.Reader],
) -> FooMessage_FMapEntry raise {
  let msg = FooMessage_FMapEntry::default()
  try {
    for ;; {
      match (reader |> @lib.read_tag()) {
        (1, _) => msg.key = reader |> @lib.read_string()
        (2, _) => msg.value = reader |> @lib.read_int32()
        (_, wire) => reader |> @lib.read_unknown(wire)
      }
    }
  } catch {
    @lib.EndOfStream => ()
    err => raise err
  }
  msg
}

///|
pub impl @lib.Write for FooMessage_FMapEntry with write(
  self : FooMessage_FMapEntry,
  writer : &@lib.Writer,
) -> Unit raise {
  writer |> @lib.write_varint(10UL)
  writer |> @lib.write_string(self.key)
  writer |> @lib.write_varint(16UL)
  writer |> @lib.write_int32(self.value)
}

///|
pub impl ToJson for FooMessage_FMapEntry with to_json(self) {
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
pub impl @json.FromJson for FooMessage_FMapEntry with from_json(
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
      key => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @lib.AsyncRead for FooMessage_FMapEntry with read_with_limit(
  reader : @lib.LimitedReader[&@lib.AsyncReader],
) -> FooMessage_FMapEntry raise {
  let msg = FooMessage_FMapEntry::default()
  try {
    for ;; {
      match (reader |> @lib.async_read_tag()) {
        (1, _) => msg.key = reader |> @lib.async_read_string()
        (2, _) => msg.value = reader |> @lib.async_read_int32()
        (_, wire) => reader |> @lib.async_read_unknown(wire)
      }
    }
  } catch {
    @lib.EndOfStream => ()
    err => raise err
  }
  msg
}

///|
pub impl @lib.AsyncWrite for FooMessage_FMapEntry with write(
  self : FooMessage_FMapEntry,
  writer : &@lib.AsyncWriter,
) -> Unit raise {
  writer |> @lib.async_write_varint(10UL)
  writer |> @lib.async_write_string(self.key)
  writer |> @lib.async_write_varint(16UL)
  writer |> @lib.async_write_int32(self.value)
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
  mut f_bar_message : BarMessage
  mut f_repeated_int32 : Array[Int]
  mut f_repeated_packed_int32 : Array[Int]
  mut f_repeated_packed_float : Array[Float]
  mut f_baz : BazMessage
  mut f_nested : BazMessage_Nested
  mut f_nested_enum : BazMessage_Nested_NestedEnum
  mut f_map : Map[String, Int]
  mut f_repeated_string : Array[String]
  mut f_repeated_baz_message : Array[BazMessage]
  mut f_optional_string : String?
  mut with_json_name : String
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
pub impl Default for FooMessage_TestOneof with default() -> FooMessage_TestOneof {
  NotSet
}

///|
pub impl @json.FromJson for FooMessage_TestOneof with from_json(
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
pub impl ToJson for FooMessage_TestOneof with to_json(
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
pub impl @lib.Sized for FooMessage with size_of(self) {
  let mut size = 0U
  size += 1U + @lib.size_of(self.f_int32)
  size += 1U + @lib.size_of(self.f_int64)
  size += 1U + @lib.size_of(self.f_uint32)
  size += 1U + @lib.size_of(self.f_uint64)
  size += 1U + @lib.size_of(self.f_sint32)
  size += 1U + @lib.size_of(self.f_sint64)
  size += 1U + @lib.size_of(self.f_bool)
  size += 1U + @lib.size_of(self.f_foo_enum)
  size += 1U + 8U
  size += 1U + 8U
  size += 1U + 4U
  size += 1U + 4U
  size += 1U + 8U
  size += 1U + 4U
  size += 1U +
    ({
      let size = @lib.size_of(self.f_bytes)
      @lib.size_of(size) + size
    })
  size += 2U +
    ({
      let size = @lib.size_of(self.f_string)
      @lib.size_of(size) + size
    })
  size += 2U +
    ({
      let size = @lib.size_of(self.f_bar_message)
      @lib.size_of(size) + size
    })
  size += 2U +
    ({
      let size = self.f_repeated_int32
        .iter()
        .map(@lib.size_of)
        .fold(init=0U, UInt::add)
      @lib.size_of(size) + size
    })
  size += 2U +
    ({
      let size = self.f_repeated_packed_int32
        .iter()
        .map(@lib.size_of)
        .fold(init=0U, UInt::add)
      @lib.size_of(size) + size
    })
  size += 2U +
    ({
      let size = self.f_repeated_packed_float.length().reinterpret_as_uint() * 4
      @lib.size_of(size) + size
    })
  size += 2U +
    ({
      let size = @lib.size_of(self.f_baz)
      @lib.size_of(size) + size
    })
  size += 2U +
    ({
      let size = @lib.size_of(self.f_nested)
      @lib.size_of(size) + size
    })
  size += 2U + @lib.size_of(self.f_nested_enum)
  for k, v in self.f_map {
    let key_size = 1U +
      ({
        let size = @lib.size_of(k)
        @lib.size_of(size) + size
      })
    let value_size = 1U + @lib.size_of(v)
    size += 2U + @lib.size_of(key_size + value_size) + key_size + value_size
  }
  for s in self.f_repeated_string {
    let s = @lib.size_of(s)
    size += 2U + @lib.size_of(s) + s
  }
  for s in self.f_repeated_baz_message {
    let s = @lib.size_of(s)
    size += 2U + @lib.size_of(s) + s
  }
  if self.f_optional_string is Some(v) {
    size += 2U +
      ({
        let size = @lib.size_of(v)
        @lib.size_of(size) + size
      })
  }
  size += 2U +
    ({
      let size = @lib.size_of(self.with_json_name)
      @lib.size_of(size) + size
    })
  match self.test_oneof {
    F1(v) => size += 2U + @lib.size_of(v)
    F2(v) => size += 2U + @lib.size_of(v)
    F3(v) =>
      size += 2U +
        ({
          let size = @lib.size_of(v)
          @lib.size_of(size) + size
        })
    NotSet => ()
  }
  size
}

///|
pub impl Default for FooMessage with default() -> FooMessage {
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
    f_bar_message: BarMessage::default(),
    f_repeated_int32: [],
    f_repeated_packed_int32: [],
    f_repeated_packed_float: [],
    f_baz: BazMessage::default(),
    f_nested: BazMessage_Nested::default(),
    f_nested_enum: BazMessage_Nested_NestedEnum::default(),
    f_map: {},
    f_repeated_string: [],
    f_repeated_baz_message: [],
    f_optional_string: None,
    with_json_name: String::default(),
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
  f_bar_message : BarMessage,
  f_repeated_int32 : Array[Int],
  f_repeated_packed_int32 : Array[Int],
  f_repeated_packed_float : Array[Float],
  f_baz : BazMessage,
  f_nested : BazMessage_Nested,
  f_nested_enum : BazMessage_Nested_NestedEnum,
  f_map : Map[String, Int],
  f_repeated_string : Array[String],
  f_repeated_baz_message : Array[BazMessage],
  f_optional_string? : String,
  with_json_name : String,
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
    test_oneof,
  }
}

///|
pub impl @lib.Read for FooMessage with read_with_limit(
  reader : @lib.LimitedReader[&@lib.Reader],
) -> FooMessage raise {
  let msg = FooMessage::default()
  try {
    for ;; {
      match (reader |> @lib.read_tag()) {
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
          msg.f_bar_message = (reader |> @lib.read_message() : BarMessage)
        (19, _) =>
          msg.f_repeated_int32.push_iter(
            (reader |> @lib.read_packed(@lib.read_int32, None)).iter(),
          )
        (20, _) =>
          msg.f_repeated_packed_int32.push_iter(
            (reader |> @lib.read_packed(@lib.read_int32, None)).iter(),
          )
        (21, _) =>
          msg.f_repeated_packed_float.push_iter(
            (reader |> @lib.read_packed(@lib.read_float, Some(4))).iter(),
          )
        (23, _) => msg.f_baz = (reader |> @lib.read_message() : BazMessage)
        (24, _) =>
          msg.f_nested = (reader |> @lib.read_message() : BazMessage_Nested)
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
        (27, _) =>
          msg.test_oneof = reader
            |> @lib.read_int32()
            |> FooMessage_TestOneof::F1
        (28, _) =>
          msg.test_oneof = reader
            |> @lib.read_bool()
            |> FooMessage_TestOneof::F2
        (29, _) =>
          msg.test_oneof = reader
            |> @lib.read_string()
            |> FooMessage_TestOneof::F3
        (_, wire) => reader |> @lib.read_unknown(wire)
      }
    }
  } catch {
    @lib.EndOfStream => ()
    err => raise err
  }
  msg
}

///|
pub impl @lib.Write for FooMessage with write(
  self : FooMessage,
  writer : &@lib.Writer,
) -> Unit raise {
  writer |> @lib.write_varint(8UL)
  writer |> @lib.write_int32(self.f_int32)
  writer |> @lib.write_varint(16UL)
  writer |> @lib.write_int64(self.f_int64)
  writer |> @lib.write_varint(24UL)
  writer |> @lib.write_uint32(self.f_uint32)
  writer |> @lib.write_varint(32UL)
  writer |> @lib.write_uint64(self.f_uint64)
  writer |> @lib.write_varint(40UL)
  writer |> @lib.write_sint32(self.f_sint32)
  writer |> @lib.write_varint(48UL)
  writer |> @lib.write_sint64(self.f_sint64)
  writer |> @lib.write_varint(56UL)
  writer |> @lib.write_bool(self.f_bool)
  writer |> @lib.write_varint(64UL)
  writer |> @lib.write_enum(self.f_foo_enum.to_enum())
  writer |> @lib.write_varint(73UL)
  writer |> @lib.write_fixed64(self.f_fixed64)
  writer |> @lib.write_varint(81UL)
  writer |> @lib.write_sfixed64(self.f_sfixed64)
  writer |> @lib.write_varint(93UL)
  writer |> @lib.write_fixed32(self.f_fixed32)
  writer |> @lib.write_varint(101UL)
  writer |> @lib.write_sfixed32(self.f_sfixed32)
  writer |> @lib.write_varint(105UL)
  writer |> @lib.write_double(self.f_double)
  writer |> @lib.write_varint(117UL)
  writer |> @lib.write_float(self.f_float)
  writer |> @lib.write_varint(122UL)
  writer |> @lib.write_bytes(self.f_bytes)
  writer |> @lib.write_varint(130UL)
  writer |> @lib.write_string(self.f_string)
  writer |> @lib.write_varint(146UL)
  writer |> @lib.write_uint32(@lib.size_of(self.f_bar_message))
  @lib.Write::write(self.f_bar_message, writer)
  writer |> @lib.write_varint(154UL)
  let size = self.f_repeated_int32
    .iter()
    .map(@lib.size_of)
    .fold(init=0U, UInt::add)
  writer |> @lib.write_uint32(size)
  for item in self.f_repeated_int32 {
    writer |> @lib.write_int32(item)
  }
  writer |> @lib.write_varint(162UL)
  let size = self.f_repeated_packed_int32
    .iter()
    .map(@lib.size_of)
    .fold(init=0U, UInt::add)
  writer |> @lib.write_uint32(size)
  for item in self.f_repeated_packed_int32 {
    writer |> @lib.write_int32(item)
  }
  writer |> @lib.write_varint(170UL)
  let size = self.f_repeated_packed_float.length().reinterpret_as_uint() * 4
  writer |> @lib.write_uint32(size)
  for item in self.f_repeated_packed_float {
    writer |> @lib.write_float(item)
  }
  writer |> @lib.write_varint(186UL)
  writer |> @lib.write_uint32(@lib.size_of(self.f_baz))
  @lib.Write::write(self.f_baz, writer)
  writer |> @lib.write_varint(194UL)
  writer |> @lib.write_uint32(@lib.size_of(self.f_nested))
  @lib.Write::write(self.f_nested, writer)
  writer |> @lib.write_varint(200UL)
  writer |> @lib.write_enum(self.f_nested_enum.to_enum())
  let keys = self.f_map.keys().collect()
  for i in 0..<keys.length() {
    let k = keys[i]
    let v = self.f_map.get(k).unwrap()
    writer |> @lib.write_varint(210UL)
    let key_size = 1U +
      ({
        let size = @lib.size_of(k)
        @lib.size_of(size) + size
      })
    let value_size = 1U + @lib.size_of(v)
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
    writer |> @lib.write_uint32(@lib.size_of(item))
    @lib.Write::write(item, writer)
  }
  if self.f_optional_string is Some(v) {
    writer |> @lib.write_varint(258UL)
    writer |> @lib.write_string(v)
  }
  writer |> @lib.write_varint(266UL)
  writer |> @lib.write_string(self.with_json_name)
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
pub impl ToJson for FooMessage with to_json(self) {
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
  if self.f_bar_message != Default::default() {
    json["fBarMessage"] = self.f_bar_message.to_json()
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
  if self.f_baz != Default::default() {
    json["fBaz"] = self.f_baz.to_json()
  }
  if self.f_nested != Default::default() {
    json["fNested"] = self.f_nested.to_json()
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
  match self.test_oneof {
    NotSet => ()
    F1(v) => json["f1"] = v.to_json()
    F2(v) => json["f2"] = v.to_json()
    F3(v) => json["f3"] = v.to_json()
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for FooMessage with from_json(
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
      ("fBytes", String(value)) => message.f_bytes = @lib.base64_decode(value)
      ("fString", value) => message.f_string = @json.from_json(value, path~)
      ("fBarMessage", value) =>
        message.f_bar_message = @json.from_json(value, path~)
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
      ("fBaz", value) => message.f_baz = @json.from_json(value, path~)
      ("fNested", value) => message.f_nested = @json.from_json(value, path~)
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
      ("f1", value) => message.test_oneof = @json.from_json(value, path~)
      ("f2", value) => message.test_oneof = @json.from_json(value, path~)
      ("f3", value) => message.test_oneof = @json.from_json(value, path~)
      key => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @lib.AsyncRead for FooMessage with read_with_limit(
  reader : @lib.LimitedReader[&@lib.AsyncReader],
) -> FooMessage raise {
  let msg = FooMessage::default()
  try {
    for ;; {
      match (reader |> @lib.async_read_tag()) {
        (1, _) => msg.f_int32 = reader |> @lib.async_read_int32()
        (2, _) => msg.f_int64 = reader |> @lib.async_read_int64()
        (3, _) => msg.f_uint32 = reader |> @lib.async_read_uint32()
        (4, _) => msg.f_uint64 = reader |> @lib.async_read_uint64()
        (5, _) => msg.f_sint32 = (reader |> @lib.async_read_sint32()).0
        (6, _) => msg.f_sint64 = (reader |> @lib.async_read_sint64()).0
        (7, _) => msg.f_bool = reader |> @lib.async_read_bool()
        (8, _) =>
          msg.f_foo_enum = reader
            |> @lib.async_read_enum()
            |> FooEnum::from_enum
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
        (19, _) =>
          msg.f_repeated_int32.push_iter(
            (reader |> @lib.async_read_packed(@lib.async_read_int32, None)).iter(),
          )
        (20, _) =>
          msg.f_repeated_packed_int32.push_iter(
            (reader |> @lib.async_read_packed(@lib.async_read_int32, None)).iter(),
          )
        (21, _) =>
          msg.f_repeated_packed_float.push_iter(
            (reader |> @lib.async_read_packed(@lib.async_read_float, Some(4))).iter(),
          )
        (23, _) =>
          msg.f_baz = (reader |> @lib.async_read_message() : BazMessage)
        (24, _) =>
          msg.f_nested = (
            reader |> @lib.async_read_message() : BazMessage_Nested)
        (25, _) =>
          msg.f_nested_enum = reader
            |> @lib.async_read_enum()
            |> BazMessage_Nested_NestedEnum::from_enum
        (26, _) => {
          let { key, value } = (
            reader |> @lib.async_read_message() : FooMessage_FMapEntry)
          msg.f_map[key] = value
        }
        (30, _) =>
          msg.f_repeated_string.push(reader |> @lib.async_read_string())
        (31, _) =>
          msg.f_repeated_baz_message.push(
            (reader |> @lib.async_read_message() : BazMessage),
          )
        (32, _) =>
          msg.f_optional_string = reader |> @lib.async_read_string() |> Some
        (33, _) => msg.with_json_name = reader |> @lib.async_read_string()
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
        (_, wire) => reader |> @lib.async_read_unknown(wire)
      }
    }
  } catch {
    @lib.EndOfStream => ()
    err => raise err
  }
  msg
}

///|
pub impl @lib.AsyncWrite for FooMessage with write(
  self : FooMessage,
  writer : &@lib.AsyncWriter,
) -> Unit raise {
  writer |> @lib.async_write_varint(8UL)
  writer |> @lib.async_write_int32(self.f_int32)
  writer |> @lib.async_write_varint(16UL)
  writer |> @lib.async_write_int64(self.f_int64)
  writer |> @lib.async_write_varint(24UL)
  writer |> @lib.async_write_uint32(self.f_uint32)
  writer |> @lib.async_write_varint(32UL)
  writer |> @lib.async_write_uint64(self.f_uint64)
  writer |> @lib.async_write_varint(40UL)
  writer |> @lib.async_write_sint32(self.f_sint32)
  writer |> @lib.async_write_varint(48UL)
  writer |> @lib.async_write_sint64(self.f_sint64)
  writer |> @lib.async_write_varint(56UL)
  writer |> @lib.async_write_bool(self.f_bool)
  writer |> @lib.async_write_varint(64UL)
  writer |> @lib.async_write_enum(self.f_foo_enum.to_enum())
  writer |> @lib.async_write_varint(73UL)
  writer |> @lib.async_write_fixed64(self.f_fixed64)
  writer |> @lib.async_write_varint(81UL)
  writer |> @lib.async_write_sfixed64(self.f_sfixed64)
  writer |> @lib.async_write_varint(93UL)
  writer |> @lib.async_write_fixed32(self.f_fixed32)
  writer |> @lib.async_write_varint(101UL)
  writer |> @lib.async_write_sfixed32(self.f_sfixed32)
  writer |> @lib.async_write_varint(105UL)
  writer |> @lib.async_write_double(self.f_double)
  writer |> @lib.async_write_varint(117UL)
  writer |> @lib.async_write_float(self.f_float)
  writer |> @lib.async_write_varint(122UL)
  writer |> @lib.async_write_bytes(self.f_bytes)
  writer |> @lib.async_write_varint(130UL)
  writer |> @lib.async_write_string(self.f_string)
  writer |> @lib.async_write_varint(146UL)
  writer |> @lib.async_write_uint32(@lib.size_of(self.f_bar_message))
  @lib.AsyncWrite::write(self.f_bar_message, writer)
  writer |> @lib.async_write_varint(154UL)
  let size = self.f_repeated_int32
    .iter()
    .map(@lib.size_of)
    .fold(init=0U, UInt::add)
  writer |> @lib.async_write_uint32(size)
  for item in self.f_repeated_int32 {
    writer |> @lib.async_write_int32(item)
  }
  writer |> @lib.async_write_varint(162UL)
  let size = self.f_repeated_packed_int32
    .iter()
    .map(@lib.size_of)
    .fold(init=0U, UInt::add)
  writer |> @lib.async_write_uint32(size)
  for item in self.f_repeated_packed_int32 {
    writer |> @lib.async_write_int32(item)
  }
  writer |> @lib.async_write_varint(170UL)
  let size = self.f_repeated_packed_float.length().reinterpret_as_uint() * 4
  writer |> @lib.async_write_uint32(size)
  for item in self.f_repeated_packed_float {
    writer |> @lib.async_write_float(item)
  }
  writer |> @lib.async_write_varint(186UL)
  writer |> @lib.async_write_uint32(@lib.size_of(self.f_baz))
  @lib.AsyncWrite::write(self.f_baz, writer)
  writer |> @lib.async_write_varint(194UL)
  writer |> @lib.async_write_uint32(@lib.size_of(self.f_nested))
  @lib.AsyncWrite::write(self.f_nested, writer)
  writer |> @lib.async_write_varint(200UL)
  writer |> @lib.async_write_enum(self.f_nested_enum.to_enum())
  let keys = self.f_map.keys().collect()
  for i in 0..<keys.length() {
    let k = keys[i]
    let v = self.f_map.get(k).unwrap()
    writer |> @lib.async_write_varint(210UL)
    let key_size = 1U +
      ({
        let size = @lib.size_of(k)
        @lib.size_of(size) + size
      })
    let value_size = 1U + @lib.size_of(v)
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
    writer |> @lib.async_write_uint32(@lib.size_of(item))
    @lib.AsyncWrite::write(item, writer)
  }
  if self.f_optional_string is Some(v) {
    writer |> @lib.async_write_varint(258UL)
    writer |> @lib.async_write_string(v)
  }
  writer |> @lib.async_write_varint(266UL)
  writer |> @lib.async_write_string(self.with_json_name)
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
} derive(Eq, Debug)

///|
pub fn BazMessage_Nested_NestedEnum::to_enum(
  self : BazMessage_Nested_NestedEnum,
) -> @lib.Enum {
  match self {
    BazMessage_Nested_NestedEnum::Foo => 0
    BazMessage_Nested_NestedEnum::Bar => 1
    BazMessage_Nested_NestedEnum::Baz => 2
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
    _ => Default::default()
  }
}

///|
pub impl Default for BazMessage_Nested_NestedEnum with default() -> BazMessage_Nested_NestedEnum {
  BazMessage_Nested_NestedEnum::Foo
}

///|
pub impl @lib.Sized for BazMessage_Nested_NestedEnum with size_of(
  self : BazMessage_Nested_NestedEnum,
) {
  @lib.Sized::size_of(self.to_enum())
}

///|
pub impl @json.FromJson for BazMessage_Nested_NestedEnum with from_json(
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
    _ =>
      raise @json.JsonDecodeError(
        (path, "Expected a number or string for enum"),
      )
  }
}

///|
pub impl ToJson for BazMessage_Nested_NestedEnum with to_json(
  self : BazMessage_Nested_NestedEnum,
) -> Json {
  match self {
    BazMessage_Nested_NestedEnum::Foo => "Foo"
    BazMessage_Nested_NestedEnum::Bar => "Bar"
    BazMessage_Nested_NestedEnum::Baz => "Baz"
  }
}

///|
pub(all) struct BazMessage_Nested_NestedMessage {
  mut f_nested : Int
} derive(Eq, Debug)

///|
pub impl @lib.Sized for BazMessage_Nested_NestedMessage with size_of(self) {
  let mut size = 0U
  size += 1U + @lib.size_of(self.f_nested)
  size
}

///|
pub impl Default for BazMessage_Nested_NestedMessage with default() -> BazMessage_Nested_NestedMessage {
  BazMessage_Nested_NestedMessage::{ f_nested: Int::default() }
}

///|
pub fn BazMessage_Nested_NestedMessage::new(
  f_nested : Int,
) -> BazMessage_Nested_NestedMessage {
  BazMessage_Nested_NestedMessage::{ f_nested, }
}

///|
pub impl @lib.Read for BazMessage_Nested_NestedMessage with read_with_limit(
  reader : @lib.LimitedReader[&@lib.Reader],
) -> BazMessage_Nested_NestedMessage raise {
  let msg = BazMessage_Nested_NestedMessage::default()
  try {
    for ;; {
      match (reader |> @lib.read_tag()) {
        (1, _) => msg.f_nested = reader |> @lib.read_int32()
        (_, wire) => reader |> @lib.read_unknown(wire)
      }
    }
  } catch {
    @lib.EndOfStream => ()
    err => raise err
  }
  msg
}

///|
pub impl @lib.Write for BazMessage_Nested_NestedMessage with write(
  self : BazMessage_Nested_NestedMessage,
  writer : &@lib.Writer,
) -> Unit raise {
  writer |> @lib.write_varint(8UL)
  writer |> @lib.write_int32(self.f_nested)
}

///|
pub impl ToJson for BazMessage_Nested_NestedMessage with to_json(self) {
  let json : Map[String, Json] = {}
  if self.f_nested != Default::default() {
    json["fNested"] = self.f_nested.to_json()
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for BazMessage_Nested_NestedMessage with from_json(
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
      key => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @lib.AsyncRead for BazMessage_Nested_NestedMessage with read_with_limit(
  reader : @lib.LimitedReader[&@lib.AsyncReader],
) -> BazMessage_Nested_NestedMessage raise {
  let msg = BazMessage_Nested_NestedMessage::default()
  try {
    for ;; {
      match (reader |> @lib.async_read_tag()) {
        (1, _) => msg.f_nested = reader |> @lib.async_read_int32()
        (_, wire) => reader |> @lib.async_read_unknown(wire)
      }
    }
  } catch {
    @lib.EndOfStream => ()
    err => raise err
  }
  msg
}

///|
pub impl @lib.AsyncWrite for BazMessage_Nested_NestedMessage with write(
  self : BazMessage_Nested_NestedMessage,
  writer : &@lib.AsyncWriter,
) -> Unit raise {
  writer |> @lib.async_write_varint(8UL)
  writer |> @lib.async_write_int32(self.f_nested)
}

///|
pub(all) struct BazMessage_Nested {
  mut f_nested : BazMessage_Nested_NestedMessage
} derive(Eq, Debug)

///|
pub impl @lib.Sized for BazMessage_Nested with size_of(self) {
  let mut size = 0U
  size += 1U +
    ({
      let size = @lib.size_of(self.f_nested)
      @lib.size_of(size) + size
    })
  size
}

///|
pub impl Default for BazMessage_Nested with default() -> BazMessage_Nested {
  BazMessage_Nested::{ f_nested: BazMessage_Nested_NestedMessage::default() }
}

///|
pub fn BazMessage_Nested::new(
  f_nested : BazMessage_Nested_NestedMessage,
) -> BazMessage_Nested {
  BazMessage_Nested::{ f_nested, }
}

///|
pub impl @lib.Read for BazMessage_Nested with read_with_limit(
  reader : @lib.LimitedReader[&@lib.Reader],
) -> BazMessage_Nested raise {
  let msg = BazMessage_Nested::default()
  try {
    for ;; {
      match (reader |> @lib.read_tag()) {
        (1, _) =>
          msg.f_nested = (
            reader |> @lib.read_message() : BazMessage_Nested_NestedMessage)
        (_, wire) => reader |> @lib.read_unknown(wire)
      }
    }
  } catch {
    @lib.EndOfStream => ()
    err => raise err
  }
  msg
}

///|
pub impl @lib.Write for BazMessage_Nested with write(
  self : BazMessage_Nested,
  writer : &@lib.Writer,
) -> Unit raise {
  writer |> @lib.write_varint(10UL)
  writer |> @lib.write_uint32(@lib.size_of(self.f_nested))
  @lib.Write::write(self.f_nested, writer)
}

///|
pub impl ToJson for BazMessage_Nested with to_json(self) {
  let json : Map[String, Json] = {}
  if self.f_nested != Default::default() {
    json["fNested"] = self.f_nested.to_json()
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for BazMessage_Nested with from_json(
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
      ("fNested", value) => message.f_nested = @json.from_json(value, path~)
      key => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @lib.AsyncRead for BazMessage_Nested with read_with_limit(
  reader : @lib.LimitedReader[&@lib.AsyncReader],
) -> BazMessage_Nested raise {
  let msg = BazMessage_Nested::default()
  try {
    for ;; {
      match (reader |> @lib.async_read_tag()) {
        (1, _) =>
          msg.f_nested = (
            reader |> @lib.async_read_message() :
            BazMessage_Nested_NestedMessage)
        (_, wire) => reader |> @lib.async_read_unknown(wire)
      }
    }
  } catch {
    @lib.EndOfStream => ()
    err => raise err
  }
  msg
}

///|
pub impl @lib.AsyncWrite for BazMessage_Nested with write(
  self : BazMessage_Nested,
  writer : &@lib.AsyncWriter,
) -> Unit raise {
  writer |> @lib.async_write_varint(10UL)
  writer |> @lib.async_write_uint32(@lib.size_of(self.f_nested))
  @lib.AsyncWrite::write(self.f_nested, writer)
}

///|
pub(all) struct BazMessage {
  mut nested : BazMessage_Nested
  mut b_int64 : Int64
  mut b_string : String
} derive(Eq, Debug)

///|
pub impl @lib.Sized for BazMessage with size_of(self) {
  let mut size = 0U
  size += 1U +
    ({
      let size = @lib.size_of(self.nested)
      @lib.size_of(size) + size
    })
  size += 1U + @lib.size_of(self.b_int64)
  size += 1U +
    ({
      let size = @lib.size_of(self.b_string)
      @lib.size_of(size) + size
    })
  size
}

///|
pub impl Default for BazMessage with default() -> BazMessage {
  BazMessage::{
    nested: BazMessage_Nested::default(),
    b_int64: Int64::default(),
    b_string: String::default(),
  }
}

///|
pub fn BazMessage::new(
  nested : BazMessage_Nested,
  b_int64 : Int64,
  b_string : String,
) -> BazMessage {
  BazMessage::{ nested, b_int64, b_string }
}

///|
pub impl @lib.Read for BazMessage with read_with_limit(
  reader : @lib.LimitedReader[&@lib.Reader],
) -> BazMessage raise {
  let msg = BazMessage::default()
  try {
    for ;; {
      match (reader |> @lib.read_tag()) {
        (1, _) =>
          msg.nested = (reader |> @lib.read_message() : BazMessage_Nested)
        (2, _) => msg.b_int64 = reader |> @lib.read_int64()
        (3, _) => msg.b_string = reader |> @lib.read_string()
        (_, wire) => reader |> @lib.read_unknown(wire)
      }
    }
  } catch {
    @lib.EndOfStream => ()
    err => raise err
  }
  msg
}

///|
pub impl @lib.Write for BazMessage with write(
  self : BazMessage,
  writer : &@lib.Writer,
) -> Unit raise {
  writer |> @lib.write_varint(10UL)
  writer |> @lib.write_uint32(@lib.size_of(self.nested))
  @lib.Write::write(self.nested, writer)
  writer |> @lib.write_varint(16UL)
  writer |> @lib.write_int64(self.b_int64)
  writer |> @lib.write_varint(26UL)
  writer |> @lib.write_string(self.b_string)
}

///|
pub impl ToJson for BazMessage with to_json(self) {
  let json : Map[String, Json] = {}
  if self.nested != Default::default() {
    json["nested"] = self.nested.to_json()
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
pub impl @json.FromJson for BazMessage with from_json(
  json : Json,
  path : @json.JsonPath,
) -> BazMessage raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError((path, "Expected an object for BazMessage"))
  }
  let message = BazMessage::default()
  for key, value in obj {
    match (key, value) {
      ("nested", value) => message.nested = @json.from_json(value, path~)
      ("bInt64", value) => message.b_int64 = @json.from_json(value, path~)
      ("bString", value) => message.b_string = @json.from_json(value, path~)
      key => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @lib.AsyncRead for BazMessage with read_with_limit(
  reader : @lib.LimitedReader[&@lib.AsyncReader],
) -> BazMessage raise {
  let msg = BazMessage::default()
  try {
    for ;; {
      match (reader |> @lib.async_read_tag()) {
        (1, _) =>
          msg.nested = (reader |> @lib.async_read_message() : BazMessage_Nested)
        (2, _) => msg.b_int64 = reader |> @lib.async_read_int64()
        (3, _) => msg.b_string = reader |> @lib.async_read_string()
        (_, wire) => reader |> @lib.async_read_unknown(wire)
      }
    }
  } catch {
    @lib.EndOfStream => ()
    err => raise err
  }
  msg
}

///|
pub impl @lib.AsyncWrite for BazMessage with write(
  self : BazMessage,
  writer : &@lib.AsyncWriter,
) -> Unit raise {
  writer |> @lib.async_write_varint(10UL)
  writer |> @lib.async_write_uint32(@lib.size_of(self.nested))
  @lib.AsyncWrite::write(self.nested, writer)
  writer |> @lib.async_write_varint(16UL)
  writer |> @lib.async_write_int64(self.b_int64)
  writer |> @lib.async_write_varint(26UL)
  writer |> @lib.async_write_string(self.b_string)
}

///|
pub(all) struct RepeatedMessage {
  mut bar_message : Array[BarMessage]
} derive(Eq, Debug)

///|
pub impl @lib.Sized for RepeatedMessage with size_of(self) {
  let mut size = 0U
  for s in self.bar_message {
    let s = @lib.size_of(s)
    size += 1U + @lib.size_of(s) + s
  }
  size
}

///|
pub impl Default for RepeatedMessage with default() -> RepeatedMessage {
  RepeatedMessage::{ bar_message: [] }
}

///|
pub fn RepeatedMessage::new(bar_message : Array[BarMessage]) -> RepeatedMessage {
  RepeatedMessage::{ bar_message, }
}

///|
pub impl @lib.Read for RepeatedMessage with read_with_limit(
  reader : @lib.LimitedReader[&@lib.Reader],
) -> RepeatedMessage raise {
  let msg = RepeatedMessage::default()
  try {
    for ;; {
      match (reader |> @lib.read_tag()) {
        (1, _) =>
          msg.bar_message.push((reader |> @lib.read_message() : BarMessage))
        (_, wire) => reader |> @lib.read_unknown(wire)
      }
    }
  } catch {
    @lib.EndOfStream => ()
    err => raise err
  }
  msg
}

///|
pub impl @lib.Write for RepeatedMessage with write(
  self : RepeatedMessage,
  writer : &@lib.Writer,
) -> Unit raise {
  for item in self.bar_message {
    writer |> @lib.write_varint(10UL)
    writer |> @lib.write_uint32(@lib.size_of(item))
    @lib.Write::write(item, writer)
  }
}

///|
pub impl ToJson for RepeatedMessage with to_json(self) {
  let json : Map[String, Json] = {}
  if self.bar_message != Default::default() {
    json["barMessage"] = self.bar_message.to_json()
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for RepeatedMessage with from_json(
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
      key => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @lib.AsyncRead for RepeatedMessage with read_with_limit(
  reader : @lib.LimitedReader[&@lib.AsyncReader],
) -> RepeatedMessage raise {
  let msg = RepeatedMessage::default()
  try {
    for ;; {
      match (reader |> @lib.async_read_tag()) {
        (1, _) =>
          msg.bar_message.push(
            (reader |> @lib.async_read_message() : BarMessage),
          )
        (_, wire) => reader |> @lib.async_read_unknown(wire)
      }
    }
  } catch {
    @lib.EndOfStream => ()
    err => raise err
  }
  msg
}

///|
pub impl @lib.AsyncWrite for RepeatedMessage with write(
  self : RepeatedMessage,
  writer : &@lib.AsyncWriter,
) -> Unit raise {
  for item in self.bar_message {
    writer |> @lib.async_write_varint(10UL)
    writer |> @lib.async_write_uint32(@lib.size_of(item))
    @lib.AsyncWrite::write(item, writer)
  }
}

///|
pub(all) struct EmptyMessage {
  mut field : Int
} derive(Eq, Debug)

///|
pub impl @lib.Sized for EmptyMessage with size_of(self) {
  let mut size = 0U
  size += 1U + @lib.size_of(self.field)
  size
}

///|
pub impl Default for EmptyMessage with default() -> EmptyMessage {
  EmptyMessage::{ field: Int::default() }
}

///|
pub fn EmptyMessage::new(field : Int) -> EmptyMessage {
  EmptyMessage::{ field, }
}

///|
pub impl @lib.Read for EmptyMessage with read_with_limit(
  reader : @lib.LimitedReader[&@lib.Reader],
) -> EmptyMessage raise {
  let msg = EmptyMessage::default()
  try {
    for ;; {
      match (reader |> @lib.read_tag()) {
        (1, _) => msg.field = reader |> @lib.read_int32()
        (_, wire) => reader |> @lib.read_unknown(wire)
      }
    }
  } catch {
    @lib.EndOfStream => ()
    err => raise err
  }
  msg
}

///|
pub impl @lib.Write for EmptyMessage with write(
  self : EmptyMessage,
  writer : &@lib.Writer,
) -> Unit raise {
  writer |> @lib.write_varint(8UL)
  writer |> @lib.write_int32(self.field)
}

///|
pub impl ToJson for EmptyMessage with to_json(self) {
  let json : Map[String, Json] = {}
  if self.field != Default::default() {
    json["field"] = self.field.to_json()
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for EmptyMessage with from_json(
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
      key => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @lib.AsyncRead for EmptyMessage with read_with_limit(
  reader : @lib.LimitedReader[&@lib.AsyncReader],
) -> EmptyMessage raise {
  let msg = EmptyMessage::default()
  try {
    for ;; {
      match (reader |> @lib.async_read_tag()) {
        (1, _) => msg.field = reader |> @lib.async_read_int32()
        (_, wire) => reader |> @lib.async_read_unknown(wire)
      }
    }
  } catch {
    @lib.EndOfStream => ()
    err => raise err
  }
  msg
}

///|
pub impl @lib.AsyncWrite for EmptyMessage with write(
  self : EmptyMessage,
  writer : &@lib.AsyncWriter,
) -> Unit raise {
  writer |> @lib.async_write_varint(8UL)
  writer |> @lib.async_write_int32(self.field)
}

///|
pub(all) struct EmptyMessageWithField {
  mut empty_message : EmptyMessage
} derive(Eq, Debug)

///|
pub impl @lib.Sized for EmptyMessageWithField with size_of(self) {
  let mut size = 0U
  size += 1U +
    ({
      let size = @lib.size_of(self.empty_message)
      @lib.size_of(size) + size
    })
  size
}

///|
pub impl Default for EmptyMessageWithField with default() -> EmptyMessageWithField {
  EmptyMessageWithField::{ empty_message: EmptyMessage::default() }
}

///|
pub fn EmptyMessageWithField::new(
  empty_message : EmptyMessage,
) -> EmptyMessageWithField {
  EmptyMessageWithField::{ empty_message, }
}

///|
pub impl @lib.Read for EmptyMessageWithField with read_with_limit(
  reader : @lib.LimitedReader[&@lib.Reader],
) -> EmptyMessageWithField raise {
  let msg = EmptyMessageWithField::default()
  try {
    for ;; {
      match (reader |> @lib.read_tag()) {
        (1, _) =>
          msg.empty_message = (reader |> @lib.read_message() : EmptyMessage)
        (_, wire) => reader |> @lib.read_unknown(wire)
      }
    }
  } catch {
    @lib.EndOfStream => ()
    err => raise err
  }
  msg
}

///|
pub impl @lib.Write for EmptyMessageWithField with write(
  self : EmptyMessageWithField,
  writer : &@lib.Writer,
) -> Unit raise {
  writer |> @lib.write_varint(10UL)
  writer |> @lib.write_uint32(@lib.size_of(self.empty_message))
  @lib.Write::write(self.empty_message, writer)
}

///|
pub impl ToJson for EmptyMessageWithField with to_json(self) {
  let json : Map[String, Json] = {}
  if self.empty_message != Default::default() {
    json["emptyMessage"] = self.empty_message.to_json()
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for EmptyMessageWithField with from_json(
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
        message.empty_message = @json.from_json(value, path~)
      key => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @lib.AsyncRead for EmptyMessageWithField with read_with_limit(
  reader : @lib.LimitedReader[&@lib.AsyncReader],
) -> EmptyMessageWithField raise {
  let msg = EmptyMessageWithField::default()
  try {
    for ;; {
      match (reader |> @lib.async_read_tag()) {
        (1, _) =>
          msg.empty_message = (
            reader |> @lib.async_read_message() : EmptyMessage)
        (_, wire) => reader |> @lib.async_read_unknown(wire)
      }
    }
  } catch {
    @lib.EndOfStream => ()
    err => raise err
  }
  msg
}

///|
pub impl @lib.AsyncWrite for EmptyMessageWithField with write(
  self : EmptyMessageWithField,
  writer : &@lib.AsyncWriter,
) -> Unit raise {
  writer |> @lib.async_write_varint(10UL)
  writer |> @lib.async_write_uint32(@lib.size_of(self.empty_message))
  @lib.AsyncWrite::write(self.empty_message, writer)
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
pub impl Default for OnlyOneOfField_TestOneof with default() -> OnlyOneOfField_TestOneof {
  NotSet
}

///|
pub impl @json.FromJson for OnlyOneOfField_TestOneof with from_json(
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
pub impl ToJson for OnlyOneOfField_TestOneof with to_json(
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
pub impl @lib.Sized for OnlyOneOfField with size_of(self) {
  let mut size = 0U
  match self.test_oneof {
    F1(v) => size += 1U + @lib.size_of(v)
    F2(v) => size += 1U + @lib.size_of(v)
    F3(v) =>
      size += 1U +
        ({
          let size = @lib.size_of(v)
          @lib.size_of(size) + size
        })
    NotSet => ()
  }
  size
}

///|
pub impl Default for OnlyOneOfField with default() -> OnlyOneOfField {
  OnlyOneOfField::{ test_oneof: OnlyOneOfField_TestOneof::NotSet }
}

///|
pub fn OnlyOneOfField::new(
  test_oneof? : OnlyOneOfField_TestOneof = OnlyOneOfField_TestOneof::NotSet,
) -> OnlyOneOfField {
  OnlyOneOfField::{ test_oneof, }
}

///|
pub impl @lib.Read for OnlyOneOfField with read_with_limit(
  reader : @lib.LimitedReader[&@lib.Reader],
) -> OnlyOneOfField raise {
  let msg = OnlyOneOfField::default()
  try {
    for ;; {
      match (reader |> @lib.read_tag()) {
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
        (_, wire) => reader |> @lib.read_unknown(wire)
      }
    }
  } catch {
    @lib.EndOfStream => ()
    err => raise err
  }
  msg
}

///|
pub impl @lib.Write for OnlyOneOfField with write(
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
pub impl ToJson for OnlyOneOfField with to_json(self) {
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
pub impl @json.FromJson for OnlyOneOfField with from_json(
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
      key => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @lib.AsyncRead for OnlyOneOfField with read_with_limit(
  reader : @lib.LimitedReader[&@lib.AsyncReader],
) -> OnlyOneOfField raise {
  let msg = OnlyOneOfField::default()
  try {
    for ;; {
      match (reader |> @lib.async_read_tag()) {
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
        (_, wire) => reader |> @lib.async_read_unknown(wire)
      }
    }
  } catch {
    @lib.EndOfStream => ()
    err => raise err
  }
  msg
}

///|
pub impl @lib.AsyncWrite for OnlyOneOfField with write(
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
