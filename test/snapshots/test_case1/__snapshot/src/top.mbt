pub(all) enum FooEnum {
  FIRST_VALUE
  SECOND_VALUE
} derive(Eq, Show)
pub fn FooEnum::to_enum(self : FooEnum) -> @lib.Enum {
  match self {
    FooEnum::FIRST_VALUE => 0
    FooEnum::SECOND_VALUE => 2
  }
}
pub fn FooEnum::from_enum(i : @lib.Enum) -> FooEnum {
  match i.inner() {
    0 => FooEnum::FIRST_VALUE
    2 => FooEnum::SECOND_VALUE
    _ => Default::default()
  }
}
pub impl Default for FooEnum with default() -> FooEnum {
  FooEnum::FIRST_VALUE
}
pub impl @lib.Sized for FooEnum with size_of(self : FooEnum) {
  @lib.Sized::size_of(self.to_enum())
}
pub impl @json.FromJson for FooEnum with from_json(json: Json, path: @json.JsonPath) -> FooEnum raise {
  match json {
    String(s) if s == "FIRST_VALUE" => FooEnum::FIRST_VALUE
    String(s) if s == "SECOND_VALUE" => FooEnum::SECOND_VALUE
    Number(n) if n == 0 => FooEnum::FIRST_VALUE
    Number(n) if n == 2 => FooEnum::SECOND_VALUE
    _ =>  raise @json.JsonDecodeError((path, "Expected a number or string for enum"))
  }
}
pub impl ToJson for FooEnum with to_json(self : FooEnum) -> Json {
  match self {
    FooEnum::FIRST_VALUE => "FIRST_VALUE"
    FooEnum::SECOND_VALUE => "SECOND_VALUE"
  }
}
pub(all) struct BarMessage {
  mut b_int32 : Int
} derive(Eq, Show)
pub impl @lib.Sized for BarMessage with size_of(self) {
  let mut size = 0U
  size += 1U + @lib.size_of(self.b_int32)
  size
}
pub impl Default for BarMessage with default() -> BarMessage {
  BarMessage::{
    b_int32 : Int::default(),
  }
}
pub impl @lib.Read for BarMessage with read(reader : &@lib.Reader) {
  let msg =   BarMessage::default()

  while not(reader |> @lib.is_eof()) {
    match (reader |> @lib.read_tag()) {
      (1, _) => msg.b_int32 = reader |> @lib.read_int32()
     (_, wire) => reader |> @lib.read_unknown(wire)
    }
  }
  msg
}
pub impl @lib.Write for BarMessage with write(self, writer) {
  writer |> @lib.write_varint(8UL);writer |> @lib.write_int32(self.b_int32)
}
pub impl ToJson for BarMessage with to_json(self) {

  let json: Map[String, Json] = {}
  if self.b_int32 != Default::default() {
  json["bInt32"] = self.b_int32.to_json()
  }
  Json::object(json)
}
pub impl @json.FromJson for BarMessage with from_json(json: Json, path: @json.JsonPath) -> BarMessage raise {
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
pub(all) struct FooMessage_FMapEntry {
  mut key : String
  mut value : Int
} derive(Eq, Show)
pub impl @lib.Sized for FooMessage_FMapEntry with size_of(self) {
  let mut size = 0U
  size += 1U + { let size = @lib.size_of(self.key); @lib.size_of(size) + size }
  size += 1U + @lib.size_of(self.value)
  size
}
pub impl Default for FooMessage_FMapEntry with default() -> FooMessage_FMapEntry {
  FooMessage_FMapEntry::{
    key : String::default(),
    value : Int::default(),
  }
}
pub impl @lib.Read for FooMessage_FMapEntry with read(reader : &@lib.Reader) {
  let msg =   FooMessage_FMapEntry::default()

  while not(reader |> @lib.is_eof()) {
    match (reader |> @lib.read_tag()) {
      (1, _) => msg.key = reader |> @lib.read_string()
      (2, _) => msg.value = reader |> @lib.read_int32()
     (_, wire) => reader |> @lib.read_unknown(wire)
    }
  }
  msg
}
pub impl @lib.Write for FooMessage_FMapEntry with write(self, writer) {
  writer |> @lib.write_varint(10UL);writer |> @lib.write_string(self.key)
  writer |> @lib.write_varint(16UL);writer |> @lib.write_int32(self.value)
}
pub impl ToJson for FooMessage_FMapEntry with to_json(self) {

