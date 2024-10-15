struct BytesReader {
  mut start : Int
  mut end : Int
}

/// A trait for reading messages from a buffer.
pub trait MessageRead {
  from_reader(BytesReader, Bytes) -> Self!ReaderError
}

type! ReaderError {
  UnexpectedEndOfBuffer
  Varint
}

fn raed_byte(self : BytesReader, bytes : Bytes) -> Byte!ReaderError {
  let len = bytes.length()
  if self.start >= len {
    raise UnexpectedEndOfBuffer
  }
  self.start += 1
  bytes[self.start]
}

fn read_varint32(self : BytesReader, bytes : Bytes) -> UInt!ReaderError {
  let mut b : Byte = self.raed_byte!(bytes) // byte0
  if (b & 0x80) == 0 {
    return b.to_uint()
  }
  let mut r = (b & 0x7f).to_uint()
  b = self.raed_byte!(bytes) // byte1
  r = r | ((b & 0x7f).to_uint() << 7)
  if (b & 0x80) == 0 {
    return r
  }
  b = self.raed_byte!(bytes) // byte2
  r = r | ((b & 0x7f).to_uint() << 14)
  if (b & 0x80) == 0 {
    return r
  }
  b = self.raed_byte!(bytes) // byte3
  r = r | ((b & 0x7f).to_uint() << 21)
  if (b & 0x80) == 0 {
    return r
  }
  b = self.raed_byte!(bytes) // byte4
  r = r | ((b & 0xf).to_uint() << 28) // silently prevent overflow; only mask 0xF
  if (b & 0x80) == 0 {
    // WARNING ABOUT TRUNCATION
    //
    // In this case, byte4 takes the form 0ZZZ_YYYY where:
    //     Y: part of the resulting 32-bit number
    //     Z: beyond 32 bits (excess bits,not used)
    //
    // If the Z bits were set, it might indicate that the number being
    // decoded was intended to be bigger than 32 bits, suggesting an
    // error somewhere else.
    //
    // However, for the sake of consistency with Google's own protobuf
    // implementation, and also to allow for any efficient use of those
    // extra bits by users if they wish (this package is meant for speed
    // optimization anyway) we shall not check for this here.
    //
    // Therefore, THIS FUNCTION SIMPLY IGNORES THE EXTRA BITS, WHICH IS
    // ESSENTIALLY A SILENT TRUNCATION!
    return r
  }

  // ANOTHER WARNING ABOUT TRUNCATION
  //
  // Again, we do not check whether the byte representation fits within 32
  // bits, and simply ignore extra bytes, CONSTITUTING A SILENT
  // TRUNCATION!
  //
  // Therefore, if the user wants this function to avoid ignoring any
  // bits/bytes, they need to ensure that the input is a varint
  // representing a value within EITHER u32 OR i32 range. Since at this
  // point we are beyond 5 bits, the only possible case is a negative i32
  // (since negative numbers are always 10 bytes in protobuf). We must
  // have exactly 5 bytes more to go.
  //
  // Since we know it must be a negative number, and this function is
  // meant to read 32-bit ints (there is a different function for reading
  // 64-bit ints), the user might want to take care to ensure that this
  // negative number is within valid i32 range, i.e. at least
  // -2,147,483,648. Otherwise, this function simply ignores the extra
  // bits, essentially constituting a silent truncation!
  //
  // What this means in the end is that the user should ensure that the
  // resulting number, once decoded from the varint format, takes such a
  // form:
  //
  // 11111111_11111111_11111111_11111111_1XXXXXXX_XXXXXXXX_XXXXXXXX_XXXXXXXX
  // ^(MSB bit 63)                       ^(bit 31 is set)                  ^(LSB bit 0)

  // discard extra bytes
  for _ in 0..<5 {
    b = self.raed_byte!(bytes)
    if (b & 0x80) == 0 {
      return r
    }
  }
  // cannot read more than 10 bytes
  raise ReaderError::Varint
}

