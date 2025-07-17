
///|
test "proto3_test_case_1" {
  inspect(from_file_to_proto3_message("../bin/proto3_test_case_1.bin"), content=(
    #|{f_int32: 42, f_int64: 1234567890, f_uint32: 0, f_uint64: 0, f_sint32: 0, f_sint64: 0, f_bool: false, f_foo_enum: FIRST_VALUE, f_fixed64: 0, f_sfixed64: 0, f_fixed32: 0, f_sfixed32: 0, f_double: 0, f_float: 0, f_bytes: b"\x01\x02\x03\x04", f_string: "Hello, World!", f_bar_message: {b_int32: 0}, f_repeated_int32: [], f_repeated_packed_int32: [], f_repeated_packed_float: [], f_baz: {nested: {f_nested: {f_nested: 0}}, b_int64: 0, b_string: ""}, f_nested: {f_nested: {f_nested: 0}}, f_nested_enum: Foo, f_map: {}, f_repeated_string: [], f_repeated_baz_message: [], f_optional_string: None, test_oneof: NotSet}
  ))
}

///|
test "proto3_test_case_2" {
  inspect(from_file_to_proto3_message("../bin/proto3_test_case_2.bin"), content=(
    #|{f_int32: -42, f_int64: -1234567890, f_uint32: 0, f_uint64: 0, f_sint32: 0, f_sint64: 0, f_bool: true, f_foo_enum: SECOND_VALUE, f_fixed64: 0, f_sfixed64: 0, f_fixed32: 0, f_sfixed32: 0, f_double: 0, f_float: 0, f_bytes: b"\x05\x06\x07\x08", f_string: "Test String", f_bar_message: {b_int32: 100}, f_repeated_int32: [1, 2, 3, 4, 5], f_repeated_packed_int32: [], f_repeated_packed_float: [], f_baz: {nested: {f_nested: {f_nested: 0}}, b_int64: 0, b_string: ""}, f_nested: {f_nested: {f_nested: 0}}, f_nested_enum: Foo, f_map: {}, f_repeated_string: [], f_repeated_baz_message: [], f_optional_string: None, test_oneof: NotSet}
  ))
}

///|
test "proto3_test_case_3" {
  inspect(
    from_file_to_proto3_message("../bin/proto3_test_case_3.bin"),
    content=(
      #|{f_int32: 1000, f_int64: 2000, f_uint32: 0, f_uint64: 0, f_sint32: 0, f_sint64: 0, f_bool: false, f_foo_enum: FIRST_VALUE, f_fixed64: 0, f_sfixed64: 0, f_fixed32: 0, f_sfixed32: 0, f_double: 0, f_float: 0, f_bytes: b"", f_string: "Another test string", f_bar_message: {b_int32: 0}, f_repeated_int32: [10, 20, 30], f_repeated_packed_int32: [], f_repeated_packed_float: [], f_baz: {nested: {f_nested: {f_nested: 0}}, b_int64: 0, b_string: ""}, f_nested: {f_nested: {f_nested: 0}}, f_nested_enum: Foo, f_map: {}, f_repeated_string: [], f_repeated_baz_message: [], f_optional_string: None, test_oneof: F3("This is a oneof field")}
)
  )
}

///|
test "proto3_test_case_4" {
  inspect(from_file_to_proto3_message("../bin/proto3_test_case_4.bin"), content=(
    #|{f_int32: 0, f_int64: 0, f_uint32: 0, f_uint64: 0, f_sint32: 0, f_sint64: 0, f_bool: true, f_foo_enum: FIRST_VALUE, f_fixed64: 0, f_sfixed64: 0, f_fixed32: 0, f_sfixed32: 0, f_double: 3.14, f_float: 0, f_bytes: b"", f_string: "", f_bar_message: {b_int32: 0}, f_repeated_int32: [], f_repeated_packed_int32: [], f_repeated_packed_float: [], f_baz: {nested: {f_nested: {f_nested: 0}}, b_int64: 0, b_string: ""}, f_nested: {f_nested: {f_nested: 0}}, f_nested_enum: Foo, f_map: {"key1": 1, "key2": 2, "key3": 3}, f_repeated_string: [], f_repeated_baz_message: [], f_optional_string: None, test_oneof: NotSet}


  ))
}

