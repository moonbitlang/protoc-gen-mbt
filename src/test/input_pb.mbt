// Code generated from src/test/input.proto by protoc-gen-mbt. DO NOT EDIT.

enum FooEnum {
	FooEnum_FIRST_VALUE
	FooEnum_SECOND_VALUE
} derive(Eq)

fn FooEnum::default() -> FooEnum {
	FooEnum::FooEnum_FIRST_VALUE
}

impl @lib.FromProto for FooEnum with from(i : Int) {
	match i {
		0 => FooEnum::FooEnum_FIRST_VALUE
		2 => FooEnum::FooEnum_SECOND_VALUE
		_ => Default::default()
	}
}

impl @lib.ToProto for FooEnum with into(self) {
	match self {
		FooEnum::FooEnum_FIRST_VALUE => 0
		FooEnum::FooEnum_SECOND_VALUE => 2
	}
}

struct BarMessage {
	mut bint32 : Int
} derive(Default, Eq)

impl @lib.MessageWrite for BarMessage with write_to_writer(self, w : @lib.Writer) {
	if self.bint32 != Int::default() { w.write_with_tag(8, fn(w) { w.write_int32(self.bint32) }) }
}

impl @lib.MessageWrite for BarMessage with get_size(self) {
	0
}

impl @lib.MessageRead for BarMessage with from_reader(br : @lib.BytesReader, b : Bytes) {
	let msg = 	BarMessage::default()
	while br.is_eof().not() {
		match br.next_tag?(b) {
			Ok(8) => msg.bint32 = br.read_int32!(b)
			Ok(t) => br.read_unknown!(b, t)
			Err(e) => raise e
		}
	}
	msg
}

struct FooMessage_FMapEntry {
	mut key : String
	mut value : Int
} derive(Default, Eq)

impl @lib.MessageWrite for FooMessage_FMapEntry with write_to_writer(self, w : @lib.Writer) {
	if self.key != String::default() { w.write_with_tag(10, fn(w) { w.write_string(self.key) }) }
	if self.value != Int::default() { w.write_with_tag(16, fn(w) { w.write_int32(self.value) }) }
}

impl @lib.MessageWrite for FooMessage_FMapEntry with get_size(self) {
	0
}

impl @lib.MessageRead for FooMessage_FMapEntry with from_reader(br : @lib.BytesReader, b : Bytes) {
	let msg = 	FooMessage_FMapEntry::default()
	while br.is_eof().not() {
		match br.next_tag?(b) {
			Ok(10) => msg.key = br.read_string!(b)
			Ok(16) => msg.value = br.read_int32!(b)
			Ok(t) => br.read_unknown!(b, t)
			Err(e) => raise e
		}
	}
	msg
}

struct FooMessage {
	mut fint32 : Int
	mut fint64 : Int64
	mut fuint32 : UInt
	mut fuint64 : UInt64
	mut fsint32 : Int
	mut fsint64 : Int64
	mut fbool : Bool
	mut f_foo_enum : FooEnum
	mut ffixed64 : UInt64
	mut fsfixed64 : Int64
	mut ffixed32 : UInt
	mut fsfixed32 : Int
	mut fdouble : Double
	mut ffloat : Float
	mut fbytes : Bytes
	mut fstring : String
	mut fself_message : FooMessage
	mut fbar_message : BarMessage
	mut frepeated_int32 : Array[Int]
	mut frepeated_packed_int32 : Array[Int]
	mut frepeated_packed_float : Array[Float]
	mut fbaz : BazMessage
	mut fnested : BazMessage_Nested
	mut fnested_enum : BazMessage_Nested_NestedEnum
	mut fmap : Map[String, Int]
	mut frepeated_string : Array[String]
	mut frepeated_baz_message : Array[BazMessage]
	mut foomessage_testoneof : FooMessage_TestOneof
} derive(Default, Eq)

