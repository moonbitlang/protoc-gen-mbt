// Code generated from example/plugin.proto by protoc-gen-mbt. DO NOT EDIT.

struct Version {
  major : Int
  minor : Int
  patch : Int
  suffix : String
} derive(Show, Eq)

struct CodeGeneratorRequest {
  file_to_generate : Array[String]
  parameter : String
  proto_file : Array[FileDescriptorProto]
  source_file_descriptors : Array[FileDescriptorProto]
  compiler_version : Version
} derive(Show, Eq)

enum CodeGeneratorResponse_Feature {
  CodeGeneratorResponse_FEATURE_NONE
  CodeGeneratorResponse_FEATURE_PROTO3_OPTIONAL
  CodeGeneratorResponse_FEATURE_SUPPORTS_EDITIONS
} derive(Show, Eq)

struct CodeGeneratorResponse_File {
  name : String
  insertion_point : String
  content : String
  generated_code_info : GeneratedCodeInfo
} derive(Show, Eq)

struct CodeGeneratorResponse {
  error : String
  supported_features : UInt64
  minimum_edition : Int
  maximum_edition : Int
  file : Array[CodeGeneratorResponse_File]
} derive(Show, Eq)

// Code generated from example/descriptor.proto by protoc-gen-mbt. DO NOT EDIT.

enum Edition {
  Edition_EDITION_UNKNOWN
  Edition_EDITION_LEGACY
  Edition_EDITION_PROTO2
  Edition_EDITION_PROTO3
  Edition_EDITION_2023
  Edition_EDITION_2024
  Edition_EDITION_1_TEST_ONLY
  Edition_EDITION_2_TEST_ONLY
  Edition_EDITION_99997_TEST_ONLY
  Edition_EDITION_99998_TEST_ONLY
  Edition_EDITION_99999_TEST_ONLY
  Edition_EDITION_MAX
} derive(Show, Eq)

struct FileDescriptorSet {
  file : Array[FileDescriptorProto]
} derive(Show, Eq)

struct FileDescriptorProto {
  name : String
  package : String
  dependency : Array[String]
  public_dependency : Array[Int]
  weak_dependency : Array[Int]
  message_type : Array[DescriptorProto]
  enum_type : Array[EnumDescriptorProto]
  service : Array[ServiceDescriptorProto]
  extension : Array[FieldDescriptorProto]
  options : FileOptions
  source_code_info : SourceCodeInfo
  syntax : String
  edition : Edition
} derive(Show, Eq)

struct DescriptorProto_ExtensionRange {
  start : Int
  end : Int
  options : ExtensionRangeOptions
} derive(Show, Eq)

struct DescriptorProto_ReservedRange {
  start : Int
  end : Int
} derive(Show, Eq)

struct DescriptorProto {
  name : String
  field : Array[FieldDescriptorProto]
  extension : Array[FieldDescriptorProto]
  nested_type : Array[DescriptorProto]
  enum_type : Array[EnumDescriptorProto]
  extension_range : Array[DescriptorProto_ExtensionRange]
  oneof_decl : Array[OneofDescriptorProto]
  options : MessageOptions
  reserved_range : Array[DescriptorProto_ReservedRange]
  reserved_name : Array[String]
} derive(Show, Eq)

enum ExtensionRangeOptions_VerificationState {
  ExtensionRangeOptions_DECLARATION
  ExtensionRangeOptions_UNVERIFIED
} derive(Show, Eq)

struct ExtensionRangeOptions_Declaration {
  number : Int
  full_name : String
  decl_type : String
  reserved : Bool
  repeated : Bool
} derive(Show, Eq)

struct ExtensionRangeOptions {
  uninterpreted_option : Array[UninterpretedOption]
  declaration : Array[ExtensionRangeOptions_Declaration]
  features : FeatureSet
  verification : ExtensionRangeOptions_VerificationState
} derive(Show, Eq)

pub enum FieldDescriptorProto_Type {
  FieldDescriptorProto_TYPE_DOUBLE
  FieldDescriptorProto_TYPE_FLOAT
  FieldDescriptorProto_TYPE_INT64
  FieldDescriptorProto_TYPE_UINT64
  FieldDescriptorProto_TYPE_INT32
  FieldDescriptorProto_TYPE_FIXED64
  FieldDescriptorProto_TYPE_FIXED32
  FieldDescriptorProto_TYPE_BOOL
  FieldDescriptorProto_TYPE_STRING
  FieldDescriptorProto_TYPE_GROUP
  FieldDescriptorProto_TYPE_MESSAGE
  FieldDescriptorProto_TYPE_BYTES
  FieldDescriptorProto_TYPE_UINT32
  FieldDescriptorProto_TYPE_ENUM
  FieldDescriptorProto_TYPE_SFIXED32
  FieldDescriptorProto_TYPE_SFIXED64
  FieldDescriptorProto_TYPE_SINT32
  FieldDescriptorProto_TYPE_SINT64
} derive(Show, Eq)

