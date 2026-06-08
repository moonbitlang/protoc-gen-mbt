// Copyright 2025 International Digital Economy Academy
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
/// Trait representing the reader
pub(open) trait Reader {
  fn read(Self, FixedArray[Byte], offset~ : Int, max_length~ : Int) -> Int? raise
}

///|
let varint_bytes : FixedArray[Byte] = FixedArray::make(256, 0)

///|
fn[T : Reader] read_byte(reader : T) -> Byte raise {
  match reader.read(varint_bytes, offset=0, max_length=1) {
    Some(1) => varint_bytes[0]
    _ => raise EndOfStream
  }
}

///|
fn[T : Reader] read_exactly(
  reader : T,
  bytes : FixedArray[Byte],
  offset~ : Int,
  length~ : Int,
) -> Unit raise {
  let mut read_length = 0
  while read_length < length {
    match
      reader.read(
        bytes,
        offset=offset + read_length,
        max_length=length - read_length,
      ) {
      Some(len) => {
        if len <= 0 {
          raise ReaderError::EndOfStream
        }
        read_length += len
      }
      None => raise ReaderError::EndOfStream
    }
  }
}

///|
pub fn[T : Reader] read_tag(reader : T) -> (UInt, UInt) raise {
  let value = reader |> read_varint32()
  let tag = value >> 3
  let wire_type = value & 0x7
  if wire_type > 5 {
    raise ReaderError::UnknownWireType(wire_type)
  }
  (tag, wire_type)
}

///|
pub fn[T : Reader] read_varint32(reader : T) -> UInt raise {
  let mut b = 0U
  for i in 0..<5 {
    let byte = reader |> read_byte() |> Byte::to_uint()
    if i == 4 && byte > 0x0FU {
      raise ReaderError::OverlongVarint
    }
    b = ((byte & 0x7F) << (i * 7)) | b
    if (byte & 0x80) == 0 {
      return b
    }
  } nobreak {
    raise ReaderError::OverlongVarint
  }
}

///|
fn[T : Reader] read_varint64(reader : T) -> UInt64 raise {
  let mut b = 0UL
  for i in 0..<10 {
    let byte = reader |> read_byte() |> Byte::to_uint64()
    if i == 9 && byte > 0x01UL {
      raise ReaderError::OverlongVarint
    }
    b = ((byte & 0x7F) << (i * 7)) | b
    if (byte & 0x80) == 0 {
      return b
    }
  } nobreak {
    raise ReaderError::OverlongVarint
  }
}

///|
pub fn[T : Reader] read_int32(reader : T) -> Int raise {
  // if integer is negative, varint32 is encoded as 10 bytes
  reader |> read_varint64() |> UInt64::to_int()
}

///|
pub fn[T : Reader] read_int64(reader : T) -> Int64 raise {
  reader |> read_varint64() |> UInt64::reinterpret_as_int64()
}

///|
pub fn[T : Reader] read_uint32(reader : T) -> UInt raise {
  reader |> read_varint32()
}

///|
pub fn[T : Reader] read_uint64(reader : T) -> UInt64 raise {
  reader |> read_varint64()
}

///|
pub fn[T : Reader] read_sint32(reader : T) -> SInt raise {
  let n = reader |> read_varint32()
  // zigzag encoding
  (n >> 1).reinterpret_as_int() ^ -(n & 1).reinterpret_as_int()
}

///|
pub fn[T : Reader] read_sint64(reader : T) -> SInt64 raise {
  let n = reader |> read_varint64()
  // zigzag encoding
  (n >> 1).reinterpret_as_int64() ^ -(n & 1).reinterpret_as_int64()
}

///|
pub fn[T : Reader] read_fixed32(reader : T) -> UInt raise {
  read_exactly(reader, varint_bytes, offset=0, length=4)
  let mut v : UInt = 0
  for i in 0..<4 {
    v = v | (varint_bytes[i].to_uint() << (i * 8))
  }
  v
}

