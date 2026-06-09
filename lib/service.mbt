///|
/// Describes one RPC method declared inside a protobuf service.
pub(all) struct MethodDescriptor {
  ///
  /// Method name as declared in the `.proto` file.
  name : String
  ///
  /// Fully qualified protobuf method name, without a leading dot.
  full_name : String
  ///
  /// Canonical RPC path, such as `/package.Service/Method`.
  path : String
  ///
  /// Fully qualified protobuf input message type name, without a leading dot.
  input_type_name : String
  ///
  /// Fully qualified protobuf output message type name, without a leading dot.
  output_type_name : String
  ///
  /// Whether the method accepts a stream of input messages.
  client_streaming : Bool
  ///
  /// Whether the method returns a stream of output messages.
  server_streaming : Bool
} derive(Eq, Debug)

///|
/// Describes one protobuf service and its RPC methods.
pub(all) struct ServiceDescriptor {
  ///
  /// Service name as declared in the `.proto` file.
  name : String
  ///
  /// Fully qualified protobuf service name, without a leading dot.
  full_name : String
  ///
  /// Methods declared by this service.
  methods : Array[MethodDescriptor]
} derive(Eq, Debug)
