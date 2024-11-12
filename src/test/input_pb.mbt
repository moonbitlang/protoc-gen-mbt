// Code generated from src/test/input.proto by protoc-gen-mbt. DO NOT EDIT.

pub enum FooEnum {
  FooEnum_FIRST_VALUE
  FooEnum_SECOND_VALUE
} derive(Eq, Show)
pub fn to_enum(self : FooEnum) -> @lib.Enum {
  match self {
    FooEnum::FooEnum_FIRST_VALUE => 0
    FooEnum::FooEnum_SECOND_VALUE => 2
  }
}
pub fn FooEnum::from_enum(i : @lib.Enum) -> FooEnum {
  match i._ {
    0 => FooEnum::FooEnum_FIRST_VALUE
    2 => FooEnum::FooEnum_SECOND_VALUE
    _ => Default::default()
  }
}
pub fn FooEnum::default() -> FooEnum {
  FooEnum::FooEnum_FIRST_VALUE
}
impl @lib.Sized for FooEnum with size_of(self : FooEnum) {
  @lib.Sized::size_of(self.to_enum())
}
pub struct BarMessage {
  mut b_int32 : Int
} derive(Default, Eq, Show)
pub impl @lib.Read for BarMessage with read(reader : @lib.Reader) {	let msg =   BarMessage::default()
  while not(reader |> @lib.is_eof!()) {
    match (reader |> @lib.read_tag!()) {
      (1, _) => msg.b_int32 = reader |> @lib.read_int32!()
      (_, wire) => reader |> @lib.read_unknown!(wire)
    }
  }
  msg
}
impl @lib.MessageWrite for BarMessage with write_to_writer(self, w : @lib.Writer) {
	if self.bint32 != Int::default() { w.write_with_tag(8, fn(w) { w.write_int32(self.bint32) }) }
}

impl @lib.MessageWrite for BarMessage with get_size(self) {
	0
}

pub struct FooMessage_FMapEntry {
  mut key : String
  mut value : Int
} derive(Default, Eq, Show)
pub impl @lib.Read for FooMessage_FMapEntry with read(reader : @lib.Reader) {	let msg =   FooMessage_FMapEntry::default()
  while not(reader |> @lib.is_eof!()) {
    match (reader |> @lib.read_tag!()) {
      (1, _) => msg.key = reader |> @lib.read_string!()
      (2, _) => msg.value = reader |> @lib.read_int32!()
      (_, wire) => reader |> @lib.read_unknown!(wire)
    }
  }
  msg
}
impl @lib.MessageWrite for FooMessage_FMapEntry with write_to_writer(self, w : @lib.Writer) {
	if self.key != String::default() { w.write_with_tag(10, fn(w) { w.write_string(self.key) }) }
	if self.value != Int::default() { w.write_with_tag(16, fn(w) { w.write_int32(self.value) }) }
}

impl @lib.MessageWrite for FooMessage_FMapEntry with get_size(self) {
	0
}

