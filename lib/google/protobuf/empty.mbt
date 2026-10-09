///|
pub(all) struct Empty {} derive(Eq, Debug)

///|
pub impl @lib.Sized for Empty with fn size_of(_) {
  0
}

///|
pub impl Default for Empty with fn default() -> Empty {
  Empty::{ }
}

///|
#alias(new, deprecated)
pub fn Empty::Empty() -> Empty {
  Empty::{ }
}

///|
pub impl @lib.Read for Empty with fn read_with_limit(_) -> Empty noraise {
  Default::default()
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
  Default::default()
}

///|
pub impl @lib.AsyncRead for Empty with fn read_with_limit(_) -> Empty noraise {
  Default::default()
}

///|
pub impl @lib.AsyncWrite for Empty with fn write(_, _) -> Unit noraise {

}

///|
pub extend Empty with Eq::{equal}

///|
#deprecated("Use `!=` instead")
pub extend Empty with Eq::{not_equal}

///|
pub extend Empty with Debug::{to_repr}

///|
pub extend Empty with Default::{default}

///|
pub extend Empty with @lib.Sized::{size_of}

///|
pub extend Empty with @lib.Read::{read, read_with_limit}

///|
pub extend Empty with @lib.Write::{write}

///|
pub extend Empty with ToJson::{to_json}

///|
pub extend Empty with @json.FromJson::{from_json}