enum FooMessage_TestOneof {
	F1(Int)
	F2(Bool)
	F3(String)
	OneofNone
} derive(Default, Eq)

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
	w.write_packed_with_tag(154, self.frepeated_int32, fn(w, m) { w.write_int32(m) }, fn(m) { @lib.sizeof_varint(m.to_uint64()) })
	// REPEATED
	w.write_packed_with_tag(162, self.frepeated_packed_int32, fn(w, m) { w.write_int32(m) }, fn(m) { @lib.sizeof_varint(m.to_uint64()) })
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
	w.write_packed_with_tag(242, self.frepeated_string, fn(w, m) { w.write_string(m) }, fn(m) { @lib.sizeof_len(m.len()) })
	// REPEATED
	w.write_packed_with_tag(250, self.frepeated_baz_message, fn(w, m) { w.write_message(m) }, fn(m) { @lib.sizeof_len(m.get_size()) })
}

impl @lib.MessageWrite for FooMessage with get_size(self) {
	0
}

impl @lib.MessageRead for FooMessage with from_reader(br : @lib.BytesReader, b : Bytes) {
	let msg = 	FooMessage::default()
	while br.is_eof().not() {
		match br.next_tag?(b) {
			Ok(8) => msg.fint32 = br.read_int32!(b)
			Ok(16) => msg.fint64 = br.read_int64!(b)
			Ok(24) => msg.fuint32 = br.read_uint32!(b)
			Ok(32) => msg.fuint64 = br.read_uint64!(b)
			Ok(40) => msg.fsint32 = br.read_sint32!(b)
			Ok(48) => msg.fsint64 = br.read_sint64!(b)
			Ok(56) => msg.fbool = br.read_bool!(b)
			Ok(64) => msg.f_foo_enum = br.read_enum!(b)
			Ok(73) => msg.ffixed64 = br.read_fixed64!(b)
			Ok(81) => msg.fsfixed64 = br.read_sfixed64!(b)
			Ok(93) => msg.ffixed32 = br.read_fixed32!(b)
			Ok(101) => msg.fsfixed32 = br.read_sfixed32!(b)
			Ok(105) => msg.fdouble = br.read_double!(b)
			Ok(117) => msg.ffloat = br.read_float!(b)
			Ok(122) => msg.fbytes = br.read_bytes!(b)
			Ok(130) => msg.fstring = br.read_string!(b)
			Ok(138) => msg.fself_message = br.read_message!(b)
			Ok(146) => msg.fbar_message = br.read_message!(b)
			Ok(154) => msg.frepeated_int32 = br.read_packed!(b, fn(br, b) { br.read_int32!(b) })
			Ok(162) => msg.frepeated_packed_int32 = br.read_packed!(b, fn(br, b) { br.read_int32!(b) })
			Ok(170) => msg.frepeated_packed_float = br.read_packed!(b, fn(br, b) { br.read_float!(b) })
			Ok(186) => msg.fbaz = br.read_message!(b)
			Ok(194) => msg.fnested = br.read_message!(b)
			Ok(200) => msg.fnested_enum = br.read_enum!(b)
			Ok(210) => msg.fmap = br.read_packed!(b, fn(br, b) { br.read_message!(b) })
			Ok(216) => msg.foomessage_testoneof = FooMessage_TestOneof::F1(br.read_int32!(b))
			Ok(224) => msg.foomessage_testoneof = FooMessage_TestOneof::F2(br.read_bool!(b))
			Ok(234) => msg.foomessage_testoneof = FooMessage_TestOneof::F3(br.read_string!(b))
			Ok(242) => msg.frepeated_string = br.read_packed!(b, fn(br, b) { br.read_string!(b) })
			Ok(250) => msg.frepeated_baz_message = br.read_packed!(b, fn(br, b) { br.read_message!(b) })
			Ok(t) => br.read_unknown!(b, t)
			Err(e) => raise e
		}
	}
	msg
}

enum BazMessage_Nested_NestedEnum {
	BazMessage_Nested_Foo
	BazMessage_Nested_Bar
	BazMessage_Nested_Baz
} derive(Eq)

fn BazMessage_Nested_NestedEnum::default() -> BazMessage_Nested_NestedEnum {
	BazMessage_Nested_NestedEnum::BazMessage_Nested_Foo
}

impl @lib.FromProto for BazMessage_Nested_NestedEnum with from(i : Int) {
	match i {
		0 => BazMessage_Nested_NestedEnum::BazMessage_Nested_Foo
		1 => BazMessage_Nested_NestedEnum::BazMessage_Nested_Bar
		2 => BazMessage_Nested_NestedEnum::BazMessage_Nested_Baz
		_ => Default::default()
	}
}