pub struct FooMessage {
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
  mut f_self_message : FooMessage
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
  mut test_oneof : FooMessage_Testoneof
} derive(Default, Eq, Show)
pub impl @lib.Read for FooMessage with read(reader : @lib.Reader) {	let msg =   FooMessage::default()
  while not(reader |> @lib.is_eof!()) {
    match (reader |> @lib.read_tag!()) {
      (1, _) => msg.f_int32 = reader |> @lib.read_int32!()
      (2, _) => msg.f_int64 = reader |> @lib.read_int64!()
      (3, _) => msg.f_uint32 = reader |> @lib.read_uint32!()
      (4, _) => msg.f_uint64 = reader |> @lib.read_uint64!()
      (5, _) => msg.f_sint32 = (reader |> @lib.read_sint32!())._
      (6, _) => msg.f_sint64 = (reader |> @lib.read_sint64!())._
      (7, _) => msg.f_bool = reader |> @lib.read_bool!()
      (8, _) => msg.f_foo_enum = reader |> @lib.read_enum!() |> FooEnum::from_enum
      (9, _) => msg.f_fixed64 = reader |> @lib.read_fixed64!()
      (10, _) => msg.f_sfixed64 = reader |> @lib.read_sfixed64!()
      (11, _) => msg.f_fixed32 = reader |> @lib.read_fixed32!()
      (12, _) => msg.f_sfixed32 = reader |> @lib.read_sfixed32!()
      (13, _) => msg.f_double = reader |> @lib.read_double!()
      (14, _) => msg.f_float = reader |> @lib.read_float!()
      (15, _) => msg.f_bytes = reader |> @lib.read_bytes!()
      (16, _) => msg.f_string = reader |> @lib.read_string!()
      (17, _) => msg.f_self_message = ((reader |> @lib.Read::read!()) : FooMessage)
      (18, _) => msg.f_bar_message = ((reader |> @lib.Read::read!()) : BarMessage)
      (19, _) => { msg.f_repeated_int32.push_iter((reader |> @lib.read_packed!(@lib.read_int32, None)).iter()) }
      (20, _) => { msg.f_repeated_packed_int32.push_iter((reader |> @lib.read_packed!(@lib.read_int32, None)).iter()) }
      (21, _) => { msg.f_repeated_packed_float.push_iter((reader |> @lib.read_packed!(@lib.read_float, Some(32))).iter()) }
      (23, _) => msg.f_baz = ((reader |> @lib.Read::read!()) : BazMessage)
      (24, _) => msg.f_nested = ((reader |> @lib.Read::read!()) : BazMessage_Nested)
      (25, _) => msg.f_nested_enum = reader |> @lib.read_enum!() |> BazMessage_Nested_NestedEnum::from_enum
      (26, _) => { let {key, value} = ((reader |> @lib.Read::read!()) : FooMessage_FMapEntry); msg.f_map[key] = value}
      (27, _) => msg.test_oneof = reader |> @lib.read_int32!() |> FooMessage_Testoneof::F1
      (28, _) => msg.test_oneof = reader |> @lib.read_bool!() |> FooMessage_Testoneof::F2
      (29, _) => msg.test_oneof = reader |> @lib.read_string!() |> FooMessage_Testoneof::F3
      (30, _) => msg.f_repeated_string.push(reader |> @lib.read_string!())
      (31, _) => msg.f_repeated_baz_message.push(((reader |> @lib.Read::read!()) : BazMessage))
      (_, wire) => reader |> @lib.read_unknown!(wire)
    }
  }
  msg
}
impl @lib.MessageWrite for FooMessage with write_to_writer(self, w : @lib.Writer) {
	if self.fint32 != Int::default() { w.write_with_tag(8, fn(w) { w.write_int32(self.fint32) }) }
	if self.fint64 != Int64::default() { w.write_with_tag(16, fn(w) { w.write_int64(self.fint64) }) }
	if self.fuint32 != UInt::default() { w.write_with_tag(24, fn(w) { w.write_uint32(self.fuint32) }) }
	if self.fuint64 != UInt64::default() { w.write_with_tag(32, fn(w) { w.write_uint64(self.fuint64) }) }
	if self.fsint32 != Int::default() { w.write_with_tag(40, fn(w) { w.write_sint32(self.fsint32) }) }
	if self.fsint64 != Int64::default() { w.write_with_tag(48, fn(w) { w.write_sint64(self.fsint64) }) }
	if self.fbool != Bool::default() { w.write_with_tag(56, fn(w) { w.write_bool(self.fbool) }) }
	if self.f_foo_enum != FooEnum::default() { w.write_with_tag(64, fn(w) { w.write_enum(self.f_foo_enum) }) }
	if self.ffixed64 != UInt64::default() { w.write_with_tag(73, fn(w) { w.write_fixed64(self.ffixed64) }) }
	if self.fsfixed64 != Int64::default() { w.write_with_tag(81, fn(w) { w.write_sfixed64(self.fsfixed64) }) }
	if self.ffixed32 != UInt::default() { w.write_with_tag(93, fn(w) { w.write_fixed32(self.ffixed32) }) }
	if self.fsfixed32 != Int::default() { w.write_with_tag(101, fn(w) { w.write_sfixed32(self.fsfixed32) }) }
	if self.fdouble != Double::default() { w.write_with_tag(105, fn(w) { w.write_double(self.fdouble) }) }
	if self.ffloat != Float::default() { w.write_with_tag(117, fn(w) { w.write_float(self.ffloat) }) }
	if self.fbytes != Bytes::default() { w.write_with_tag(122, fn(w) { w.write_bytes(self.fbytes) }) }
	if self.fstring != String::default() { w.write_with_tag(130, fn(w) { w.write_string(self.fstring) }) }
	if self.fself_message != FooMessage::default() { w.write_with_tag(138, fn(w) { w.write_message(self.fself_message) }) }
	if self.fbar_message != BarMessage::default() { w.write_with_tag(146, fn(w) { w.write_message(self.fbar_message) }) }
	// REPEATED
	w.write_packed_with_tag(154, self.frepeated_int32, fn(w, m) { w.write_int32(m) }, fn(m) { @lib.Sized::size_of(m) })
	// REPEATED
	w.write_packed_with_tag(162, self.frepeated_packed_int32, fn(w, m) { w.write_int32(m) }, fn(m) { @lib.Sized::size_of(m) })
	// REPEATED
	w.write_packed_fixed_with_tag(170, self.frepeated_packed_float, fn(w, m) { w.write_float(m) }, fn(m) { 4 })
	if self.fbaz != BazMessage::default() { w.write_with_tag(186, fn(w) { w.write_message(self.fbaz) }) }
	if self.fnested != BazMessage_Nested::default() { w.write_with_tag(194, fn(w) { w.write_message(self.fnested) }) }
	if self.fnested_enum != BazMessage_Nested_NestedEnum::default() { w.write_with_tag(200, fn(w) { w.write_enum(self.fnested_enum) }) }
	// MAP
	// ONEOF
	// ONEOF
	// ONEOF
	// REPEATED
	w.write_packed_with_tag(242, self.frepeated_string, fn(w, m) { w.write_string(m) }, fn(m) { @lib.Sized::size_of(m.length()) })
	// REPEATED
	w.write_packed_with_tag(250, self.frepeated_baz_message, fn(w, m) { w.write_message(m) }, fn(m) { @lib.Sized::size_of(m) })
}

