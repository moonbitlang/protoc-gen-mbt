///|
fn [M: @lib.Read]from_file_to_proto_message(file : String) -> M raise {
  let bytes = (try? @fs.read_file_to_bytes(file)).unwrap()
  let reader = @lib.BytesReader::from_bytes(bytes)
  return (@lib.Read::read(reader) : M)
}

///|
test "proto2_test_case_1" {
  inspect(
    (from_file_to_proto_message("../bin/proto2_test_case_1.bin") : @gen_proto2.FooMessageP2),
    content=(
      #|{f_int32: 42, f_int64: 1234567890, f_uint32: None, f_uint64: None, f_sint32: None, f_sint64: None, f_bool: None, f_foo_enum: Some(FIRST_VALUEX), f_fixed64: None, f_sfixed64: None, f_fixed32: None, f_sfixed32: None, f_double: None, f_float: None, f_bytes: Some(b"\x01\x02\x03\x04"), f_string: Some("Hello, World!"), f_bar_message: None, f_repeated_int32: [], f_repeated_packed_int32: [], f_repeated_packed_float: [], f_baz: None, f_nested: None, f_nested_enum: Some(Foo), f_map: [], f1: None, f2: None, f3: None, f_repeated_string: [], f_repeated_baz_message: [], f_optional_string: None, f_default_int32: Some(42), f_default_string: Some("default_value"), f_default_bool: Some(true), f_default_double: Some(3.14), f_default_enum: Some(SECOND_VALUEX)}
    ),
  )
}

///|
test "proto2_test_case_2" {
  inspect(
    (from_file_to_proto_message("../bin/proto2_test_case_2.bin") : @gen_proto2.FooMessageP2),
    content=(
      #|{f_int32: 42, f_int64: 1234567890, f_uint32: None, f_uint64: None, f_sint32: None, f_sint64: None, f_bool: None, f_foo_enum: None, f_fixed64: None, f_sfixed64: None, f_fixed32: None, f_sfixed32: None, f_double: None, f_float: None, f_bytes: None, f_string: None, f_bar_message: None, f_repeated_int32: [1, 2, 3, 4, 5], f_repeated_packed_int32: [6, 7, 8, 9, 10], f_repeated_packed_float: [], f_baz: None, f_nested: None, f_nested_enum: Some(Foo), f_map: [], f1: None, f2: None, f3: None, f_repeated_string: [], f_repeated_baz_message: [], f_optional_string: None, f_default_int32: Some(42), f_default_string: Some("default_value"), f_default_bool: Some(true), f_default_double: Some(3.14), f_default_enum: Some(SECOND_VALUEX)}
    ),
  )
}

///|
test "proto2_test_case_3" {
  inspect(
    (from_file_to_proto_message("../bin/proto2_test_case_3.bin") : @gen_proto2.FooMessageP2),
    content=(
      #|{f_int32: -42, f_int64: -1234567890, f_uint32: None, f_uint64: None, f_sint32: None, f_sint64: None, f_bool: None, f_foo_enum: None, f_fixed64: None, f_sfixed64: None, f_fixed32: None, f_sfixed32: None, f_double: None, f_float: None, f_bytes: None, f_string: None, f_bar_message: None, f_repeated_int32: [], f_repeated_packed_int32: [], f_repeated_packed_float: [], f_baz: None, f_nested: None, f_nested_enum: Some(Foo), f_map: [], f1: None, f2: None, f3: None, f_repeated_string: [], f_repeated_baz_message: [], f_optional_string: None, f_default_int32: Some(42), f_default_string: Some("default_value"), f_default_bool: Some(false), f_default_double: Some(3.2229), f_default_enum: Some(FIRST_VALUEX)}
    ),
  )
}

///|
test "proto2_test_case_4" {
  inspect(
    (from_file_to_proto_message("../bin/proto2_test_case_4.bin") : @gen_proto2.FooMessageP2),
    content=(
      #|{f_int32: 2147483647, f_int64: 9223372036854775807, f_uint32: Some(4294967295), f_uint64: Some(18446744073709551615), f_sint32: Some(-2147483648), f_sint64: Some(-9223372036854775808), f_bool: None, f_foo_enum: None, f_fixed64: Some(987654321012345), f_sfixed64: Some(-987654321012345), f_fixed32: Some(123456789), f_sfixed32: Some(-123456789), f_double: Some(123.456789), f_float: Some(78.90119934082031), f_bytes: None, f_string: None, f_bar_message: None, f_repeated_int32: [], f_repeated_packed_int32: [], f_repeated_packed_float: [], f_baz: None, f_nested: None, f_nested_enum: Some(Foo), f_map: [], f1: None, f2: None, f3: None, f_repeated_string: [], f_repeated_baz_message: [], f_optional_string: None, f_default_int32: Some(42), f_default_string: Some("default_value"), f_default_bool: Some(true), f_default_double: Some(3.14), f_default_enum: Some(SECOND_VALUEX)}
    ),
  )
}

