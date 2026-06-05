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
  @debug.assert_eq(r |> @protobuf.read_varint32(), 150)
}

///|

///|
test "read_int32" {
  let bytes = b"\xFE\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x01"
  let r = @protobuf.BytesReader::from_bytes(bytes) as &@protobuf.Reader
  @debug.assert_eq(r |> @protobuf.read_int64(), -2)
}

///|
test "read_int32/2" {
  let bytes = b"\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x01"
  let r = @protobuf.BytesReader::from_bytes(bytes) as &@protobuf.Reader
  @debug.assert_eq(r |> @protobuf.read_int32(), -1)
}

///|
test "read_int32/3" {
  // negative int32 is encoded as 10-byte varint (sign-extended to 64 bits),
  // so read_int32 (which uses read_varint64) must be used instead of read_varint32
  let bytes = b"\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x01"
  let r = @protobuf.BytesReader::from_bytes(bytes) as &@protobuf.Reader
  @debug.assert_eq(r |> @protobuf.read_int32(), -1)
}

///|
test "end_of_bytes" {
  // negative int32 is encoded as 10-byte varint (sign-extended to 64 bits),
  // so read_int32 (which uses read_varint64) must be used instead of read_varint32
  let bytes = b"\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x01"
  let r = @protobuf.BytesReader::from_bytes(bytes) as &@protobuf.Reader
  @debug.assert_eq(r |> @protobuf.read_int32(), -1)
}

///|
test "read_string" {
  let r = @protobuf.BytesReader::from_bytes(b"\x02\x61\x62")
    as &@protobuf.Reader
  @debug.assert_eq(r |> @protobuf.read_string(), "ab")
  let r = @protobuf.BytesReader::from_bytes(b"\x06\xE4\xB8\xAD\xE6\x96\x87")
    as &@protobuf.Reader
  @debug.assert_eq(r |> @protobuf.read_string(), "中文")
}

///|
test "read_string/overlong_2byte" {
  // \xC0\x80 is an overlong encoding of U+0000 (null)
  let r = @protobuf.BytesReader::from_bytes(b"\x02\xC0\x80")
    as &@protobuf.Reader
  try {
    let _ = r |> @protobuf.read_string()
    fail("expected InvalidString")
  } catch {
    @protobuf.InvalidString => ()
    err => raise err
  }
}

///|
test "read_string/surrogate" {
  // \xED\xA0\x80 is U+D800 (surrogate)
  let r = @protobuf.BytesReader::from_bytes(b"\x03\xED\xA0\x80")
    as &@protobuf.Reader
  try {
    let _ = r |> @protobuf.read_string()
    fail("expected InvalidString")
  } catch {
    @protobuf.InvalidString => ()
    err => raise err
  }
}

///|
test "read_string/invalid_continuation" {
  // \xC2\xFF has a second byte that is not a valid continuation byte.
  let r = @protobuf.BytesReader::from_bytes(b"\x02\xC2\xFF")
    as &@protobuf.Reader
  try {
    let _ = r |> @protobuf.read_string()
    fail("expected InvalidString")
  } catch {
    @protobuf.InvalidString => ()
    err => raise err
  }
}

///|
test "read_string/invalid_continuation_3byte" {
  // \xE0\x00\x80 has a second byte that is not a valid continuation byte.
  let r = @protobuf.BytesReader::from_bytes(b"\x03\xE0\x00\x80")
    as &@protobuf.Reader
  try {
    let _ = r |> @protobuf.read_string()
    fail("expected InvalidString")
  } catch {
    @protobuf.InvalidString => ()
    err => raise err
  }
}

///|
test "read_string/overlong_3byte" {
  // \xE0\x80\x80 is an overlong encoding of U+0000 (decoded value < 0x800)
  let r = @protobuf.BytesReader::from_bytes(b"\x03\xE0\x80\x80")
    as &@protobuf.Reader
  try {
    let _ = r |> @protobuf.read_string()
    fail("expected InvalidString")
  } catch {
    @protobuf.InvalidString => ()
    err => raise err
  }
}

///|
test "read_string/codepoint_too_large" {
  // \xF4\x90\x80\x80 encodes U+110000, which is above Unicode's max code point.
  let r = @protobuf.BytesReader::from_bytes(b"\x04\xF4\x90\x80\x80")
    as &@protobuf.Reader
  try {
    let _ = r |> @protobuf.read_string()
    fail("expected InvalidString")
  } catch {
    @protobuf.InvalidString => ()
    err => raise err
  }
}

///|
test "read_string/invalid_payload_is_consumed" {
  let r = @protobuf.BytesReader::from_bytes(b"\x03\xFF\x61\x62\x96\x01")
    as &@protobuf.Reader
  try {
    let _ = r |> @protobuf.read_string()
    fail("expected InvalidString")
  } catch {
    @protobuf.InvalidString => ()
    err => raise err
  }
  @debug.assert_eq(r |> @protobuf.read_varint32(), 150)
}

