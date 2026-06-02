///|
/// 
fn[T : Default + @protobuf.AsyncRead] from_bin_to_proto_message(
  file : String,
) -> T {
  let bytes = try! @fs.read_file_to_bytes(file)
  let reader = @protobuf.BytesReader::from_bytes(bytes)
  let mut buf = T::default()
  async_run(async fn() -> Unit noraise {
    buf = @protobuf.AsyncRead::read(reader) catch { _ => T::default() }
  })
  buf
}

///|
fn[T : Default + @json.FromJson] from_json_to_proto_message(file : String) -> T {
  let string = try! @fs.read_file_to_string(file)
  let json = @json.parse(string) catch {
    err => {
      println("Error parsing JSON: \{err}")
      Json::null()
    }
  }
  @json.from_json(json) catch {
    err => {
      println("Error converting JSON to proto message: \{err}")
      T::default()
    }
  }
}

///|
fn async_run(f : async () -> Unit noraise) -> Unit = "%async.run"

///|
fn unpacked_int32_bytes(
  field_number : UInt,
  values : Array[Int],
) -> Bytes raise {
  let writer = @buffer.Buffer::Buffer()
  for value in values {
    writer |> @protobuf.write_tag((field_number, 0U))
    writer |> @protobuf.write_int32(value)
  }
  writer.to_bytes()
}

///|
fn unpacked_float_bytes(
  field_number : UInt,
  values : Array[Float],
) -> Bytes raise {
  let writer = @buffer.Buffer::Buffer()
  for value in values {
    writer |> @protobuf.write_tag((field_number, 5U))
    writer |> @protobuf.write_float(value)
  }
  writer.to_bytes()
}

///|
fn unpacked_enum_bytes(
  field_number : UInt,
  values : Array[@protobuf.Enum],
) -> Bytes raise {
  let writer = @buffer.Buffer::Buffer()
  for value in values {
    writer |> @protobuf.write_tag((field_number, 0U))
    writer |> @protobuf.write_enum(value)
  }
  writer.to_bytes()
}

///|
fn enum_wire_entries(
  bytes : Bytes,
  field_number : UInt,
) -> Array[(UInt, UInt)] raise {
  let reader = @protobuf.BytesReader::from_bytes(bytes) as &@protobuf.Reader
  let entries = []
  while true {
    let tag_result = try reader |> @protobuf.read_tag() catch {
      _ => None
    } noraise {
      v => Some(v)
    }
    match tag_result {
      Some((tag, wire_type)) =>
        if tag == field_number {
          match wire_type {
            0 => entries.push((wire_type, (reader |> @protobuf.read_enum()).0))
            2 => {
              let values = reader
                |> @protobuf.read_packed(@protobuf.read_enum, None)
              for value in values {
                entries.push((wire_type, value.0))
              }
            }
            _ => reader |> @protobuf.read_unknown(wire_type)
          }
        } else {
          reader |> @protobuf.read_unknown(wire_type)
        }
      None => break
    }
  }
  entries
}

///|
test "proto3_repeated_packable_accepts_unpacked_encoding" {
  let bytes = unpacked_int32_bytes(19U, [10, 20, 30])
  let reader = @protobuf.BytesReader::from_bytes(bytes) as &@protobuf.Reader
  let message : @gen_proto3.FooMessage = @protobuf.Read::read(reader)
  @debug.assert_eq(message.f_repeated_int32, [10, 20, 30])
}

///|
test "proto3_explicit_packed_int32_accepts_unpacked_encoding" {
  let bytes = unpacked_int32_bytes(20U, [6, 7, 8])
  let reader = @protobuf.BytesReader::from_bytes(bytes) as &@protobuf.Reader
  let message : @gen_proto3.FooMessage = @protobuf.Read::read(reader)
  @debug.assert_eq(message.f_repeated_packed_int32, [6, 7, 8])
}

///|
test "proto3_repeated_float_accepts_unpacked_encoding" {
  let bytes = unpacked_float_bytes(21U, [1, 2.5])
  let reader = @protobuf.BytesReader::from_bytes(bytes) as &@protobuf.Reader
  let message : @gen_proto3.FooMessage = @protobuf.Read::read(reader)
  @debug.assert_eq(message.f_repeated_packed_float, [1, 2.5])
}

///|
test "proto3_async_repeated_packable_accepts_unpacked_encoding" {
  let bytes = unpacked_int32_bytes(19U, [10, 20, 30])
  let reader = @protobuf.BytesReader::from_bytes(bytes)
  let mut message = @gen_proto3.FooMessage::default()
  async_run(async fn() -> Unit noraise {
    message = @protobuf.AsyncRead::read(reader) catch {
      _ => @gen_proto3.FooMessage::default()
    }
  })
  @debug.assert_eq(message.f_repeated_int32, [10, 20, 30])
}