///|
pub fn[T : Reader] read_fixed64(reader : T) -> UInt64 raise {
  read_exactly(reader, varint_bytes, offset=0, length=8)
  let mut v : UInt64 = 0
  for i in 0..<8 {
    v = v | (varint_bytes[i].to_uint64() << (i * 8))
  }
  v
}

///|
pub fn[T : Reader] read_sfixed32(reader : T) -> Int raise {
  reader |> read_fixed32() |> UInt::reinterpret_as_int
}

///|
pub fn[T : Reader] read_sfixed64(reader : T) -> Int64 raise {
  reader |> read_fixed64() |> UInt64::reinterpret_as_int64
}

///|
pub fn[T : Reader] read_float(reader : T) -> Float raise {
  reader |> read_sfixed32() |> Float::reinterpret_from_int
}

///|
pub fn[T : Reader] read_double(reader : T) -> Double raise {
  reader |> read_sfixed64() |> Int64::reinterpret_as_double
}

///|
pub fn[T : Reader] read_bool(reader : T) -> Bool raise {
  (reader |> read_varint32()) != 0
}

///|
pub fn[T : Reader] read_enum(reader : T) -> Enum raise {
  reader |> read_uint32()
}

///|
pub fn[T : Reader] read_bytes(reader : T) -> Bytes raise {
  let length = reader |> read_int32()
  if length < 0 {
    raise ReaderError::InvalidLength
  }
  let bytes : FixedArray[Byte] = FixedArray::make(length, 0)
  read_exactly(reader, bytes, offset=0, length~)
  bytes.unsafe_reinterpret_as_bytes()
}

///|
pub fn[T : Reader] read_string(reader : T) -> String raise {
  reader |> read_bytes() |> decode_utf8_string()
}

///|
/// Reads a length-delimited embedded message after its size prefix.
pub fn[M : Read + Default] read_message(
  reader : LimitedReader[&Reader],
) -> M raise {
  let len = reader |> read_int32()
  if len < 0 {
    raise ReaderError::InvalidLength
  }
  match len {
    0 => M::default()
    _ => {
      let new_limit = if reader.limit is Some(l) {
        if l < len {
          raise EndOfStream
        }
        Some(l - len)
      } else {
        None
      }
      reader.limit = Some(len)
      let previous_end_group = reader.end_group
      let previous_end_group_seen = reader.end_group_seen
      reader.end_group = None
      reader.end_group_seen = false
      let msg = try reader |> M::read_with_limit() catch {
        err => {
          reader.limit = new_limit
          reader.end_group = previous_end_group
          reader.end_group_seen = previous_end_group_seen
          raise err
        }
      }
      reader.end_group = previous_end_group
      reader.end_group_seen = previous_end_group_seen
      reader.limit = new_limit
      msg
    }
  }
}

///|
/// Reads a delimited message payload after its start-group tag has already
/// been consumed, then consumes the matching end-group tag for `field_number`.
///
/// This helper is used by generated code for proto2 groups and Editions
/// `features.message_encoding = DELIMITED`.
pub fn[M : Read] read_delimited_message(
  reader : LimitedReader[&Reader],
  field_number : UInt,
) -> M raise {
  let previous_end_group = reader.end_group
  let previous_end_group_seen = reader.end_group_seen
  reader.end_group = Some(field_number)
  reader.end_group_seen = false
  let msg = try {
    let msg = reader |> M::read_with_limit()
    if !reader.end_group_seen {
      reader |> read_delimited_message_tail(field_number)
    }
    msg
  } catch {
    err => {
      reader.end_group = previous_end_group
      reader.end_group_seen = previous_end_group_seen
      raise err
    }
  }
  let end_group_seen = reader.end_group_seen
  reader.end_group = previous_end_group
  reader.end_group_seen = previous_end_group_seen
  if !end_group_seen {
    raise EndOfStream
  }
  msg
}