fn read_varint64(self : BytesReader, bytes : Bytes) -> UInt64!ReaderError {
  // part 0
  let mut b : Byte = self.raed_byte!(bytes) // byte0
  if (b & 0x80) == 0 {
    return b.to_uint64()
  }
  let mut r0 = (b & 0x7f).to_uint()
  b = self.raed_byte!(bytes) // byte1
  r0 = r0 | ((b & 0x7f).to_uint() << 7)
  if (b & 0x80) == 0 {
    return r0.to_uint64()
  }
  b = self.raed_byte!(bytes) // byte2
  r0 = r0 | ((b & 0x7f).to_uint() << 14)
  if (b & 0x80) == 0 {
    return r0.to_uint64()
  }
  b = self.raed_byte!(bytes) // byte3
  r0 = r0 | ((b & 0x7f).to_uint() << 21)
  if (b & 0x80) == 0 {
    return r0.to_uint64()
  }
  b = self.raed_byte!(bytes) // byte4
  r0 = r0 | ((b & 0x7f).to_uint() << 28)
  if (b & 0x80) == 0 {
    return r0.to_uint64()
  }
  // part 1
  b = self.raed_byte!(bytes) // byte5
  let mut r1 = (b & 0x7f).to_uint()
  if (b & 0x80) == 0 {
    return r0.to_uint64() | (r1.to_uint64() << 28)
  }
  b = self.raed_byte!(bytes) // byte6
  r1 = r1 | ((b & 0x7f).to_uint() << 7)
  if (b & 0x80) == 0 {
    return r0.to_uint64() | (r1.to_uint64() << 28)
  }
  b = self.raed_byte!(bytes) // byte7
  r1 = r1 | ((b & 0x7f).to_uint() << 14)
  if (b & 0x80) == 0 {
    return r0.to_uint64() | (r1.to_uint64() << 28)
  }
  b = self.raed_byte!(bytes) // byte8
  r1 = r1 | ((b & 0x7f).to_uint() << 21)
  if (b & 0x80) == 0 {
    return r0.to_uint64() | (r1.to_uint64() << 28)
  }
  // part 2
  b = self.raed_byte!(bytes) // byte9
  let mut r2 = (b & 0x7f).to_uint()
  if (b & 0x80) == 0 {
    return r0.to_uint64() | (r1.to_uint64() << 28) | (r2.to_uint64() << 56)
  }
  // WARNING ABOUT TRUNCATION:
  //
  // For the number to be within valid 64 bit range, some conditions about
  // this last byte must be met:
  // 1. This must be the last byte (MSB not set)
  // 2. No 64-bit overflow (middle 6 bits are beyond 64 bits for the
  //    entire varint, so they cannot be set either)
  //
  // However, for the sake of consistency with Google's own protobuf
  // implementation, and also to allow for any efficient use of those
  // extra bits by users if they wish (this crate is meant for speed
  // optimization anyway) we shall not check for this here.
  //
  // Therefore, THIS FUNCTION SIMPLY IGNORES THE EXTRA BITS, WHICH IS
  // ESSENTIALLY A SILENT TRUNCATION!

  b = self.raed_byte!(bytes)
  r2 = r2 | (b.to_uint() << 7)
  if (b & 0x80) == 0 {
    return r0.to_uint64() | (r1.to_uint64() << 28) | (r2.to_uint64() << 56)
  }

  // cannot read more than 10 bytes
  raise ReaderError::Varint
}

fn read_int_from_bytes(self : BytesReader, bytes : Bytes) -> Int!ReaderError {
  let mut v : Int = 0
  for i in 0..<4 {
    let b = self.raed_byte!(bytes)
    v = v | (b.to_int() << (i * 8))
  }
  v
}

fn read_int64_from_bytes(
  self : BytesReader,
  bytes : Bytes
) -> Int64!ReaderError {
  let mut v : Int64 = 0
  for i in 0..<8 {
    let b = self.raed_byte!(bytes)
    v = v | (b.to_int64() << (i * 8))
  }
  v
}

fn read_uint_from_bytes(self : BytesReader, bytes : Bytes) -> UInt!ReaderError {
  let mut v : UInt = 0
  for i in 0..<4 {
    let b = self.raed_byte!(bytes)
    v = v | (b.to_uint() << (i * 8))
  }
  v
}

fn read_uint64_from_bytes(
  self : BytesReader,
  bytes : Bytes
) -> UInt64!ReaderError {
  let mut v : UInt64 = 0
  for i in 0..<8 {
    let b = self.raed_byte!(bytes)
    v = v | (b.to_uint64() << (i * 8))
  }
  v
}

fn read_int32(self : BytesReader, bytes : Bytes) -> Int!ReaderError {
  self.read_varint32!(bytes).reinterpret_as_int()
}

fn read_int64(self : BytesReader, bytes : Bytes) -> Int64!ReaderError {
  self.read_varint64!(bytes).to_int64()
}

fn read_uint32(self : BytesReader, bytes : Bytes) -> UInt!ReaderError {
  self.read_varint32!(bytes)
}

fn read_uint64(self : BytesReader, bytes : Bytes) -> UInt64!ReaderError {
  self.read_varint64!(bytes)
}

fn read_sint32(self : BytesReader, bytes : Bytes) -> Int!ReaderError {
  let n = self.read_varint32!(bytes)
  // zigzag encoding
  (n >> 1).reinterpret_as_int() ^ -(n & 1).reinterpret_as_int()
}

fn read_sint64(self : BytesReader, bytes : Bytes) -> Int64!ReaderError {
  let n = self.read_varint64!(bytes)
  // zigzag encoding
  (n >> 1).to_int64() ^ -(n & 1).to_int64()
}

fn read_fixed[T](
  self : BytesReader,
  bytes : Bytes,
  read : (BytesReader, Bytes) -> T!ReaderError
) -> T!ReaderError {
  let v = read!(self, bytes)
  v
}

fn read_fixed64(self : BytesReader, bytes : Bytes) -> UInt64!ReaderError {
  self.read_fixed!(bytes, read_uint64_from_bytes)
}

fn read_fixed32(self : BytesReader, bytes : Bytes) -> UInt!ReaderError {
  self.read_fixed!(bytes, read_uint_from_bytes)
}

fn read_sfixed32(self : BytesReader, bytes : Bytes) -> Int!ReaderError {
  self.read_fixed!(bytes, read_int_from_bytes)
}

fn read_sfixed64(self : BytesReader, bytes : Bytes) -> Int64!ReaderError {
  self.read_fixed!(bytes, read_int64_from_bytes)
}

fn read_float(self : BytesReader, bytes : Bytes) -> Float!ReaderError {
  self.read_fixed!(bytes, read_int_from_bytes).reinterpret_as_float()
}

fn read_double(self : BytesReader, bytes : Bytes) -> Double!ReaderError {
  self.read_fixed!(bytes, read_int64_from_bytes).reinterpret_as_double()
}

fn read_bool(self : BytesReader, bytes : Bytes) -> Bool!ReaderError {
  self.read_varint32!(bytes) != 0
}

// fn read_enum[T](self : BytesReader, bytes : Bytes) -> T!ReaderError {
//   self.read_int32!(bytes).reinterpret_as_enum()
// }