///|
test "proto3_test_case_5" {
  inspect(from_file_to_proto3_message("../bin/proto3_test_case_5.bin"), content=(
    #|{f_int32: 0, f_int64: 0, f_uint32: 0, f_uint64: 0, f_sint32: 0, f_sint64: 0, f_bool: false, f_foo_enum: FIRST_VALUE, f_fixed64: 0, f_sfixed64: 0, f_fixed32: 0, f_sfixed32: 0, f_double: 0, f_float: 0, f_bytes: b"", f_string: "Repeated Int32 Test", f_bar_message: {b_int32: 0}, f_repeated_int32: [10, 20, 30], f_repeated_packed_int32: [], f_repeated_packed_float: [], f_baz: {nested: {f_nested: {f_nested: 0}}, b_int64: 0, b_string: ""}, f_nested: {f_nested: {f_nested: 0}}, f_nested_enum: Foo, f_map: {}, f_repeated_string: [], f_repeated_baz_message: [], f_optional_string: None, test_oneof: NotSet}
  ))
}

///|
test "proto3_test_case_6" {
  inspect(from_file_to_proto3_message("../bin/proto3_test_case_6.bin"), content=(
    #|{f_int32: 0, f_int64: 0, f_uint32: 0, f_uint64: 0, f_sint32: 0, f_sint64: 0, f_bool: false, f_foo_enum: FIRST_VALUE, f_fixed64: 0, f_sfixed64: 0, f_fixed32: 0, f_sfixed32: 0, f_double: 0, f_float: 0, f_bytes: b"", f_string: "", f_bar_message: {b_int32: 100}, f_repeated_int32: [], f_repeated_packed_int32: [], f_repeated_packed_float: [], f_baz: {nested: {f_nested: {f_nested: 0}}, b_int64: 0, b_string: ""}, f_nested: {f_nested: {f_nested: 0}}, f_nested_enum: Foo, f_map: {}, f_repeated_string: [], f_repeated_baz_message: [], f_optional_string: None, test_oneof: NotSet}
  ))
}


///|
test "proto3_test_case_7" {
  inspect(from_file_to_proto3_message("../bin/proto3_test_case_7.bin"), content=(
    #|{f_int32: -42, f_int64: -1234567890, f_uint32: 0, f_uint64: 0, f_sint32: 0, f_sint64: 0, f_bool: false, f_foo_enum: FIRST_VALUE, f_fixed64: 0, f_sfixed64: 0, f_fixed32: 0, f_sfixed32: 0, f_double: 0, f_float: 0, f_bytes: b"", f_string: "", f_bar_message: {b_int32: 0}, f_repeated_int32: [], f_repeated_packed_int32: [], f_repeated_packed_float: [], f_baz: {nested: {f_nested: {f_nested: 0}}, b_int64: 0, b_string: ""}, f_nested: {f_nested: {f_nested: 0}}, f_nested_enum: Foo, f_map: {}, f_repeated_string: [], f_repeated_baz_message: [], f_optional_string: None, test_oneof: NotSet}
  ))
}

///|
test "proto3_test_case_8" {
  inspect(from_file_to_proto3_message("../bin/proto3_test_case_8.bin"), content=(
    #|{f_int32: -1, f_int64: 0, f_uint32: 0, f_uint64: 0, f_sint32: 0, f_sint64: 0, f_bool: false, f_foo_enum: FIRST_VALUE, f_fixed64: 0, f_sfixed64: 0, f_fixed32: 0, f_sfixed32: 0, f_double: 0, f_float: 0, f_bytes: b"", f_string: "", f_bar_message: {b_int32: 0}, f_repeated_int32: [], f_repeated_packed_int32: [], f_repeated_packed_float: [], f_baz: {nested: {f_nested: {f_nested: 0}}, b_int64: 0, b_string: ""}, f_nested: {f_nested: {f_nested: 0}}, f_nested_enum: Foo, f_map: {}, f_repeated_string: [], f_repeated_baz_message: [], f_optional_string: None, test_oneof: NotSet}
  ))
}