  let json: Map[String, Json] = {}
  if self.key != Default::default() {
  json["key"] = self.key.to_json()
  }
  if self.value != Default::default() {
  json["value"] = self.value.to_json()
  }
  Json::object(json)
}
pub impl @json.FromJson for FooMessage_FMapEntry with from_json(json: Json, path: @json.JsonPath) -> FooMessage_FMapEntry raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError((path, "Expected an object for FooMessage_FMapEntry"))
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
pub(all) struct FooMessage {
  mut f_int32 : Int
  mut f_int64 : Int64
  mut f_uint32 : UInt
  mut f_uint64 : UInt64
  mut f_sint32 : Int
  mut f_sint64 : Int64
  mut f_bool : Bool
  mut f_foo_enum :  FooEnum 
  mut f_fixed64 : UInt64
  mut f_sfixed64 : Int64
  mut f_fixed32 : UInt
  mut f_sfixed32 : Int
  mut f_double : Double
  mut f_float : Float
  mut f_bytes : Bytes
  mut f_string : String
  mut f_bar_message :  BarMessage 
  mut f_repeated_int32 : Array[Int]
  mut f_repeated_packed_int32 : Array[Int]
  mut f_repeated_packed_float : Array[Float]
  mut f_baz :  BazMessage 
  mut f_nested :  BazMessage_Nested 
  mut f_nested_enum :  BazMessage_Nested_NestedEnum 
  mut f_map : Map[String, Int]
  mut f_repeated_string : Array[String]
  mut f_repeated_baz_message : Array[BazMessage]
  mut f_optional_string : String?
  mut test_oneof : FooMessage_TestOneof
} derive(Eq, Show)
pub(all) enum FooMessage_TestOneof {
  F1(Int)
  F2(Bool)
  F3(String)
  NotSet
} derive(Eq, Show)
pub impl Default for FooMessage_TestOneof with default() -> FooMessage_TestOneof {
  NotSet
}
pub impl @json.FromJson for FooMessage_TestOneof with from_json(json: Json, path: @json.JsonPath) -> FooMessage_TestOneof raise {
  if (try? FooMessage_TestOneof::F1(json |> @json.from_json(path~))) is Ok(value) {
    return value
  }
  if (try? FooMessage_TestOneof::F2(json |> @json.from_json(path~))) is Ok(value) {
    return value
  }
  if (try? FooMessage_TestOneof::F3(json |> @json.from_json(path~))) is Ok(value) {
    return value
  }
FooMessage_TestOneof::NotSet
}
pub impl ToJson for FooMessage_TestOneof with to_json(self : FooMessage_TestOneof) -> Json {
  match self {
    FooMessage_TestOneof::F1(v) => v.to_json(),
    FooMessage_TestOneof::F2(v) => v.to_json(),
    FooMessage_TestOneof::F3(v) => v.to_json(),
    FooMessage_TestOneof::NotSet => Json::null(),
  }
}
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
  size += 1U + { let size = @lib.size_of(self.f_bytes); @lib.size_of(size) + size }
  size += 2U + { let size = @lib.size_of(self.f_string); @lib.size_of(size) + size }
  size += 2U + { let size = @lib.size_of(self.f_bar_message); @lib.size_of(size) + size }
  size += 2U + { let size = self.f_repeated_int32.iter().map(@lib.size_of).fold(init=0U, UInt::op_add); @lib.size_of(size) + size }
  size += 2U + { let size = self.f_repeated_packed_int32.iter().map(@lib.size_of).fold(init=0U, UInt::op_add); @lib.size_of(size) + size }
  size += 2U + { let size = self.f_repeated_packed_float.length().reinterpret_as_uint() * 4; @lib.size_of(size) + size}
  size += 2U + { let size = @lib.size_of(self.f_baz); @lib.size_of(size) + size }
  size += 2U + { let size = @lib.size_of(self.f_nested); @lib.size_of(size) + size }
  size += 2U + @lib.size_of(self.f_nested_enum)
  size += self.f_map.iter().map(fn(key_value) {
    let (k, v) = key_value
    let key_size = 1U + { let size = @lib.size_of(k); @lib.size_of(size) + size }
    let value_size = 1U + @lib.size_of(v)
    2U + @lib.size_of(key_size + value_size) + key_size + value_size 
  }).fold(init=0U, UInt::op_add)
  size += self.f_repeated_string.iter().map(@lib.size_of).map(s => 2U + @lib.size_of(s) + s).fold(init=0U, UInt::op_add)
  size += self.f_repeated_baz_message.iter().map(@lib.size_of).map(s => 2U + @lib.size_of(s) + s).fold(init=0U, UInt::op_add)
  match self.f_optional_string {
    Some(v) => size += 2U + { let size = @lib.size_of(v); @lib.size_of(size) + size }
    None => ()
  }
  match self.test_oneof {
    F1(v) => { size += 2U + @lib.size_of(v) }
    F2(v) => { size += 2U + @lib.size_of(v) }
    F3(v) => { size += 2U + { let size = @lib.size_of(v); @lib.size_of(size) + size } }
    NotSet => ()
  }
  size
}
pub impl Default for FooMessage with default() -> FooMessage {
  FooMessage::{
    f_int32 : Int::default(),
    f_int64 : Int64::default(),
    f_uint32 : UInt::default(),
    f_uint64 : UInt64::default(),
    f_sint32 : Int::default(),
    f_sint64 : Int64::default(),
    f_bool : Bool::default(),
    f_foo_enum : FooEnum::default(),
    f_fixed64 : UInt64::default(),
    f_sfixed64 : Int64::default(),
    f_fixed32 : UInt::default(),
    f_sfixed32 : Int::default(),
    f_double : Double::default(),
    f_float : Float::default(),
    f_bytes : Bytes::default(),
    f_string : String::default(),
    f_bar_message : BarMessage::default(),
    f_repeated_int32 : [],
    f_repeated_packed_int32 : [],
    f_repeated_packed_float : [],
    f_baz : BazMessage::default(),
    f_nested : BazMessage_Nested::default(),
    f_nested_enum : BazMessage_Nested_NestedEnum::default(),
    f_map : {},
    f_repeated_string : [],
    f_repeated_baz_message : [],
    f_optional_string : None,
    test_oneof : FooMessage_TestOneof::NotSet,
  }
}
pub impl @lib.Read for FooMessage with read(reader : &@lib.Reader) {
  let msg =   FooMessage::default()

