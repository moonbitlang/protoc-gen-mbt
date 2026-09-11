# MoonBit protobuf generator

`protoc-gen-mbt` is a Protocol Buffers compiler plugin that generates MoonBit
messages, binary codecs, and optional JSON and asynchronous I/O support.

## Install

Install the [MoonBit toolchain](https://www.moonbitlang.com/download/) and
[protoc](https://github.com/protocolbuffers/protobuf/releases/tag/v33.0), then run:

```sh
moon install moonbitlang/protoc-gen-mbt@0.2.0
```

Ensure the directory containing the installed `protoc-gen-mbt` executable is on
your `PATH`. The project's CI uses protoc 33.0.

## Generate code

```sh
protoc --mbt_out=. --mbt_opt=project_name=generated example.proto
```

`project_name` names the generated module directory under `--mbt_out`. Generated
modules depend on `moonbitlang/protobuf@0.1.3`.

See the [project documentation](https://github.com/moonbitlang/protoc-gen-mbt#arguments)
for generator options and the
[supported features](https://github.com/moonbitlang/protoc-gen-mbt/blob/main/doc/spec.md).
