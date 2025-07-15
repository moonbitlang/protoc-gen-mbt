pub(all) struct Hello_MetadataEntry {
  mut key : String
  mut value : String
} derive(Eq, Show)
pub impl @lib.Sized for Hello_MetadataEntry with size_of(self) {
  let mut size = 0U
  size += 1U + { let size = @lib.size_of(self.key); @lib.size_of(size) + size }
  size += 1U + { let size = @lib.size_of(self.value); @lib.size_of(size) + size }
  size
}
pub impl Default for Hello_MetadataEntry with default() -> Hello_MetadataEntry {
  {
    key : String::default(),
    value : String::default(),
  }
}
pub impl @lib.Read for Hello_MetadataEntry with read(reader : &@lib.Reader) {
  let msg =   Hello_MetadataEntry::default()

  while not(reader |> @lib.is_eof()) {
    match (reader |> @lib.read_tag()) {
      (1, _) => msg.key = reader |> @lib.read_string()
      (2, _) => msg.value = reader |> @lib.read_string()
     (_, wire) => reader |> @lib.read_unknown(wire)
    }
  }
  msg
}
pub impl @lib.Write for Hello_MetadataEntry with write(self, writer) {
  writer |> @lib.write_varint(10UL);writer |> @lib.write_string(self.key)
  writer |> @lib.write_varint(18UL);writer |> @lib.write_string(self.value)
}
pub(all) struct Hello {
  mut name : String
  mut age : Int
  mut hobbies : Array[String]
  mut metadata : Map[String, String]
  mut friend : Hello?
} derive(Eq, Show)
pub impl @lib.Sized for Hello with size_of(self) {
  let mut size = 0U
  size += 1U + { let size = @lib.size_of(self.name); @lib.size_of(size) + size }
  size += 1U + @lib.size_of(self.age)
  size += self.hobbies.iter().map(@lib.size_of).map(s => 1U + @lib.size_of(s) + s).fold(init=0U, UInt::op_add)
  size += self.metadata.iter().map(fn(key_value) {
    let (k, v) = key_value
    let key_size = 1U + { let size = @lib.size_of(k); @lib.size_of(size) + size }
    let value_size = 1U + { let size = @lib.size_of(v); @lib.size_of(size) + size }
    1U + @lib.size_of(key_size + value_size) + key_size + value_size  }).fold(init=0U, UInt::op_add)
  match self.friend {
    Some(v) => size += 1U + { let size = @lib.size_of(v); @lib.size_of(size) + size }
    None => ()
  }
  size
}
pub impl Default for Hello with default() -> Hello {
  {
    name : String::default(),
    age : Int::default(),
    hobbies : [],
    metadata : {},
    friend : None,
  }
}
pub impl @lib.Read for Hello with read(reader : &@lib.Reader) {
  let msg =   Hello::default()

  while not(reader |> @lib.is_eof()) {
    match (reader |> @lib.read_tag()) {
      (1, _) => msg.name = reader |> @lib.read_string()
      (2, _) => msg.age = reader |> @lib.read_int32()
      (3, _) => msg.hobbies.push(reader |> @lib.read_string())
      (4, _) => { let {key, value} = ((reader |> @lib.read_message()) : Hello_MetadataEntry); msg.metadata[key] = value }
      (5, _) => msg.friend = ((reader |> @lib.read_message()) : Hello) |> Some
     (_, wire) => reader |> @lib.read_unknown(wire)
    }
  }
  msg
}
pub impl @lib.Write for Hello with write(self, writer) {
  writer |> @lib.write_varint(10UL);writer |> @lib.write_string(self.name)
  writer |> @lib.write_varint(16UL);writer |> @lib.write_int32(self.age)
  self.hobbies.iter().each(fn(v) {
    writer |> @lib.write_varint(26UL)
    writer |> @lib.write_string(v)
  })
  self.metadata.iter().each(fn(key_value) {
    let (k, v) = key_value
    writer |> @lib.write_varint(34UL)
    let key_size = 1U + { let size = @lib.size_of(k); @lib.size_of(size) + size }
    let value_size = 1U + { let size = @lib.size_of(v); @lib.size_of(size) + size }
    writer |> @lib.write_uint32(key_size + value_size)
    writer |> @lib.write_varint(10UL);
    writer |> @lib.write_string(k)
    writer |> @lib.write_varint(18UL);
    writer |> @lib.write_string(v)
  })
  match self.friend {
    Some(v) => {
      writer |> @lib.write_varint(42UL);writer |> @lib.write_uint32(@lib.size_of(v)); @lib.Write::write(v, writer)
    }
    None => ()
  }
}
