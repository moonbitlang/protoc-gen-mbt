# Context

## Domain Terms

- **Generator**: the MoonBit protoc plugin that turns protobuf descriptors into MoonBit packages.
- **Runtime**: the MoonBit protobuf library used by generated code for read, write, size, and JSON behavior.
- **Generated-code harness**: a test workflow that builds the Generator, generates MoonBit code from focused proto fixtures, and verifies the generated code through its public Runtime interfaces.
- **Harness case**: a self-contained Generated-code harness input with proto fixtures, a runner test, and `case.toml` metadata.