  while not(reader |> @lib.is_eof()) {
    match (reader |> @lib.read_tag()) {
      (1, _) => msg.f_int32 = reader |> @lib.read_int32()
      (2, _) => msg.f_int64 = reader |> @lib.read_int64()
      (3, _) => msg.f_uint32 = reader |> @lib.read_uint32()
      (4, _) => msg.f_uint64 = reader |> @lib.read_uint64()
      (5, _) => msg.f_sint32 = (reader |> @lib.read_sint32()).inner()
      (6, _) => msg.f_sint64 = (reader |> @lib.read_sint64()).inner()
      (7, _) => msg.f_bool = reader |> @lib.read_bool()
      (8, _) => msg.f_foo_enum = reader |> @lib.read_enum() |> FooEnum::from_enum
      (9, _) => msg.f_fixed64 = reader |> @lib.read_fixed64()
      (10, _) => msg.f_sfixed64 = reader |> @lib.read_sfixed64()
      (11, _) => msg.f_fixed32 = reader |> @lib.read_fixed32()
      (12, _) => msg.f_sfixed32 = reader |> @lib.read_sfixed32()
      (13, _) => msg.f_double = reader |> @lib.read_double()
      (14, _) => msg.f_float = reader |> @lib.read_float()
      (15, _) => msg.f_bytes = reader |> @lib.read_bytes()
      (16, _) => msg.f_string = reader |> @lib.read_string()
      (18, _) => msg.f_bar_message = ((reader |> @lib.read_message()) : BarMessage)
      (19, _) => { msg.f_repeated_int32.push_iter((reader |> @lib.read_packed(@lib.read_int32, None)).iter()) }
      (20, _) => { msg.f_repeated_packed_int32.push_iter((reader |> @lib.read_packed(@lib.read_int32, None)).iter()) }
      (21, _) => { msg.f_repeated_packed_float.push_iter((reader |> @lib.read_packed(@lib.read_float, Some(4))).iter()) }
      (23, _) => msg.f_baz = ((reader |> @lib.read_message()) : BazMessage)
      (24, _) => msg.f_nested = ((reader |> @lib.read_message()) : BazMessage_Nested)
      (25, _) => msg.f_nested_enum = reader |> @lib.read_enum() |> BazMessage_Nested_NestedEnum::from_enum
      (26, _) => { let {key, value} = ((reader |> @lib.read_message()) : FooMessage_FMapEntry); msg.f_map[key] = value }
      (30, _) => msg.f_repeated_string.push(reader |> @lib.read_string())
      (31, _) => msg.f_repeated_baz_message.push(((reader |> @lib.read_message()) : BazMessage))
      (32, _) => msg.f_optional_string = reader |> @lib.read_string() |> Some
      (27, _) => msg.test_oneof = reader |> @lib.read_int32() |> FooMessage_TestOneof::F1
      (28, _) => msg.test_oneof = reader |> @lib.read_bool() |> FooMessage_TestOneof::F2
      (29, _) => msg.test_oneof = reader |> @lib.read_string() |> FooMessage_TestOneof::F3
     (_, wire) => reader |> @lib.read_unknown(wire)
    }
  }
  msg
}
pub impl @lib.Write for FooMessage with write(self, writer) {
  writer |> @lib.write_varint(8UL);writer |> @lib.write_int32(self.f_int32)
  writer |> @lib.write_varint(16UL);writer |> @lib.write_int64(self.f_int64)
  writer |> @lib.write_varint(24UL);writer |> @lib.write_uint32(self.f_uint32)
  writer |> @lib.write_varint(32UL);writer |> @lib.write_uint64(self.f_uint64)
  writer |> @lib.write_varint(40UL);writer |> @lib.write_sint32(self.f_sint32)
  writer |> @lib.write_varint(48UL);writer |> @lib.write_sint64(self.f_sint64)
  writer |> @lib.write_varint(56UL);writer |> @lib.write_bool(self.f_bool)
  writer |> @lib.write_varint(64UL);writer |> @lib.write_enum(self.f_foo_enum.to_enum())
  writer |> @lib.write_varint(73UL);writer |> @lib.write_fixed64(self.f_fixed64)
  writer |> @lib.write_varint(81UL);writer |> @lib.write_sfixed64(self.f_sfixed64)
  writer |> @lib.write_varint(93UL);writer |> @lib.write_fixed32(self.f_fixed32)
  writer |> @lib.write_varint(101UL);writer |> @lib.write_sfixed32(self.f_sfixed32)
  writer |> @lib.write_varint(105UL);writer |> @lib.write_double(self.f_double)
  writer |> @lib.write_varint(117UL);writer |> @lib.write_float(self.f_float)
  writer |> @lib.write_varint(122UL);writer |> @lib.write_bytes(self.f_bytes)
  writer |> @lib.write_varint(130UL);writer |> @lib.write_string(self.f_string)
  writer |> @lib.write_varint(146UL);writer |> @lib.write_uint32(@lib.size_of(self.f_bar_message)); @lib.Write::write(self.f_bar_message, writer)
  writer |> @lib.write_varint(154UL)
  let size = self.f_repeated_int32.iter().map(@lib.size_of).fold(init=0U, UInt::op_add)
  writer |> @lib.write_uint32(size)
  self.f_repeated_int32.iter().each(fn(v) {
    writer |> @lib.write_int32(v)
  })
  writer |> @lib.write_varint(162UL)
  let size = self.f_repeated_packed_int32.iter().map(@lib.size_of).fold(init=0U, UInt::op_add)
  writer |> @lib.write_uint32(size)
  self.f_repeated_packed_int32.iter().each(fn(v) {
    writer |> @lib.write_int32(v)
  })
  writer |> @lib.write_varint(170UL)
  let size = self.f_repeated_packed_float.length().reinterpret_as_uint() * 4
  writer |> @lib.write_uint32(size)
  self.f_repeated_packed_float.iter().each(fn(v) {
    writer |> @lib.write_float(v)
  })
  writer |> @lib.write_varint(186UL);writer |> @lib.write_uint32(@lib.size_of(self.f_baz)); @lib.Write::write(self.f_baz, writer)
  writer |> @lib.write_varint(194UL);writer |> @lib.write_uint32(@lib.size_of(self.f_nested)); @lib.Write::write(self.f_nested, writer)
  writer |> @lib.write_varint(200UL);writer |> @lib.write_enum(self.f_nested_enum.to_enum())
  self.f_map.iter().each(fn(key_value) {
    let (k, v) = key_value
    writer |> @lib.write_varint(210UL)
    let key_size = 1U + { let size = @lib.size_of(k); @lib.size_of(size) + size }
    let value_size = 1U + @lib.size_of(v)
    writer |> @lib.write_uint32(key_size + value_size)
    writer |> @lib.write_varint(10UL);
    writer |> @lib.write_string(k)
    writer |> @lib.write_varint(16UL);
    writer |> @lib.write_int32(v)
  })
  self.f_repeated_string.iter().each(fn(v) {
    writer |> @lib.write_varint(242UL)
    writer |> @lib.write_string(v)
  })
  self.f_repeated_baz_message.iter().each(fn(v) {
    writer |> @lib.write_varint(250UL)
    writer |> @lib.write_uint32(@lib.size_of(v)); @lib.Write::write(v, writer)
  })
  match self.f_optional_string {
    Some(v) => {
      writer |> @lib.write_varint(258UL);writer |> @lib.write_string(v)
    }
    None => ()
  }
  match self.test_oneof {
    FooMessage_TestOneof::F1(v) => {
      writer |> @lib.write_varint(216UL); writer |> @lib.write_int32(v)
    }
    FooMessage_TestOneof::F2(v) => {
      writer |> @lib.write_varint(224UL); writer |> @lib.write_bool(v)
    }
    FooMessage_TestOneof::F3(v) => {
      writer |> @lib.write_varint(234UL); writer |> @lib.write_string(v)
    }
    FooMessage_TestOneof::NotSet => ()
  }
}
pub impl ToJson for FooMessage with to_json(self) {

