pub trait Sized {
  sizeof(Self) -> UInt
}

fn sizeof_varint(v : UInt64) -> UInt {
  if v < 0x80 {
    1
  } else if v < 0x3FFF {
    2
  } else if v < 0x1FFFFF {
    3
  } else if v < 0xFFFFFFF {
    4
  } else if v < 0x7FFFFFFFF {
    5
  } else if v < 0x3FFFFFFFFFF {
    6
  } else if v < 0x1FFFFFFFFFFFF {
    7
  } else if v < 0xFFFFFFFFFFFFFF {
    8
  } else if v < 0x7FFFFFFFFFFFFFFF {
    9
  } else {
    10
  }
}

pub impl Sized for UInt with sizeof(self) { sizeof_varint(self.to_uint64()) }

pub impl Sized for UInt64 with sizeof(self) { sizeof_varint(self) }

pub impl Sized for Int with sizeof(self) {
  sizeof_varint(self.to_int64().reinterpret_as_uint64())
}

pub impl Sized for Int64 with sizeof(self) {
  sizeof_varint(self.reinterpret_as_uint64())
}

pub impl Sized for SInt with sizeof(self) {
  sizeof_varint(
    ((self._ << 1) ^ (self._ >> 31)).reinterpret_as_uint().to_uint64(),
  )
}

pub impl Sized for SInt64 with sizeof(self) {
  sizeof_varint(((self._ << 1) ^ (self._ >> 63)).reinterpret_as_uint64())
}

pub impl Sized for Bool with sizeof(__) { 1 }

pub impl Sized for Enum with sizeof(self) {
  sizeof_varint(self._.to_int64().reinterpret_as_uint64())
}
