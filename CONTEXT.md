# Context

## Domain Terms

- **Generator**: the MoonBit protoc plugin that turns protobuf descriptors into MoonBit packages.
- **Runtime**: the MoonBit protobuf library used by generated code for read, write, size, and JSON behavior.
- **Standard protobuf package**: Runtime-owned generated MoonBit packages for Google protobuf descriptor, compiler, and well-known types under `google/protobuf`.
- **Feature resolver**: Generator logic that turns protobuf Editions feature options, inheritance, and syntax defaults into semantic questions used by templates.
- **Field shape semantics**: Generator-side decisions that turn protobuf field descriptors and Feature resolver answers into generated MoonBit shape decisions, such as presence, packing, maps, defaults, names, and per-field read/write/size/JSON categories.
- **Field storage shape**: The first Field shape semantics slice that resolves a generated field's MoonBit storage declaration: field name, base MoonBit type, optional/list/map wrapping, and default expression when it follows directly from storage.
- **Field codec shape**: The Field shape semantics slice that resolves generated binary read/write/size categories for normal fields, including singular, optional, repeated, packed repeated, map field handling, and packed/unpacked read compatibility.
- **Field JSON shape**: The Field shape semantics slice that resolves generated JSON categories for normal fields, including JSON names, default comparison expressions, optional/list/map handling, and scalar JSON adapters.
- **Oneof shape**: Generator-side decisions that turn protobuf oneof descriptors into generated enum names, message storage fields, enum variants, field numbers, value types, and oneof read/write/size/JSON cases.
- **Message shape**: Generator-side decisions that collect a message's generated MoonBit name, normal Field shape slices, Oneof shapes, and Runtime-owned JSON implementation status for template emission.
- **Message framing**: Runtime-owned handling of protobuf message frame mechanics, including length-delimited message writes, message-field tag reads, normal `EndOfStream` completion, and unknown-field skipping.
- **Field envelope**: Runtime-owned size and write framing around a field payload, including the encoded tag size, optional length prefix size, and payload size.
- **Generated file plan**: Generator-side plan that decides which output files to produce, in what order, with which response paths, before templates render file contents.
- **Package manifest plan**: Generated file plan slice that decides `moon.pkg` imports, including Runtime imports, JSON/derive support imports, dependency package paths, and stable import aliases before manifest rendering.
- **Generated-code harness**: a test workflow that builds the Generator, generates MoonBit code from focused proto fixtures, and verifies the generated code through its public Runtime interfaces.
- **Harness case**: a self-contained Generated-code harness input with proto fixtures, a runner test, and `case.toml` metadata.