///|
test "proto3_repeated_enum_writer_round_trips_packed_encoding" {
  let message = @gen_proto3.FooMessage::default()
  message.f_repeated_packed_enum.push(@gen_proto3.FooEnum::FIRST_VALUE)
  message.f_repeated_packed_enum.push(@gen_proto3.FooEnum::SECOND_VALUE)
  let writer = @buffer.Buffer::Buffer()
  @protobuf.Write::write(message, writer)
  let reader = @protobuf.BytesReader::from_bytes(writer.to_bytes())
    as &@protobuf.Reader
  let decoded : @gen_proto3.FooMessage = @protobuf.Read::read(reader)
  @debug.assert_eq(decoded.f_repeated_packed_enum, [
    @gen_proto3.FooEnum::FIRST_VALUE,
    @gen_proto3.FooEnum::SECOND_VALUE,
  ])
}

///|
test "proto3_repeated_enum_accepts_unpacked_encoding" {
  let bytes = unpacked_enum_bytes(34U, [
    @gen_proto3.FooEnum::FIRST_VALUE.to_enum(),
    @gen_proto3.FooEnum::SECOND_VALUE.to_enum(),
  ])
  let reader = @protobuf.BytesReader::from_bytes(bytes) as &@protobuf.Reader
  let message : @gen_proto3.FooMessage = @protobuf.Read::read(reader)
  @debug.assert_eq(message.f_repeated_packed_enum, [
    @gen_proto3.FooEnum::FIRST_VALUE,
    @gen_proto3.FooEnum::SECOND_VALUE,
  ])
}

///|
test "proto3_explicit_unpacked_enum_writer_emits_unpacked_encoding" {
  let message = @gen_proto3.FooMessage::default()
  message.f_repeated_unpacked_enum.push(@gen_proto3.FooEnum::FIRST_VALUE)
  message.f_repeated_unpacked_enum.push(@gen_proto3.FooEnum::SECOND_VALUE)
  let writer = @buffer.Buffer::Buffer()
  @protobuf.Write::write(message, writer)
  @debug.assert_eq(enum_wire_entries(writer.to_bytes(), 35U), [
    (0U, @gen_proto3.FooEnum::FIRST_VALUE.to_enum().0),
    (0U, @gen_proto3.FooEnum::SECOND_VALUE.to_enum().0),
  ])
}

///|
test "proto3_test_case_1" {
  let json : @gen_proto3.FooMessage = from_bin_to_proto_message(
    "../bin/proto3_test_case_1.bin",
  )
  json_inspect(json, content={
    "fInt32": 42,
    "fInt64": "1234567890",
    "fBytes": "AQIDBA==",
    "fString": "Hello, World!",
  })
  let file_json : @gen_proto3.FooMessage = from_json_to_proto_message(
    "../bin/proto3_test_case_1.json",
  )
  @debug.assert_eq(file_json, json)
}

///|
test "proto3_test_case_2" {
  let json : @gen_proto3.FooMessage = from_bin_to_proto_message(
    "../bin/proto3_test_case_2.bin",
  )
  json_inspect(json, content={
    "fInt32": -42,
    "fInt64": "-1234567890",
    "fBool": true,
    "fFooEnum": "SECOND_VALUE",
    "fBytes": "BQYHCA==",
    "fString": "Test String",
    "fBarMessage": { "bInt32": 100 },
    "fRepeatedInt32": [1, 2, 3, 4, 5],
  })
  let file_json : @gen_proto3.FooMessage = from_json_to_proto_message(
    "../bin/proto3_test_case_2.json",
  )
  @debug.assert_eq(file_json, json)
}

///|
test "proto3_test_case_3" {
  let json : @gen_proto3.FooMessage = from_bin_to_proto_message(
    "../bin/proto3_test_case_3.bin",
  )
  json_inspect(json, content={
    "fInt32": 1000,
    "fInt64": "2000",
    "fString": "Another test string",
    "fRepeatedInt32": [10, 20, 30],
    "f3": "This is a oneof field",
  })
  let file_json : @gen_proto3.FooMessage = from_json_to_proto_message(
    "../bin/proto3_test_case_3.json",
  )
  @debug.assert_eq(file_json, json)
}

