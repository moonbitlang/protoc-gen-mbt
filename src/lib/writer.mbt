fn field_type(f : @generator.FieldDescriptorProto_Type) -> Int {
  match f {
    FieldDescriptorProto_TYPE_INT32
    | FieldDescriptorProto_TYPE_UINT32
    | FieldDescriptorProto_TYPE_SINT32
    | FieldDescriptorProto_TYPE_INT64
    | FieldDescriptorProto_TYPE_UINT64
    | FieldDescriptorProto_TYPE_SINT64
    | FieldDescriptorProto_TYPE_BOOL | FieldDescriptorProto_TYPE_ENUM => 0
    FieldDescriptorProto_TYPE_DOUBLE
    | FieldDescriptorProto_TYPE_FIXED64 | FieldDescriptorProto_TYPE_SFIXED64 =>
      1
    FieldDescriptorProto_TYPE_STRING
    | FieldDescriptorProto_TYPE_BYTES | FieldDescriptorProto_TYPE_MESSAGE => 2
    FieldDescriptorProto_TYPE_GROUP => 3
    FieldDescriptorProto_TYPE_FIXED32
    | FieldDescriptorProto_TYPE_SFIXED32 | FieldDescriptorProto_TYPE_FLOAT => 5
  }
}

fn zigzag_encoding(v : Int64) -> Int64 {
  if v < 0 {
    v * -2 - 1
  } else {
    v * 2
  }
}

pub trait WriteExt {
  pb_write_u32(Self, UInt) -> Unit
  pb_write_u64(Self, UInt64) -> Unit
}

struct Writer {
  inner : Buffer
}

fn write_varint(self : Writer, input : UInt64) -> Unit {
  let mut v = input
  while v >= 0x80 {
    self.inner.write_byte((v.to_byte() & 0x7F) | 0x80)
    v = v >> 7
  }
  self.inner.write_byte(v.to_byte())
}

fn write_tag(self : Writer, tag : UInt) -> Unit {
  self.write_varint(tag.to_uint64())
}

fn write_int32(self : Writer, v : Int) -> Unit {
  self.write_varint(v.to_int64().reinterpret_as_uint64())
}

fn write_int64(self : Writer, v : Int64) -> Unit {
  self.write_varint(v.reinterpret_as_uint64())
}

fn write_uint32(self : Writer, v : UInt) -> Unit {
  self.write_varint(v.to_uint64())
}

fn write_uint64(self : Writer, v : UInt64) -> Unit {
  self.write_varint(v)
}

fn write_sint32(self : Writer, v : Int) -> Unit {
  self.write_varint(((v << 1) ^ (v >> 31)).to_uint64())
}

fn write_sint64(self : Writer, v : Int64) -> Unit {
  self.write_varint(((v << 1) ^ (v >> 63)).reinterpret_as_uint64())
}

pub impl WriteExt for Buffer with pb_write_u32(self, v) {
  for i in 0..<4 {
    self.write_byte((v >> (i * 8)).to_byte())
  }
}

pub impl WriteExt for Buffer with pb_write_u64(self, v) {
  for i in 0..<8 {
    self.write_byte((v >> (i * 8)).to_byte())
  }
}

fn write_fixed32(self : Writer, v : UInt) -> Unit {
  WriteExt::pb_write_u32(self.inner, v)
}

fn write_fixed64(self : Writer, v : UInt64) -> Unit {
  WriteExt::pb_write_u64(self.inner, v)
}

fn write_sfixed32(self : Writer, v : Int) -> Unit {
  WriteExt::pb_write_u32(self.inner, v.reinterpret_as_uint())
}

fn write_sfixed64(self : Writer, v : Int64) -> Unit {
  WriteExt::pb_write_u64(self.inner, v.reinterpret_as_uint64())
}

fn write_float(self : Writer, v : Float) -> Unit {
  WriteExt::pb_write_u32(
    self.inner,
    v.reinterpret_as_int().reinterpret_as_uint(),
  )
}

fn write_double(self : Writer, v : Double) -> Unit {
  WriteExt::pb_write_u64(self.inner, v.reinterpret_as_uint64())
}

fn write_bool(self : Writer, v : Bool) -> Unit {
  self.inner.write_byte((if v { 1 } else { 0 }).to_byte())
}

fn write_enum(self : Writer, v : Int) -> Unit {
  self.write_int32(v)
}

fn write_bytes(self : Writer, v : Bytes) -> Unit {
  self.write_varint(v.length().to_uint64())
  self.inner.write_bytes(v)
}

fn write_string(self : Writer, v : String) -> Unit {
  self.write_varint(v.length().to_uint64())
  self.inner.write_string(v)
}

pub trait MessageWrite {
  write_to_writer(Self, Writer) -> Unit
  get_size(Self) -> UInt
}

fn write_message(self : Writer, m : MessageWrite) -> Unit {
  let len = m.get_size()
  self.write_varint(len.to_uint64())
  m.write_to_writer(self)
}

fn write_with_tag(self : Writer, tag : UInt, f : (Writer) -> Unit) -> Unit {
  self.write_tag(tag)
  f(self)
}

/// Write entire map
fn wirte_map(
  self : Writer,
  size : UInt,
  write_key_fn : (Writer) -> Unit,
  tag_key : UInt,
  write_val_fn : (Writer) -> Unit,
  tag_val : UInt
) -> Unit {
  self.write_varint(size.to_uint64())
  self.write_tag(tag_key)
  write_key_fn(self)
  self.write_tag(tag_val)
  write_val_fn(self)
}

/// Writes packed repeated field: length first then the chunk of data
// fn write_packed[T](
//   self : Writer,
//   v : Array[T],
//   write_fn : (Writer, T) -> Unit,
//   size_fn : (T) -> UInt
// ) -> Unit {
//   if v.is_empty() {
//     return
//   }
//   let mut total_len = 0U
//   v.each(fn(x) { total_len += size_fn(x) })
//   self.write_varint(total_len.to_uint64())
//   for i in v {
//     write_fn(self, i)
//   }
// }

// fn write_packed_with_tag[T](
//   self : Writer,
//   tag : UInt,
//   v : Array[T],
//   write_fn : (Writer, T) -> Unit,
//   size_fn : (T) -> UInt
// ) -> Unit {
//   if v.is_empty() {
//     return
//   }
//   let mut total_len = 0U
//   v.each(fn(x) { total_len += size_fn(x) })
//   self.write_tag(tag)
//   self.write_varint(total_len.to_uint64())
//   for i in v {
//     write_fn(self, i)
//   }
// }
