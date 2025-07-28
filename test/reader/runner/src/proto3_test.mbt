///|
/// 
fn from_file_to_proto_message(file : String) -> @gen_proto3.FooMessage {
  let bytes = (try? @fs.read_file_to_bytes(file)).unwrap()
  let reader = @protobuf.BytesReader::from_bytes(bytes)
  let mut buf = @gen_proto3.FooMessage::default()
  async_run(async fn() -> Unit noraise {
    buf = @gen_proto3.FooMessage::read(reader) catch {
      _ => @gen_proto3.FooMessage::default()
    }
  })
  buf
}

///|
test "proto3_test_case_1" {
  @json.inspect(from_file_to_proto_message("../bin/proto3_test_case_1.bin"), content={
    "fInt32": 42,
    "fInt64": "1234567890",
    "fBytes": "AQIDBA==",
    "fString": "Hello, World!",
  })
}

///|
test "proto3_test_case_2" {
  @json.inspect(from_file_to_proto_message("../bin/proto3_test_case_2.bin"), content={
    "fInt32": -42,
    "fInt64": "-1234567890",
    "fBool": true,
    "fFooEnum": "SECOND_VALUE",
    "fBytes": "BQYHCA==",
    "fString": "Test String",
    "fBarMessage": { "bInt32": 100 },
    "fRepeatedInt32": [1, 2, 3, 4, 5],
  })
}

///|
test "proto3_test_case_3" {
  @json.inspect(from_file_to_proto_message("../bin/proto3_test_case_3.bin"), content={
    "fInt32": 1000,
    "fInt64": "2000",
    "fString": "Another test string",
    "fRepeatedInt32": [10, 20, 30],
  })
}

///|
test "proto3_test_case_4" {
  @json.inspect(from_file_to_proto_message("../bin/proto3_test_case_4.bin"), content={
    "fBool": true,
    "fDouble": 3.14,
    "fMap": { "key1": 1, "key2": 2, "key3": 3 },
  })
}

///|
test "proto3_test_case_5" {
  @json.inspect(from_file_to_proto_message("../bin/proto3_test_case_5.bin"), content={
    "fString": "Repeated Int32 Test",
    "fRepeatedInt32": [10, 20, 30],
  })
}

///|
test "proto3_test_case_6" {
  @json.inspect(from_file_to_proto_message("../bin/proto3_test_case_6.bin"), content={
    "fBarMessage": { "bInt32": 100 },
  })
}

///|
test "proto3_test_case_7" {
  @json.inspect(from_file_to_proto_message("../bin/proto3_test_case_7.bin"), content={
    "fInt32": -42,
    "fInt64": "-1234567890",
  })
}

///|
test "proto3_test_case_8" {
  @json.inspect(from_file_to_proto_message("../bin/proto3_test_case_8.bin"), content={
    "fInt32": -1,
  })
}

///|
test "proto3_test_case_9" {
  @json.inspect(from_file_to_proto_message("../bin/proto3_test_case_9.bin"), content={
    "fString": "Test Repeated String",
    "fRepeatedString": ["test1", "test2", "test3"],
  })
}

///|
test "proto3_test_case_10" {
  @json.inspect(from_file_to_proto_message("../bin/proto3_test_case_10.bin"), content={
    "fUint32": 4294967295,
    "fUint64": "18446744073709551615",
  })
}

///|
test "proto3_test_case_11" {
  @json.inspect(from_file_to_proto_message("../bin/proto3_test_case_11.bin"), content={
    "fSint32": -123,
    "fSint64": "-9876543210",
  })
}

///|
test "proto3_test_case_12" {
  @json.inspect(from_file_to_proto_message("../bin/proto3_test_case_12.bin"), content={
    "fFixed64": "1000000000000000000",
    "fSfixed64": "-500000000000000000",
    "fFixed32": 1000000000,
    "fSfixed32": -500000000,
  })
}

///|
test "proto3_test_case_13" {
  @json.inspect(from_file_to_proto_message("../bin/proto3_test_case_13.bin"), content={
    "fDouble": 2.718281828459045,
    "fFloat": 3.141590118408203,
  })
}

