package main

import (
	proto3 "github.com/moonbitlang/input-go-gen/proto3"
)

var proto3_test_case_1 = &proto3.FooMessage{
	FInt32:    42,
	FInt64:    1234567890,
	FString:   "Hello, World!",
	FBytes:    []byte{0x01, 0x02, 0x03, 0x04},
	F_FooEnum: proto3.FooEnum_FIRST_VALUE,
}

var proto3_test_case_2 = &proto3.FooMessage{
	FInt32:         -42,
	FInt64:         -1234567890,
	FBytes:         []byte{0x05, 0x06, 0x07, 0x08},
	F_FooEnum:      proto3.FooEnum_SECOND_VALUE,
	FRepeatedInt32: []int32{1, 2, 3, 4, 5},
	FBool:          true,
	FString:        "Test String",
	FBarMessage: &proto3.BarMessage{
		BInt32: 100,
	},
}

var proto3_test_case_3 = &proto3.FooMessage{
	TestOneof: &proto3.FooMessage_F3{
		F3: "This is a oneof field",
	},
	FInt32:         1000,
	FInt64:         2000,
	FString:        "Another test string",
	FRepeatedInt32: []int32{10, 20, 30},
}

var proto3_test_case_4 = &proto3.FooMessage{
	FMap: map[string]int32{
		"key1": 1,
		"key2": 2,
		"key3": 3,
	},
	FDouble: 3.14,
	FBool:   true,
}

var proto3_test_case_5 = &proto3.FooMessage{
	FRepeatedInt32: []int32{10, 20, 30},
	FString:        "Repeated Int32 Test",
}

var proto3_test_case_6 = &proto3.FooMessage{
	FBarMessage: &proto3.BarMessage{
		BInt32: 100,
	},
}

var proto3_test_case_7 = &proto3.FooMessage{
	FInt32: -42,
	FInt64: -1234567890,
}

var proto3_test_case_8 = &proto3.FooMessage{
	FInt32: -1,
}

var proto3_test_case_9 = &proto3.FooMessage{
	FRepeatedString: []string{"test1", "test2", "test3"},
	FString:         "Test Repeated String",
}

var proto3_test_case_10 = &proto3.FooMessage{
	FUint32: 4294967295,           // max uint32
	FUint64: 18446744073709551615, // max uint64
}

var proto3_test_case_11 = &proto3.FooMessage{
	FSint32: -123,
	FSint64: -9876543210,
}

var proto3_test_case_12 = &proto3.FooMessage{
	FFixed32:  1000000000,
	FFixed64:  1000000000000000000,
	FSfixed32: -500000000,
	FSfixed64: -500000000000000000,
}

var proto3_test_case_13 = &proto3.FooMessage{
	FFloat:  3.14159,
	FDouble: 2.718281828459045,
}

var proto3_test_case_14 = &proto3.FooMessage{
	F_FooEnum: proto3.FooEnum_SECOND_VALUE,
	FString:   "Enum test",
}

var proto3_test_case_15 = &proto3.FooMessage{
	FRepeatedPackedInt32: []int32{-1, -2, -3, -4, -5},
	FRepeatedPackedFloat: []float32{1.1, 2.2, 3.3, 4.4, 5.5},
	FString:              "Negative repeated integers",
}

var proto3_test_case_16 = &proto3.FooMessage{
	FBaz: &proto3.BazMessage{
		BInt64:  999888777,
		BString: "Nested baz message",
		Nested: &proto3.BazMessage_Nested{
			FNested: &proto3.BazMessage_Nested_NestedMessage{
				FNested: 42,
			},
		},
	},
}

var proto3_test_case_17 = &proto3.FooMessage{
	FBytes: []byte("Binary data with special chars: \x00\x01\x02\xFF"),
}

var proto3_test_case_18 = &proto3.FooMessage{
	FString: "Unicode test: 你好世界 🌍 مرحبا بالعالم",
}

var proto3_test_case_19 = &proto3.FooMessage{
	TestOneof: &proto3.FooMessage_F1{
		F1: 12345,
	},
	FString: "Oneof with F1",
}

var proto3_test_case_20 = &proto3.FooMessage{
	TestOneof: &proto3.FooMessage_F2{
		F2: true,
	},
	FString: "Oneof with F2 bool",
}

var p3testCases = []*proto3.FooMessage{
	proto3_test_case_1,
	proto3_test_case_2,
	proto3_test_case_3,
	proto3_test_case_4,
	proto3_test_case_5,
	proto3_test_case_6,
	proto3_test_case_7,
	proto3_test_case_8,
	proto3_test_case_9,
	proto3_test_case_10,
	proto3_test_case_11,
	proto3_test_case_12,
	proto3_test_case_13,
	proto3_test_case_14,
	proto3_test_case_15,
	proto3_test_case_16,
	proto3_test_case_17,
	proto3_test_case_18,
	proto3_test_case_19,
	proto3_test_case_20,
}

//	var proto3_empty_test_case = &proto3.EmptyMessageWithField{
//		EmptyMessage: &proto3.EmptyMessage{},
//	}
var emptyTestCase = []byte{0x08, 0x00}