  let json: Map[String, Json] = {}
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
  Json::object(json)
}
pub impl @json.FromJson for FooMessage with from_json(json: Json, path: @json.JsonPath) -> FooMessage raise {
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
      ("fFloat", Number(value)) => message.f_float = value.to_float()
      ("fBytes", String(value)) => message.f_bytes = @lib.base64_decode(value)
      ("fString", value) => message.f_string = @json.from_json(value, path~)
      ("fBarMessage", value) => message.f_bar_message = @json.from_json(value, path~)
      ("fRepeatedInt32", Array(value)) => message.f_repeated_int32 = value.map(v => 
@json.from_json(v, path~))
      ("fRepeatedPackedInt32", Array(value)) => message.f_repeated_packed_int32 = value.map(v => 
@json.from_json(v, path~))
      ("fRepeatedPackedFloat", Array(value)) => message.f_repeated_packed_float = value.map(v => 
v.as_number().unwrap().to_float())
      ("fBaz", value) => message.f_baz = @json.from_json(value, path~)
      ("fNested", value) => message.f_nested = @json.from_json(value, path~)
      ("fNestedEnum", value) => message.f_nested_enum = @json.from_json(value, path~)
      ("fMap", _) => message.f_map = @json.from_json(value, path~)
      ("fRepeatedString", Array(value)) => message.f_repeated_string = value.map(v => 
@json.from_json(v, path~))
      ("fRepeatedBazMessage", Array(value)) => message.f_repeated_baz_message = value.map(v => 
@json.from_json(v, path~))
      ("fOptionalString", value) => message.f_optional_string = Some(@json.from_json(value, path~))
      key => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
      }
  }
  message
}
pub(all) enum BazMessage_Nested_NestedEnum {
  Foo
  Bar
  Baz
} derive(Eq, Show)
pub fn BazMessage_Nested_NestedEnum::to_enum(self : BazMessage_Nested_NestedEnum) -> @lib.Enum {
  match self {
    BazMessage_Nested_NestedEnum::Foo => 0
    BazMessage_Nested_NestedEnum::Bar => 1
    BazMessage_Nested_NestedEnum::Baz => 2
  }
}
pub fn BazMessage_Nested_NestedEnum::from_enum(i : @lib.Enum) -> BazMessage_Nested_NestedEnum {
  match i.inner() {
    0 => BazMessage_Nested_NestedEnum::Foo
    1 => BazMessage_Nested_NestedEnum::Bar
    2 => BazMessage_Nested_NestedEnum::Baz
    _ => Default::default()
  }
}
pub impl Default for BazMessage_Nested_NestedEnum with default() -> BazMessage_Nested_NestedEnum {
  BazMessage_Nested_NestedEnum::Foo
}
pub impl @lib.Sized for BazMessage_Nested_NestedEnum with size_of(self : BazMessage_Nested_NestedEnum) {
  @lib.Sized::size_of(self.to_enum())
}
pub impl @json.FromJson for BazMessage_Nested_NestedEnum with from_json(json: Json, path: @json.JsonPath) -> BazMessage_Nested_NestedEnum raise {
  match json {
    String(s) if s == "Foo" => BazMessage_Nested_NestedEnum::Foo
    String(s) if s == "Bar" => BazMessage_Nested_NestedEnum::Bar
    String(s) if s == "Baz" => BazMessage_Nested_NestedEnum::Baz
    Number(n) if n == 0 => BazMessage_Nested_NestedEnum::Foo
    Number(n) if n == 1 => BazMessage_Nested_NestedEnum::Bar
    Number(n) if n == 2 => BazMessage_Nested_NestedEnum::Baz
    _ =>  raise @json.JsonDecodeError((path, "Expected a number or string for enum"))
  }
}
pub impl ToJson for BazMessage_Nested_NestedEnum with to_json(self : BazMessage_Nested_NestedEnum) -> Json {
  match self {
    BazMessage_Nested_NestedEnum::Foo => "Foo"
    BazMessage_Nested_NestedEnum::Bar => "Bar"
    BazMessage_Nested_NestedEnum::Baz => "Baz"
  }
}
pub(all) struct BazMessage_Nested_NestedMessage {
  mut f_nested : Int
} derive(Eq, Show)
pub impl @lib.Sized for BazMessage_Nested_NestedMessage with size_of(self) {
  let mut size = 0U
  size += 1U + @lib.size_of(self.f_nested)
  size
}
pub impl Default for BazMessage_Nested_NestedMessage with default() -> BazMessage_Nested_NestedMessage {
  BazMessage_Nested_NestedMessage::{
    f_nested : Int::default(),
  }
}
pub impl @lib.Read for BazMessage_Nested_NestedMessage with read(reader : &@lib.Reader) {
  let msg =   BazMessage_Nested_NestedMessage::default()

