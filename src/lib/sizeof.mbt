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
