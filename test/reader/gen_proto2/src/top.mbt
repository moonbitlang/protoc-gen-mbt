///|
pub(all) enum FooEnumP2 {
  FIRST_VALUEX
  SECOND_VALUEX
} derive(Eq, Show)

///|
fn FooEnumP2::to_enum(self : FooEnumP2) -> @lib.Enum {
  match self {
    FooEnumP2::FIRST_VALUEX => 0
    FooEnumP2::SECOND_VALUEX => 2
  }
}

///|
fn FooEnumP2::from_enum(i : @lib.Enum) -> FooEnumP2 {
  match i.inner() {
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
pub(all) struct BarMessageP2 {
  mut b_int32 : Int
} derive(Eq, Show)

///|
pub impl @lib.Sized for BarMessageP2 with size_of(self) {
  let mut size = 0U
  size += 1U + @lib.size_of(self.b_int32)
  size
}

///|
pub impl Default for BarMessageP2 with default() -> BarMessageP2 {
  { b_int32: Int::default() }
}

///|
pub impl @lib.Read for BarMessageP2 with read(reader : &@lib.Reader) {
  let msg = BarMessageP2::default()
  while not(reader |> @lib.is_eof()) {
    match (reader |> @lib.read_tag()) {
      (1, _) => msg.b_int32 = reader |> @lib.read_int32()
      (_, wire) => reader |> @lib.read_unknown(wire)
    }
  }
  msg
}

///|
pub impl @lib.Write for BarMessageP2 with write(self, writer) {
  writer |> @lib.write_varint(8UL)
  writer |> @lib.write_int32(self.b_int32)
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
} derive(Eq, Show)

///|
pub impl @lib.Sized for FooMessageP2 with size_of(self) {
  let mut size = 0U
  size += 1U + @lib.size_of(self.f_int32)
  size += 1U + @lib.size_of(self.f_int64)
  match self.f_uint32 {
    Some(v) => size += 1U + @lib.size_of(v)
    None => ()
  }
  match self.f_uint64 {
    Some(v) => size += 1U + @lib.size_of(v)
    None => ()
  }
  match self.f_sint32 {
    Some(v) => size += 1U + @lib.size_of(v)
    None => ()
  }
  match self.f_sint64 {
    Some(v) => size += 1U + @lib.size_of(v)
    None => ()
  }
  match self.f_bool {
    Some(v) => size += 1U + @lib.size_of(v)
    None => ()
  }
  match self.f_foo_enum {
    Some(v) => size += 1U + @lib.size_of(v)
    None => ()
  }
  match self.f_fixed64 {
    Some(v) => size += 1U + 8U
    None => ()
  }
  match self.f_sfixed64 {
    Some(v) => size += 1U + 8U
    None => ()
  }
  match self.f_fixed32 {
    Some(v) => size += 1U + 4U
    None => ()
  }
  match self.f_sfixed32 {
    Some(v) => size += 1U + 4U
    None => ()
  }
  match self.f_double {
    Some(v) => size += 1U + 8U
    None => ()
  }
  match self.f_float {
    Some(v) => size += 1U + 4U
    None => ()
  }
  match self.f_bytes {
    Some(v) =>
      size += 1U +
        {
          let size = @lib.size_of(v)
          @lib.size_of(size) + size
        }
    None => ()
  }
  match self.f_string {
    Some(v) =>
      size += 2U +
        {
          let size = @lib.size_of(v)
          @lib.size_of(size) + size
        }
    None => ()
  }
  match self.f_bar_message {
    Some(v) =>
      size += 2U +
        {
          let size = @lib.size_of(v)
          @lib.size_of(size) + size
        }
    None => ()
  }
  size += self.f_repeated_int32
    .iter()
    .map(@lib.size_of)
    .map(s => 2U + @lib.size_of(s) + s)
    .fold(init=0U, UInt::op_add)
  size += 2U +
    {
      let size = self.f_repeated_packed_int32
        .iter()
        .map(@lib.size_of)
        .fold(init=0U, UInt::op_add)
      @lib.size_of(size) + size
    }
  size += 2U +
    {
      let size = self.f_repeated_packed_float.length().reinterpret_as_uint() * 4
      @lib.size_of(size) + size
    }
  match self.f_baz {
    Some(v) =>
      size += 2U +
        {
          let size = @lib.size_of(v)
          @lib.size_of(size) + size
        }
    None => ()
  }
  match self.f_nested {
    Some(v) =>
      size += 2U +
        {
          let size = @lib.size_of(v)
          @lib.size_of(size) + size
        }
    None => ()
  }
  match self.f_nested_enum {
    Some(v) => size += 2U + @lib.size_of(v)
    None => ()
  }
  size += self.f_map
    .iter()
    .map(@lib.size_of)
    .map(s => 2U + @lib.size_of(s) + s)
    .fold(init=0U, UInt::op_add)
  match self.f1 {
    Some(v) => size += 2U + @lib.size_of(v)
    None => ()
  }
  match self.f2 {
    Some(v) => size += 2U + @lib.size_of(v)
    None => ()
  }
  match self.f3 {
    Some(v) =>
      size += 2U +
        {
          let size = @lib.size_of(v)
          @lib.size_of(size) + size
        }
    None => ()
  }
  size += self.f_repeated_string
    .iter()
    .map(@lib.size_of)
    .map(s => 2U + @lib.size_of(s) + s)
    .fold(init=0U, UInt::op_add)
  size += self.f_repeated_baz_message
    .iter()
    .map(@lib.size_of)
    .map(s => 2U + @lib.size_of(s) + s)
    .fold(init=0U, UInt::op_add)
  match self.f_optional_string {
    Some(v) =>
      size += 2U +
        {
          let size = @lib.size_of(v)
          @lib.size_of(size) + size
        }
    None => ()
  }
  match self.f_default_int32 {
    Some(v) => size += 2U + @lib.size_of(v)
    None => ()
  }
  match self.f_default_string {
    Some(v) =>
      size += 2U +
        {
          let size = @lib.size_of(v)
          @lib.size_of(size) + size
        }
    None => ()
  }
  match self.f_default_bool {
    Some(v) => size += 2U + @lib.size_of(v)
    None => ()
  }
  match self.f_default_double {
    Some(v) => size += 2U + 8U
    None => ()
  }
  match self.f_default_enum {
    Some(v) => size += 2U + @lib.size_of(v)
    None => ()
  }
  size
}

///|
pub impl Default for FooMessageP2 with default() -> FooMessageP2 {
  {
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
pub impl @lib.Read for FooMessageP2 with read(reader : &@lib.Reader) {
  let msg = FooMessageP2::default()
  while not(reader |> @lib.is_eof()) {
    match (reader |> @lib.read_tag()) {
      (1, _) => msg.f_int32 = reader |> @lib.read_int32()
      (2, _) => msg.f_int64 = reader |> @lib.read_int64()
      (3, _) => msg.f_uint32 = reader |> @lib.read_uint32() |> Some
      (4, _) => msg.f_uint64 = reader |> @lib.read_uint64() |> Some
      (5, _) => msg.f_sint32 = (reader |> @lib.read_sint32()).inner() |> Some
      (6, _) => msg.f_sint64 = (reader |> @lib.read_sint64()).inner() |> Some
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
  msg
}

///|
pub impl @lib.Write for FooMessageP2 with write(self, writer) {
  writer |> @lib.write_varint(8UL)
  writer |> @lib.write_int32(self.f_int32)
  writer |> @lib.write_varint(16UL)
  writer |> @lib.write_int64(self.f_int64)
  match self.f_uint32 {
    Some(v) => {
      writer |> @lib.write_varint(24UL)
      writer |> @lib.write_uint32(v)
    }
    None => ()
  }
  match self.f_uint64 {
    Some(v) => {
      writer |> @lib.write_varint(32UL)
      writer |> @lib.write_uint64(v)
    }
    None => ()
  }
  match self.f_sint32 {
    Some(v) => {
      writer |> @lib.write_varint(40UL)
      writer |> @lib.write_sint32(v)
    }
    None => ()
  }
  match self.f_sint64 {
    Some(v) => {
      writer |> @lib.write_varint(48UL)
      writer |> @lib.write_sint64(v)
    }
    None => ()
  }
  match self.f_bool {
    Some(v) => {
      writer |> @lib.write_varint(56UL)
      writer |> @lib.write_bool(v)
    }
    None => ()
  }
  match self.f_foo_enum {
    Some(v) => {
      writer |> @lib.write_varint(64UL)
      writer |> @lib.write_enum(v.to_enum())
    }
    None => ()
  }
  match self.f_fixed64 {
    Some(v) => {
      writer |> @lib.write_varint(73UL)
      writer |> @lib.write_fixed64(v)
    }
    None => ()
  }
  match self.f_sfixed64 {
    Some(v) => {
      writer |> @lib.write_varint(81UL)
      writer |> @lib.write_sfixed64(v)
    }
    None => ()
  }
  match self.f_fixed32 {
    Some(v) => {
      writer |> @lib.write_varint(93UL)
      writer |> @lib.write_fixed32(v)
    }
    None => ()
  }
  match self.f_sfixed32 {
    Some(v) => {
      writer |> @lib.write_varint(101UL)
      writer |> @lib.write_sfixed32(v)
    }
    None => ()
  }
  match self.f_double {
    Some(v) => {
      writer |> @lib.write_varint(105UL)
      writer |> @lib.write_double(v)
    }
    None => ()
  }
  match self.f_float {
    Some(v) => {
      writer |> @lib.write_varint(117UL)
      writer |> @lib.write_float(v)
    }
    None => ()
  }
  match self.f_bytes {
    Some(v) => {
      writer |> @lib.write_varint(122UL)
      writer |> @lib.write_bytes(v)
    }
    None => ()
  }
  match self.f_string {
    Some(v) => {
      writer |> @lib.write_varint(130UL)
      writer |> @lib.write_string(v)
    }
    None => ()
  }
  match self.f_bar_message {
    Some(v) => {
      writer |> @lib.write_varint(146UL)
      writer |> @lib.write_uint32(@lib.size_of(v))
      @lib.Write::write(v, writer)
    }
    None => ()
  }
  self.f_repeated_int32
  .iter()
  .each(fn(v) {
    writer |> @lib.write_varint(152UL)
    writer |> @lib.write_int32(v)
  })
  writer |> @lib.write_varint(162UL)
  let size = self.f_repeated_packed_int32
    .iter()
    .map(@lib.size_of)
    .fold(init=0U, UInt::op_add)
  writer |> @lib.write_uint32(size)
  self.f_repeated_packed_int32
  .iter()
  .each(fn(v) { writer |> @lib.write_int32(v) })
  writer |> @lib.write_varint(170UL)
  let size = self.f_repeated_packed_float.length().reinterpret_as_uint() * 4
  writer |> @lib.write_uint32(size)
  self.f_repeated_packed_float
  .iter()
  .each(fn(v) { writer |> @lib.write_float(v) })
  match self.f_baz {
    Some(v) => {
      writer |> @lib.write_varint(186UL)
      writer |> @lib.write_uint32(@lib.size_of(v))
      @lib.Write::write(v, writer)
    }
    None => ()
  }
  match self.f_nested {
    Some(v) => {
      writer |> @lib.write_varint(194UL)
      writer |> @lib.write_uint32(@lib.size_of(v))
      @lib.Write::write(v, writer)
    }
    None => ()
  }
  match self.f_nested_enum {
    Some(v) => {
      writer |> @lib.write_varint(200UL)
      writer |> @lib.write_enum(v.to_enum())
    }
    None => ()
  }
  self.f_map
  .iter()
  .each(fn(v) {
    writer |> @lib.write_varint(218UL)
    writer |> @lib.write_uint32(@lib.size_of(v))
    @lib.Write::write(v, writer)
  })
  match self.f1 {
    Some(v) => {
      writer |> @lib.write_varint(224UL)
      writer |> @lib.write_int32(v)
    }
    None => ()
  }
  match self.f2 {
    Some(v) => {
      writer |> @lib.write_varint(232UL)
      writer |> @lib.write_bool(v)
    }
    None => ()
  }
  match self.f3 {
    Some(v) => {
      writer |> @lib.write_varint(242UL)
      writer |> @lib.write_string(v)
    }
    None => ()
  }
  self.f_repeated_string
  .iter()
  .each(fn(v) {
    writer |> @lib.write_varint(250UL)
    writer |> @lib.write_string(v)
  })
  self.f_repeated_baz_message
  .iter()
  .each(fn(v) {
    writer |> @lib.write_varint(258UL)
    writer |> @lib.write_uint32(@lib.size_of(v))
    @lib.Write::write(v, writer)
  })
  match self.f_optional_string {
    Some(v) => {
      writer |> @lib.write_varint(266UL)
      writer |> @lib.write_string(v)
    }
    None => ()
  }
  match self.f_default_int32 {
    Some(v) => {
      writer |> @lib.write_varint(272UL)
      writer |> @lib.write_int32(v)
    }
    None => ()
  }
  match self.f_default_string {
    Some(v) => {
      writer |> @lib.write_varint(282UL)
      writer |> @lib.write_string(v)
    }
    None => ()
  }
  match self.f_default_bool {
    Some(v) => {
      writer |> @lib.write_varint(288UL)
      writer |> @lib.write_bool(v)
    }
    None => ()
  }
  match self.f_default_double {
    Some(v) => {
      writer |> @lib.write_varint(297UL)
      writer |> @lib.write_double(v)
    }
    None => ()
  }
  match self.f_default_enum {
    Some(v) => {
      writer |> @lib.write_varint(304UL)
      writer |> @lib.write_enum(v.to_enum())
    }
    None => ()
  }
}

///|
pub(all) struct MapEntryP2 {
  mut key : String
  mut value : Int
} derive(Eq, Show)

///|
pub impl @lib.Sized for MapEntryP2 with size_of(self) {
  let mut size = 0U
  size += 1U +
    {
      let size = @lib.size_of(self.key)
      @lib.size_of(size) + size
    }
  size += 1U + @lib.size_of(self.value)
  size
}

///|
pub impl Default for MapEntryP2 with default() -> MapEntryP2 {
  { key: String::default(), value: Int::default() }
}

///|
pub impl @lib.Read for MapEntryP2 with read(reader : &@lib.Reader) {
  let msg = MapEntryP2::default()
  while not(reader |> @lib.is_eof()) {
    match (reader |> @lib.read_tag()) {
      (1, _) => msg.key = reader |> @lib.read_string()
      (2, _) => msg.value = reader |> @lib.read_int32()
      (_, wire) => reader |> @lib.read_unknown(wire)
    }
  }
  msg
}

///|
pub impl @lib.Write for MapEntryP2 with write(self, writer) {
  writer |> @lib.write_varint(10UL)
  writer |> @lib.write_string(self.key)
  writer |> @lib.write_varint(16UL)
  writer |> @lib.write_int32(self.value)
}

///|
pub(all) enum BazMessageP2_Nested_NestedEnum {
  Foo
  Bar
  Baz
} derive(Eq, Show)

///|
fn BazMessageP2_Nested_NestedEnum::to_enum(
  self : BazMessageP2_Nested_NestedEnum
) -> @lib.Enum {
  match self {
    BazMessageP2_Nested_NestedEnum::Foo => 0
    BazMessageP2_Nested_NestedEnum::Bar => 1
    BazMessageP2_Nested_NestedEnum::Baz => 2
  }
}

///|
fn BazMessageP2_Nested_NestedEnum::from_enum(
  i : @lib.Enum
) -> BazMessageP2_Nested_NestedEnum {
  match i.inner() {
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
  self : BazMessageP2_Nested_NestedEnum
) {
  @lib.Sized::size_of(self.to_enum())
}

///|
pub(all) struct BazMessageP2_Nested_NestedMessage {
  mut f_nested : Int
} derive(Eq, Show)

///|
pub impl @lib.Sized for BazMessageP2_Nested_NestedMessage with size_of(self) {
  let mut size = 0U
  size += 1U + @lib.size_of(self.f_nested)
  size
}

///|
pub impl Default for BazMessageP2_Nested_NestedMessage with default() -> BazMessageP2_Nested_NestedMessage {
  { f_nested: Int::default() }
}

///|
pub impl @lib.Read for BazMessageP2_Nested_NestedMessage with read(
  reader : &@lib.Reader
) {
  let msg = BazMessageP2_Nested_NestedMessage::default()
  while not(reader |> @lib.is_eof()) {
    match (reader |> @lib.read_tag()) {
      (1, _) => msg.f_nested = reader |> @lib.read_int32()
      (_, wire) => reader |> @lib.read_unknown(wire)
    }
  }
  msg
}

///|
pub impl @lib.Write for BazMessageP2_Nested_NestedMessage with write(
  self,
  writer
) {
  writer |> @lib.write_varint(8UL)
  writer |> @lib.write_int32(self.f_nested)
}

///|
pub(all) struct BazMessageP2_Nested {
  mut f_nested : BazMessageP2_Nested_NestedMessage?
} derive(Eq, Show)

///|
pub impl @lib.Sized for BazMessageP2_Nested with size_of(self) {
  let mut size = 0U
  match self.f_nested {
    Some(v) =>
      size += 1U +
        {
          let size = @lib.size_of(v)
          @lib.size_of(size) + size
        }
    None => ()
  }
  size
}

///|
pub impl Default for BazMessageP2_Nested with default() -> BazMessageP2_Nested {
  { f_nested: None }
}

///|
pub impl @lib.Read for BazMessageP2_Nested with read(reader : &@lib.Reader) {
  let msg = BazMessageP2_Nested::default()
  while not(reader |> @lib.is_eof()) {
    match (reader |> @lib.read_tag()) {
      (1, _) =>
        msg.f_nested = (
            reader |> @lib.read_message() : BazMessageP2_Nested_NestedMessage)
          |> Some
      (_, wire) => reader |> @lib.read_unknown(wire)
    }
  }
  msg
}

///|
pub impl @lib.Write for BazMessageP2_Nested with write(self, writer) {
  match self.f_nested {
    Some(v) => {
      writer |> @lib.write_varint(10UL)
      writer |> @lib.write_uint32(@lib.size_of(v))
      @lib.Write::write(v, writer)
    }
    None => ()
  }
}

///|
pub(all) struct BazMessageP2 {
  mut nested : BazMessageP2_Nested?
  mut b_int64 : Int64?
  mut b_string : String?
} derive(Eq, Show)

///|
pub impl @lib.Sized for BazMessageP2 with size_of(self) {
  let mut size = 0U
  match self.nested {
    Some(v) =>
      size += 1U +
        {
          let size = @lib.size_of(v)
          @lib.size_of(size) + size
        }
    None => ()
  }
  match self.b_int64 {
    Some(v) => size += 1U + @lib.size_of(v)
    None => ()
  }
  match self.b_string {
    Some(v) =>
      size += 1U +
        {
          let size = @lib.size_of(v)
          @lib.size_of(size) + size
        }
    None => ()
  }
  size
}

///|
pub impl Default for BazMessageP2 with default() -> BazMessageP2 {
  { nested: None, b_int64: None, b_string: None }
}

///|
pub impl @lib.Read for BazMessageP2 with read(reader : &@lib.Reader) {
  let msg = BazMessageP2::default()
  while not(reader |> @lib.is_eof()) {
    match (reader |> @lib.read_tag()) {
      (1, _) =>
        msg.nested = (reader |> @lib.read_message() : BazMessageP2_Nested)
          |> Some
      (2, _) => msg.b_int64 = reader |> @lib.read_int64() |> Some
      (3, _) => msg.b_string = reader |> @lib.read_string() |> Some
      (_, wire) => reader |> @lib.read_unknown(wire)
    }
  }
  msg
}

///|
pub impl @lib.Write for BazMessageP2 with write(self, writer) {
  match self.nested {
    Some(v) => {
      writer |> @lib.write_varint(10UL)
      writer |> @lib.write_uint32(@lib.size_of(v))
      @lib.Write::write(v, writer)
    }
    None => ()
  }
  match self.b_int64 {
    Some(v) => {
      writer |> @lib.write_varint(16UL)
      writer |> @lib.write_int64(v)
    }
    None => ()
  }
  match self.b_string {
    Some(v) => {
      writer |> @lib.write_varint(26UL)
      writer |> @lib.write_string(v)
    }
    None => ()
  }
}

///|
pub(all) struct RepeatedMessageP2 {
  mut bar_message : Array[BarMessageP2]
} derive(Eq, Show)

///|
pub impl @lib.Sized for RepeatedMessageP2 with size_of(self) {
  let mut size = 0U
  size += self.bar_message
    .iter()
    .map(@lib.size_of)
    .map(s => 1U + @lib.size_of(s) + s)
    .fold(init=0U, UInt::op_add)
  size
}

///|
pub impl Default for RepeatedMessageP2 with default() -> RepeatedMessageP2 {
  { bar_message: [] }
}

///|
pub impl @lib.Read for RepeatedMessageP2 with read(reader : &@lib.Reader) {
  let msg = RepeatedMessageP2::default()
  while not(reader |> @lib.is_eof()) {
    match (reader |> @lib.read_tag()) {
      (1, _) =>
        msg.bar_message.push((reader |> @lib.read_message() : BarMessageP2))
      (_, wire) => reader |> @lib.read_unknown(wire)
    }
  }
  msg
}

///|
pub impl @lib.Write for RepeatedMessageP2 with write(self, writer) {
  self.bar_message
  .iter()
  .each(fn(v) {
    writer |> @lib.write_varint(10UL)
    writer |> @lib.write_uint32(@lib.size_of(v))
    @lib.Write::write(v, writer)
  })
}
