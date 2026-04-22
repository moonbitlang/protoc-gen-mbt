///|
pub(all) struct MethodDescriptor {
  name : String
  full_name : String
  client_streaming : Bool
  server_streaming : Bool
} derive(Eq, Show)

///|
pub(all) struct ServiceDescriptor {
  name : String
  full_name : String
  methods : Array[MethodDescriptor]
} derive(Eq, Show)