enum FieldDescriptorProto_Label {
  FieldDescriptorProto_LABEL_OPTIONAL
  FieldDescriptorProto_LABEL_REPEATED
  FieldDescriptorProto_LABEL_REQUIRED
} derive(Show, Eq)

struct FieldDescriptorProto {
  name : String
  number : Int
  label : FieldDescriptorProto_Label
  proto_type : FieldDescriptorProto_Type
  type_name : String
  extendee : String
  default_value : String
  oneof_index : Int
  json_name : String
  options : FieldOptions
  proto3optional : Bool
} derive(Show, Eq)

struct OneofDescriptorProto {
  name : String
  options : OneofOptions
} derive(Show, Eq)

struct EnumDescriptorProto_EnumReservedRange {
  start : Int
  end : Int
} derive(Show, Eq)

struct EnumDescriptorProto {
  name : String
  value : Array[EnumValueDescriptorProto]
  options : EnumOptions
  reserved_range : Array[EnumDescriptorProto_EnumReservedRange]
  reserved_name : Array[String]
} derive(Show, Eq)

struct EnumValueDescriptorProto {
  name : String
  number : Int
  options : EnumValueOptions
} derive(Show, Eq)

struct ServiceDescriptorProto {
  name : String
  method : Array[MethodDescriptorProto]
  options : ServiceOptions
} derive(Show, Eq)

struct MethodDescriptorProto {
  name : String
  input_type : String
  output_type : String
  options : MethodOptions
  client_streaming : Bool
  server_streaming : Bool
} derive(Show, Eq)

enum FileOptions_OptimizeMode {
  FileOptions_SPEED
  FileOptions_CODE_SIZE
  FileOptions_LITE_RUNTIME
} derive(Show, Eq)

struct FileOptions {
  java_package : String
  java_outer_classname : String
  java_multiple_files : Bool
  java_generate_equals_and_hash : Bool
  java_string_check_utf8 : Bool
  optimize_for : FileOptions_OptimizeMode
  go_package : String
  cc_generic_services : Bool
  java_generic_services : Bool
  py_generic_services : Bool
  deprecated : Bool
  cc_enable_arenas : Bool
  objc_class_prefix : String
  csharp_namespace : String
  swift_prefix : String
  php_class_prefix : String
  php_namespace : String
  php_metadata_namespace : String
  ruby_package : String
  features : FeatureSet
  uninterpreted_option : Array[UninterpretedOption]
} derive(Show, Eq)

struct MessageOptions {
  message_set_wire_format : Bool
  no_standard_descriptor_accessor : Bool
  deprecated : Bool
  map_entry : Bool
  deprecated_legacy_json_field_conflicts : Bool
  features : FeatureSet
  uninterpreted_option : Array[UninterpretedOption]
} derive(Show, Eq)

enum FieldOptions_CType {
  FieldOptions_STRING
  FieldOptions_CORD
  FieldOptions_STRING_PIECE
} derive(Show, Eq)

enum FieldOptions_JSType {
  FieldOptions_JS_NORMAL
  FieldOptions_JS_STRING
  FieldOptions_JS_NUMBER
} derive(Show, Eq)

enum FieldOptions_OptionRetention {
  FieldOptions_RETENTION_UNKNOWN
  FieldOptions_RETENTION_RUNTIME
  FieldOptions_RETENTION_SOURCE
} derive(Show, Eq)

enum FieldOptions_OptionTargetType {
  FieldOptions_TARGET_TYPE_UNKNOWN
  FieldOptions_TARGET_TYPE_FILE
  FieldOptions_TARGET_TYPE_EXTENSION_RANGE
  FieldOptions_TARGET_TYPE_MESSAGE
  FieldOptions_TARGET_TYPE_FIELD
  FieldOptions_TARGET_TYPE_ONEOF
  FieldOptions_TARGET_TYPE_ENUM
  FieldOptions_TARGET_TYPE_ENUM_ENTRY
  FieldOptions_TARGET_TYPE_SERVICE
  FieldOptions_TARGET_TYPE_METHOD
} derive(Show, Eq)

struct FieldOptions_EditionDefault {
  edition : Edition
  value : String
} derive(Show, Eq)

struct FieldOptions_FeatureSupport {
  edition_introduced : Edition
  edition_deprecated : Edition
  deprecation_warning : String
  edition_removed : Edition
} derive(Show, Eq)

struct FieldOptions {
  ctype : FieldOptions_CType
  packed : Bool
  jstype : FieldOptions_JSType
  lazy : Bool
  unverified_lazy : Bool
  deprecated : Bool
  weak : Bool
  debug_redact : Bool
  retention : FieldOptions_OptionRetention
  targets : Array[FieldOptions_OptionTargetType]
  edition_defaults : Array[FieldOptions_EditionDefault]
  features : FeatureSet
  feature_support : FieldOptions_FeatureSupport
  uninterpreted_option : Array[UninterpretedOption]
} derive(Show, Eq)

