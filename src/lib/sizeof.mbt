pub fn sizeof_varint(v : UInt64) -> UInt {
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

pub fn sizeof_len(l : UInt) -> UInt {
  sizeof_varint(l.to_uint64())
}

pub fn sizeof_int32(v : Int) -> UInt {
  sizeof_varint(v.to_uint64())
}

pub fn sizeof_int64(v : Int64) -> UInt {
  sizeof_varint(v.reinterpret_as_uint64())
}

pub fn sizeof_uint32(v : UInt) -> UInt {
  sizeof_varint(v.to_uint64())
}

pub fn sizeof_uint64(v : UInt64) -> UInt {
  sizeof_varint(v)
}

pub fn sizeof_sint32(v : Int) -> UInt {
  sizeof_varint(((v << 1) ^ (v >> 31)).to_uint64())
}

pub fn sizeof_sint64(v : Int64) -> UInt {
  sizeof_varint(((v << 1) ^ (v >> 63)).reinterpret_as_uint64())
}

pub fn sizeof_bool(__ : Bool) -> UInt {
  1
}

pub fn sizeof_enum(v : Int) -> UInt {
  sizeof_int32(v)
}
