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

pub type! ReaderError {
  UnexpectedEnd
  InvalidString
  UnknownWireType(UInt)
} derive(Eq, Show)

pub(open) trait Reader {
  next(Self) -> Byte?
  next_bytes(Self, UInt) -> Bytes?!ReaderError
}

pub fn is_eof[T : Reader](reader : T) -> Bool!ReaderError {
  reader.next_bytes!(0).is_empty()
}

fn read_byte[T : Reader](reader : T) -> Byte!ReaderError {
  match reader.next() {
    Some(b) => b
    None => raise UnexpectedEnd
  }
}

pub fn read_tag[T : Reader](reader : T) -> (UInt, UInt)!ReaderError {
  let value = reader |> read_varint32!()
  let tag = value >> 3
  let wire_type = value & 0x7
  if wire_type > 5 {
    raise ReaderError::UnknownWireType(wire_type)
  }
  (tag, wire_type)
}

pub fn read_varint32[T : Reader](reader : T) -> UInt!ReaderError {
  let mut b = 0U
  for i in 0..<5 {
    let byte = reader |> read_byte!() |> Byte::to_uint()
    b = ((byte & 0x7F) << (i * 7)) | b
    if (byte & 0x80) == 0 {
      return b
    }
  } else {
    b
  }
}

fn read_varint64[T : Reader](reader : T) -> UInt64!ReaderError {
  let mut b = 0UL
  for i in 0..<10 {
    let byte = reader |> read_byte!() |> Byte::to_uint64()
    b = ((byte & 0x7F) << (i * 7)) | b
    if (byte & 0x80) == 0 {
      return b
    }
  } else {
    b
  }
}

pub fn read_int32[T : Reader](reader : T) -> Int!ReaderError {
  reader |> read_varint32!() |> UInt::reinterpret_as_int
}

pub fn read_int64[T : Reader](reader : T) -> Int64!ReaderError {
  reader |> read_varint64!() |> UInt64::reinterpret_as_int64()
}

pub fn read_uint32[T : Reader](reader : T) -> UInt!ReaderError {
  reader |> read_varint32!()
}

pub fn read_uint64[T : Reader](reader : T) -> UInt64!ReaderError {
  reader |> read_varint64!()
}

pub fn read_sint32[T : Reader](reader : T) -> SInt!ReaderError {
  let n = reader |> read_varint32!()
  // zigzag encoding
  (n >> 1).reinterpret_as_int() ^ -(n & 1).reinterpret_as_int()
}

pub fn read_sint64[T : Reader](reader : T) -> SInt64!ReaderError {
  let n = reader |> read_varint64!()
  // zigzag encoding
  (n >> 1).reinterpret_as_int64() ^ -(n & 1).reinterpret_as_int64()
}

pub fn read_fixed32[T : Reader](reader : T) -> UInt!ReaderError {
  let mut v : UInt = 0
  for i in 0..<4 {
    let b = reader |> read_byte!()
    v = v | (b.to_uint() << (i * 8))
  }
  v
}

pub fn read_fixed64[T : Reader](reader : T) -> UInt64!ReaderError {
  let mut v : UInt64 = 0
  for i in 0..<8 {
    let b = reader |> read_byte!()
    v = v | (b.to_uint64() << (i * 8))
  }
  v
}

pub fn read_sfixed32[T : Reader](reader : T) -> Int!ReaderError {
  reader |> read_fixed32!() |> UInt::reinterpret_as_int
}

pub fn read_sfixed64[T : Reader](reader : T) -> Int64!ReaderError {
  reader |> read_fixed64!() |> UInt64::reinterpret_as_int64
}

pub fn read_float[T : Reader](reader : T) -> Float!ReaderError {
  reader |> read_sfixed32!() |> Int::reinterpret_as_float
}

pub fn read_double[T : Reader](reader : T) -> Double!ReaderError {
  reader |> read_sfixed64!() |> Int64::reinterpret_as_double
}

pub fn read_bool[T : Reader](reader : T) -> Bool!ReaderError {
  (reader |> read_varint32!()) != 0
}

pub fn read_enum[T : Reader](reader : T) -> Enum!ReaderError {
  reader |> read_uint32!()
}

pub fn read_bytes(self : Reader) -> Bytes!ReaderError {
  let length = self |> read_int32!()
  let bytes = Bytes::new(length)
  for i in 0..<length {
    bytes[i] = self |> read_byte!()
  }
  bytes
}

pub fn read_string(self : Reader) -> String!ReaderError {
  let length = self |> read_int32!()
  let string = StringBuilder::new()
  for i = 0; i < length; {
    let b = self |> read_byte!() |> Byte::to_int()
    if b < 0x80 {
      string.write_char(Char::from_int(b))
      continue i + 1
    } else if b < 0xE0 {
      if i + 1 == length {
        raise ReaderError::InvalidString
      }
      let b2 = self |> read_byte!() |> Byte::to_int()
      let ch = ((b & 0x1F) << 6) | (b2 & 0x3F)
      string.write_char(Char::from_int(ch))
      continue i + 2
    } else if b < 0xF0 {
      if i + 2 >= length {
        raise ReaderError::InvalidString
      }
      let b2 = self |> read_byte!() |> Byte::to_int()
      let b3 = self |> read_byte!() |> Byte::to_int()
      let ch = ((b & 0x0F) << 12) | ((b2 & 0x3F) << 6) | (b3 & 0x3F)
      string.write_char(Char::from_int(ch))
      continue i + 3
    } else if b < 0xF8 {
      if i + 3 >= length {
        raise ReaderError::InvalidString
      }
      let b2 = self |> read_byte!() |> Byte::to_int()
      let b3 = self |> read_byte!() |> Byte::to_int()
      let b4 = self |> read_byte!() |> Byte::to_int()
      let ch = ((b & 0x07) << 18) |
        ((b2 & 0x3F) << 12) |
        ((b3 & 0x3F) << 6) |
        (b4 & 0x3F)
      string.write_char(Char::from_int(ch))
      continue i + 4
    } else {
      raise ReaderError::InvalidString
    }
  }
  string.to_string()
}

/// Reads packed repeated field (Array[M])
///
/// Note: packed field are stored as a variable length chunk of data, while regular repeated
/// fields behaves like an iterator, yielding their tag everytime
pub fn read_packed[M : Sized, R : Reader](
  reader : R,
  read_fn : (Reader) -> M!ReaderError,
  size : UInt?
) -> Array[M]!ReaderError {
  let len = reader |> read_varint32!()
  guard let Some(bytes) = reader.next_bytes!(len) else {
    _ => raise ReaderError::UnexpectedEnd
  }
  let reader = bytes |> BytesReader::from_bytes
  let array = []
  match size {
    Some(size) =>
      for i = 0U; i < len / size; i = i + 1 {
        array.push(reader |> read_fn!())
      }
    None =>
      for i = 0U; i < len; {
        let value = reader |> read_fn!()
        let size = value.size_of()
        array.push(value)
        continue i + size
      }
  }
  array
}

pub fn read_unknown[T : Reader](
  reader : T,
  wire_type : UInt
) -> Unit!ReaderError {
  match wire_type {
    0 => reader |> read_varint64!() |> ignore
    1 => reader |> read_fixed64!() |> ignore
    2 => reader |> read_bytes!() |> ignore
    5 => reader |> read_fixed32!() |> ignore
    _ => raise ReaderError::UnknownWireType(wire_type)
  }
}