struct OneofOptions {
  features : FeatureSet
  uninterpreted_option : Array[UninterpretedOption]
} derive(Show, Eq)

struct EnumOptions {
  allow_alias : Bool
  deprecated : Bool
  deprecated_legacy_json_field_conflicts : Bool
  features : FeatureSet
  uninterpreted_option : Array[UninterpretedOption]
} derive(Show, Eq)

struct EnumValueOptions {
  deprecated : Bool
  features : FeatureSet
  debug_redact : Bool
  feature_support : FieldOptions_FeatureSupport
  uninterpreted_option : Array[UninterpretedOption]
} derive(Show, Eq)

struct ServiceOptions {
  features : FeatureSet
  deprecated : Bool
  uninterpreted_option : Array[UninterpretedOption]
} derive(Show, Eq)

enum MethodOptions_IdempotencyLevel {
  MethodOptions_IDEMPOTENCY_UNKNOWN
  MethodOptions_NO_SIDE_EFFECTS
  MethodOptions_IDEMPOTENT
} derive(Show, Eq)

struct MethodOptions {
  deprecated : Bool
  idempotency_level : MethodOptions_IdempotencyLevel
  features : FeatureSet
  uninterpreted_option : Array[UninterpretedOption]
} derive(Show, Eq)

struct UninterpretedOption_NamePart {
  name_part : String
  is_extension : Bool
} derive(Show, Eq)

struct UninterpretedOption {
  name : Array[UninterpretedOption_NamePart]
  identifier_value : String
  positive_int_value : UInt64
  negative_int_value : Int64
  double_value : Double
  string_value : Bytes
  aggregate_value : String
} derive(Show, Eq)

enum FeatureSet_FieldPresence {
  FeatureSet_FIELD_PRESENCE_UNKNOWN
  FeatureSet_EXPLICIT
  FeatureSet_IMPLICIT
  FeatureSet_LEGACY_REQUIRED
} derive(Show, Eq)

enum FeatureSet_EnumType {
  FeatureSet_ENUM_TYPE_UNKNOWN
  FeatureSet_OPEN
  FeatureSet_CLOSED
} derive(Show, Eq)

enum FeatureSet_RepeatedFieldEncoding {
  FeatureSet_REPEATED_FIELD_ENCODING_UNKNOWN
  FeatureSet_PACKED
  FeatureSet_EXPANDED
} derive(Show, Eq)

enum FeatureSet_Utf8Validation {
  FeatureSet_UTF8_VALIDATION_UNKNOWN
  FeatureSet_VERIFY
  FeatureSet_NONE
} derive(Show, Eq)

enum FeatureSet_MessageEncoding {
  FeatureSet_MESSAGE_ENCODING_UNKNOWN
  FeatureSet_LENGTH_PREFIXED
  FeatureSet_DELIMITED
} derive(Show, Eq)

enum FeatureSet_JsonFormat {
  FeatureSet_JSON_FORMAT_UNKNOWN
  FeatureSet_ALLOW
  FeatureSet_LEGACY_BEST_EFFORT
} derive(Show, Eq)

struct FeatureSet {
  field_presence : FeatureSet_FieldPresence
  enum_type : FeatureSet_EnumType
  repeated_field_encoding : FeatureSet_RepeatedFieldEncoding
  utf8validation : FeatureSet_Utf8Validation
  message_encoding : FeatureSet_MessageEncoding
  json_format : FeatureSet_JsonFormat
} derive(Show, Eq)

struct FeatureSetDefaults_FeatureSetEditionDefault {
  edition : Edition
  overridable_features : FeatureSet
  fixed_features : FeatureSet
} derive(Show, Eq)

struct FeatureSetDefaults {
  defaults : Array[FeatureSetDefaults_FeatureSetEditionDefault]
  minimum_edition : Edition
  maximum_edition : Edition
} derive(Show, Eq)

struct SourceCodeInfo_Location {
  path : Array[Int]
  span : Array[Int]
  leading_comments : String
  trailing_comments : String
  leading_detached_comments : Array[String]
} derive(Show, Eq)

struct SourceCodeInfo {
  location : Array[SourceCodeInfo_Location]
} derive(Show, Eq)

enum GeneratedCodeInfo_Annotation_Semantic {
  GeneratedCodeInfo_Annotation_NONE
  GeneratedCodeInfo_Annotation_SET
  GeneratedCodeInfo_Annotation_ALIAS
} derive(Show, Eq)

struct GeneratedCodeInfo_Annotation {
  path : Array[Int]
  source_file : String
  begin : Int
  end : Int
  semantic : GeneratedCodeInfo_Annotation_Semantic
} derive(Show, Eq)

struct GeneratedCodeInfo {
  annotation : Array[GeneratedCodeInfo_Annotation]
} derive(Show, Eq)
