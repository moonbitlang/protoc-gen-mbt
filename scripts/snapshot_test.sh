#!/bin/bash

set -e

# Command line argument handling
UPDATE_SNAPSHOTS=false
HELP=false

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
    echo "  --update-snapshots, -u    Update __snapshot directories with generated code"
    echo "  --help, -h               Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0                       Run snapshot test (compare only)"
    echo "  $0 --update-snapshots    Run test and update snapshots if different"
    echo ""
    exit 0
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"


verify_tool() {
    local tool="$1"
    local version_flag="${2:---version}"
    
    if ! command -v "$tool" &> /dev/null; then
        echo "❌ $tool is not installed or not in PATH"
        return 1
    fi
    return 0
}

get_exe_extension() {
    if [ "$(detect_os)" = "windows" ]; then
        echo ".exe"
    else
        echo ""
    fi
}

get_path_separator() {
    if [ "$(detect_os)" = "windows" ]; then
        echo ";"
    else
        echo ":"
    fi
}

detect_os() {
    case "$(uname -s)" in
        Linux*)     echo "linux";;
        Darwin*)    echo "macos";;
        CYGWIN*|MINGW*|MSYS*) echo "windows";;
        *)          echo "unknown";;
    esac
}

echo "   Working directory: $(pwd)"
echo "   Script directory: ${SCRIPT_DIR}"
echo "   Project root: ${PROJECT_ROOT}"
echo "   OS: $(detect_os)"

verify_tool "protoc" --version || exit 1
verify_tool "moon" version || exit 1  
verify_tool "go" version || exit 1


# compiler proto-gen-mbt plugin
EXE_EXT="$(get_exe_extension)"
PLUGIN_NAME="protoc-gen-mbt${EXE_EXT}"
cd "${PROJECT_ROOT}/cli" && moon build --target native
# move to the project root
if [ -f "./target/native/release/build/protoc-gen-mbt.exe" ]; then
    mv "./target/native/release/build/protoc-gen-mbt.exe" "${PROJECT_ROOT}/${PLUGIN_NAME}"
elif [ -f "./target/native/release/build/protoc-gen-mbt" ]; then
    mv "./target/native/release/build/protoc-gen-mbt" "${PROJECT_ROOT}/${PLUGIN_NAME}"
else
    echo "❌ Plugin binary not found after build"
    exit 1
fi
export PATH="${PROJECT_ROOT}$(get_path_separator)${PATH}"
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
    gen_dir="${proto_dir}/__gen"
    mkdir -p "${gen_dir}"
    
    proto_files_in_dir=$(find "${proto_dir}" -maxdepth 1 -name "*.proto" -type f -exec basename {} \;)
    
    if [ -n "${proto_files_in_dir}" ]; then
        protoc \
            --proto_path="${proto_dir}" \
            --mbt_out="${gen_dir}" \
            --mbt_opt=paths=source_relative,project_name=snapshot \
            ${proto_files_in_dir}
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
            if diff -r "${gen_dir}" "${snapshot_dir}" > /dev/null 2>&1; then
                continue
            else
                echo "⚠️ Differences detected in: $(basename ${proto_dir})"
                diff -r "${gen_dir}" "${snapshot_dir}" || true
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



