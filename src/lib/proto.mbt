pub trait Read {
  read(Reader) -> Self!ReaderError
}

pub trait Write {
  write(Self, Writer) -> Unit
}

pub trait Proto: Read + Write {}
