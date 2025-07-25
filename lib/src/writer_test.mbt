// Copyright 2024 International Digital Economy Academy
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

///|
test "varint" {
  let writer = @buffer.new()
  writer |> @protobuf.write_varint(150)
  assert_eq(writer.to_bytes(), b"\x96\x01")
}

///|
test "integer" {
  let writer = @buffer.new()
  writer |> @protobuf.write_int64(-2)
  assert_eq(writer.to_bytes(), b"\xFE\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x01")
}

///|
test "signed integer" {
  let writer = @buffer.new()
  writer |> @protobuf.write_sint32(0)
  writer |> @protobuf.write_sint32(-1)
  writer |> @protobuf.write_sint32(1)
  writer |> @protobuf.write_sint32(-2)
  assert_eq(writer.to_bytes(), b"\x00\x01\x02\x03")
}

///|
test "string" {
  let writer = @buffer.new()
  writer |> @protobuf.write_string("ab")
  writer |> @protobuf.write_string("中文")
  assert_eq(writer.to_bytes(), b"\x02\x61\x62\x06\xE4\xB8\xAD\xE6\x96\x87")
}

///|
test "async_write_varint" {
  let writer = @buffer.new()
  @async.with_event_loop(fn(_) { writer |> @protobuf.async_write_varint(150) })
  assert_eq(writer.to_bytes(), b"\x96\x01")
}

///|
test "string" {
  let writer = @buffer.new()
  @async.with_event_loop(fn(_) {
    writer |> @protobuf.async_write_string("Hello, World!")
  })
  assert_eq(writer.to_bytes(), b"\x0DHello, World!")
}

///|
test "write bytes" {
  let writer = @buffer.new()
  @async.with_event_loop(fn(_) {
    writer |> @protobuf.async_write_bytes(b"\x01\x02\x03")
  })
  assert_eq(writer.to_bytes(), b"\x03\x01\x02\x03")
}
