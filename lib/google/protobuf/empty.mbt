///|
pub(all) struct Empty {} derive(Eq, Debug)

///|
pub impl @lib.Sized for Empty with fn size_of(_) {
  0
}

///|
pub impl Default for Empty with fn default() -> Empty {
  Empty::{  }
}

///|
pub fn Empty::new() -> Empty {
  Empty::{  }
}

///|
pub impl @lib.Read for Empty with fn read_with_limit(_) -> Empty noraise {
  Empty::default()
}

///|
pub impl @lib.Write for Empty with fn write(_, _) -> Unit noraise {

}

///|
pub impl ToJson for Empty with fn to_json(_) {
  {}
}

///|
pub impl @json.FromJson for Empty with fn from_json(_, _) -> Empty noraise {
  Empty::default()
}

///|
pub impl @lib.AsyncRead for Empty with fn read_with_limit(_) -> Empty noraise {
  Empty::default()
}

///|
pub impl @lib.AsyncWrite for Empty with fn write(_, _) -> Unit noraise {

}
