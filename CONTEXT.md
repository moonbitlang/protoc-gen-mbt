# Context

## Domain Terms

- **Generator**: the MoonBit protoc plugin that turns protobuf descriptors into MoonBit packages.
- **Runtime**: the MoonBit protobuf library used by generated code for read, write, size, and JSON behavior.
- **Standard protobuf package**: Runtime-owned generated MoonBit packages for Google protobuf descriptor, compiler, and well-known types under `google/protobuf`.
- **Feature resolver**: Generator logic that turns protobuf Editions feature options, inheritance, and syntax defaults into semantic questions used by templates.
- **Generated-code harness**: a test workflow that builds the Generator, generates MoonBit code from focused proto fixtures, and verifies the generated code through its public Runtime interfaces.
- **Harness case**: a self-contained Generated-code harness input with proto fixtures, a runner test, and `case.toml` metadata.