///|
test "error" {
  let r = @protobuf.BytesReader::from_bytes(b"") as &@protobuf.Reader
  try {
    let _ = r |> @protobuf.read_varint32()
    fail("expected EndOfStream")
  } catch {
    @protobuf.EndOfStream => ()
    err => raise err
  }
}

///|
test "BytesReader::read returns None for out-of-range offset" {
  let reader = @protobuf.BytesReader::from_bytes(b"\x01\x02\x03")
  let buf : FixedArray[Byte] = FixedArray::make(4, b'\x00')
  // offset equals buffer length -> should return None, not wrap
  let result = (reader as &@protobuf.Reader).read(buf, offset=4, max_length=1)
  @debug.assert_eq(result, None)
  // offset exceeds buffer length -> should also return None
  let result2 = (reader as &@protobuf.Reader).read(buf, offset=10, max_length=1)
  @debug.assert_eq(result2, None)
}

///|
test "overlong_varint32" {
  // 6 bytes all with continuation bit set: overlong for varint32 (max 5 bytes)
  let bytes = b"\x80\x80\x80\x80\x80\x80"
  let r = @protobuf.BytesReader::from_bytes(bytes) as &@protobuf.Reader
  try {
    let _ = r |> @protobuf.read_varint32()
    fail("expected OverlongVarint")
  } catch {
    @protobuf.OverlongVarint => ()
    err => raise err
  }
}

///|
test "read_varint32 rejects final-byte overflow" {
  let bytes = b"\xFF\xFF\xFF\xFF\x10"
  let r = @protobuf.BytesReader::from_bytes(bytes) as &@protobuf.Reader
  try {
    let _ = r |> @protobuf.read_varint32()
    fail("expected OverlongVarint")
  } catch {
    @protobuf.OverlongVarint => ()
    err => raise err
  }
}

///|
test "overlong_varint64" {
  // 11 bytes all with continuation bit set: overlong for varint64 (max 10 bytes)
  let bytes = b"\x80\x80\x80\x80\x80\x80\x80\x80\x80\x80\x80"
  let r = @protobuf.BytesReader::from_bytes(bytes) as &@protobuf.Reader
  try {
    let _ = r |> @protobuf.read_int64()
    fail("expected OverlongVarint")
  } catch {
    @protobuf.OverlongVarint => ()
    err => raise err
  }
}

///|
test "read_varint64 rejects final-byte overflow" {
  let bytes = b"\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x02"
  let r = @protobuf.BytesReader::from_bytes(bytes) as &@protobuf.Reader
  try {
    let _ = r |> @protobuf.read_int64()
    fail("expected OverlongVarint")
  } catch {
    @protobuf.OverlongVarint => ()
    err => raise err
  }
}

///|
test "read_bytes/negative_length" {
  // -1 encoded as a protobuf int32 (10-byte varint)
  let r = @protobuf.BytesReader::from_bytes(
      b"\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x01",
    )
    as &@protobuf.Reader
  try {
    let _ = r |> @protobuf.read_bytes()
    fail("expected InvalidLength")
  } catch {
    @protobuf.InvalidLength => ()
    err => raise err
  }
}

///|
test "read_string/negative_length" {
  // -1 encoded as a protobuf int32 (10-byte varint)
  let r = @protobuf.BytesReader::from_bytes(
      b"\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x01",
    )
    as &@protobuf.Reader
  try {
    let _ = r |> @protobuf.read_string()
    fail("expected InvalidLength")
  } catch {
    @protobuf.InvalidLength => ()
    err => raise err
  }
}

///|
test "read_message_fields handles known fields and skips unknown fields" {
  let reader = @protobuf.BytesReader::from_bytes(b"\x08\x96\x01\x10\x01")
    as &@protobuf.Reader
  let reader = @protobuf.LimitedReader::new(reader)
  let mut value = 0
  reader
  |> @protobuf.read_message_fields(fn(field_number, wire_type) raise {
    match (field_number, wire_type) {
      (1, 0) => {
        value = reader |> @protobuf.read_int32()
        true
      }
      _ => false
    }
  })
  @debug.assert_eq(value, 150)
}

///|
test "read_packed rejects misaligned length for fixed-size elements" {
  // Length prefix of 5 bytes, but fixed32 elements are 4 bytes each.
  // 5 % 4 != 0, so this should be rejected.
  let bytes = b"\x05\x01\x02\x03\x04\x05"
  let r = @protobuf.BytesReader::from_bytes(bytes)
  try {
    let _ = @protobuf.read_packed(r, @protobuf.read_fixed32, Some(4))
    fail("expected InvalidPackedLength")
  } catch {
    @protobuf.InvalidPackedLength => ()
    err => raise err
  }
}
