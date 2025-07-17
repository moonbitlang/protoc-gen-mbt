package main

import (
	"flag"
	"fmt"
	"os"
	"path/filepath"

	proto3 "github.com/moonbit-community/input-go-gen/proto3"

	"google.golang.org/protobuf/proto"
)

func write_to_file(filename string, data []byte) error {
	return os.WriteFile(filename, data, 0644)
}

func read_from_file(filename string) ([]byte, error) {
	data, err := os.ReadFile(filename)
	if err != nil {
		return nil, fmt.Errorf("failed to read file %s: %w", filename, err)
	}
	return data, nil
}

func try_to_unmarshal(data []byte) (*proto3.FooMessage, error) {
	var foo proto3.FooMessage
	if err := proto.Unmarshal(data, &foo); err != nil {
		return nil, fmt.Errorf("failed to unmarshal data: %w", err)
	}
	return &foo, nil
}

func marshal_and_write_to_file(outputDir, filename string, foo *proto3.FooMessage) error {
	// Use deterministic marshaling to ensure consistent output
	options := proto.MarshalOptions{
		Deterministic: true,
	}
	data, err := options.Marshal(foo)
	if err != nil {
		return fmt.Errorf("failed to marshal FooMessage: %w", err)
	}

	// Create output directory if it doesn't exist
	if err := os.MkdirAll(outputDir, 0755); err != nil {
		return fmt.Errorf("failed to create output directory %s: %w", outputDir, err)
	}

	outputPath := filepath.Join(outputDir, fmt.Sprintf("%s.bin", filename))
	if err := write_to_file(outputPath, data); err != nil {
		return fmt.Errorf("failed to write to file %s: %w", outputPath, err)
	}

	return nil
}

var test_case_1 = &proto3.FooMessage{
	FInt32:    42,
	FInt64:    1234567890,
	FString:   "Hello, World!",
	FBytes:    []byte{0x01, 0x02, 0x03, 0x04},
	F_FooEnum: proto3.FooEnum_FIRST_VALUE,
}

var test_case_2 = &proto3.FooMessage{
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

var test_case_3 = &proto3.FooMessage{
	TestOneof: &proto3.FooMessage_F3{
		F3: "This is a oneof field",
	},
	FInt32:         1000,
	FInt64:         2000,
	FString:        "Another test string",
	FRepeatedInt32: []int32{10, 20, 30},
}

var test_case_4 = &proto3.FooMessage{
	FMap: map[string]int32{
		"key1": 1,
		"key2": 2,
		"key3": 3,
	},
	FDouble: 3.14,
	FBool:   true,
}

var test_case_5 = &proto3.FooMessage{
	FRepeatedInt32: []int32{10, 20, 30},
	FString:        "Repeated Int32 Test",
}

var test_case_6 = &proto3.FooMessage{
	FBarMessage: &proto3.BarMessage{
		BInt32: 100,
	},
}

var test_case_7 = &proto3.FooMessage{
	FInt32: -42,
	FInt64: -1234567890,
}

var test_case_8 = &proto3.FooMessage{
	FInt32: -1,
}

var test_case_9 = &proto3.FooMessage{
	FRepeatedString: []string{"test1", "test2", "test3"},
	FString:         "Test Repeated String",
}

var test_case_10 = &proto3.FooMessage{
	FUint32: 4294967295,           // max uint32
	FUint64: 18446744073709551615, // max uint64
}

var test_case_11 = &proto3.FooMessage{
	FSint32: -123,
	FSint64: -9876543210,
}

var test_case_12 = &proto3.FooMessage{
	FFixed32:  1000000000,
	FFixed64:  1000000000000000000,
	FSfixed32: -500000000,
	FSfixed64: -500000000000000000,
}

var test_case_13 = &proto3.FooMessage{
	FFloat:  3.14159,
	FDouble: 2.718281828459045,
}

var test_case_14 = &proto3.FooMessage{
	F_FooEnum: proto3.FooEnum_SECOND_VALUE,
	FString:   "Enum test",
}

var test_case_15 = &proto3.FooMessage{
	FRepeatedPackedInt32: []int32{-1, -2, -3, -4, -5},
	FRepeatedPackedFloat: []float32{1.1, 2.2, 3.3, 4.4, 5.5},
	FString:              "Negative repeated integers",
}

var test_case_16 = &proto3.FooMessage{
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

var test_case_17 = &proto3.FooMessage{
	FBytes: []byte("Binary data with special chars: \x00\x01\x02\xFF"),
}

var test_case_18 = &proto3.FooMessage{
	FString: "Unicode test: 你好世界 🌍 مرحبا بالعالم",
}

var test_case_19 = &proto3.FooMessage{
	TestOneof: &proto3.FooMessage_F1{
		F1: 12345,
	},
	FString: "Oneof with F1",
}

var test_case_20 = &proto3.FooMessage{
	TestOneof: &proto3.FooMessage_F2{
		F2: true,
	},
	FString: "Oneof with F2 bool",
}

func main() {
	var outputDir = flag.String("o", "./bin", "Output directory for generated binary files")
	flag.StringVar(outputDir, "output", "./bin", "Output directory for generated binary files")
	var help = flag.Bool("help", false, "Show help message")

	flag.Usage = func() {
		fmt.Fprintf(os.Stderr, "Usage: %s [OPTIONS]\n\n", os.Args[0])
		fmt.Fprintf(os.Stderr, "Generate protobuf test case binary files.\n\n")
		fmt.Fprintf(os.Stderr, "Options:\n")
		flag.PrintDefaults()
		fmt.Fprintf(os.Stderr, "\nExamples:\n")
		fmt.Fprintf(os.Stderr, "  %s                           # Generate files to ./bin\n", os.Args[0])
		fmt.Fprintf(os.Stderr, "  %s -o ./test-data            # Generate files to ./test-data\n", os.Args[0])
		fmt.Fprintf(os.Stderr, "  %s --output /tmp/protobuf    # Generate files to /tmp/protobuf\n", os.Args[0])
	}

	flag.Parse()
	if *help {
		flag.Usage()
		os.Exit(0)
	}

	p3testCases := []*proto3.FooMessage{
		test_case_1,
		test_case_2,
		test_case_3,
		test_case_4,
		test_case_5,
		test_case_6,
		test_case_7,
		test_case_8,
		test_case_9,
		test_case_10,
		test_case_11,
		test_case_12,
		test_case_13,
		test_case_14,
		test_case_15,
		test_case_16,
		test_case_17,
		test_case_18,
		test_case_19,
		test_case_20,
	}

	for i, testCase := range p3testCases {
		name := fmt.Sprintf("proto3_test_case_%d", i+1)
		if err := marshal_and_write_to_file(*outputDir, name, testCase); err != nil {
			fmt.Fprintf(os.Stderr, "Error generating %s: %v\n", name, err)
			os.Exit(1)
		}
	}
}