///|
test "proto3_test_case_14" {
  @json.inspect(from_file_to_proto_message("../bin/proto3_test_case_14.bin"), content={
    "fFooEnum": "SECOND_VALUE",
    "fString": "Enum test",
  })
}

///|
test "proto3_test_case_15" {
  @json.inspect(from_file_to_proto_message("../bin/proto3_test_case_15.bin"), content={
    "fString": "Negative repeated integers",
    "fRepeatedPackedInt32": [-1, -2, -3, -4, -5],
    "fRepeatedPackedFloat": [
      1.100000023841858, 2.200000047683716, 3.299999952316284, 4.400000095367432,
      5.5,
    ],
  })
}

///|
test "proto3_test_case_16" {
  let json = from_file_to_proto_message("../bin/proto3_test_case_16.bin")
  @json.inspect(json, content={
    "fBaz": {
      "nested": { "fNested": { "fNested": 42 } },
      "bInt64": "999888777",
      "bString": "Nested baz message",
    },
  })
  let message : @gen_proto3.FooMessage = @json.from_json(json.to_json())
  @json.inspect(message, content={
    "fBaz": {
      "nested": { "fNested": { "fNested": 42 } },
      "bInt64": "999888777",
      "bString": "Nested baz message",
    },
  })
}

///|
test "proto3_test_case_17" {
  let json = from_file_to_proto_message("../bin/proto3_test_case_17.bin")
  @json.inspect(json, content={
    "fBytes": "QmluYXJ5IGRhdGEgd2l0aCBzcGVjaWFsIGNoYXJzOiAAAQL/",
  })
  let message : @gen_proto3.FooMessage = @json.from_json(json.to_json())
  @json.inspect(message, content={
    "fBytes": "QmluYXJ5IGRhdGEgd2l0aCBzcGVjaWFsIGNoYXJzOiAAAQL/",
  })
}

///|
test "proto3_test_case_18" {
  let json = from_file_to_proto_message("../bin/proto3_test_case_18.bin")
  @json.inspect(json, content={
    "fString": "Unicode test: 你好世界 🌍 مرحبا بالعالم",
  })
  let message : @gen_proto3.FooMessage = @json.from_json(json.to_json())
  @json.inspect(message, content={
    "fString": "Unicode test: 你好世界 🌍 مرحبا بالعالم",
  })
}

///|
test "proto3_test_case_19" {
  let json = from_file_to_proto_message("../bin/proto3_test_case_19.bin")
  @json.inspect(json, content={ "fString": "Oneof with F1" })
  let message : @gen_proto3.FooMessage = @json.from_json(json.to_json())
  @json.inspect(message, content={ "fString": "Oneof with F1" })
}

///|
test "proto3_test_case_20" {
  let json = from_file_to_proto_message("../bin/proto3_test_case_20.bin")
  @json.inspect(json, content={ "fString": "Oneof with F2 bool" })
  let message : @gen_proto3.FooMessage = @json.from_json(json.to_json())
  @json.inspect(message, content={ "fString": "Oneof with F2 bool" })
}

///| 
fn from_file_to_empty_message(
  file : String,
) -> @gen_proto3.EmptyMessageWithField {
  let bytes = (try? @fs.read_file_to_bytes(file)).unwrap()
  let reader = @protobuf.BytesReader::from_bytes(bytes)
  let mut buf = @gen_proto3.EmptyMessageWithField::default()
  async_run(async fn() -> Unit noraise {
    buf = @gen_proto3.EmptyMessageWithField::read(reader) catch {
      _ => @gen_proto3.EmptyMessageWithField::default()
    }
  })
  buf
}

///|
test "proto3_test_case_22" {
  let json = from_file_to_empty_message("../bin/proto3_empty.bin")
  @json.inspect(json, content={})
  let message : @gen_proto3.EmptyMessageWithField = @json.from_json(
    json.to_json(),
  )
  @json.inspect(message, content={})
}