///|
test "proto2_test_case_5" {
  inspect(
    (from_file_to_proto_message("../bin/proto2_test_case_5.bin") : @gen_proto2.FooMessageP2),
    content=(
      #|{f_int32: 100, f_int64: 200, f_uint32: None, f_uint64: None, f_sint32: None, f_sint64: None, f_bool: Some(true), f_foo_enum: Some(SECOND_VALUEX), f_fixed64: None, f_sfixed64: None, f_fixed32: None, f_sfixed32: None, f_double: None, f_float: None, f_bytes: None, f_string: None, f_bar_message: None, f_repeated_int32: [], f_repeated_packed_int32: [], f_repeated_packed_float: [], f_baz: None, f_nested: None, f_nested_enum: Some(Foo), f_map: [], f1: None, f2: None, f3: None, f_repeated_string: [], f_repeated_baz_message: [], f_optional_string: None, f_default_int32: Some(42), f_default_string: Some("default_value"), f_default_bool: Some(true), f_default_double: Some(3.14), f_default_enum: Some(SECOND_VALUEX)}
    ),
  )
}

///|
test "proto2_test_case_6" {
  inspect(
    (from_file_to_proto_message("../bin/proto2_test_case_6.bin") : @gen_proto2.FooMessageP2),
    content=(
      #|{f_int32: 300, f_int64: 400, f_uint32: None, f_uint64: None, f_sint32: None, f_sint64: None, f_bool: None, f_foo_enum: None, f_fixed64: None, f_sfixed64: None, f_fixed32: None, f_sfixed32: None, f_double: None, f_float: None, f_bytes: None, f_string: None, f_bar_message: Some({b_int32: 500}), f_repeated_int32: [], f_repeated_packed_int32: [], f_repeated_packed_float: [], f_baz: Some({nested: Some({f_nested: Some({f_nested: 700})}), b_int64: Some(600), b_string: Some("nested baz message")}), f_nested: None, f_nested_enum: Some(Foo), f_map: [], f1: None, f2: None, f3: None, f_repeated_string: [], f_repeated_baz_message: [], f_optional_string: None, f_default_int32: Some(42), f_default_string: Some("default_value"), f_default_bool: Some(true), f_default_double: Some(3.14), f_default_enum: Some(SECOND_VALUEX)}
    ),
  )
}

///|
test "proto2_test_case_7" {
  inspect(
    (from_file_to_proto_message("../bin/proto2_test_case_7.bin") : @gen_proto2.FooMessageP2),
    content=(
      #|{f_int32: 800, f_int64: 900, f_uint32: None, f_uint64: None, f_sint32: None, f_sint64: None, f_bool: None, f_foo_enum: None, f_fixed64: None, f_sfixed64: None, f_fixed32: None, f_sfixed32: None, f_double: None, f_float: None, f_bytes: None, f_string: None, f_bar_message: None, f_repeated_int32: [10, 20, 30, 40, 50], f_repeated_packed_int32: [60, 70, 80, 90, 100], f_repeated_packed_float: [1.100000023841858, 2.200000047683716, 3.299999952316284, 4.400000095367432, 5.5], f_baz: None, f_nested: None, f_nested_enum: Some(Foo), f_map: [], f1: None, f2: None, f3: None, f_repeated_string: ["first", "second", "third"], f_repeated_baz_message: [{nested: None, b_int64: Some(1001), b_string: Some("first repeated baz")}, {nested: None, b_int64: Some(1002), b_string: Some("second repeated baz")}], f_optional_string: None, f_default_int32: Some(42), f_default_string: Some("default_value"), f_default_bool: Some(true), f_default_double: Some(3.14), f_default_enum: Some(SECOND_VALUEX)}

    ),
  )
}

///|
test "proto2_test_case_8" {
  inspect(
    (from_file_to_proto_message("../bin/proto2_test_case_8.bin") : @gen_proto2.FooMessageP2),
    content=(
      #|{f_int32: 0, f_int64: 0, f_uint32: None, f_uint64: None, f_sint32: None, f_sint64: None, f_bool: Some(false), f_foo_enum: None, f_fixed64: None, f_sfixed64: None, f_fixed32: None, f_sfixed32: None, f_double: None, f_float: None, f_bytes: Some(b""), f_string: Some(""), f_bar_message: None, f_repeated_int32: [], f_repeated_packed_int32: [], f_repeated_packed_float: [], f_baz: None, f_nested: None, f_nested_enum: Some(Foo), f_map: [], f1: None, f2: None, f3: None, f_repeated_string: [], f_repeated_baz_message: [], f_optional_string: None, f_default_int32: Some(42), f_default_string: Some("default_value"), f_default_bool: Some(true), f_default_double: Some(3.14), f_default_enum: Some(SECOND_VALUEX)}
    ),
  )
}

