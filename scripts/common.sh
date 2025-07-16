#!/bin/bash

# Common functions for test scripts

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

# Build protoc-gen-mbt plugin
build_plugin() {
    local project_root="$1"
    cd "${project_root}/cli" && moon build --target native
    
    # Move plugin to project root
    if [ -f "./target/native/release/build/protoc-gen-mbt.exe" ]; then
        mv "./target/native/release/build/protoc-gen-mbt.exe" "${project_root}/${PLUGIN_NAME}"
    elif [ -f "./target/native/release/build/protoc-gen-mbt" ]; then
        mv "./target/native/release/build/protoc-gen-mbt" "${project_root}/${PLUGIN_NAME}"
    else
        echo "❌ Plugin binary not found after build"
        exit 1
    fi
    
    export PATH="${project_root}$(get_path_separator)${PATH}"
}

# Build protoc command with common options
build_protoc_command() {
    local proto_dir="$1"
    local output_dir="$2"
    local project_name="$3"
    local proto_files="$4"
    local include_path="$5"
    
    local protoc_cmd="protoc --proto_path=\"${proto_dir}\""
    
    # Add user-specified include path if provided
    if [ -n "${include_path}" ]; then
        protoc_cmd="${protoc_cmd} --proto_path=\"${include_path}\""
    fi
    
    protoc_cmd="${protoc_cmd} --mbt_out=\"${output_dir}\" --mbt_opt=paths=source_relative,project_name=${project_name} ${proto_files}"
    
    echo "${protoc_cmd}"
}
