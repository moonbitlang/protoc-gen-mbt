#!/usr/bin/env python3
"""
Common functions for test scripts.

This module provides utilities for OS detection, tool verification,
and building protoc commands for the MoonBit protobuf code generator.
"""

import json
import subprocess
import sys
from pathlib import Path
from typing import Optional

from logger import get_logger

logger = get_logger(__name__)


def build_plugin(project_root: Path) -> None:
    """
    Build the protoc-gen-mbt plugin using moon build system.

    Args:
        project_root: Path to the project root directory

    Raises:
        SystemExit: If the build fails or plugin binary is not found
    """
    cli_dir = project_root / "cli"
    plugin_name = "protoc-gen-mbt.exe"

    logger.info(f"Building plugin in {cli_dir}...")

    # Change to cli directory and build
    try:
        subprocess.run(
            ["moon", "build", "--target", "native"],
            cwd=cli_dir,
            check=True,
            capture_output=True,
            text=True,
        )
        logger.info("Plugin build successful")
    except subprocess.CalledProcessError as e:
        logger.error(f"Plugin build failed: {e}")
        logger.error(f"stdout: {e.stdout}")
        logger.error(f"stderr: {e.stderr}")
        sys.exit(1)

    # Find and move the plugin binary
    plugin_path = cli_dir / "target" / "native" / "release" / "build" / plugin_name

    if plugin_path.exists():
        destination = project_root / plugin_name

        # Remove destination file if it already exists
        if destination.exists():
            destination.unlink()

        plugin_path.rename(destination)
        logger.info(f"Plugin moved to {destination}")
    else:
        logger.error("Plugin binary not found after build")
        sys.exit(1)


def build_protoc_command(
    proto_dir: Path,
    output_dir: Path,
    project_name: str,
    project_root: Path,
    proto_files: list[str],
    username: str = "username",
    include_path: Optional[str] = None,
) -> list[str]:
    """
    Build protoc command with common options for MoonBit code generation.

    Args:
        proto_dir: Directory containing proto files
        output_dir: Directory for generated output
        project_name: Name of the project for generated code
        proto_files: Proto file(s) to process
        include_path: Additional include path for protoc (optional)

    Returns:
        List of command arguments for subprocess execution
    """
    cmd = [
        "protoc",
        f"--plugin=protoc-gen-mbt={project_root / 'protoc-gen-mbt.exe'}",
        f"--proto_path={proto_dir}",
    ]

    # Add user-specified include path if provided
    if include_path:
        cmd.append(f"--proto_path={include_path}")

    cmd.extend(
        [
            f"--mbt_out={output_dir}",
            f"--mbt_opt=paths=source_relative,project_name={project_name},username={username}",
        ]
    )

    cmd.extend(proto_files)

    return cmd


def run_command(
    cmd: list[str], cwd: Optional[Path] = None, description: str = ""
) -> None:
    """
    Run a command with proper error handling and logging.

    Args:
        cmd: Command to run as list of arguments
        cwd: Working directory for the command
        description: Description of what the command does (for logging)

    Raises:
        SystemExit: If the command fails
    """
    if description:
        logger.info(f"Running: {description}")

    logger.info(f"Command: {' '.join(cmd)}")

    try:
        result = subprocess.run(
            cmd, cwd=cwd, check=True, capture_output=True, text=True
        )
        if result.stdout:
            logger.info(f"Output: {result.stdout}")
    except subprocess.CalledProcessError as e:
        logger.error(f"Command failed: {e}")
        if e.stdout:
            logger.error(f"stdout: {e.stdout}")
        if e.stderr:
            logger.error(f"stderr: {e.stderr}")
        sys.exit(1)


def update_lib_deps(project_root: Path, gen_mod_json_dir: Path) -> None:
    """Fix the deps path in the generated moon.mod.json file."""

    gen_mod_json = gen_mod_json_dir / "moon.mod.json"

    logger.info("Fixing deps path in generated moon.mod.json...")

    if not gen_mod_json.exists():
        logger.error(f"Generated module file not found: {gen_mod_json}")
        sys.exit(1)

    # Read the existing JSON file
    with open(gen_mod_json, "r") as f:
        module_config = json.load(f)

    # Update the deps section
    relative_path = (
        project_root / 'lib').relative_to(gen_mod_json_dir, walk_up=True).as_posix()
    module_config["deps"]["moonbit-community/protobuf/lib"] = {
        "path": relative_path
    }

    # Write the updated JSON back to the file
    with open(gen_mod_json, "w") as f:
        json.dump(module_config, f, indent=2)

    logger.info(f"Updated deps path in {gen_mod_json_dir}")
