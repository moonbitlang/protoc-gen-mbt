pub(open) trait Read {
  read(Reader) -> Self!ReaderError
}

pub(open) trait Write {
  write(Self, Writer) -> Unit
}

pub(open) trait Proto: Read + Write {}
