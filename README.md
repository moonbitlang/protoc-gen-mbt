# MoonBit protobuf generator

## Known Issues

- Deprecated group is not supported
- Optional is supported but not enabled (to be investigated)
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