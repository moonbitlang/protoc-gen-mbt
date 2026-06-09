///|
const WIRE_TYPE_VARINT = 0

///|
const WIRE_TYPE_FIXED64 = 1

///|
const WIRE_TYPE_LENGTH_DELIMITED = 2

///|
const WIRE_TYPE_START_GROUP = 3

///|
const WIRE_TYPE_END_GROUP = 4

///|
const WIRE_TYPE_FIXED32 = 5

///|
fn runtime_wire_type_const(wire_type : Int) -> String raise {
  match wire_type {
    WIRE_TYPE_VARINT => "@lib.WIRE_TYPE_VARINT"
    WIRE_TYPE_FIXED64 => "@lib.WIRE_TYPE_FIXED64"
    WIRE_TYPE_LENGTH_DELIMITED => "@lib.WIRE_TYPE_LENGTH_DELIMITED"
    WIRE_TYPE_START_GROUP => "@lib.WIRE_TYPE_START_GROUP"
    WIRE_TYPE_END_GROUP => "@lib.WIRE_TYPE_END_GROUP"
    WIRE_TYPE_FIXED32 => "@lib.WIRE_TYPE_FIXED32"
    _ => raise @model.UnexpectedType("unknown wire type \{wire_type}")
  }
}