impl @lib.MessageWrite for FooMessage with get_size(self) {
	0
}

pub enum FooMessage_Testoneof {
  F1(Int)
  F2(Bool)
  F3(String)
  NotSet
} derive(Eq, Show)
pub fn FooMessage_Testoneof::default() -> FooMessage_Testoneof {
  NotSet
}
pub enum BazMessage_Nested_NestedEnum {
  BazMessage_Nested_Foo
  BazMessage_Nested_Bar
  BazMessage_Nested_Baz
} derive(Eq, Show)
pub fn to_enum(self : BazMessage_Nested_NestedEnum) -> @lib.Enum {
  match self {
    BazMessage_Nested_NestedEnum::BazMessage_Nested_Foo => 0
    BazMessage_Nested_NestedEnum::BazMessage_Nested_Bar => 1
    BazMessage_Nested_NestedEnum::BazMessage_Nested_Baz => 2
  }
}
pub fn BazMessage_Nested_NestedEnum::from_enum(i : @lib.Enum) -> BazMessage_Nested_NestedEnum {
  match i._ {
    0 => BazMessage_Nested_NestedEnum::BazMessage_Nested_Foo
    1 => BazMessage_Nested_NestedEnum::BazMessage_Nested_Bar
    2 => BazMessage_Nested_NestedEnum::BazMessage_Nested_Baz
    _ => Default::default()
  }
}
pub fn BazMessage_Nested_NestedEnum::default() -> BazMessage_Nested_NestedEnum {
  BazMessage_Nested_NestedEnum::BazMessage_Nested_Foo
}
impl @lib.Sized for BazMessage_Nested_NestedEnum with size_of(self : BazMessage_Nested_NestedEnum) {
  @lib.Sized::size_of(self.to_enum())
}
pub struct BazMessage_Nested_NestedMessage {
  mut f_nested : Int
} derive(Default, Eq, Show)
pub impl @lib.Read for BazMessage_Nested_NestedMessage with read(reader : @lib.Reader) {	let msg =   BazMessage_Nested_NestedMessage::default()
  while not(reader |> @lib.is_eof!()) {
    match (reader |> @lib.read_tag!()) {
      (1, _) => msg.f_nested = reader |> @lib.read_int32!()
      (_, wire) => reader |> @lib.read_unknown!(wire)
    }
  }
  msg
}
impl @lib.MessageWrite for BazMessage_Nested_NestedMessage with write_to_writer(self, w : @lib.Writer) {
	if self.fnested != Int::default() { w.write_with_tag(8, fn(w) { w.write_int32(self.fnested) }) }
}

