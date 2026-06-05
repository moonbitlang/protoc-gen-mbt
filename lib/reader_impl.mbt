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
pub(all) suberror ReaderError {
  EndOfStream
  InvalidString
  InvalidBase64
  InvalidLength
  InvalidPackedLength
  OverlongVarint
  UnknownWireType(UInt)
} derive(Eq, Debug)

///|
pub impl Show for ReaderError with fn output(self, logger) {
  match self {
    EndOfStream => logger.write_string("EndOfStream")
    InvalidString => logger.write_string("InvalidString")
    InvalidBase64 => logger.write_string("InvalidBase64")
    InvalidLength => logger.write_string("InvalidLength")
    InvalidPackedLength => logger.write_string("InvalidPackedLength")
    OverlongVarint => logger.write_string("OverlongVarint")
    UnknownWireType(wire_type) =>
      logger
      ..write_string("UnknownWireType(")
      ..write_object(wire_type)
      .write_string(")")
  }
}

///|
struct BytesReader {
  data : Bytes
  len : Int
  mut start : Int
}

///|
pub impl Show for BytesReader with fn output(self, logger) {
  logger
  ..write_string("{data: ")
  ..write_object(self.data)
  ..write_string(", len: ")
  ..write_object(self.len)
  ..write_string(", start: ")
  ..write_object(self.start)
  .write_string("}")
}

///|
pub fn BytesReader::from_bytes(data : Bytes) -> BytesReader {
  { data, len: data.length(), start: 0 }
}

///|
/// Wraps another reader and serves small reads from an internal buffer.
struct BufferedReader[T] {
  reader : T
  buffer : FixedArray[Byte]
  mut start : Int
  mut end : Int
}

///|
pub fn[T] BufferedReader::new(
  reader : T,
  capacity? : Int = 4096,
) -> BufferedReader[T] {
  let capacity = if capacity <= 0 { 4096 } else { capacity }
  { reader, buffer: FixedArray::make(capacity, 0), start: 0, end: 0 }
}

///|
fn[T] BufferedReader::read_from_buffer(
  self : BufferedReader[T],
  bytes : FixedArray[Byte],
  offset~ : Int,
  max_length~ : Int,
) -> Int {
  let read_length = @cmp.minimum(max_length, self.end - self.start)
  if read_length == 1 {
    bytes[offset] = self.buffer[self.start]
  } else {
    self.buffer.blit_to(
      bytes,
      len=read_length,
      src_offset=self.start,
      dst_offset=offset,
    )
  }
  self.start += read_length
  if self.start == self.end {
    self.start = 0
    self.end = 0
  }
  read_length
}

///|
pub impl Reader for BytesReader with fn read(
  self,
  bytes : FixedArray[Byte],
  offset~ : Int,
  max_length~ : Int,
) -> Int? {
  if offset >= bytes.length() || max_length <= 0 || self.start >= self.len {
    return None
  }
  let read_length = @cmp.minimum(
    @cmp.minimum(bytes.length() - offset, max_length),
    self.len - self.start,
  )
  if read_length == 1 {
    bytes[offset] = self.data[self.start]
  } else {
    bytes.blit_from_bytes(offset, self.data, self.start, read_length)
  }
  self.start += read_length
  Some(read_length)
}

///|
pub impl AsyncReader for BytesReader with fn read(
  self,
  bytes : FixedArray[Byte],
  offset~ : Int,
  max_length~ : Int,
) -> Int? raise {
  if offset >= bytes.length() || max_length <= 0 || self.start >= self.len {
    return None
  }
  let read_length = @cmp.minimum(
    @cmp.minimum(bytes.length() - offset, max_length),
    self.len - self.start,
  )
  if read_length == 1 {
    bytes[offset] = self.data[self.start]
  } else {
    bytes.blit_from_bytes(offset, self.data, self.start, read_length)
  }
  self.start += read_length
  Some(read_length)
}

///|
pub impl[T : Reader] Reader for BufferedReader[T] with fn read(
  self,
  bytes : FixedArray[Byte],
  offset~ : Int,
  max_length~ : Int,
) -> Int? {
  if offset >= bytes.length() || max_length <= 0 {
    return None
  }
  let max_length = @cmp.minimum(bytes.length() - offset, max_length)
  if self.start < self.end {
    return Some(self.read_from_buffer(bytes, offset~, max_length~))
  }
  if max_length >= self.buffer.length() {
    self.reader.read(bytes, offset~, max_length~)
  } else {
    match
      self.reader.read(self.buffer, offset=0, max_length=self.buffer.length()) {
      Some(read_length) => {
        if read_length <= 0 {
          return Some(read_length)
        }
        self.start = 0
        self.end = read_length
        Some(self.read_from_buffer(bytes, offset~, max_length~))
      }
      None => None
    }
  }
}

///|
pub impl[T : AsyncReader] AsyncReader for BufferedReader[T] with fn read(
  self,
  bytes : FixedArray[Byte],
  offset~ : Int,
  max_length~ : Int,
) -> Int? {
  if offset >= bytes.length() || max_length <= 0 {
    return None
  }
  let max_length = @cmp.minimum(bytes.length() - offset, max_length)
  if self.start < self.end {
    return Some(self.read_from_buffer(bytes, offset~, max_length~))
  }
  if max_length >= self.buffer.length() {
    self.reader.read(bytes, offset~, max_length~)
  } else {
    match
      self.reader.read(self.buffer, offset=0, max_length=self.buffer.length()) {
      Some(read_length) => {
        if read_length <= 0 {
          return Some(read_length)
        }
        self.start = 0
        self.end = read_length
        Some(self.read_from_buffer(bytes, offset~, max_length~))
      }
      None => None
    }
  }
}

///|
pub(all) struct LimitedReader[T] {
  reader : T
  mut limit : Int?
}

///|
pub fn[T] LimitedReader::new(reader : T, limit? : Int) -> LimitedReader[T] {
  { reader, limit }
}

///|
pub impl[T : Reader] Reader for LimitedReader[T] with fn read(
  self,
  bytes : FixedArray[Byte],
  offset~ : Int,
  max_length~ : Int,
) -> Int? {
  if self.limit is Some(0) {
    return None
  }
  let max_length = if self.limit is Some(limit) {
    @cmp.minimum(limit, max_length)
  } else {
    max_length
  }
  let read_length = self.reader.read(bytes, offset~, max_length~)
  if read_length is Some(length) && self.limit is Some(limit) {
    self.limit = Some(limit - length)
  }
  read_length
}

///|
pub impl[T : AsyncReader] AsyncReader for LimitedReader[T] with fn read(
  self,
  bytes : FixedArray[Byte],
  offset~ : Int,
  max_length~ : Int,
) -> Int? raise {
  if self.limit is Some(0) {
    return None
  }
  let max_length = if self.limit is Some(limit) {
    @cmp.minimum(limit, max_length)
  } else {
    max_length
  }
  let read_length = self.reader.read(bytes, offset~, max_length~)
  if read_length is Some(length) && self.limit is Some(limit) {
    self.limit = Some(limit - length)
  }
  read_length
}