  while not(reader |> @lib.is_eof()) {
    match (reader |> @lib.read_tag()) {
      (1, _) => msg.f_nested = reader |> @lib.read_int32()
     (_, wire) => reader |> @lib.read_unknown(wire)
    }
  }
  msg
}
pub impl @lib.Write for BazMessage_Nested_NestedMessage with write(self, writer) {
  writer |> @lib.write_varint(8UL);writer |> @lib.write_int32(self.f_nested)
}
pub impl ToJson for BazMessage_Nested_NestedMessage with to_json(self) {

  let json: Map[String, Json] = {}
  if self.f_nested != Default::default() {
  json["fNested"] = self.f_nested.to_json()
  }
  Json::object(json)
}
pub impl @json.FromJson for BazMessage_Nested_NestedMessage with from_json(json: Json, path: @json.JsonPath) -> BazMessage_Nested_NestedMessage raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError((path, "Expected an object for BazMessage_Nested_NestedMessage"))
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
pub(all) struct BazMessage_Nested {
  mut f_nested :  BazMessage_Nested_NestedMessage 
} derive(Eq, Show)
pub impl @lib.Sized for BazMessage_Nested with size_of(self) {
  let mut size = 0U
  size += 1U + { let size = @lib.size_of(self.f_nested); @lib.size_of(size) + size }
  size
}
pub impl Default for BazMessage_Nested with default() -> BazMessage_Nested {
  BazMessage_Nested::{
    f_nested : BazMessage_Nested_NestedMessage::default(),
  }
}
pub impl @lib.Read for BazMessage_Nested with read(reader : &@lib.Reader) {
  let msg =   BazMessage_Nested::default()

