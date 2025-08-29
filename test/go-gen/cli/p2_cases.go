package main

import (
	proto2 "github.com/moonbitlang/input-go-gen/proto2"
	"google.golang.org/protobuf/proto"
)

// Test case for proto2 with various field types
var proto2_test_case_1 = &proto2.FooMessageP2{
	FInt32:    proto.Int32(42),
	FInt64:    proto.Int64(1234567890),
	FString:   proto.String("Hello, World!"),
	FBytes:    []byte{0x01, 0x02, 0x03, 0x04},
	F_FooEnum: proto2.FooEnumP2(proto2.FooEnumP2_FIRST_VALUEX).Enum(),
}

// Packed repeated integers for proto2
var proto2_test_case_2 = &proto2.FooMessageP2{
	FInt32:               proto.Int32(42),
	FInt64:               proto.Int64(1234567890),
	FRepeatedInt32:       []int32{1, 2, 3, 4, 5},
	FRepeatedPackedInt32: []int32{6, 7, 8, 9, 10},
}

// Default test case for proto2
var proto2_test_case_3 = &proto2.FooMessageP2{
	FInt32:         proto.Int32(-42),
	FInt64:         proto.Int64(-1234567890),
	FDefaultBool:   proto.Bool(false),
	FDefaultEnum:   proto2.FooEnumP2(proto2.FooEnumP2_FIRST_VALUEX).Enum(),
	FDefaultDouble: proto.Float64(3.2229),
}

// Test case with all numeric types
var proto2_test_case_4 = &proto2.FooMessageP2{
	FInt32:    proto.Int32(2147483647),            // max int32
	FInt64:    proto.Int64(9223372036854775807),   // max int64
	FUint32:   proto.Uint32(4294967295),           // max uint32
	FUint64:   proto.Uint64(18446744073709551615), // max uint64
	FSint32:   proto.Int32(-2147483648),           // min int32
	FSint64:   proto.Int64(-9223372036854775808),  // min int64
	FFixed32:  proto.Uint32(123456789),
	FFixed64:  proto.Uint64(987654321012345),
	FSfixed32: proto.Int32(-123456789),
	FSfixed64: proto.Int64(-987654321012345),
	FDouble:   proto.Float64(123.456789),
	FFloat:    proto.Float32(78.9012),
}

// Test case with boolean and enum variations
var proto2_test_case_5 = &proto2.FooMessageP2{
	FInt32:    proto.Int32(100),
	FInt64:    proto.Int64(200),
	FBool:     proto.Bool(true),
	F_FooEnum: proto2.FooEnumP2(proto2.FooEnumP2_SECOND_VALUEX).Enum(),
}

// Test case with nested messages
var proto2_test_case_6 = &proto2.FooMessageP2{
	FInt32: proto.Int32(300),
	FInt64: proto.Int64(400),
	FBarMessage: &proto2.BarMessageP2{
		BInt32: proto.Int32(500),
	},
	FBaz: &proto2.BazMessageP2{
		BInt64:  proto.Int64(600),
		BString: proto.String("nested baz message"),
		Nested: &proto2.BazMessageP2_Nested{
			FNested: &proto2.BazMessageP2_Nested_NestedMessage{
				FNested: proto.Int32(700),
			},
		},
	},
}

// Test case with repeated fields
var proto2_test_case_7 = &proto2.FooMessageP2{
	FInt32:               proto.Int32(800),
	FInt64:               proto.Int64(900),
	FRepeatedInt32:       []int32{10, 20, 30, 40, 50},
	FRepeatedPackedInt32: []int32{60, 70, 80, 90, 100},
	FRepeatedPackedFloat: []float32{1.1, 2.2, 3.3, 4.4, 5.5},
	FRepeatedString:      []string{"first", "second", "third"},
	FRepeatedBazMessage: []*proto2.BazMessageP2{
		{
			BInt64:  proto.Int64(1001),
			BString: proto.String("first repeated baz"),
		},
		{
			BInt64:  proto.Int64(1002),
			BString: proto.String("second repeated baz"),
		},
	},
}

// Test case with empty/zero values
var proto2_test_case_8 = &proto2.FooMessageP2{
	FInt32:  proto.Int32(0),
	FInt64:  proto.Int64(0),
	FString: proto.String(""),
	FBytes:  []byte{},
	FBool:   proto.Bool(false),
}

// Test case with special characters and edge cases
var proto2_test_case_9 = &proto2.FooMessageP2{
	FInt32:  proto.Int32(-1),
	FInt64:  proto.Int64(-1),
	FString: proto.String("Special chars: !@#$%^&*()_+{}|:<>?[]\\;',./"),
	FBytes:  []byte{0x00, 0xFF, 0x7F, 0x80, 0x01, 0xFE},
}

// Test case with unicode strings
var proto2_test_case_10 = &proto2.FooMessageP2{
	FInt32:  proto.Int32(12345),
	FInt64:  proto.Int64(67890),
	FString: proto.String("Unicode: 你好世界 🌍 こんにちは العالم"),
	FBytes:  []byte("UTF-8 bytes: 测试"),
}

// Test case with nested enum
var proto2_test_case_11 = &proto2.FooMessageP2{
	FInt32:      proto.Int32(111),
	FInt64:      proto.Int64(222),
	FNestedEnum: proto2.BazMessageP2_Nested_NestedEnum(proto2.BazMessageP2_Nested_Bar).Enum(),
	FNested: &proto2.BazMessageP2_Nested{
		FNested: &proto2.BazMessageP2_Nested_NestedMessage{
			FNested: proto.Int32(333),
		},
	},
}

// Test case with optional fields set to non-default values
var proto2_test_case_12 = &proto2.FooMessageP2{
	FInt32:          proto.Int32(444),
	FInt64:          proto.Int64(555),
	FOptionalString: proto.String("optional string value"),
	F1:              proto.Int32(666),
	F2:              proto.Bool(true),
	F3:              proto.String("f3 value"),
}

var p2testCases = []*proto2.FooMessageP2{
	proto2_test_case_1,
	proto2_test_case_2,
	proto2_test_case_3,
	proto2_test_case_4,
	proto2_test_case_5,
	proto2_test_case_6,
	proto2_test_case_7,
	proto2_test_case_8,
	proto2_test_case_9,
	proto2_test_case_10,
	proto2_test_case_11,
	proto2_test_case_12,
}
