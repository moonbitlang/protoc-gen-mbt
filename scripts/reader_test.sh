#!/bin/bash

set -e

# Load common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"

# Initialize common variables
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
EXE_EXT="$(get_exe_extension)"
PLUGIN_NAME="protoc-gen-mbt${EXE_EXT}"

# Initialize script-specific variables
HELP=false
PROTO_INCLUDE_PATH=""

# Command line argument handling
while [[ $# -gt 0 ]]; do
    case $1 in
        --help|-h)
            HELP=true
            shift
            ;;
        --include-path|-I)
            PROTO_INCLUDE_PATH="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            HELP=true
            shift
            ;;
    esac
done

# Help message
if [ "$HELP" = true ]; then
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --include-path, -I <path>    Additional proto include path for protoc"
    echo "  --help, -h                   Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0                           Run reader test"
    echo "  $0 --include-path /usr/include       Use custom include path for protobuf"
    echo ""
    exit 0
fi

# Verify required tools
verify_tool "protoc" --version || exit 1
verify_tool "moon" version || exit 1  
verify_tool "go" version || exit 1

# Build protoc-gen-mbt plugin
build_plugin "${PROJECT_ROOT}"

cd "${PROJECT_ROOT}"

# Step 1: Generate code from test/reader/input.proto
READER_DIR="${PROJECT_ROOT}/test/reader"

# Build and execute protoc command
PROTOC_CMD=$(build_protoc_command "${READER_DIR}" "${READER_DIR}" "gen" "input.proto" "${PROTO_INCLUDE_PATH}")
eval ${PROTOC_CMD}

# Fix deps path in gen/moon.mod.json
GEN_MOD_JSON="${READER_DIR}/gen/moon.mod.json"
if [ -f "${GEN_MOD_JSON}" ]; then
    if command -v jq &> /dev/null; then
        jq '.deps = {"moonbit-community/protobuf/lib": {"path": "../../../lib"}}' "${GEN_MOD_JSON}" > "${GEN_MOD_JSON}.tmp" && mv "${GEN_MOD_JSON}.tmp" "${GEN_MOD_JSON}"
    else
        cat > "${GEN_MOD_JSON}" << 'EOF'
{
 "name": "username/gen",
 "version": "0.1.0",
 "readme": "",
 "repository": "",
 "license": "",
 "keywords": [],
 "description": "",
 "source": "src",
 "deps": {
   "moonbit-community/protobuf/lib": {
    "path": "../../../lib"
   }
 }
}
EOF
    fi
fi

BIN_DIR="${PROJECT_ROOT}/test/reader/bin"
cd "${PROJECT_ROOT}/test/go-gen/cli"
go run main.go -o "${BIN_DIR}"

# run the reader test
cd "${PROJECT_ROOT}/test/reader/runner"
moon test

rm -r "${PROJECT_ROOT}/test/reader/gen"
rm -r "${PROJECT_ROOT}/test/reader/bin"

