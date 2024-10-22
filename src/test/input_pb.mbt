// Code generated from src/test/input.proto by protoc-gen-mbt. DO NOT EDIT.

enum FooEnum {
	FooEnum_FIRST_VALUE
	FooEnum_SECOND_VALUE
}

impl Default for FooEnum with default() {
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
} derive(Default)

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
} derive(Default)

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
	mut fmap : Array[FooMessage_FMapEntry]
	mut frepeated_string : Array[String]
	mut frepeated_baz_message : Array[BazMessage]
	mut foomessage_testoneof : FooMessage_TestOneof
} derive(Default)

enum FooMessage_TestOneof {
	F1(Int)
	F2(Bool)
	F3(String)
	None
} derive(Default)

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
}

impl Default for BazMessage_Nested_NestedEnum with default() {
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
} derive(Default)

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
} derive(Default)

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
} derive(Default)

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
} derive(Default)

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