  while not(reader |> @lib.is_eof()) {
    match (reader |> @lib.read_tag()) {
      (1, _) => msg.f_nested = ((reader |> @lib.read_message()) : BazMessage_Nested_NestedMessage)
     (_, wire) => reader |> @lib.read_unknown(wire)
    }
  }
  msg
}
pub impl @lib.Write for BazMessage_Nested with write(self, writer) {
  writer |> @lib.write_varint(10UL);writer |> @lib.write_uint32(@lib.size_of(self.f_nested)); @lib.Write::write(self.f_nested, writer)
}
pub impl ToJson for BazMessage_Nested with to_json(self) {

  let json: Map[String, Json] = {}
  if self.f_nested != Default::default() {
  json["fNested"] = self.f_nested.to_json()
  }
  Json::object(json)
}
pub impl @json.FromJson for BazMessage_Nested with from_json(json: Json, path: @json.JsonPath) -> BazMessage_Nested raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError((path, "Expected an object for BazMessage_Nested"))
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
pub(all) struct BazMessage {
  mut nested :  BazMessage_Nested 
  mut b_int64 : Int64
  mut b_string : String
} derive(Eq, Show)
pub impl @lib.Sized for BazMessage with size_of(self) {
  let mut size = 0U
  size += 1U + { let size = @lib.size_of(self.nested); @lib.size_of(size) + size }
  size += 1U + @lib.size_of(self.b_int64)
  size += 1U + { let size = @lib.size_of(self.b_string); @lib.size_of(size) + size }
  size
}
pub impl Default for BazMessage with default() -> BazMessage {
  BazMessage::{
    nested : BazMessage_Nested::default(),
    b_int64 : Int64::default(),
    b_string : String::default(),
  }
}
pub impl @lib.Read for BazMessage with read(reader : &@lib.Reader) {
  let msg =   BazMessage::default()

