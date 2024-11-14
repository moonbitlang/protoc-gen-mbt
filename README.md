# MoonBit protobuf generator

This is the protobuf compiler for MoonBit, consisting of the compiler plugin written in Go and the runtime library.

The compiler and the runtime library are not published yet. To use this protobuf generator:

1. Clone this [repository](https://github.com/moonbit-community/protoc-gen-mbt)
2. Build the compiler plugin with `go build .`
3. Generate the MoonBit output with `PATH=".:$PATH" protoc --mbt_out=. --mbt_opt=paths=source_relative input.proto`: the plugin should be on the path, and it will generate a `input_pb.mbt` next to the `input.proto`.
4. Use the generated MoonBit file given that it imports the runtime library with the alias `lib`.

This will be simplified in the future development.

## Known Issues

- Deprecated group is not supported
- Package is not supported
- Extensions and custom options are ignored
- Self referencing field is not supported

## Supported

See [spec](doc/spec.md)

## Developing

```sh
go build . && PATH=".:$PATH" protoc --mbt_out=. --mbt_opt=paths=source_relative src/test/input.proto
```

It will generated `input_pb.mbt` file in the same directory as the input file.

### Structure

- `src/lib`
    - `proto.mbt` `types.mbt`: General type definitions
    - `reader.mbt` `reader_impl.mbt`: `Reader` definition and implementations
    - `writer.mbt` `writer_impl.mbt`: `Writer` definition and implementations
    - `sizeof.mbt`: used when calculating size of the message

- `main.go`
    - The main entry point for the protoc plugin