impl @lib.ToProto for BazMessage_Nested_NestedEnum with into(self) {
	match self {
		BazMessage_Nested_NestedEnum::BazMessage_Nested_Foo => 0
		BazMessage_Nested_NestedEnum::BazMessage_Nested_Bar => 1
		BazMessage_Nested_NestedEnum::BazMessage_Nested_Baz => 2
	}
}

struct BazMessage_Nested_NestedMessage {
	mut fnested : Int
} derive(Default, Eq)

impl @lib.MessageWrite for BazMessage_Nested_NestedMessage with write_to_writer(self, w : @lib.Writer) {
	if self.fnested != Int::default() { w.write_with_tag(8, fn(w) { w.write_int32(self.fnested) }) }
}

impl @lib.MessageWrite for BazMessage_Nested_NestedMessage with get_size(self) {
	0
}

impl @lib.MessageRead for BazMessage_Nested_NestedMessage with from_reader(br : @lib.BytesReader, b : Bytes) {
	let msg = 	BazMessage_Nested_NestedMessage::default()
	while br.is_eof().not() {
		match br.next_tag?(b) {
			Ok(8) => msg.fnested = br.read_int32!(b)
			Ok(t) => br.read_unknown!(b, t)
			Err(e) => raise e
		}
	}
	msg
}

struct BazMessage_Nested {
	mut fnested : BazMessage_Nested_NestedMessage
} derive(Default, Eq)

impl @lib.MessageWrite for BazMessage_Nested with write_to_writer(self, w : @lib.Writer) {
	if self.fnested != BazMessage_Nested_NestedMessage::default() { w.write_with_tag(10, fn(w) { w.write_message(self.fnested) }) }
}

impl @lib.MessageWrite for BazMessage_Nested with get_size(self) {
	0
}

impl @lib.MessageRead for BazMessage_Nested with from_reader(br : @lib.BytesReader, b : Bytes) {
	let msg = 	BazMessage_Nested::default()
	while br.is_eof().not() {
		match br.next_tag?(b) {
			Ok(10) => msg.fnested = br.read_message!(b)
			Ok(t) => br.read_unknown!(b, t)
			Err(e) => raise e
		}
	}
	msg
}

struct BazMessage {
	mut nested : BazMessage_Nested
	mut bint64 : Int64
	mut bstring : String
} derive(Default, Eq)

impl @lib.MessageWrite for BazMessage with write_to_writer(self, w : @lib.Writer) {
	if self.nested != BazMessage_Nested::default() { w.write_with_tag(10, fn(w) { w.write_message(self.nested) }) }
	if self.bint64 != Int64::default() { w.write_with_tag(16, fn(w) { w.write_int64(self.bint64) }) }
	if self.bstring != String::default() { w.write_with_tag(26, fn(w) { w.write_string(self.bstring) }) }
}

impl @lib.MessageWrite for BazMessage with get_size(self) {
	0
}

impl @lib.MessageRead for BazMessage with from_reader(br : @lib.BytesReader, b : Bytes) {
	let msg = 	BazMessage::default()
	while br.is_eof().not() {
		match br.next_tag?(b) {
			Ok(10) => msg.nested = br.read_message!(b)
			Ok(16) => msg.bint64 = br.read_int64!(b)
			Ok(26) => msg.bstring = br.read_string!(b)
			Ok(t) => br.read_unknown!(b, t)
			Err(e) => raise e
		}
	}
	msg
}

struct RepeatedMessage {
	mut bar_message : Array[BarMessage]
} derive(Default, Eq)

impl @lib.MessageWrite for RepeatedMessage with write_to_writer(self, w : @lib.Writer) {
	// REPEATED
	w.write_packed_with_tag(10, self.bar_message, fn(w, m) { w.write_message(m) }, fn(m) { @lib.sizeof_len(m.get_size()) })
}

impl @lib.MessageWrite for RepeatedMessage with get_size(self) {
	0
}

impl @lib.MessageRead for RepeatedMessage with from_reader(br : @lib.BytesReader, b : Bytes) {
	let msg = 	RepeatedMessage::default()
	while br.is_eof().not() {
		match br.next_tag?(b) {
			Ok(10) => msg.bar_message = br.read_packed!(b, fn(br, b) { br.read_message!(b) })
			Ok(t) => br.read_unknown!(b, t)
			Err(e) => raise e
		}
	}
	msg
}

