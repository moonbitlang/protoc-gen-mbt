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

test "varint" {
  let r = @lib.BytesReader::from_bytes(b"\x96\x01") as @lib.Reader
  assert_eq!(r |> @lib.read_varint32!(), 150)
  assert_eq!(r.next_bytes(0), None)
}

test "integer" {
  let r = @lib.BytesReader::from_bytes(
      b"\xFE\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x01",
    )
    as @lib.Reader
  assert_eq!(r |> @lib.read_int64!(), -2)
}

test "signed integer" {
  let r = @lib.BytesReader::from_bytes(b"\x00") as @lib.Reader
  assert_eq!(r |> @lib.read_sint32!(), 0)
  let r = @lib.BytesReader::from_bytes(b"\x01") as @lib.Reader
  assert_eq!(r |> @lib.read_sint32!(), -1)
  let r = @lib.BytesReader::from_bytes(b"\x02") as @lib.Reader
  assert_eq!(r |> @lib.read_sint32!(), 1)
  let r = @lib.BytesReader::from_bytes(b"\x03") as @lib.Reader
  assert_eq!(r |> @lib.read_sint32!(), -2)
}

test "string" {
  let r = @lib.BytesReader::from_bytes(b"\x02\x61\x62") as @lib.Reader
  assert_eq!(r |> @lib.read_string!(), "ab")
  let r = @lib.BytesReader::from_bytes(b"\x06\xE4\xB8\xAD\xE6\x96\x87")
    as @lib.Reader
  assert_eq!(r |> @lib.read_string!(), "中文")
}

test "error" {
  let r = @lib.BytesReader::from_bytes(b"") as @lib.Reader
  assert_eq!(r |> @lib.read_varint32?(), Err(@lib.UnexpectedEnd))
}