///|
test "proto3_test_case_9" {
  inspect(from_file_to_proto3_message("../bin/proto3_test_case_9.bin"), content=(
    #|{f_int32: 0, f_int64: 0, f_uint32: 0, f_uint64: 0, f_sint32: 0, f_sint64: 0, f_bool: false, f_foo_enum: FIRST_VALUE, f_fixed64: 0, f_sfixed64: 0, f_fixed32: 0, f_sfixed32: 0, f_double: 0, f_float: 0, f_bytes: b"", f_string: "Test Repeated String", f_bar_message: {b_int32: 0}, f_repeated_int32: [], f_repeated_packed_int32: [], f_repeated_packed_float: [], f_baz: {nested: {f_nested: {f_nested: 0}}, b_int64: 0, b_string: ""}, f_nested: {f_nested: {f_nested: 0}}, f_nested_enum: Foo, f_map: {}, f_repeated_string: ["test1", "test2", "test3"], f_repeated_baz_message: [], f_optional_string: None, test_oneof: NotSet}
  ))
}

///|
test "proto3_test_case_10" {
  inspect(from_file_to_proto3_message("../bin/proto3_test_case_10.bin"), content=(
    #|{f_int32: 0, f_int64: 0, f_uint32: 4294967295, f_uint64: 18446744073709551615, f_sint32: 0, f_sint64: 0, f_bool: false, f_foo_enum: FIRST_VALUE, f_fixed64: 0, f_sfixed64: 0, f_fixed32: 0, f_sfixed32: 0, f_double: 0, f_float: 0, f_bytes: b"", f_string: "", f_bar_message: {b_int32: 0}, f_repeated_int32: [], f_repeated_packed_int32: [], f_repeated_packed_float: [], f_baz: {nested: {f_nested: {f_nested: 0}}, b_int64: 0, b_string: ""}, f_nested: {f_nested: {f_nested: 0}}, f_nested_enum: Foo, f_map: {}, f_repeated_string: [], f_repeated_baz_message: [], f_optional_string: None, test_oneof: NotSet}
  ))
}

///|
test "proto3_test_case_11" {
  inspect(from_file_to_proto3_message("../bin/proto3_test_case_11.bin"), content=(
    #|{f_int32: 0, f_int64: 0, f_uint32: 0, f_uint64: 0, f_sint32: -123, f_sint64: -9876543210, f_bool: false, f_foo_enum: FIRST_VALUE, f_fixed64: 0, f_sfixed64: 0, f_fixed32: 0, f_sfixed32: 0, f_double: 0, f_float: 0, f_bytes: b"", f_string: "", f_bar_message: {b_int32: 0}, f_repeated_int32: [], f_repeated_packed_int32: [], f_repeated_packed_float: [], f_baz: {nested: {f_nested: {f_nested: 0}}, b_int64: 0, b_string: ""}, f_nested: {f_nested: {f_nested: 0}}, f_nested_enum: Foo, f_map: {}, f_repeated_string: [], f_repeated_baz_message: [], f_optional_string: None, test_oneof: NotSet}
  ))
}

///|
test "proto3_test_case_12" {
  inspect(from_file_to_proto3_message("../bin/proto3_test_case_12.bin"), content=(
    #|{f_int32: 0, f_int64: 0, f_uint32: 0, f_uint64: 0, f_sint32: 0, f_sint64: 0, f_bool: false, f_foo_enum: FIRST_VALUE, f_fixed64: 1000000000000000000, f_sfixed64: -500000000000000000, f_fixed32: 1000000000, f_sfixed32: -500000000, f_double: 0, f_float: 0, f_bytes: b"", f_string: "", f_bar_message: {b_int32: 0}, f_repeated_int32: [], f_repeated_packed_int32: [], f_repeated_packed_float: [], f_baz: {nested: {f_nested: {f_nested: 0}}, b_int64: 0, b_string: ""}, f_nested: {f_nested: {f_nested: 0}}, f_nested_enum: Foo, f_map: {}, f_repeated_string: [], f_repeated_baz_message: [], f_optional_string: None, test_oneof: NotSet}
  ))
}