  while not(reader |> @lib.is_eof()) {
    match (reader |> @lib.read_tag()) {
      (1, _) => msg.nested = ((reader |> @lib.read_message()) : BazMessage_Nested)
      (2, _) => msg.b_int64 = reader |> @lib.read_int64()
      (3, _) => msg.b_string = reader |> @lib.read_string()
     (_, wire) => reader |> @lib.read_unknown(wire)
    }
  }
  msg
}
pub impl @lib.Write for BazMessage with write(self, writer) {
  writer |> @lib.write_varint(10UL);writer |> @lib.write_uint32(@lib.size_of(self.nested)); @lib.Write::write(self.nested, writer)
  writer |> @lib.write_varint(16UL);writer |> @lib.write_int64(self.b_int64)
  writer |> @lib.write_varint(26UL);writer |> @lib.write_string(self.b_string)
}
pub impl ToJson for BazMessage with to_json(self) {

  let json: Map[String, Json] = {}
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
pub impl @json.FromJson for BazMessage with from_json(json: Json, path: @json.JsonPath) -> BazMessage raise {
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
pub(all) struct RepeatedMessage {
  mut bar_message : Array[BarMessage]
} derive(Eq, Show)
pub impl @lib.Sized for RepeatedMessage with size_of(self) {
  let mut size = 0U
  size += self.bar_message.iter().map(@lib.size_of).map(s => 1U + @lib.size_of(s) + s).fold(init=0U, UInt::op_add)
  size
}
pub impl Default for RepeatedMessage with default() -> RepeatedMessage {
  RepeatedMessage::{
    bar_message : [],
  }
}
pub impl @lib.Read for RepeatedMessage with read(reader : &@lib.Reader) {
  let msg =   RepeatedMessage::default()

  while not(reader |> @lib.is_eof()) {
    match (reader |> @lib.read_tag()) {
      (1, _) => msg.bar_message.push(((reader |> @lib.read_message()) : BarMessage))
     (_, wire) => reader |> @lib.read_unknown(wire)
    }
  }
  msg
}
pub impl @lib.Write for RepeatedMessage with write(self, writer) {
  self.bar_message.iter().each(fn(v) {
    writer |> @lib.write_varint(10UL)
    writer |> @lib.write_uint32(@lib.size_of(v)); @lib.Write::write(v, writer)
  })
}
pub impl ToJson for RepeatedMessage with to_json(self) {

  let json: Map[String, Json] = {}
  if self.bar_message != Default::default() {
  json["barMessage"] = self.bar_message.to_json()
  }
  Json::object(json)
}
pub impl @json.FromJson for RepeatedMessage with from_json(json: Json, path: @json.JsonPath) -> RepeatedMessage raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError((path, "Expected an object for RepeatedMessage"))
  }
  let message = RepeatedMessage::default()

  for key, value in obj {
    match (key, value) {
      ("barMessage", Array(value)) => message.bar_message = value.map(v => 
@json.from_json(v, path~))
      key => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
      }
  }
  message
}
