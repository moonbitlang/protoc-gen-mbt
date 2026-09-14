# MoonBit protobuf generator

This is the protobuf compiler for MoonBit, consisting of the compiler plugin written in MoonBit and the runtime library.

## Install and use

Install the [MoonBit toolchain](https://www.moonbitlang.com/download/) and
[protoc](https://github.com/protocolbuffers/protobuf/releases/tag/v33.0). Use `moonx`
to run the published generator on demand. Since `protoc` launches an executable
plugin, create a wrapper for your shell.

### macOS / Linux (POSIX shell)

```sh
cat > protoc-gen-mbt.sh <<'EOF'
#!/bin/sh
exec moonx moonbitlang/protoc-gen-mbt@0.2.0 "$@"
EOF
chmod +x protoc-gen-mbt.sh
```

Then generate code:

```sh
protoc --plugin=protoc-gen-mbt=./protoc-gen-mbt.sh \
  --mbt_out=. --mbt_opt=project_name=generated example.proto
```

### Windows (PowerShell)

Create a command wrapper in the current directory, then generate code:

```powershell
@'
@echo off
moonx moonbitlang/protoc-gen-mbt@0.2.0 %*
'@ | Set-Content -Path .\protoc-gen-mbt.cmd -Encoding ascii

protoc --mbt_out=. --mbt_opt=project_name=generated example.proto
```

Run `protoc` from the same directory so it can find `protoc-gen-mbt.cmd`.
Omit `--plugin` for this Windows wrapper.

`project_name` names the generated module directory under `--mbt_out`.
Generated modules depend on `moonbitlang/protobuf@0.1.3`.
The project's CI uses protoc 33.0. See [Developing](#developing) to build the
plugin from source.

## Known Issues

- Deprecated group is not supported
- Extensions and custom options are ignored

## Supported

See [spec](doc/spec.md)

## Developing

```sh
moon -C cli build --release
mkdir gen-proto3
cp cli/_build/native/release/build/protoc-gen-mbt.exe .
# Project name selects the generated module directory under --mbt_out
protoc --plugin=protoc-gen-mbt=protoc-gen-mbt.exe --mbt_out=. --mbt_opt=paths=source_relative,project_name=gen-proto3 test/reader/proto3.proto
```

The generated MoonBit file (e.g., `proto3_pb.mbt`) will be placed in the specified output directory (e.g., `gen-proto3`).

## Arguments

You can pass project parameters using `--mbt_opt`, separated by commas:

| Name          | Type    | Description                                   | Default Value         |
|---------------|---------|-----------------------------------------------|----------------------|
| json          | bool    | Generate additional `JSON` serialization code   | true            |
| derive        | string  | Comma-separated list of derive traits for generated types (`Show`, `Eq`, `Hash`, `Compare`, `Arbitrary`) | Show,Eq |
| async         | bool    | Generate async read/write code                 | true                 |
| username      | string  | Username to be used in `moon.mod.json`        | username    |
| project_name  | string  | Project name to be used in `moon.mod.json` & `moon.pkg.json`     | protoc-gen-mbt    |
| source_dir    | string  | Source directory inside the generated project; use `.` to write packages at the project root | src                  |

Example usage in a POSIX shell:

```sh
protoc --plugin=protoc-gen-mbt=./protoc-gen-mbt.sh --mbt_out=. --mbt_opt=json=true,derive=Show,Eq,Hash,username=yourname,project_name=yourproject input.proto
```

In PowerShell, use the `.cmd` wrapper configured above:

```powershell
protoc --mbt_out=. "--mbt_opt=json=true,derive=Show,Eq,Hash,username=yourname,project_name=yourproject" input.proto
```

## Project Structure

- **`cli/`** - Protocol Buffer compiler plugin that generates MoonBit code from `.proto` files
- **`lib/`** - MoonBit protobuf runtime library and generated standard protobuf packages
- **`plugin/`** - Protobuf compiler protocol source files used to regenerate standard protobuf packages
- **`test/`** - Integration and snapshot tests
- **`doc/`** - Project documentation (see [spec.md](doc/spec.md) for protobuf to MoonBit type mappings)
- **`scripts/`** - Development and testing scripts

## Development Scripts

Key scripts in the `scripts/` directory:

### workflow.py snapshot-test
Tests code generation by comparing output with snapshots:
```sh
# Run snapshot tests
python3 scripts/workflow.py snapshot-test

# Update snapshots after intentional changes
python3 scripts/workflow.py snapshot-test --update
```

### workflow.py reader-test
Tests protobuf reader functionality:
```sh
python3 scripts/workflow.py reader-test
```

### workflow.py generate-plugin
Regenerates plugin code from `plugin.proto`:
```sh
python3 scripts/workflow.py generate-plugin
```

`scripts/workflow.py` keeps the workflow in one file instead of spreading command helpers
across multiple scripts.
