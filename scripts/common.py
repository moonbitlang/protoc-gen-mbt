#!/usr/bin/env python3
"""
Common functions for test scripts.

This module provides utilities for OS detection, tool verification,
and building protoc commands for the MoonBit protobuf code generator.
"""

import logging
import os
import subprocess
import sys
from pathlib import Path
from typing import Optional

# Set up module logger
logger = logging.getLogger(__name__)


def verify_tool(tool: str, version_flag: str = "--version") -> bool:
    """
    Verify that a command-line tool is available and accessible.

    Args:
        tool: Name of the tool to verify
        version_flag: Flag to use for version check (default: --version)

    Returns:
        True if tool is available, False otherwise
    """
    try:
        subprocess.run([tool, version_flag],
                       capture_output=True,
                       check=True,
                       timeout=10)
        return True
    except (subprocess.CalledProcessError, FileNotFoundError, subprocess.TimeoutExpired):
        logger.error(f"{tool} is not installed or not in PATH")
        return False


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
            text=True
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

def build_protoc_command(proto_dir: Path, output_dir: Path, project_name: str, project_root: Path,
                         proto_files: str, include_path: Optional[str] = None) -> list[str]:
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

    cmd.extend([
        f"--mbt_out={output_dir}",
        f"--mbt_opt=paths=source_relative,project_name={project_name}",
        proto_files
    ])

    return cmd


def run_command(cmd: list[str], cwd: Optional[Path] = None, description: str = "") -> None:
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
            cmd,
            cwd=cwd,
            check=True,
            capture_output=True,
            text=True
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
