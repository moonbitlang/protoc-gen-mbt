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

///|
test "read_int32" {
  let bytes = b"\xFE\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x01"
  let r = @protobuf.BytesReader::from_bytes(bytes) as &@protobuf.Reader
  assert_eq(r |> @protobuf.read_int64(), -2)
}

///|
test "read_int32/2" {
  let bytes = b"\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x01"
  let r = @protobuf.BytesReader::from_bytes(bytes) as &@protobuf.Reader
  assert_eq(r |> @protobuf.read_int32(), -1)
}

///|
test "read_int32/3" {
  let bytes = b"\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x01"
  let r = @protobuf.BytesReader::from_bytes(bytes) as &@protobuf.Reader
  assert_eq(r |> @protobuf.read_varint32() |> UInt::reinterpret_as_int, -1)
  // assert_eq(r |> @protobuf.is_eof(), false)
}

///|
test "end_of_bytes" {
  let bytes = b"\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x01"
  let r = @protobuf.BytesReader::from_bytes(bytes) as &@protobuf.Reader
  assert_eq(r |> @protobuf.read_varint32() |> UInt::reinterpret_as_int, -1)
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
test "error" {
  let r = @protobuf.BytesReader::from_bytes(b"") as &@protobuf.Reader
  inspect(try? (r |> @protobuf.read_varint32()), content="Err(EndOfStream)")
}