///|
test "proto3_test_case_4" {
  let json : @gen_proto3.FooMessage = from_bin_to_proto_message(
    "../bin/proto3_test_case_4.bin",
  )
  json_inspect(json, content={
    "fBool": true,
    "fDouble": 3.14,
    "fMap": { "key1": 1, "key2": 2, "key3": 3 },
  })
  let file_json : @gen_proto3.FooMessage = from_json_to_proto_message(
    "../bin/proto3_test_case_4.json",
  )
  @debug.assert_eq(file_json, json)
}

///|
test "proto3_test_case_5" {
  let json : @gen_proto3.FooMessage = from_bin_to_proto_message(
    "../bin/proto3_test_case_5.bin",
  )
  json_inspect(json, content={
    "fString": "Repeated Int32 Test",
    "fRepeatedInt32": [10, 20, 30],
  })
  let file_json : @gen_proto3.FooMessage = from_json_to_proto_message(
    "../bin/proto3_test_case_5.json",
  )
  @debug.assert_eq(file_json, json)
}

///|
test "proto3_test_case_6" {
  let json : @gen_proto3.FooMessage = from_bin_to_proto_message(
    "../bin/proto3_test_case_6.bin",
  )
  json_inspect(json, content={ "fBarMessage": { "bInt32": 100 } })
  let file_json : @gen_proto3.FooMessage = from_json_to_proto_message(
    "../bin/proto3_test_case_6.json",
  )
  @debug.assert_eq(file_json, json)
}

///|
test "proto3_test_case_7" {
  let json : @gen_proto3.FooMessage = from_bin_to_proto_message(
    "../bin/proto3_test_case_7.bin",
  )
  json_inspect(json, content={ "fInt32": -42, "fInt64": "-1234567890" })
  let file_json : @gen_proto3.FooMessage = from_json_to_proto_message(
    "../bin/proto3_test_case_7.json",
  )
  @debug.assert_eq(file_json, json)
}

///|
test "proto3_test_case_8" {
  let json : @gen_proto3.FooMessage = from_bin_to_proto_message(
    "../bin/proto3_test_case_8.bin",
  )
  json_inspect(json, content={ "fInt32": -1 })
  let file_json : @gen_proto3.FooMessage = from_json_to_proto_message(
    "../bin/proto3_test_case_8.json",
  )
  @debug.assert_eq(file_json, json)
}

///|
test "proto3_test_case_9" {
  let json : @gen_proto3.FooMessage = from_bin_to_proto_message(
    "../bin/proto3_test_case_9.bin",
  )
  json_inspect(json, content={
    "fString": "Test Repeated String",
    "fRepeatedString": ["test1", "test2", "test3"],
  })
  let file_json : @gen_proto3.FooMessage = from_json_to_proto_message(
    "../bin/proto3_test_case_9.json",
  )
  @debug.assert_eq(file_json, json)
}

///|
test "proto3_test_case_10" {
  let json : @gen_proto3.FooMessage = from_bin_to_proto_message(
    "../bin/proto3_test_case_10.bin",
  )
  json_inspect(json, content={
    "fUint32": 4294967295,
    "fUint64": "18446744073709551615",
  })
  let file_json : @gen_proto3.FooMessage = from_json_to_proto_message(
    "../bin/proto3_test_case_10.json",
  )
  @debug.assert_eq(file_json, json)
}

///|
test "proto3_test_case_11" {
  let json : @gen_proto3.FooMessage = from_bin_to_proto_message(
    "../bin/proto3_test_case_11.bin",
  )
  json_inspect(json, content={ "fSint32": -123, "fSint64": "-9876543210" })
  let file_json : @gen_proto3.FooMessage = from_json_to_proto_message(
    "../bin/proto3_test_case_11.json",
  )
  @debug.assert_eq(file_json, json)
}

///|
test "proto3_test_case_12" {
  let json : @gen_proto3.FooMessage = from_bin_to_proto_message(
    "../bin/proto3_test_case_12.bin",
  )
  json_inspect(json, content={
    "fFixed64": "1000000000000000000",
    "fSfixed64": "-500000000000000000",
    "fFixed32": 1000000000,
    "fSfixed32": -500000000,
  })
  let file_json : @gen_proto3.FooMessage = from_json_to_proto_message(
    "../bin/proto3_test_case_12.json",
  )
  @debug.assert_eq(file_json, json)
}

///|
test "proto3_test_case_13" {
  let json : @gen_proto3.FooMessage = from_bin_to_proto_message(
    "../bin/proto3_test_case_13.bin",
  )
  json_inspect(json, content={
    "fDouble": 2.718281828459045,
    "fFloat": 3.141590118408203,
  })
  let file_json : @gen_proto3.FooMessage = from_json_to_proto_message(
    "../bin/proto3_test_case_13.json",
  )
  @debug.assert_eq(file_json, json)
}

