///|
pub(all) enum FooEnumP2 {
  FIRST_VALUEX
  SECOND_VALUEX
} derive(Eq, Debug)

///|
pub fn FooEnumP2::to_enum(self : FooEnumP2) -> @lib.Enum {
  match self {
    FooEnumP2::FIRST_VALUEX => 0
    FooEnumP2::SECOND_VALUEX => 2
  }
}

///|
pub fn FooEnumP2::from_enum(i : @lib.Enum) -> FooEnumP2 {
  match i.0 {
    0 => FooEnumP2::FIRST_VALUEX
    2 => FooEnumP2::SECOND_VALUEX
    _ => Default::default()
  }
}

///|
pub impl Default for FooEnumP2 with default() -> FooEnumP2 {
  FooEnumP2::FIRST_VALUEX
}

///|
pub impl @lib.Sized for FooEnumP2 with size_of(self : FooEnumP2) {
  @lib.Sized::size_of(self.to_enum())
}

///|
pub impl @json.FromJson for FooEnumP2 with from_json(
  json : Json,
  path : @json.JsonPath,
) -> FooEnumP2 raise {
  match json {
    String("FIRST_VALUEX") => FooEnumP2::FIRST_VALUEX
    String("SECOND_VALUEX") => FooEnumP2::SECOND_VALUEX
    Number(0, ..) => FooEnumP2::FIRST_VALUEX
    Number(2, ..) => FooEnumP2::SECOND_VALUEX
    _ =>
      raise @json.JsonDecodeError(
        (path, "Expected a number or string for enum"),
      )
  }
}

///|
pub impl ToJson for FooEnumP2 with to_json(self : FooEnumP2) -> Json {
  match self {
    FooEnumP2::FIRST_VALUEX => "FIRST_VALUEX"
    FooEnumP2::SECOND_VALUEX => "SECOND_VALUEX"
  }
}

///|
pub(all) struct BarMessageP2 {
  mut b_int32 : Int
} derive(Eq, Debug)

///|
pub impl @lib.Sized for BarMessageP2 with size_of(self) {
  let mut size = 0U
  size += 1U + @lib.size_of(self.b_int32)
  size
}

///|
pub impl Default for BarMessageP2 with default() -> BarMessageP2 {
  BarMessageP2::{ b_int32: Int::default() }
}

///|
pub fn BarMessageP2::new(b_int32 : Int) -> BarMessageP2 {
  BarMessageP2::{ b_int32, }
}

