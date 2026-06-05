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
  let writer = Buffer()
  writer |> @protobuf.write_varint(150)
  @debug.assert_eq(writer.to_bytes(), b"\x96\x01")
}

///|
test "varint size boundaries" {
  @debug.assert_eq(@protobuf.size_of(0x7FUL), 1U)
  @debug.assert_eq(@protobuf.size_of(0x80UL), 2U)
  @debug.assert_eq(@protobuf.size_of(0x3FFFUL), 2U)
  @debug.assert_eq(@protobuf.size_of(0x4000UL), 3U)
  @debug.assert_eq(@protobuf.size_of(0x1FFFFFUL), 3U)
  @debug.assert_eq(@protobuf.size_of(0x200000UL), 4U)
  @debug.assert_eq(@protobuf.size_of(0xFFFFFFFUL), 4U)
  @debug.assert_eq(@protobuf.size_of(0x10000000UL), 5U)
}

///|
test "integer" {
  let writer = Buffer()
  writer |> @protobuf.write_int64(-2)
  @debug.assert_eq(
    writer.to_bytes(),
    b"\xFE\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x01",
  )
}

///|
test "signed integer" {
  let writer = Buffer()
  writer |> @protobuf.write_sint32(0)
  writer |> @protobuf.write_sint32(-1)
  writer |> @protobuf.write_sint32(1)
  writer |> @protobuf.write_sint32(-2)
  @debug.assert_eq(writer.to_bytes(), b"\x00\x01\x02\x03")
}

///|
test "string" {
  let writer = Buffer()
  writer |> @protobuf.write_string("ab")
  writer |> @protobuf.write_string("中文")
  @debug.assert_eq(
    writer.to_bytes(),
    b"\x02\x61\x62\x06\xE4\xB8\xAD\xE6\x96\x87",
  )
}

///|
struct TinyMessage {
  value : Int
}

///|
impl @protobuf.Sized for TinyMessage with fn size_of(self) {
  @protobuf.size_of(self.value)
}

///|
impl @protobuf.Write for TinyMessage with fn write(self, writer) raise {
  writer |> @protobuf.write_int32(self.value)
}

///|
test "write_message prefixes the encoded message size" {
  let writer = Buffer()
  writer |> @protobuf.write_message({ value: 150 })
  @debug.assert_eq(writer.to_bytes(), b"\x02\x96\x01")
}