///|
test "proto3_test_case_13" {
  inspect(from_file_to_proto3_message("../bin/proto3_test_case_13.bin"), content=(
    #|{f_int32: 0, f_int64: 0, f_uint32: 0, f_uint64: 0, f_sint32: 0, f_sint64: 0, f_bool: false, f_foo_enum: FIRST_VALUE, f_fixed64: 0, f_sfixed64: 0, f_fixed32: 0, f_sfixed32: 0, f_double: 2.718281828459045, f_float: 3.141590118408203, f_bytes: b"", f_string: "", f_bar_message: {b_int32: 0}, f_repeated_int32: [], f_repeated_packed_int32: [], f_repeated_packed_float: [], f_baz: {nested: {f_nested: {f_nested: 0}}, b_int64: 0, b_string: ""}, f_nested: {f_nested: {f_nested: 0}}, f_nested_enum: Foo, f_map: {}, f_repeated_string: [], f_repeated_baz_message: [], f_optional_string: None, test_oneof: NotSet}
  ))
}

///|
test "proto3_test_case_14" {
  inspect(from_file_to_proto3_message("../bin/proto3_test_case_14.bin"), content=(
    #|{f_int32: 0, f_int64: 0, f_uint32: 0, f_uint64: 0, f_sint32: 0, f_sint64: 0, f_bool: false, f_foo_enum: SECOND_VALUE, f_fixed64: 0, f_sfixed64: 0, f_fixed32: 0, f_sfixed32: 0, f_double: 0, f_float: 0, f_bytes: b"", f_string: "Enum test", f_bar_message: {b_int32: 0}, f_repeated_int32: [], f_repeated_packed_int32: [], f_repeated_packed_float: [], f_baz: {nested: {f_nested: {f_nested: 0}}, b_int64: 0, b_string: ""}, f_nested: {f_nested: {f_nested: 0}}, f_nested_enum: Foo, f_map: {}, f_repeated_string: [], f_repeated_baz_message: [], f_optional_string: None, test_oneof: NotSet}
  ))
}

///|
test "proto3_test_case_15" {
  inspect(from_file_to_proto3_message("../bin/proto3_test_case_15.bin"), content=(
    #|{f_int32: 0, f_int64: 0, f_uint32: 0, f_uint64: 0, f_sint32: 0, f_sint64: 0, f_bool: false, f_foo_enum: FIRST_VALUE, f_fixed64: 0, f_sfixed64: 0, f_fixed32: 0, f_sfixed32: 0, f_double: 0, f_float: 0, f_bytes: b"", f_string: "Negative repeated integers", f_bar_message: {b_int32: 0}, f_repeated_int32: [], f_repeated_packed_int32: [-1, -2, -3, -4, -5], f_repeated_packed_float: [], f_baz: {nested: {f_nested: {f_nested: 0}}, b_int64: 0, b_string: ""}, f_nested: {f_nested: {f_nested: 0}}, f_nested_enum: Foo, f_map: {}, f_repeated_string: [], f_repeated_baz_message: [], f_optional_string: None, test_oneof: NotSet}

  ))
}

///|
test "proto3_test_case_16" {
  inspect(from_file_to_proto3_message("../bin/proto3_test_case_16.bin"), content=(
    #|{f_int32: 0, f_int64: 0, f_uint32: 0, f_uint64: 0, f_sint32: 0, f_sint64: 0, f_bool: false, f_foo_enum: FIRST_VALUE, f_fixed64: 0, f_sfixed64: 0, f_fixed32: 0, f_sfixed32: 0, f_double: 0, f_float: 0, f_bytes: b"", f_string: "", f_bar_message: {b_int32: 0}, f_repeated_int32: [], f_repeated_packed_int32: [], f_repeated_packed_float: [], f_baz: {nested: {f_nested: {f_nested: 42}}, b_int64: 999888777, b_string: "Nested baz message"}, f_nested: {f_nested: {f_nested: 0}}, f_nested_enum: Foo, f_map: {}, f_repeated_string: [], f_repeated_baz_message: [], f_optional_string: None, test_oneof: NotSet}
  ))
}