///|
test "proto2_test_case_9" {
  inspect(
    (from_file_to_proto_message("../bin/proto2_test_case_9.bin") : @gen_proto2.FooMessageP2),
    content=(
      #|{f_int32: -1, f_int64: -1, f_uint32: None, f_uint64: None, f_sint32: None, f_sint64: None, f_bool: None, f_foo_enum: None, f_fixed64: None, f_sfixed64: None, f_fixed32: None, f_sfixed32: None, f_double: None, f_float: None, f_bytes: Some(b"\x00\xff\x7f\x80\x01\xfe"), f_string: Some("Special chars: !@#$%^&*()_+{}|:<>?[]\\;',./"), f_bar_message: None, f_repeated_int32: [], f_repeated_packed_int32: [], f_repeated_packed_float: [], f_baz: None, f_nested: None, f_nested_enum: Some(Foo), f_map: [], f1: None, f2: None, f3: None, f_repeated_string: [], f_repeated_baz_message: [], f_optional_string: None, f_default_int32: Some(42), f_default_string: Some("default_value"), f_default_bool: Some(true), f_default_double: Some(3.14), f_default_enum: Some(SECOND_VALUEX)}
    ),
  )
}

///|
test "proto2_test_case_10" {
  inspect(
    (from_file_to_proto_message("../bin/proto2_test_case_10.bin") : @gen_proto2.FooMessageP2),
    content=(
      #|{f_int32: 12345, f_int64: 67890, f_uint32: None, f_uint64: None, f_sint32: None, f_sint64: None, f_bool: None, f_foo_enum: None, f_fixed64: None, f_sfixed64: None, f_fixed32: None, f_sfixed32: None, f_double: None, f_float: None, f_bytes: Some(b"\x55\x54\x46\x2d\x38\x20\x62\x79\x74\x65\x73\x3a\x20\xe6\xb5\x8b\xe8\xaf\x95"), f_string: Some("Unicode: 你好世界 🌍 こんにちは العالم"), f_bar_message: None, f_repeated_int32: [], f_repeated_packed_int32: [], f_repeated_packed_float: [], f_baz: None, f_nested: None, f_nested_enum: Some(Foo), f_map: [], f1: None, f2: None, f3: None, f_repeated_string: [], f_repeated_baz_message: [], f_optional_string: None, f_default_int32: Some(42), f_default_string: Some("default_value"), f_default_bool: Some(true), f_default_double: Some(3.14), f_default_enum: Some(SECOND_VALUEX)}
    ),
  )
}

///|
test "proto2_test_case_11" {
  inspect(
    (from_file_to_proto_message("../bin/proto2_test_case_11.bin") : @gen_proto2.FooMessageP2),
    content=(
      #|{f_int32: 111, f_int64: 222, f_uint32: None, f_uint64: None, f_sint32: None, f_sint64: None, f_bool: None, f_foo_enum: None, f_fixed64: None, f_sfixed64: None, f_fixed32: None, f_sfixed32: None, f_double: None, f_float: None, f_bytes: None, f_string: None, f_bar_message: None, f_repeated_int32: [], f_repeated_packed_int32: [], f_repeated_packed_float: [], f_baz: None, f_nested: Some({f_nested: Some({f_nested: 333})}), f_nested_enum: Some(Bar), f_map: [], f1: None, f2: None, f3: None, f_repeated_string: [], f_repeated_baz_message: [], f_optional_string: None, f_default_int32: Some(42), f_default_string: Some("default_value"), f_default_bool: Some(true), f_default_double: Some(3.14), f_default_enum: Some(SECOND_VALUEX)}
    ),
  )
}

///|
test "proto2_test_case_12" {
  inspect(
    (from_file_to_proto_message("../bin/proto2_test_case_12.bin") : @gen_proto2.FooMessageP2),
    content=(
      #|{f_int32: 444, f_int64: 555, f_uint32: None, f_uint64: None, f_sint32: None, f_sint64: None, f_bool: None, f_foo_enum: None, f_fixed64: None, f_sfixed64: None, f_fixed32: None, f_sfixed32: None, f_double: None, f_float: None, f_bytes: None, f_string: None, f_bar_message: None, f_repeated_int32: [], f_repeated_packed_int32: [], f_repeated_packed_float: [], f_baz: None, f_nested: None, f_nested_enum: Some(Foo), f_map: [], f1: Some(666), f2: Some(true), f3: Some("f3 value"), f_repeated_string: [], f_repeated_baz_message: [], f_optional_string: Some("optional string value"), f_default_int32: Some(42), f_default_string: Some("default_value"), f_default_bool: Some(true), f_default_double: Some(3.14), f_default_enum: Some(SECOND_VALUEX)}
    ),
  )
}


// test "proto2_test_case_13" {
//   inspect(
//     (from_file_to_proto_message("../bin/proto2_test_case_13.bin") : @gen_proto2.EmptyMessage),
//     content=(
//       "{empty_field: None}"
//     ),
//   )
// }