///|
fn[T : Reader] read_delimited_message_tail(
  reader : LimitedReader[T],
  field_number : UInt,
) -> Unit raise {
  while !reader.end_group_seen {
    let next = Some(reader |> read_tag()) catch {
      EndOfStream => None
      err => raise err
    }
    match next {
      Some((nested_field_number, 4)) =>
        if nested_field_number == field_number {
          reader.end_group_seen = true
        } else {
          raise ReaderError::UnknownWireType(4)
        }
      Some((nested_field_number, nested_wire_type)) =>
        reader
        |> skip_message_field_by_number(nested_field_number, nested_wire_type)
      None => break
    }
  }
}

///|
/// Reads the next field number and wire type within a message body.
///
/// Returns `None` at the end of a length-delimited message or after consuming
/// the matching end-group tag for a delimited message.
pub fn[R : Reader] read_next_message_field(
  reader : LimitedReader[R],
) -> (UInt, UInt)? raise {
  Some(
    {
      let (field_number, wire) = reader |> read_tag()
      if wire == 4 {
        match reader.end_group {
          Some(end_group) if field_number == end_group => {
            reader.end_group_seen = true
            return None
          }
          _ => raise ReaderError::UnknownWireType(wire)
        }
      }
      (field_number, wire)
    },
  ) catch {
    EndOfStream => None
    err => raise err
  }
}

///|
/// Reads packed repeated field (Array[M])
///
/// Note: packed field are stored as a variable length chunk of data, while regular repeated
/// fields behaves like an iterator, yielding their tag everytime
pub fn[M : Sized, R : Reader] read_packed(
  reader : R,
  read_fn : (LimitedReader[R]) -> M raise,
  size : UInt?,
) -> Array[M] raise {
  let len = reader |> read_varint32()
  let array = []
  let reader = LimitedReader::new(reader, limit=len.reinterpret_as_int())
  match size {
    Some(size) => {
      if len % size != 0U {
        raise ReaderError::InvalidPackedLength
      }
      for i = 0U; i < len / size; i = i + 1 {
        array.push(reader |> read_fn())
      }
    }
    None =>
      for i = 0U; i < len; {
        let value = reader |> read_fn()
        let size = value.size_of()
        array.push(value)
        continue i + size
      }
  }
  array
}

///|
/// Skips an unknown non-group field payload by wire type.
///
/// Use `skip_message_field_by_number` while parsing message bodies so unknown
/// group fields can be skipped with their matching end-group field number.
pub fn[T : Reader] read_unknown(reader : T, wire_type : UInt) -> Unit raise {
  match wire_type {
    0 => reader |> read_varint64() |> ignore
    1 => reader |> read_fixed64() |> ignore
    2 => reader |> read_bytes() |> ignore
    5 => reader |> read_fixed32() |> ignore
    _ => raise ReaderError::UnknownWireType(wire_type)
  }
}

///|
fn[T : Reader] read_unknown_field(
  reader : T,
  field_number : UInt,
  wire_type : UInt,
) -> Unit raise {
  match wire_type {
    3 =>
      while true {
        let (nested_field_number, nested_wire_type) = reader |> read_tag()
        if nested_wire_type == 4 {
          if nested_field_number == field_number {
            return
          }
          raise ReaderError::UnknownWireType(nested_wire_type)
        }
        reader |> read_unknown_field(nested_field_number, nested_wire_type)
      }
    4 => raise ReaderError::UnknownWireType(wire_type)
    _ => reader |> read_unknown(wire_type)
  }
}

///|
/// Skips an unknown non-group message field by wire type.
///
/// This legacy helper cannot skip wire type 3 groups because the matching
/// end-group tag requires the field number.
pub fn[T : Reader] skip_message_field(
  reader : T,
  wire_type : UInt,
) -> Unit raise {
  reader |> read_unknown(wire_type)
}

///|
/// Skips an unknown message field by field number and wire type.
///
/// Unlike `skip_message_field`, this handles wire type 3 groups by reading
/// nested fields until the matching wire type 4 end-group tag is found.
pub fn[T : Reader] skip_message_field_by_number(
  reader : T,
  field_number : UInt,
  wire_type : UInt,
) -> Unit raise {
  reader |> read_unknown_field(field_number, wire_type)
}