impl @lib.MessageWrite for BazMessage_Nested_NestedMessage with get_size(self) {
	0
}

pub struct BazMessage_Nested {
  mut f_nested : BazMessage_Nested_NestedMessage
} derive(Default, Eq, Show)
pub impl @lib.Read for BazMessage_Nested with read(reader : @lib.Reader) {	let msg =   BazMessage_Nested::default()
  while not(reader |> @lib.is_eof!()) {
    match (reader |> @lib.read_tag!()) {
      (1, _) => msg.f_nested = ((reader |> @lib.Read::read!()) : BazMessage_Nested_NestedMessage)
      (_, wire) => reader |> @lib.read_unknown!(wire)
    }
  }
  msg
}
impl @lib.MessageWrite for BazMessage_Nested with write_to_writer(self, w : @lib.Writer) {
	if self.fnested != BazMessage_Nested_NestedMessage::default() { w.write_with_tag(10, fn(w) { w.write_message(self.fnested) }) }
}

impl @lib.MessageWrite for BazMessage_Nested with get_size(self) {
	0
}

pub struct BazMessage {
  mut nested : BazMessage_Nested
  mut b_int64 : Int64
  mut b_string : String
} derive(Default, Eq, Show)
pub impl @lib.Read for BazMessage with read(reader : @lib.Reader) {	let msg =   BazMessage::default()
  while not(reader |> @lib.is_eof!()) {
    match (reader |> @lib.read_tag!()) {
      (1, _) => msg.nested = ((reader |> @lib.Read::read!()) : BazMessage_Nested)
      (2, _) => msg.b_int64 = reader |> @lib.read_int64!()
      (3, _) => msg.b_string = reader |> @lib.read_string!()
      (_, wire) => reader |> @lib.read_unknown!(wire)
    }
  }
  msg
}
impl @lib.MessageWrite for BazMessage with write_to_writer(self, w : @lib.Writer) {
	if self.nested != BazMessage_Nested::default() { w.write_with_tag(10, fn(w) { w.write_message(self.nested) }) }
	if self.bint64 != Int64::default() { w.write_with_tag(16, fn(w) { w.write_int64(self.bint64) }) }
	if self.bstring != String::default() { w.write_with_tag(26, fn(w) { w.write_string(self.bstring) }) }
}

impl @lib.MessageWrite for BazMessage with get_size(self) {
	0
}

pub struct RepeatedMessage {
  mut bar_message : Array[BarMessage]
} derive(Default, Eq, Show)
pub impl @lib.Read for RepeatedMessage with read(reader : @lib.Reader) {	let msg =   RepeatedMessage::default()
  while not(reader |> @lib.is_eof!()) {
    match (reader |> @lib.read_tag!()) {
      (1, _) => msg.bar_message.push(((reader |> @lib.Read::read!()) : BarMessage))
      (_, wire) => reader |> @lib.read_unknown!(wire)
    }
  }
  msg
}
impl @lib.MessageWrite for RepeatedMessage with write_to_writer(self, w : @lib.Writer) {
	// REPEATED
	w.write_packed_with_tag(10, self.bar_message, fn(w, m) { w.write_message(m) }, fn(m) { @lib.Sized::size_of(m) })
}

impl @lib.MessageWrite for RepeatedMessage with get_size(self) {
	0
}

