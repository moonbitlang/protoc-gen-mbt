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
UPDATE_SNAPSHOTS=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --update-snapshots|-u)
            UPDATE_SNAPSHOTS=true
            shift
            ;;
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
    echo "  --update-snapshots, -u       Update __snapshot directories with generated code"
    echo "  --include-path, -I <path>    Additional proto include path for protoc"
    echo "  --help, -h                   Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0                                    Run snapshot test (compare only)"
    echo "  $0 --update-snapshots                Run test and update snapshots if different"
    echo "  $0 --include-path /usr/include       Use custom include path for protobuf"
    echo "  $0 -I /opt/protobuf/include -u       Combine include path with update"
    echo ""
    exit 0
fi

echo "   Working directory: $(pwd)"
echo "   Script directory: ${SCRIPT_DIR}"
echo "   Project root: ${PROJECT_ROOT}"
echo "   OS: $(detect_os)"

# Verify required tools
verify_tool "protoc" --version || exit 1
verify_tool "moon" version || exit 1  
verify_tool "go" version || exit 1

# Build protoc-gen-mbt plugin
build_plugin "${PROJECT_ROOT}"
# find the test proto files
TEST_PROTO_DIR="${PROJECT_ROOT}/test/snapshots"

cd "${PROJECT_ROOT}"

# find all directories containing .proto files
PROTO_DIRS=$(find "${TEST_PROTO_DIR}" -name "*.proto" -type f -exec dirname {} \; | sort -u)
if [ -z "${PROTO_DIRS}" ]; then
    echo "❌ No .proto files found in ${TEST_PROTO_DIR}"
    exit 1
fi

# Generate code for each proto directory
for proto_dir in ${PROTO_DIRS}; do
    gen_dir="${proto_dir}"
    mkdir -p "${gen_dir}"
    
    proto_files_in_dir=$(find "${proto_dir}" -maxdepth 1 -name "*.proto" -type f -exec basename {} \;)
    
    if [ -n "${proto_files_in_dir}" ]; then
        # Build and execute protoc command
        PROTOC_CMD=$(build_protoc_command "${proto_dir}" "${gen_dir}" "__gen" "${proto_files_in_dir}" "${PROTO_INCLUDE_PATH}")
        eval ${PROTOC_CMD}
    else
        echo "❌ No proto files found in ${proto_dir}"
        exit 1
    fi
done

echo "✅ Code generation completed"

# Compare __gen and __snapshot directories
has_changes=false

for proto_dir in ${PROTO_DIRS}; do
    gen_dir="${proto_dir}/__gen"
    snapshot_dir="${proto_dir}/__snapshot"
    
    if [ -d "${gen_dir}" ] && [ "$(ls -A ${gen_dir} 2>/dev/null)" ]; then
        if [ -d "${snapshot_dir}" ] && [ "$(ls -A ${snapshot_dir} 2>/dev/null)" ]; then
            # Use diff with options to ignore whitespace and line ending differences
            if diff -r --strip-trailing-cr "${gen_dir}" "${snapshot_dir}" > /dev/null 2>&1; then
                continue
            else
                echo "⚠️ Differences detected in: $(basename ${proto_dir})"
                diff -r --strip-trailing-cr "${gen_dir}" "${snapshot_dir}" || true
                echo ""
                
                if [ "$UPDATE_SNAPSHOTS" = true ]; then
                    rm -rf "${snapshot_dir}"
                    mkdir -p "${snapshot_dir}"
                    cp -r "${gen_dir}/"* "${snapshot_dir}/"
                    echo "✅ Snapshot updated: $(basename ${proto_dir})"
                else
                    has_changes=true
                fi
            fi
        else
            if [ "$UPDATE_SNAPSHOTS" = true ]; then
                mkdir -p "${snapshot_dir}"
                cp -r "${gen_dir}/"* "${snapshot_dir}/"
                echo "✅ Snapshot created: $(basename ${proto_dir})"
            else
                echo "📝 New snapshot needed for: $(basename ${proto_dir})"
                has_changes=true
            fi
        fi
    else
        echo "❌ No generated files found in: $(basename ${proto_dir})"
        exit 1
    fi
done

# Final check for changes
if [ "$has_changes" = true ]; then
    echo "❌ Snapshot test failed - differences detected"
    echo "💡 To update snapshots, run: ./scripts/snapshot_test.sh --update-snapshots"
    exit 1
elif [ "$UPDATE_SNAPSHOTS" = true ]; then
    echo "✅ All snapshots updated successfully"
else
    echo "✅ All snapshots match"
fi

cd "${PROJECT_ROOT}"