///|
test "proto3_test_case_17" {
  inspect(from_file_to_proto3_message("../bin/proto3_test_case_17.bin"), content=(
    #|{f_int32: 0, f_int64: 0, f_uint32: 0, f_uint64: 0, f_sint32: 0, f_sint64: 0, f_bool: false, f_foo_enum: FIRST_VALUE, f_fixed64: 0, f_sfixed64: 0, f_fixed32: 0, f_sfixed32: 0, f_double: 0, f_float: 0, f_bytes: b"\x42\x69\x6e\x61\x72\x79\x20\x64\x61\x74\x61\x20\x77\x69\x74\x68\x20\x73\x70\x65\x63\x69\x61\x6c\x20\x63\x68\x61\x72\x73\x3a\x20\x00\x01\x02\xff", f_string: "", f_bar_message: {b_int32: 0}, f_repeated_int32: [], f_repeated_packed_int32: [], f_repeated_packed_float: [], f_baz: {nested: {f_nested: {f_nested: 0}}, b_int64: 0, b_string: ""}, f_nested: {f_nested: {f_nested: 0}}, f_nested_enum: Foo, f_map: {}, f_repeated_string: [], f_repeated_baz_message: [], f_optional_string: None, test_oneof: NotSet}
  ))
}

///|
test "proto3_test_case_18" {
  inspect(from_file_to_proto3_message("../bin/proto3_test_case_18.bin"), content=(
    #|{f_int32: 0, f_int64: 0, f_uint32: 0, f_uint64: 0, f_sint32: 0, f_sint64: 0, f_bool: false, f_foo_enum: FIRST_VALUE, f_fixed64: 0, f_sfixed64: 0, f_fixed32: 0, f_sfixed32: 0, f_double: 0, f_float: 0, f_bytes: b"", f_string: "Unicode test: 你好世界 🌍 مرحبا بالعالم", f_bar_message: {b_int32: 0}, f_repeated_int32: [], f_repeated_packed_int32: [], f_repeated_packed_float: [], f_baz: {nested: {f_nested: {f_nested: 0}}, b_int64: 0, b_string: ""}, f_nested: {f_nested: {f_nested: 0}}, f_nested_enum: Foo, f_map: {}, f_repeated_string: [], f_repeated_baz_message: [], f_optional_string: None, test_oneof: NotSet}
  ))
}

///|
test "proto3_test_case_19" {
  inspect(from_file_to_proto3_message("../bin/proto3_test_case_19.bin"), content=(
    #|{f_int32: 0, f_int64: 0, f_uint32: 0, f_uint64: 0, f_sint32: 0, f_sint64: 0, f_bool: false, f_foo_enum: FIRST_VALUE, f_fixed64: 0, f_sfixed64: 0, f_fixed32: 0, f_sfixed32: 0, f_double: 0, f_float: 0, f_bytes: b"", f_string: "Oneof with F1", f_bar_message: {b_int32: 0}, f_repeated_int32: [], f_repeated_packed_int32: [], f_repeated_packed_float: [], f_baz: {nested: {f_nested: {f_nested: 0}}, b_int64: 0, b_string: ""}, f_nested: {f_nested: {f_nested: 0}}, f_nested_enum: Foo, f_map: {}, f_repeated_string: [], f_repeated_baz_message: [], f_optional_string: None, test_oneof: F1(12345)}
  ))
}

///|
test "proto3_test_case_20" {
  inspect(from_file_to_proto3_message("../bin/proto3_test_case_20.bin"), content=(
    #|{f_int32: 0, f_int64: 0, f_uint32: 0, f_uint64: 0, f_sint32: 0, f_sint64: 0, f_bool: false, f_foo_enum: FIRST_VALUE, f_fixed64: 0, f_sfixed64: 0, f_fixed32: 0, f_sfixed32: 0, f_double: 0, f_float: 0, f_bytes: b"", f_string: "Oneof with F2 bool", f_bar_message: {b_int32: 0}, f_repeated_int32: [], f_repeated_packed_int32: [], f_repeated_packed_float: [], f_baz: {nested: {f_nested: {f_nested: 0}}, b_int64: 0, b_string: ""}, f_nested: {f_nested: {f_nested: 0}}, f_nested_enum: Foo, f_map: {}, f_repeated_string: [], f_repeated_baz_message: [], f_optional_string: None, test_oneof: F2(true)}
  ))
}