///|
test "proto3_test_case_14" {
  let json : @gen_proto3.FooMessage = from_bin_to_proto_message(
    "../bin/proto3_test_case_14.bin",
  )
  json_inspect(json, content={
    "fFooEnum": "SECOND_VALUE",
    "fString": "Enum test",
  })
  let file_json : @gen_proto3.FooMessage = from_json_to_proto_message(
    "../bin/proto3_test_case_14.json",
  )
  @debug.assert_eq(file_json, json)
}

///|
test "proto3_test_case_15" {
  let json : @gen_proto3.FooMessage = from_bin_to_proto_message(
    "../bin/proto3_test_case_15.bin",
  )
  json_inspect(json, content={
    "fString": "Negative repeated integers",
    "fRepeatedPackedInt32": [-1, -2, -3, -4, -5],
    "fRepeatedPackedFloat": [
      1.100000023841858, 2.200000047683716, 3.299999952316284, 4.400000095367432,
      5.5,
    ],
  })
  let file_json : @gen_proto3.FooMessage = from_json_to_proto_message(
    "../bin/proto3_test_case_15.json",
  )
  @debug.assert_eq(file_json, json)
}

///|
test "proto3_test_case_16" {
  let json = (
    from_bin_to_proto_message("../bin/proto3_test_case_16.bin") :
    @gen_proto3.FooMessage)
  json_inspect(json, content={
    "fBaz": {
      "nested": { "fNested": { "fNested": 42 } },
      "bInt64": "999888777",
      "bString": "Nested baz message",
    },
  })
  let message : @gen_proto3.FooMessage = @json.from_json(json.to_json())
  json_inspect(message, content={
    "fBaz": {
      "nested": { "fNested": { "fNested": 42 } },
      "bInt64": "999888777",
      "bString": "Nested baz message",
    },
  })
}

///|
test "proto3_test_case_17" {
  let json = (
    from_bin_to_proto_message("../bin/proto3_test_case_17.bin") :
    @gen_proto3.FooMessage)
  json_inspect(json, content={
    "fBytes": "QmluYXJ5IGRhdGEgd2l0aCBzcGVjaWFsIGNoYXJzOiAAAQL/",
  })
  let message : @gen_proto3.FooMessage = @json.from_json(json.to_json())
  json_inspect(message, content={
    "fBytes": "QmluYXJ5IGRhdGEgd2l0aCBzcGVjaWFsIGNoYXJzOiAAAQL/",
  })
}

///|
test "proto3_test_case_18" {
  let json = (
    from_bin_to_proto_message("../bin/proto3_test_case_18.bin") :
    @gen_proto3.FooMessage)
  json_inspect(json, content={
    "fString": "Unicode test: 你好世界 🌍 مرحبا بالعالم",
  })
  let message : @gen_proto3.FooMessage = @json.from_json(json.to_json())
  json_inspect(message, content={
    "fString": "Unicode test: 你好世界 🌍 مرحبا بالعالم",
  })
}

///|
test "proto3_test_case_19" {
  let json = (
    from_bin_to_proto_message("../bin/proto3_test_case_19.bin") :
    @gen_proto3.FooMessage)
  json_inspect(json, content={ "fString": "Oneof with F1", "f1": 12345 })
  let message : @gen_proto3.FooMessage = @json.from_json(json.to_json())
  json_inspect(message, content={ "fString": "Oneof with F1", "f1": 12345 })
}

///|
test "proto3_test_case_20" {
  let json = (
    from_bin_to_proto_message("../bin/proto3_test_case_20.bin") :
    @gen_proto3.FooMessage)
  json_inspect(json, content={ "fString": "Oneof with F2 bool", "f2": true })
  let message : @gen_proto3.FooMessage = @json.from_json(json.to_json())
  json_inspect(message, content={ "fString": "Oneof with F2 bool", "f2": true })
}

///|
test "proto3_test_case_21" {
  let json = (
    from_bin_to_proto_message("../bin/proto3_test_case_21.bin") :
    @gen_proto3.FooMessage)
  json_inspect(json, content={
    "fString": "Testing json_name field",
    "wjn": "json_name_test",
  })
  let file_json : @gen_proto3.FooMessage = from_json_to_proto_message(
    "../bin/proto3_test_case_21.json",
  )
  @debug.assert_eq(file_json, json)
}