///|
pub impl @lib.Read for BarMessageP2 with read_with_limit(
  reader : @lib.LimitedReader[&@lib.Reader],
) -> BarMessageP2 raise {
  let msg = BarMessageP2::default()
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
pub impl @lib.Write for BarMessageP2 with write(
  self : BarMessageP2,
  writer : &@lib.Writer,
) -> Unit raise {
  writer |> @lib.write_varint(8UL)
  writer |> @lib.write_int32(self.b_int32)
}

///|
pub impl ToJson for BarMessageP2 with to_json(self) {
  let json : Map[String, Json] = {}
  if self.b_int32 != Default::default() {
    json["bInt32"] = self.b_int32.to_json()
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for BarMessageP2 with from_json(
  json : Json,
  path : @json.JsonPath,
) -> BarMessageP2 raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError((path, "Expected an object for BarMessageP2"))
  }
  let message = BarMessageP2::default()
  for key, value in obj {
    match (key, value) {
      ("bInt32", value) => message.b_int32 = @json.from_json(value, path~)
      key => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @lib.AsyncRead for BarMessageP2 with read_with_limit(
  reader : @lib.LimitedReader[&@lib.AsyncReader],
) -> BarMessageP2 raise {
  let msg = BarMessageP2::default()
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
pub impl @lib.AsyncWrite for BarMessageP2 with write(
  self : BarMessageP2,
  writer : &@lib.AsyncWriter,
) -> Unit raise {
  writer |> @lib.async_write_varint(8UL)
  writer |> @lib.async_write_int32(self.b_int32)
}

///|
pub(all) struct FooMessageP2 {
  mut f_int32 : Int
  mut f_int64 : Int64
  mut f_uint32 : UInt?
  mut f_uint64 : UInt64?
  mut f_sint32 : Int?
  mut f_sint64 : Int64?
  mut f_bool : Bool?
  mut f_foo_enum : FooEnumP2?
  mut f_fixed64 : UInt64?
  mut f_sfixed64 : Int64?
  mut f_fixed32 : UInt?
  mut f_sfixed32 : Int?
  mut f_double : Double?
  mut f_float : Float?
  mut f_bytes : Bytes?
  mut f_string : String?
  mut f_bar_message : BarMessageP2?
  mut f_repeated_int32 : Array[Int]
  mut f_repeated_packed_int32 : Array[Int]
  mut f_repeated_packed_float : Array[Float]
  mut f_baz : BazMessageP2?
  mut f_nested : BazMessageP2_Nested?
  mut f_nested_enum : BazMessageP2_Nested_NestedEnum?
  mut f_map : Array[MapEntryP2]
  mut f1 : Int?
  mut f2 : Bool?
  mut f3 : String?
  mut f_repeated_string : Array[String]
  mut f_repeated_baz_message : Array[BazMessageP2]
  mut f_optional_string : String?
  mut f_default_int32 : Int?
  mut f_default_string : String?
  mut f_default_bool : Bool?
  mut f_default_double : Double?
  mut f_default_enum : FooEnumP2?
} derive(Eq, Debug)

///|
pub impl @lib.Sized for FooMessageP2 with size_of(self) {
  let mut size = 0U
  size += 1U + @lib.size_of(self.f_int32)
  size += 1U + @lib.size_of(self.f_int64)
  if self.f_uint32 is Some(v) {
    size += 1U + @lib.size_of(v)
  }
  if self.f_uint64 is Some(v) {
    size += 1U + @lib.size_of(v)
  }
  if self.f_sint32 is Some(v) {
    size += 1U + @lib.size_of(v)
  }
  if self.f_sint64 is Some(v) {
    size += 1U + @lib.size_of(v)
  }
  if self.f_bool is Some(v) {
    size += 1U + @lib.size_of(v)
  }
  if self.f_foo_enum is Some(v) {
    size += 1U + @lib.size_of(v)
  }
  if self.f_fixed64 is Some(_) {
    size += 1U + 8U
  }
  if self.f_sfixed64 is Some(_) {
    size += 1U + 8U
  }
  if self.f_fixed32 is Some(_) {
    size += 1U + 4U
  }
  if self.f_sfixed32 is Some(_) {
    size += 1U + 4U
  }
  if self.f_double is Some(_) {
    size += 1U + 8U
  }
  if self.f_float is Some(_) {
    size += 1U + 4U
  }
  if self.f_bytes is Some(v) {
    size += 1U +
      ({
        let size = @lib.size_of(v)
        @lib.size_of(size) + size
      })
  }
  if self.f_string is Some(v) {
    size += 2U +
      ({
        let size = @lib.size_of(v)
        @lib.size_of(size) + size
      })
  }
  if self.f_bar_message is Some(v) {
    size += 2U +
      ({
        let size = @lib.size_of(v)
        @lib.size_of(size) + size
      })
  }
  for s in self.f_repeated_int32 {
    let s = @lib.size_of(s)
    size += 2U + @lib.size_of(s) + s
  }
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
  if self.f_baz is Some(v) {
    size += 2U +
      ({
        let size = @lib.size_of(v)
        @lib.size_of(size) + size
      })
  }
  if self.f_nested is Some(v) {
    size += 2U +
      ({
        let size = @lib.size_of(v)
        @lib.size_of(size) + size
      })
  }
  if self.f_nested_enum is Some(v) {
    size += 2U + @lib.size_of(v)
  }
  for s in self.f_map {
    let s = @lib.size_of(s)
    size += 2U + @lib.size_of(s) + s
  }
  if self.f1 is Some(v) {
    size += 2U + @lib.size_of(v)
  }
  if self.f2 is Some(v) {
    size += 2U + @lib.size_of(v)
  }
  if self.f3 is Some(v) {
    size += 2U +
      ({
        let size = @lib.size_of(v)
        @lib.size_of(size) + size
      })
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
  if self.f_default_int32 is Some(v) {
    size += 2U + @lib.size_of(v)
  }
  if self.f_default_string is Some(v) {
    size += 2U +
      ({
        let size = @lib.size_of(v)
        @lib.size_of(size) + size
      })
  }
  if self.f_default_bool is Some(v) {
    size += 2U + @lib.size_of(v)
  }
  if self.f_default_double is Some(_) {
    size += 2U + 8U
  }
  if self.f_default_enum is Some(v) {
    size += 2U + @lib.size_of(v)
  }
  size
}

///|
pub impl Default for FooMessageP2 with default() -> FooMessageP2 {
  FooMessageP2::{
    f_int32: Int::default(),
    f_int64: Int64::default(),
    f_uint32: None,
    f_uint64: None,
    f_sint32: None,
    f_sint64: None,
    f_bool: None,
    f_foo_enum: None,
    f_fixed64: None,
    f_sfixed64: None,
    f_fixed32: None,
    f_sfixed32: None,
    f_double: None,
    f_float: None,
    f_bytes: None,
    f_string: None,
    f_bar_message: None,
    f_repeated_int32: [],
    f_repeated_packed_int32: [],
    f_repeated_packed_float: [],
    f_baz: None,
    f_nested: None,
    f_nested_enum: Some(BazMessageP2_Nested_NestedEnum::Foo),
    f_map: [],
    f1: None,
    f2: None,
    f3: None,
    f_repeated_string: [],
    f_repeated_baz_message: [],
    f_optional_string: None,
    f_default_int32: Some(42),
    f_default_string: Some("default_value"),
    f_default_bool: Some(true),
    f_default_double: Some(3.14),
    f_default_enum: Some(FooEnumP2::SECOND_VALUEX),
  }
}

///|
pub fn FooMessageP2::new(
  f_int32 : Int,
  f_int64 : Int64,
  f_uint32? : UInt,
  f_uint64? : UInt64,
  f_sint32? : Int,
  f_sint64? : Int64,
  f_bool? : Bool,
  f_foo_enum? : FooEnumP2,
  f_fixed64? : UInt64,
  f_sfixed64? : Int64,
  f_fixed32? : UInt,
  f_sfixed32? : Int,
  f_double? : Double,
  f_float? : Float,
  f_bytes? : Bytes,
  f_string? : String,
  f_bar_message? : BarMessageP2,
  f_repeated_int32 : Array[Int],
  f_repeated_packed_int32 : Array[Int],
  f_repeated_packed_float : Array[Float],
  f_baz? : BazMessageP2,
  f_nested? : BazMessageP2_Nested,
  f_nested_enum? : BazMessageP2_Nested_NestedEnum,
  f_map : Array[MapEntryP2],
  f1? : Int,
  f2? : Bool,
  f3? : String,
  f_repeated_string : Array[String],
  f_repeated_baz_message : Array[BazMessageP2],
  f_optional_string? : String,
  f_default_int32? : Int,
  f_default_string? : String,
  f_default_bool? : Bool,
  f_default_double? : Double,
  f_default_enum? : FooEnumP2,
) -> FooMessageP2 {
  FooMessageP2::{
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
    f1,
    f2,
    f3,
    f_repeated_string,
    f_repeated_baz_message,
    f_optional_string,
    f_default_int32,
    f_default_string,
    f_default_bool,
    f_default_double,
    f_default_enum,
  }
}

///|
pub impl @lib.Read for FooMessageP2 with read_with_limit(
  reader : @lib.LimitedReader[&@lib.Reader],
) -> FooMessageP2 raise {
  let msg = FooMessageP2::default()
  try {
    for ;; {
      match (reader |> @lib.read_tag()) {
        (1, _) => msg.f_int32 = reader |> @lib.read_int32()
        (2, _) => msg.f_int64 = reader |> @lib.read_int64()
        (3, _) => msg.f_uint32 = reader |> @lib.read_uint32() |> Some
        (4, _) => msg.f_uint64 = reader |> @lib.read_uint64() |> Some
        (5, _) => msg.f_sint32 = (reader |> @lib.read_sint32()).0 |> Some
        (6, _) => msg.f_sint64 = (reader |> @lib.read_sint64()).0 |> Some
        (7, _) => msg.f_bool = reader |> @lib.read_bool() |> Some
        (8, _) =>
          msg.f_foo_enum = reader
            |> @lib.read_enum()
            |> FooEnumP2::from_enum
            |> Some
        (9, _) => msg.f_fixed64 = reader |> @lib.read_fixed64() |> Some
        (10, _) => msg.f_sfixed64 = reader |> @lib.read_sfixed64() |> Some
        (11, _) => msg.f_fixed32 = reader |> @lib.read_fixed32() |> Some
        (12, _) => msg.f_sfixed32 = reader |> @lib.read_sfixed32() |> Some
        (13, _) => msg.f_double = reader |> @lib.read_double() |> Some
        (14, _) => msg.f_float = reader |> @lib.read_float() |> Some
        (15, _) => msg.f_bytes = reader |> @lib.read_bytes() |> Some
        (16, _) => msg.f_string = reader |> @lib.read_string() |> Some
        (18, _) =>
          msg.f_bar_message = (reader |> @lib.read_message() : BarMessageP2)
            |> Some
        (19, _) => msg.f_repeated_int32.push(reader |> @lib.read_int32())
        (20, _) =>
          msg.f_repeated_packed_int32.push_iter(
            (reader |> @lib.read_packed(@lib.read_int32, None)).iter(),
          )
        (21, _) =>
          msg.f_repeated_packed_float.push_iter(
            (reader |> @lib.read_packed(@lib.read_float, Some(4))).iter(),
          )
        (23, _) =>
          msg.f_baz = (reader |> @lib.read_message() : BazMessageP2) |> Some
        (24, _) =>
          msg.f_nested = (reader |> @lib.read_message() : BazMessageP2_Nested)
            |> Some
        (25, _) =>
          msg.f_nested_enum = reader
            |> @lib.read_enum()
            |> BazMessageP2_Nested_NestedEnum::from_enum
            |> Some
        (27, _) => msg.f_map.push((reader |> @lib.read_message() : MapEntryP2))
        (28, _) => msg.f1 = reader |> @lib.read_int32() |> Some
        (29, _) => msg.f2 = reader |> @lib.read_bool() |> Some
        (30, _) => msg.f3 = reader |> @lib.read_string() |> Some
        (31, _) => msg.f_repeated_string.push(reader |> @lib.read_string())
        (32, _) =>
          msg.f_repeated_baz_message.push(
            (reader |> @lib.read_message() : BazMessageP2),
          )
        (33, _) => msg.f_optional_string = reader |> @lib.read_string() |> Some
        (34, _) => msg.f_default_int32 = reader |> @lib.read_int32() |> Some
        (35, _) => msg.f_default_string = reader |> @lib.read_string() |> Some
        (36, _) => msg.f_default_bool = reader |> @lib.read_bool() |> Some
        (37, _) => msg.f_default_double = reader |> @lib.read_double() |> Some
        (38, _) =>
          msg.f_default_enum = reader
            |> @lib.read_enum()
            |> FooEnumP2::from_enum
            |> Some
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
pub impl @lib.Write for FooMessageP2 with write(
  self : FooMessageP2,
  writer : &@lib.Writer,
) -> Unit raise {
  writer |> @lib.write_varint(8UL)
  writer |> @lib.write_int32(self.f_int32)
  writer |> @lib.write_varint(16UL)
  writer |> @lib.write_int64(self.f_int64)
  if self.f_uint32 is Some(v) {
    writer |> @lib.write_varint(24UL)
    writer |> @lib.write_uint32(v)
  }
  if self.f_uint64 is Some(v) {
    writer |> @lib.write_varint(32UL)
    writer |> @lib.write_uint64(v)
  }
  if self.f_sint32 is Some(v) {
    writer |> @lib.write_varint(40UL)
    writer |> @lib.write_sint32(v)
  }
  if self.f_sint64 is Some(v) {
    writer |> @lib.write_varint(48UL)
    writer |> @lib.write_sint64(v)
  }
  if self.f_bool is Some(v) {
    writer |> @lib.write_varint(56UL)
    writer |> @lib.write_bool(v)
  }
  if self.f_foo_enum is Some(v) {
    writer |> @lib.write_varint(64UL)
    writer |> @lib.write_enum(v.to_enum())
  }
  if self.f_fixed64 is Some(v) {
    writer |> @lib.write_varint(73UL)
    writer |> @lib.write_fixed64(v)
  }
  if self.f_sfixed64 is Some(v) {
    writer |> @lib.write_varint(81UL)
    writer |> @lib.write_sfixed64(v)
  }
  if self.f_fixed32 is Some(v) {
    writer |> @lib.write_varint(93UL)
    writer |> @lib.write_fixed32(v)
  }
  if self.f_sfixed32 is Some(v) {
    writer |> @lib.write_varint(101UL)
    writer |> @lib.write_sfixed32(v)
  }
  if self.f_double is Some(v) {
    writer |> @lib.write_varint(105UL)
    writer |> @lib.write_double(v)
  }
  if self.f_float is Some(v) {
    writer |> @lib.write_varint(117UL)
    writer |> @lib.write_float(v)
  }
  if self.f_bytes is Some(v) {
    writer |> @lib.write_varint(122UL)
    writer |> @lib.write_bytes(v)
  }
  if self.f_string is Some(v) {
    writer |> @lib.write_varint(130UL)
    writer |> @lib.write_string(v)
  }
  if self.f_bar_message is Some(v) {
    writer |> @lib.write_varint(146UL)
    writer |> @lib.write_uint32(@lib.size_of(v))
    @lib.Write::write(v, writer)
  }
  for item in self.f_repeated_int32 {
    writer |> @lib.write_varint(152UL)
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
  if self.f_baz is Some(v) {
    writer |> @lib.write_varint(186UL)
    writer |> @lib.write_uint32(@lib.size_of(v))
    @lib.Write::write(v, writer)
  }
  if self.f_nested is Some(v) {
    writer |> @lib.write_varint(194UL)
    writer |> @lib.write_uint32(@lib.size_of(v))
    @lib.Write::write(v, writer)
  }
  if self.f_nested_enum is Some(v) {
    writer |> @lib.write_varint(200UL)
    writer |> @lib.write_enum(v.to_enum())
  }
  for item in self.f_map {
    writer |> @lib.write_varint(218UL)
    writer |> @lib.write_uint32(@lib.size_of(item))
    @lib.Write::write(item, writer)
  }
  if self.f1 is Some(v) {
    writer |> @lib.write_varint(224UL)
    writer |> @lib.write_int32(v)
  }
  if self.f2 is Some(v) {
    writer |> @lib.write_varint(232UL)
    writer |> @lib.write_bool(v)
  }
  if self.f3 is Some(v) {
    writer |> @lib.write_varint(242UL)
    writer |> @lib.write_string(v)
  }
  for item in self.f_repeated_string {
    writer |> @lib.write_varint(250UL)
    writer |> @lib.write_string(item)
  }
  for item in self.f_repeated_baz_message {
    writer |> @lib.write_varint(258UL)
    writer |> @lib.write_uint32(@lib.size_of(item))
    @lib.Write::write(item, writer)
  }
  if self.f_optional_string is Some(v) {
    writer |> @lib.write_varint(266UL)
    writer |> @lib.write_string(v)
  }
  if self.f_default_int32 is Some(v) {
    writer |> @lib.write_varint(272UL)
    writer |> @lib.write_int32(v)
  }
  if self.f_default_string is Some(v) {
    writer |> @lib.write_varint(282UL)
    writer |> @lib.write_string(v)
  }
  if self.f_default_bool is Some(v) {
    writer |> @lib.write_varint(288UL)
    writer |> @lib.write_bool(v)
  }
  if self.f_default_double is Some(v) {
    writer |> @lib.write_varint(297UL)
    writer |> @lib.write_double(v)
  }
  if self.f_default_enum is Some(v) {
    writer |> @lib.write_varint(304UL)
    writer |> @lib.write_enum(v.to_enum())
  }
}

///|
pub impl ToJson for FooMessageP2 with to_json(self) {
  let json : Map[String, Json] = {}
  if self.f_int32 != Default::default() {
    json["fInt32"] = self.f_int32.to_json()
  }
  if self.f_int64 != Default::default() {
    json["fInt64"] = self.f_int64.to_json()
  }
  match self.f_uint32 {
    Some(v) => json["fUint32"] = v.to_json()
    _ => ()
  }
  match self.f_uint64 {
    Some(v) => json["fUint64"] = v.to_json()
    _ => ()
  }
  match self.f_sint32 {
    Some(v) => json["fSint32"] = v.to_json()
    _ => ()
  }
  match self.f_sint64 {
    Some(v) => json["fSint64"] = v.to_json()
    _ => ()
  }
  match self.f_bool {
    Some(v) => json["fBool"] = v.to_json()
    _ => ()
  }
  match self.f_foo_enum {
    Some(v) => json["fFooEnum"] = v.to_json()
    _ => ()
  }
  match self.f_fixed64 {
    Some(v) => json["fFixed64"] = v.to_json()
    _ => ()
  }
  match self.f_sfixed64 {
    Some(v) => json["fSfixed64"] = v.to_json()
    _ => ()
  }
  match self.f_fixed32 {
    Some(v) => json["fFixed32"] = v.to_json()
    _ => ()
  }
  match self.f_sfixed32 {
    Some(v) => json["fSfixed32"] = v.to_json()
    _ => ()
  }
  match self.f_double {
    Some(v) => json["fDouble"] = v.to_json()
    _ => ()
  }
  match self.f_float {
    Some(v) => json["fFloat"] = v.to_json()
    _ => ()
  }
  match self.f_bytes {
    Some(v) => json["fBytes"] = @lib.base64_encode(v).to_json()
    _ => ()
  }
  match self.f_string {
    Some(v) => json["fString"] = v.to_json()
    _ => ()
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
  match self.f_nested_enum {
    Some(v) if v != BazMessageP2_Nested_NestedEnum::Foo =>
      json["fNestedEnum"] = v.to_json()
    _ => ()
  }
  if self.f_map != Default::default() {
    json["fMap"] = self.f_map.to_json()
  }
  match self.f1 {
    Some(v) => json["f1"] = v.to_json()
    _ => ()
  }
  match self.f2 {
    Some(v) => json["f2"] = v.to_json()
    _ => ()
  }
  match self.f3 {
    Some(v) => json["f3"] = v.to_json()
    _ => ()
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
  match self.f_default_int32 {
    Some(v) if v != 42 => json["fDefaultInt32"] = v.to_json()
    _ => ()
  }
  match self.f_default_string {
    Some(v) if v != "default_value" => json["fDefaultString"] = v.to_json()
    _ => ()
  }
  match self.f_default_bool {
    Some(v) if v != true => json["fDefaultBool"] = v.to_json()
    _ => ()
  }
  match self.f_default_double {
    Some(v) if v != 3.14 => json["fDefaultDouble"] = v.to_json()
    _ => ()
  }
  match self.f_default_enum {
    Some(v) if v != FooEnumP2::SECOND_VALUEX =>
      json["fDefaultEnum"] = v.to_json()
    _ => ()
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for FooMessageP2 with from_json(
  json : Json,
  path : @json.JsonPath,
) -> FooMessageP2 raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError((path, "Expected an object for FooMessageP2"))
  }
  let message = FooMessageP2::default()
  for key, value in obj {
    match (key, value) {
      ("fInt32", value) => message.f_int32 = @json.from_json(value, path~)
      ("fInt64", value) => message.f_int64 = @json.from_json(value, path~)
      ("fUint32", value) =>
        message.f_uint32 = Some(@json.from_json(value, path~))
      ("fUint64", value) =>
        message.f_uint64 = Some(@json.from_json(value, path~))
      ("fSint32", value) =>
        message.f_sint32 = Some(@json.from_json(value, path~))
      ("fSint64", value) =>
        message.f_sint64 = Some(@json.from_json(value, path~))
      ("fBool", value) => message.f_bool = Some(@json.from_json(value, path~))
      ("fFooEnum", value) =>
        message.f_foo_enum = Some(@json.from_json(value, path~))
      ("fFixed64", value) =>
        message.f_fixed64 = Some(@json.from_json(value, path~))
      ("fSfixed64", value) =>
        message.f_sfixed64 = Some(@json.from_json(value, path~))
      ("fFixed32", value) =>
        message.f_fixed32 = Some(@json.from_json(value, path~))
      ("fSfixed32", value) =>
        message.f_sfixed32 = Some(@json.from_json(value, path~))
      ("fDouble", value) =>
        message.f_double = Some(@json.from_json(value, path~))
      ("fFloat", Number(value, ..)) =>
        message.f_float = Some(Float::from_double(value))
      ("fBytes", String(value)) =>
        message.f_bytes = Some(@lib.base64_decode(value))
      ("fString", value) =>
        message.f_string = Some(@json.from_json(value, path~))
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
        message.f_nested_enum = Some(@json.from_json(value, path~))
      ("fMap", Array(value)) =>
        message.f_map = value.map(v => @json.from_json(v, path~))
      ("f1", value) => message.f1 = Some(@json.from_json(value, path~))
      ("f2", value) => message.f2 = Some(@json.from_json(value, path~))
      ("f3", value) => message.f3 = Some(@json.from_json(value, path~))
      ("fRepeatedString", Array(value)) =>
        message.f_repeated_string = value.map(v => @json.from_json(v, path~))
      ("fRepeatedBazMessage", Array(value)) =>
        message.f_repeated_baz_message = value.map(v => {
          @json.from_json(v, path~)
        })
      ("fOptionalString", value) =>
        message.f_optional_string = Some(@json.from_json(value, path~))
      ("fDefaultInt32", value) =>
        message.f_default_int32 = Some(@json.from_json(value, path~))
      ("fDefaultString", value) =>
        message.f_default_string = Some(@json.from_json(value, path~))
      ("fDefaultBool", value) =>
        message.f_default_bool = Some(@json.from_json(value, path~))
      ("fDefaultDouble", value) =>
        message.f_default_double = Some(@json.from_json(value, path~))
      ("fDefaultEnum", value) =>
        message.f_default_enum = Some(@json.from_json(value, path~))
      key => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @lib.AsyncRead for FooMessageP2 with read_with_limit(
  reader : @lib.LimitedReader[&@lib.AsyncReader],
) -> FooMessageP2 raise {
  let msg = FooMessageP2::default()
  try {
    for ;; {
      match (reader |> @lib.async_read_tag()) {
        (1, _) => msg.f_int32 = reader |> @lib.async_read_int32()
        (2, _) => msg.f_int64 = reader |> @lib.async_read_int64()
        (3, _) => msg.f_uint32 = reader |> @lib.async_read_uint32() |> Some
        (4, _) => msg.f_uint64 = reader |> @lib.async_read_uint64() |> Some
        (5, _) => msg.f_sint32 = (reader |> @lib.async_read_sint32()).0 |> Some
        (6, _) => msg.f_sint64 = (reader |> @lib.async_read_sint64()).0 |> Some
        (7, _) => msg.f_bool = reader |> @lib.async_read_bool() |> Some
        (8, _) =>
          msg.f_foo_enum = reader
            |> @lib.async_read_enum()
            |> FooEnumP2::from_enum
            |> Some
        (9, _) => msg.f_fixed64 = reader |> @lib.async_read_fixed64() |> Some
        (10, _) => msg.f_sfixed64 = reader |> @lib.async_read_sfixed64() |> Some
        (11, _) => msg.f_fixed32 = reader |> @lib.async_read_fixed32() |> Some
        (12, _) => msg.f_sfixed32 = reader |> @lib.async_read_sfixed32() |> Some
        (13, _) => msg.f_double = reader |> @lib.async_read_double() |> Some
        (14, _) => msg.f_float = reader |> @lib.async_read_float() |> Some
        (15, _) => msg.f_bytes = reader |> @lib.async_read_bytes() |> Some
        (16, _) => msg.f_string = reader |> @lib.async_read_string() |> Some
        (18, _) =>
          msg.f_bar_message = (
              reader |> @lib.async_read_message() : BarMessageP2)
            |> Some
        (19, _) => msg.f_repeated_int32.push(reader |> @lib.async_read_int32())
        (20, _) =>
          msg.f_repeated_packed_int32.push_iter(
            (reader |> @lib.async_read_packed(@lib.async_read_int32, None)).iter(),
          )
        (21, _) =>
          msg.f_repeated_packed_float.push_iter(
            (reader |> @lib.async_read_packed(@lib.async_read_float, Some(4))).iter(),
          )
        (23, _) =>
          msg.f_baz = (reader |> @lib.async_read_message() : BazMessageP2)
            |> Some
        (24, _) =>
          msg.f_nested = (
              reader |> @lib.async_read_message() : BazMessageP2_Nested)
            |> Some
        (25, _) =>
          msg.f_nested_enum = reader
            |> @lib.async_read_enum()
            |> BazMessageP2_Nested_NestedEnum::from_enum
            |> Some
        (27, _) =>
          msg.f_map.push((reader |> @lib.async_read_message() : MapEntryP2))
        (28, _) => msg.f1 = reader |> @lib.async_read_int32() |> Some
        (29, _) => msg.f2 = reader |> @lib.async_read_bool() |> Some
        (30, _) => msg.f3 = reader |> @lib.async_read_string() |> Some
        (31, _) =>
          msg.f_repeated_string.push(reader |> @lib.async_read_string())
        (32, _) =>
          msg.f_repeated_baz_message.push(
            (reader |> @lib.async_read_message() : BazMessageP2),
          )
        (33, _) =>
          msg.f_optional_string = reader |> @lib.async_read_string() |> Some
        (34, _) =>
          msg.f_default_int32 = reader |> @lib.async_read_int32() |> Some
        (35, _) =>
          msg.f_default_string = reader |> @lib.async_read_string() |> Some
        (36, _) => msg.f_default_bool = reader |> @lib.async_read_bool() |> Some
        (37, _) =>
          msg.f_default_double = reader |> @lib.async_read_double() |> Some
        (38, _) =>
          msg.f_default_enum = reader
            |> @lib.async_read_enum()
            |> FooEnumP2::from_enum
            |> Some
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
pub impl @lib.AsyncWrite for FooMessageP2 with write(
  self : FooMessageP2,
  writer : &@lib.AsyncWriter,
) -> Unit raise {
  writer |> @lib.async_write_varint(8UL)
  writer |> @lib.async_write_int32(self.f_int32)
  writer |> @lib.async_write_varint(16UL)
  writer |> @lib.async_write_int64(self.f_int64)
  if self.f_uint32 is Some(v) {
    writer |> @lib.async_write_varint(24UL)
    writer |> @lib.async_write_uint32(v)
  }
  if self.f_uint64 is Some(v) {
    writer |> @lib.async_write_varint(32UL)
    writer |> @lib.async_write_uint64(v)
  }
  if self.f_sint32 is Some(v) {
    writer |> @lib.async_write_varint(40UL)
    writer |> @lib.async_write_sint32(v)
  }
  if self.f_sint64 is Some(v) {
    writer |> @lib.async_write_varint(48UL)
    writer |> @lib.async_write_sint64(v)
  }
  if self.f_bool is Some(v) {
    writer |> @lib.async_write_varint(56UL)
    writer |> @lib.async_write_bool(v)
  }
  if self.f_foo_enum is Some(v) {
    writer |> @lib.async_write_varint(64UL)
    writer |> @lib.async_write_enum(v.to_enum())
  }
  if self.f_fixed64 is Some(v) {
    writer |> @lib.async_write_varint(73UL)
    writer |> @lib.async_write_fixed64(v)
  }
  if self.f_sfixed64 is Some(v) {
    writer |> @lib.async_write_varint(81UL)
    writer |> @lib.async_write_sfixed64(v)
  }
  if self.f_fixed32 is Some(v) {
    writer |> @lib.async_write_varint(93UL)
    writer |> @lib.async_write_fixed32(v)
  }
  if self.f_sfixed32 is Some(v) {
    writer |> @lib.async_write_varint(101UL)
    writer |> @lib.async_write_sfixed32(v)
  }
  if self.f_double is Some(v) {
    writer |> @lib.async_write_varint(105UL)
    writer |> @lib.async_write_double(v)
  }
  if self.f_float is Some(v) {
    writer |> @lib.async_write_varint(117UL)
    writer |> @lib.async_write_float(v)
  }
  if self.f_bytes is Some(v) {
    writer |> @lib.async_write_varint(122UL)
    writer |> @lib.async_write_bytes(v)
  }
  if self.f_string is Some(v) {
    writer |> @lib.async_write_varint(130UL)
    writer |> @lib.async_write_string(v)
  }
  if self.f_bar_message is Some(v) {
    writer |> @lib.async_write_varint(146UL)
    writer |> @lib.async_write_uint32(@lib.size_of(v))
    @lib.AsyncWrite::write(v, writer)
  }
  for item in self.f_repeated_int32 {
    writer |> @lib.async_write_varint(152UL)
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
  if self.f_baz is Some(v) {
    writer |> @lib.async_write_varint(186UL)
    writer |> @lib.async_write_uint32(@lib.size_of(v))
    @lib.AsyncWrite::write(v, writer)
  }
  if self.f_nested is Some(v) {
    writer |> @lib.async_write_varint(194UL)
    writer |> @lib.async_write_uint32(@lib.size_of(v))
    @lib.AsyncWrite::write(v, writer)
  }
  if self.f_nested_enum is Some(v) {
    writer |> @lib.async_write_varint(200UL)
    writer |> @lib.async_write_enum(v.to_enum())
  }
  for item in self.f_map {
    writer |> @lib.async_write_varint(218UL)
    writer |> @lib.async_write_uint32(@lib.size_of(item))
    @lib.AsyncWrite::write(item, writer)
  }
  if self.f1 is Some(v) {
    writer |> @lib.async_write_varint(224UL)
    writer |> @lib.async_write_int32(v)
  }
  if self.f2 is Some(v) {
    writer |> @lib.async_write_varint(232UL)
    writer |> @lib.async_write_bool(v)
  }
  if self.f3 is Some(v) {
    writer |> @lib.async_write_varint(242UL)
    writer |> @lib.async_write_string(v)
  }
  for item in self.f_repeated_string {
    writer |> @lib.async_write_varint(250UL)
    writer |> @lib.async_write_string(item)
  }
  for item in self.f_repeated_baz_message {
    writer |> @lib.async_write_varint(258UL)
    writer |> @lib.async_write_uint32(@lib.size_of(item))
    @lib.AsyncWrite::write(item, writer)
  }
  if self.f_optional_string is Some(v) {
    writer |> @lib.async_write_varint(266UL)
    writer |> @lib.async_write_string(v)
  }
  if self.f_default_int32 is Some(v) {
    writer |> @lib.async_write_varint(272UL)
    writer |> @lib.async_write_int32(v)
  }
  if self.f_default_string is Some(v) {
    writer |> @lib.async_write_varint(282UL)
    writer |> @lib.async_write_string(v)
  }
  if self.f_default_bool is Some(v) {
    writer |> @lib.async_write_varint(288UL)
    writer |> @lib.async_write_bool(v)
  }
  if self.f_default_double is Some(v) {
    writer |> @lib.async_write_varint(297UL)
    writer |> @lib.async_write_double(v)
  }
  if self.f_default_enum is Some(v) {
    writer |> @lib.async_write_varint(304UL)
    writer |> @lib.async_write_enum(v.to_enum())
  }
}

///|
pub(all) struct MapEntryP2 {
  mut key : String
  mut value : Int
} derive(Eq, Debug)

///|
pub impl @lib.Sized for MapEntryP2 with size_of(self) {
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
pub impl Default for MapEntryP2 with default() -> MapEntryP2 {
  MapEntryP2::{ key: String::default(), value: Int::default() }
}

///|
pub fn MapEntryP2::new(key : String, value : Int) -> MapEntryP2 {
  MapEntryP2::{ key, value }
}

///|
pub impl @lib.Read for MapEntryP2 with read_with_limit(
  reader : @lib.LimitedReader[&@lib.Reader],
) -> MapEntryP2 raise {
  let msg = MapEntryP2::default()
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
pub impl @lib.Write for MapEntryP2 with write(
  self : MapEntryP2,
  writer : &@lib.Writer,
) -> Unit raise {
  writer |> @lib.write_varint(10UL)
  writer |> @lib.write_string(self.key)
  writer |> @lib.write_varint(16UL)
  writer |> @lib.write_int32(self.value)
}

///|
pub impl ToJson for MapEntryP2 with to_json(self) {
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
pub impl @json.FromJson for MapEntryP2 with from_json(
  json : Json,
  path : @json.JsonPath,
) -> MapEntryP2 raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError((path, "Expected an object for MapEntryP2"))
  }
  let message = MapEntryP2::default()
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
pub impl @lib.AsyncRead for MapEntryP2 with read_with_limit(
  reader : @lib.LimitedReader[&@lib.AsyncReader],
) -> MapEntryP2 raise {
  let msg = MapEntryP2::default()
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
pub impl @lib.AsyncWrite for MapEntryP2 with write(
  self : MapEntryP2,
  writer : &@lib.AsyncWriter,
) -> Unit raise {
  writer |> @lib.async_write_varint(10UL)
  writer |> @lib.async_write_string(self.key)
  writer |> @lib.async_write_varint(16UL)
  writer |> @lib.async_write_int32(self.value)
}

///|
pub(all) enum BazMessageP2_Nested_NestedEnum {
  Foo
  Bar
  Baz
} derive(Eq, Debug)

///|
pub fn BazMessageP2_Nested_NestedEnum::to_enum(
  self : BazMessageP2_Nested_NestedEnum,
) -> @lib.Enum {
  match self {
    BazMessageP2_Nested_NestedEnum::Foo => 0
    BazMessageP2_Nested_NestedEnum::Bar => 1
    BazMessageP2_Nested_NestedEnum::Baz => 2
  }
}

///|
pub fn BazMessageP2_Nested_NestedEnum::from_enum(
  i : @lib.Enum,
) -> BazMessageP2_Nested_NestedEnum {
  match i.0 {
    0 => BazMessageP2_Nested_NestedEnum::Foo
    1 => BazMessageP2_Nested_NestedEnum::Bar
    2 => BazMessageP2_Nested_NestedEnum::Baz
    _ => Default::default()
  }
}

///|
pub impl Default for BazMessageP2_Nested_NestedEnum with default() -> BazMessageP2_Nested_NestedEnum {
  BazMessageP2_Nested_NestedEnum::Foo
}

///|
pub impl @lib.Sized for BazMessageP2_Nested_NestedEnum with size_of(
  self : BazMessageP2_Nested_NestedEnum,
) {
  @lib.Sized::size_of(self.to_enum())
}

///|
pub impl @json.FromJson for BazMessageP2_Nested_NestedEnum with from_json(
  json : Json,
  path : @json.JsonPath,
) -> BazMessageP2_Nested_NestedEnum raise {
  match json {
    String("Foo") => BazMessageP2_Nested_NestedEnum::Foo
    String("Bar") => BazMessageP2_Nested_NestedEnum::Bar
    String("Baz") => BazMessageP2_Nested_NestedEnum::Baz
    Number(0, ..) => BazMessageP2_Nested_NestedEnum::Foo
    Number(1, ..) => BazMessageP2_Nested_NestedEnum::Bar
    Number(2, ..) => BazMessageP2_Nested_NestedEnum::Baz
    _ =>
      raise @json.JsonDecodeError(
        (path, "Expected a number or string for enum"),
      )
  }
}

///|
pub impl ToJson for BazMessageP2_Nested_NestedEnum with to_json(
  self : BazMessageP2_Nested_NestedEnum,
) -> Json {
  match self {
    BazMessageP2_Nested_NestedEnum::Foo => "Foo"
    BazMessageP2_Nested_NestedEnum::Bar => "Bar"
    BazMessageP2_Nested_NestedEnum::Baz => "Baz"
  }
}

///|
pub(all) struct BazMessageP2_Nested_NestedMessage {
  mut f_nested : Int
} derive(Eq, Debug)

///|
pub impl @lib.Sized for BazMessageP2_Nested_NestedMessage with size_of(self) {
  let mut size = 0U
  size += 1U + @lib.size_of(self.f_nested)
  size
}

///|
pub impl Default for BazMessageP2_Nested_NestedMessage with default() -> BazMessageP2_Nested_NestedMessage {
  BazMessageP2_Nested_NestedMessage::{ f_nested: Int::default() }
}

///|
pub fn BazMessageP2_Nested_NestedMessage::new(
  f_nested : Int,
) -> BazMessageP2_Nested_NestedMessage {
  BazMessageP2_Nested_NestedMessage::{ f_nested, }
}

///|
pub impl @lib.Read for BazMessageP2_Nested_NestedMessage with read_with_limit(
  reader : @lib.LimitedReader[&@lib.Reader],
) -> BazMessageP2_Nested_NestedMessage raise {
  let msg = BazMessageP2_Nested_NestedMessage::default()
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
pub impl @lib.Write for BazMessageP2_Nested_NestedMessage with write(
  self : BazMessageP2_Nested_NestedMessage,
  writer : &@lib.Writer,
) -> Unit raise {
  writer |> @lib.write_varint(8UL)
  writer |> @lib.write_int32(self.f_nested)
}

///|
pub impl ToJson for BazMessageP2_Nested_NestedMessage with to_json(self) {
  let json : Map[String, Json] = {}
  if self.f_nested != Default::default() {
    json["fNested"] = self.f_nested.to_json()
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for BazMessageP2_Nested_NestedMessage with from_json(
  json : Json,
  path : @json.JsonPath,
) -> BazMessageP2_Nested_NestedMessage raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError(
      (path, "Expected an object for BazMessageP2_Nested_NestedMessage"),
    )
  }
  let message = BazMessageP2_Nested_NestedMessage::default()
  for key, value in obj {
    match (key, value) {
      ("fNested", value) => message.f_nested = @json.from_json(value, path~)
      key => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @lib.AsyncRead for BazMessageP2_Nested_NestedMessage with read_with_limit(
  reader : @lib.LimitedReader[&@lib.AsyncReader],
) -> BazMessageP2_Nested_NestedMessage raise {
  let msg = BazMessageP2_Nested_NestedMessage::default()
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
pub impl @lib.AsyncWrite for BazMessageP2_Nested_NestedMessage with write(
  self : BazMessageP2_Nested_NestedMessage,
  writer : &@lib.AsyncWriter,
) -> Unit raise {
  writer |> @lib.async_write_varint(8UL)
  writer |> @lib.async_write_int32(self.f_nested)
}

///|
pub(all) struct BazMessageP2_Nested {
  mut f_nested : BazMessageP2_Nested_NestedMessage?
} derive(Eq, Debug)

///|
pub impl @lib.Sized for BazMessageP2_Nested with size_of(self) {
  let mut size = 0U
  if self.f_nested is Some(v) {
    size += 1U +
      ({
        let size = @lib.size_of(v)
        @lib.size_of(size) + size
      })
  }
  size
}

///|
pub impl Default for BazMessageP2_Nested with default() -> BazMessageP2_Nested {
  BazMessageP2_Nested::{ f_nested: None }
}

///|
pub fn BazMessageP2_Nested::new(
  f_nested? : BazMessageP2_Nested_NestedMessage,
) -> BazMessageP2_Nested {
  BazMessageP2_Nested::{ f_nested, }
}

///|
pub impl @lib.Read for BazMessageP2_Nested with read_with_limit(
  reader : @lib.LimitedReader[&@lib.Reader],
) -> BazMessageP2_Nested raise {
  let msg = BazMessageP2_Nested::default()
  try {
    for ;; {
      match (reader |> @lib.read_tag()) {
        (1, _) =>
          msg.f_nested = (
              reader |> @lib.read_message() : BazMessageP2_Nested_NestedMessage)
            |> Some
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
pub impl @lib.Write for BazMessageP2_Nested with write(
  self : BazMessageP2_Nested,
  writer : &@lib.Writer,
) -> Unit raise {
  if self.f_nested is Some(v) {
    writer |> @lib.write_varint(10UL)
    writer |> @lib.write_uint32(@lib.size_of(v))
    @lib.Write::write(v, writer)
  }
}

///|
pub impl ToJson for BazMessageP2_Nested with to_json(self) {
  let json : Map[String, Json] = {}
  match self.f_nested {
    Some(v) => json["fNested"] = v.to_json()
    _ => ()
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for BazMessageP2_Nested with from_json(
  json : Json,
  path : @json.JsonPath,
) -> BazMessageP2_Nested raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError(
      (path, "Expected an object for BazMessageP2_Nested"),
    )
  }
  let message = BazMessageP2_Nested::default()
  for key, value in obj {
    match (key, value) {
      ("fNested", value) =>
        message.f_nested = Some(@json.from_json(value, path~))
      key => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @lib.AsyncRead for BazMessageP2_Nested with read_with_limit(
  reader : @lib.LimitedReader[&@lib.AsyncReader],
) -> BazMessageP2_Nested raise {
  let msg = BazMessageP2_Nested::default()
  try {
    for ;; {
      match (reader |> @lib.async_read_tag()) {
        (1, _) =>
          msg.f_nested = (
              reader |> @lib.async_read_message() :
              BazMessageP2_Nested_NestedMessage)
            |> Some
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
pub impl @lib.AsyncWrite for BazMessageP2_Nested with write(
  self : BazMessageP2_Nested,
  writer : &@lib.AsyncWriter,
) -> Unit raise {
  if self.f_nested is Some(v) {
    writer |> @lib.async_write_varint(10UL)
    writer |> @lib.async_write_uint32(@lib.size_of(v))
    @lib.AsyncWrite::write(v, writer)
  }
}

///|
pub(all) struct BazMessageP2 {
  mut nested : BazMessageP2_Nested?
  mut b_int64 : Int64?
  mut b_string : String?
} derive(Eq, Debug)

///|
pub impl @lib.Sized for BazMessageP2 with size_of(self) {
  let mut size = 0U
  if self.nested is Some(v) {
    size += 1U +
      ({
        let size = @lib.size_of(v)
        @lib.size_of(size) + size
      })
  }
  if self.b_int64 is Some(v) {
    size += 1U + @lib.size_of(v)
  }
  if self.b_string is Some(v) {
    size += 1U +
      ({
        let size = @lib.size_of(v)
        @lib.size_of(size) + size
      })
  }
  size
}

///|
pub impl Default for BazMessageP2 with default() -> BazMessageP2 {
  BazMessageP2::{ nested: None, b_int64: None, b_string: None }
}

///|
pub fn BazMessageP2::new(
  nested? : BazMessageP2_Nested,
  b_int64? : Int64,
  b_string? : String,
) -> BazMessageP2 {
  BazMessageP2::{ nested, b_int64, b_string }
}

///|
pub impl @lib.Read for BazMessageP2 with read_with_limit(
  reader : @lib.LimitedReader[&@lib.Reader],
) -> BazMessageP2 raise {
  let msg = BazMessageP2::default()
  try {
    for ;; {
      match (reader |> @lib.read_tag()) {
        (1, _) =>
          msg.nested = (reader |> @lib.read_message() : BazMessageP2_Nested)
            |> Some
        (2, _) => msg.b_int64 = reader |> @lib.read_int64() |> Some
        (3, _) => msg.b_string = reader |> @lib.read_string() |> Some
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
pub impl @lib.Write for BazMessageP2 with write(
  self : BazMessageP2,
  writer : &@lib.Writer,
) -> Unit raise {
  if self.nested is Some(v) {
    writer |> @lib.write_varint(10UL)
    writer |> @lib.write_uint32(@lib.size_of(v))
    @lib.Write::write(v, writer)
  }
  if self.b_int64 is Some(v) {
    writer |> @lib.write_varint(16UL)
    writer |> @lib.write_int64(v)
  }
  if self.b_string is Some(v) {
    writer |> @lib.write_varint(26UL)
    writer |> @lib.write_string(v)
  }
}

///|
pub impl ToJson for BazMessageP2 with to_json(self) {
  let json : Map[String, Json] = {}
  match self.nested {
    Some(v) => json["nested"] = v.to_json()
    _ => ()
  }
  match self.b_int64 {
    Some(v) => json["bInt64"] = v.to_json()
    _ => ()
  }
  match self.b_string {
    Some(v) => json["bString"] = v.to_json()
    _ => ()
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for BazMessageP2 with from_json(
  json : Json,
  path : @json.JsonPath,
) -> BazMessageP2 raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError((path, "Expected an object for BazMessageP2"))
  }
  let message = BazMessageP2::default()
  for key, value in obj {
    match (key, value) {
      ("nested", value) => message.nested = Some(@json.from_json(value, path~))
      ("bInt64", value) => message.b_int64 = Some(@json.from_json(value, path~))
      ("bString", value) =>
        message.b_string = Some(@json.from_json(value, path~))
      key => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @lib.AsyncRead for BazMessageP2 with read_with_limit(
  reader : @lib.LimitedReader[&@lib.AsyncReader],
) -> BazMessageP2 raise {
  let msg = BazMessageP2::default()
  try {
    for ;; {
      match (reader |> @lib.async_read_tag()) {
        (1, _) =>
          msg.nested = (
              reader |> @lib.async_read_message() : BazMessageP2_Nested)
            |> Some
        (2, _) => msg.b_int64 = reader |> @lib.async_read_int64() |> Some
        (3, _) => msg.b_string = reader |> @lib.async_read_string() |> Some
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
pub impl @lib.AsyncWrite for BazMessageP2 with write(
  self : BazMessageP2,
  writer : &@lib.AsyncWriter,
) -> Unit raise {
  if self.nested is Some(v) {
    writer |> @lib.async_write_varint(10UL)
    writer |> @lib.async_write_uint32(@lib.size_of(v))
    @lib.AsyncWrite::write(v, writer)
  }
  if self.b_int64 is Some(v) {
    writer |> @lib.async_write_varint(16UL)
    writer |> @lib.async_write_int64(v)
  }
  if self.b_string is Some(v) {
    writer |> @lib.async_write_varint(26UL)
    writer |> @lib.async_write_string(v)
  }
}

///|
pub(all) struct RepeatedMessageP2 {
  mut bar_message : Array[BarMessageP2]
} derive(Eq, Debug)

///|
pub impl @lib.Sized for RepeatedMessageP2 with size_of(self) {
  let mut size = 0U
  for s in self.bar_message {
    let s = @lib.size_of(s)
    size += 1U + @lib.size_of(s) + s
  }
  size
}

///|
pub impl Default for RepeatedMessageP2 with default() -> RepeatedMessageP2 {
  RepeatedMessageP2::{ bar_message: [] }
}

///|
pub fn RepeatedMessageP2::new(
  bar_message : Array[BarMessageP2],
) -> RepeatedMessageP2 {
  RepeatedMessageP2::{ bar_message, }
}

///|
pub impl @lib.Read for RepeatedMessageP2 with read_with_limit(
  reader : @lib.LimitedReader[&@lib.Reader],
) -> RepeatedMessageP2 raise {
  let msg = RepeatedMessageP2::default()
  try {
    for ;; {
      match (reader |> @lib.read_tag()) {
        (1, _) =>
          msg.bar_message.push((reader |> @lib.read_message() : BarMessageP2))
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
pub impl @lib.Write for RepeatedMessageP2 with write(
  self : RepeatedMessageP2,
  writer : &@lib.Writer,
) -> Unit raise {
  for item in self.bar_message {
    writer |> @lib.write_varint(10UL)
    writer |> @lib.write_uint32(@lib.size_of(item))
    @lib.Write::write(item, writer)
  }
}

///|
pub impl ToJson for RepeatedMessageP2 with to_json(self) {
  let json : Map[String, Json] = {}
  if self.bar_message != Default::default() {
    json["barMessage"] = self.bar_message.to_json()
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for RepeatedMessageP2 with from_json(
  json : Json,
  path : @json.JsonPath,
) -> RepeatedMessageP2 raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError(
      (path, "Expected an object for RepeatedMessageP2"),
    )
  }
  let message = RepeatedMessageP2::default()
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
pub impl @lib.AsyncRead for RepeatedMessageP2 with read_with_limit(
  reader : @lib.LimitedReader[&@lib.AsyncReader],
) -> RepeatedMessageP2 raise {
  let msg = RepeatedMessageP2::default()
  try {
    for ;; {
      match (reader |> @lib.async_read_tag()) {
        (1, _) =>
          msg.bar_message.push(
            (reader |> @lib.async_read_message() : BarMessageP2),
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
pub impl @lib.AsyncWrite for RepeatedMessageP2 with write(
  self : RepeatedMessageP2,
  writer : &@lib.AsyncWriter,
) -> Unit raise {
  for item in self.bar_message {
    writer |> @lib.async_write_varint(10UL)
    writer |> @lib.async_write_uint32(@lib.size_of(item))
    @lib.AsyncWrite::write(item, writer)
  }
}
