// Copyright 2024 International Digital Economy Academy

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//     http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

// /|

///|
test "varint" {
  let bytes = b"\x96\x01"
  let r = @protobuf.BytesReader::from_bytes(bytes) as &@protobuf.Reader
  assert_eq(r |> @protobuf.read_varint32(), 150)
}

///|
test "async_read_varint" {
  let bytes = b"\x96\x01"
  let r = @protobuf.BytesReader::from_bytes(bytes)
  @async.with_event_loop(fn(_) {
    let result = r |> @protobuf.async_read_varint32()
    assert_eq(result, 150)
  })
}

///|
test "read_int32" {
  let bytes = b"\xFE\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x01"
  let r = @protobuf.BytesReader::from_bytes(bytes) as &@protobuf.Reader
  assert_eq(r |> @protobuf.read_int64(), -2)
}

///|
test "async_read_int64" {
  let bytes = b"\xFE\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x01"
  let r = @protobuf.BytesReader::from_bytes(bytes)
  @async.with_event_loop(fn(_) {
    let result = r |> @protobuf.async_read_int64()
    assert_eq(result, -2)
  })
}

///|
test "read_int32/2" {
  let bytes = b"\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x01"
  let r = @protobuf.BytesReader::from_bytes(bytes) as &@protobuf.Reader
  assert_eq(r |> @protobuf.read_int32(), -1)
}

///|
test "async_read_int32/2" {
  let bytes = b"\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x01"
  let r = @protobuf.BytesReader::from_bytes(bytes)
  @async.with_event_loop(fn(_) {
    let result = r |> @protobuf.async_read_int32()
    assert_eq(result, -1)
  })
}

///|
test "read_int32/3" {
  let bytes = b"\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x01"
  let r = @protobuf.BytesReader::from_bytes(bytes) as &@protobuf.Reader
  assert_eq(r |> @protobuf.read_varint32() |> UInt::reinterpret_as_int, -1)
  // assert_eq(r |> @protobuf.is_eof(), false)
}

///|
test "async_read_varint32/3" {
  let bytes = b"\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x01"
  let r = @protobuf.BytesReader::from_bytes(bytes)
  @async.with_event_loop(fn(_) {
    let result = r
      |> @protobuf.async_read_varint32()
      |> UInt::reinterpret_as_int
    assert_eq(result, -1)
  })
}

///|
test "end_of_bytes" {
  let bytes = b"\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x01"
  let r = @protobuf.BytesReader::from_bytes(bytes) as &@protobuf.Reader
  assert_eq(r |> @protobuf.read_varint32() |> UInt::reinterpret_as_int, -1)
}

///|
test "async_end_of_bytes" {
  let bytes = b"\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x01"
  let r = @protobuf.BytesReader::from_bytes(bytes)
  @async.with_event_loop(fn(_) {
    let result = r
      |> @protobuf.async_read_varint32()
      |> UInt::reinterpret_as_int
    assert_eq(result, -1)
  })
}

///|
test "async_read_sint32" {
  let r = @protobuf.BytesReader::from_bytes(b"\x00") as &@protobuf.Reader
  assert_eq(r |> @protobuf.read_sint32(), 0)
  let r = @protobuf.BytesReader::from_bytes(b"\x01") as &@protobuf.Reader
  assert_eq(r |> @protobuf.read_sint32(), -1)
  let r = @protobuf.BytesReader::from_bytes(b"\x02") as &@protobuf.Reader
  assert_eq(r |> @protobuf.read_sint32(), 1)
  let r = @protobuf.BytesReader::from_bytes(b"\x03") as &@protobuf.Reader
  assert_eq(r |> @protobuf.read_sint32(), -2)
}

///|
test "async_read_sint32" {
  let r = @protobuf.BytesReader::from_bytes(b"\x00")
  @async.with_event_loop(fn(_) {
    let result = r |> @protobuf.async_read_sint32()
    assert_eq(result, 0)
  })
  let r = @protobuf.BytesReader::from_bytes(b"\x01")
  @async.with_event_loop(fn(_) {
    let result = r |> @protobuf.async_read_sint32()
    assert_eq(result, -1)
  })
  let r = @protobuf.BytesReader::from_bytes(b"\x02")
  @async.with_event_loop(fn(_) {
    let result = r |> @protobuf.async_read_sint32()
    assert_eq(result, 1)
  })
  let r = @protobuf.BytesReader::from_bytes(b"\x03")
  @async.with_event_loop(fn(_) {
    let result = r |> @protobuf.async_read_sint32()
    assert_eq(result, -2)
  })
}

///|
test "read_string" {
  let r = @protobuf.BytesReader::from_bytes(b"\x02\x61\x62")
    as &@protobuf.Reader
  assert_eq(r |> @protobuf.read_string(), "ab")
  let r = @protobuf.BytesReader::from_bytes(b"\x06\xE4\xB8\xAD\xE6\x96\x87")
    as &@protobuf.Reader
  assert_eq(r |> @protobuf.read_string(), "中文")
}

///|
test "async_read_string" {
  let r = @protobuf.BytesReader::from_bytes(b"\x02\x61\x62")
  @async.with_event_loop(fn(_) {
    let result = r |> @protobuf.async_read_string()
    assert_eq(result, "ab")
  })
  let r = @protobuf.BytesReader::from_bytes(b"\x06\xE4\xB8\xAD\xE6\x96\x87")
  @async.with_event_loop(fn(_) {
    let result = r |> @protobuf.async_read_string()
    assert_eq(result, "中文")
  })
}

///|
test "error" {
  let r = @protobuf.BytesReader::from_bytes(b"") as &@protobuf.Reader
  inspect(try? (r |> @protobuf.read_varint32()), content="Err(EndOfStream)")
}

///|
test "async_error" {
  let r = @protobuf.BytesReader::from_bytes(b"")
  @async.with_event_loop(fn(_) {
    let result = try? (r |> @protobuf.async_read_varint32())
    inspect(result, content="Err(EndOfStream)")
  })
}

///|
test "async_read_bytes" {
  let bytes = b"\x03\x01\x02\x03"
  let r = @protobuf.BytesReader::from_bytes(bytes)
  @async.with_event_loop(fn(_) {
    let result = r |> @protobuf.async_read_bytes()
    assert_eq(result, b"\x01\x02\x03")
  })
}
