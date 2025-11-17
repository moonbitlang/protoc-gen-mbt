#!/usr/bin/env python3
"""
Workflow utilities for MoonBit protobuf code generation tests.

This module provides high-level abstractions for common workflow patterns:
- Building plugins
- Generating protobuf code
- Running moon commands
- Managing project configuration
"""

from __future__ import annotations

import subprocess
import sys
from pathlib import Path
from typing import Callable, Optional

from logger import get_logger

logger = get_logger(__name__)


class ProjectConfig:
    """Project configuration and path management."""

    def __init__(self, project_root: Path | None = None):
        """
        Initialize project configuration.

        Args:
            project_root: Root directory of the project. If None, derived from script location.
        """
        if project_root is None:
            # Derive from this script's location
            project_root = Path(__file__).parent.absolute().parent

        self.project_root = project_root
        self.cli_dir = project_root / "cli"
        self.lib_dir = project_root / "lib"
        self.test_dir = project_root / "test"
        self.plugin_dir = project_root / "plugin"
        # Plugin binary is built in cli/target/native/release/build/
        self.plugin_exe = self.cli_dir / "target" / "native" / "release" / "build" / "protoc-gen-mbt.exe"


class CommandRunner:
    """Execute commands with logging and error handling."""

    def __init__(self, logger_instance=None):
        """
        Initialize command runner.

        Args:
            logger_instance: Logger to use. If None, uses module logger.
        """
        self.logger = logger_instance or logger

    def run(
        self,
        cmd: list[str],
        cwd: Optional[Path] = None,
        description: Optional[str] = None,
    ) -> None:
        """
        Run a command with logging and error handling.

        Args:
            cmd: Command to run as list of arguments
            cwd: Working directory for the command
            description: Human-readable description of what the command does

        Raises:
            subprocess.CalledProcessError: If the command fails
        """
        cmd_str = " ".join(cmd)
        if description:
            self.logger.info(f"{description}...")
        self.logger.info(f"$ {cmd_str}")

        try:
            result = subprocess.run(
                cmd, cwd=cwd, check=True, capture_output=True, text=True
            )
            if result.stdout:
                self.logger.info(result.stdout)
        except subprocess.CalledProcessError as e:
            self.logger.error(f"Command failed: {cmd_str}")
            if e.stdout:
                self.logger.error("=== STDOUT ===")
                self.logger.error(e.stdout)
                self.logger.error("==============")
            if e.stderr:
                self.logger.error("=== STDERR ===")
                self.logger.error(e.stderr)
                self.logger.error("==============")
            raise


class MoonCommandBuilder:
    """Build and run moon commands."""

    def __init__(self, runner: CommandRunner):
        """
        Initialize moon command builder.

        Args:
            runner: CommandRunner instance for executing commands
        """
        self.runner = runner

    def build(self, cwd: Path, target: str = "native") -> None:
        """Run 'moon build' in the given directory."""
        self.runner.run(
            ["moon", "build", "--target", target],
            cwd=cwd,
            description=f"Running moon build ({target})",
        )

    def update(self, cwd: Path) -> None:
        """Run 'moon update' in the given directory."""
        self.runner.run(["moon", "update"], cwd=cwd,
                        description="Running moon update")

    def install(self, cwd: Path) -> None:
        """Run 'moon install' in the given directory."""
        self.runner.run(["moon", "install"], cwd=cwd,
                        description="Running moon install")

    def fmt(self, cwd: Path) -> None:
        """Run 'moon fmt' in the given directory."""
        self.runner.run(["moon", "fmt"], cwd=cwd,
                        description="Running moon fmt")

    def test(self, cwd: Path, target: str = "native") -> None:
        """Run 'moon test' in the given directory."""
        self.runner.run(
            ["moon", "test", "--target", target],
            cwd=cwd,
            description=f"Running moon test ({target})",
        )

    def test_update(self, cwd: Path, target: str = "native") -> None:
        """Run 'moon test --update' in the given directory."""
        self.runner.run(
            ["moon", "test", "--target", target, "--update"],
            cwd=cwd,
            description=f"Running moon test with update ({target})",
        )

    def check(self, cwd: Path, target: str = "native") -> None:
        """Run 'moon check' in the given directory."""
        self.runner.run(
            ["moon", "check", "--target", target],
            cwd=cwd,
            description=f"Running moon check ({target})",
        )

    def info(self, cwd: Path, target: str = "native") -> None:
        """Run 'moon info' in the given directory."""
        self.runner.run(
            ["moon", "info", "--target", target],
            cwd=cwd,
            description=f"Running moon info ({target})",
        )


class WorkflowExecutor:
    """High-level workflow execution for common test patterns."""

    def __init__(self, config: ProjectConfig, runner: CommandRunner):
        """
        Initialize workflow executor.

        Args:
            config: ProjectConfig instance
            runner: CommandRunner instance
        """
        self.config = config
        self.runner = runner
        self.moon = MoonCommandBuilder(runner)

    def build_plugin(self) -> None:
        """Build the protoc-gen-mbt plugin."""
        self.moon.build(self.config.cli_dir, target="native")

        # Verify plugin exists
        if not self.config.plugin_exe.exists():
            self.runner.logger.error(
                f"Plugin binary not found: {self.config.plugin_exe}")
            sys.exit(1)

        self.runner.logger.info(
            f"Plugin built successfully at {self.config.plugin_exe}")

    def run_protoc(
        self,
        proto_dir: Path,
        output_dir: Path,
        project_name: str,
        proto_files: list[str],
        username: str = "username",
        include_path: Optional[str] = None,
    ) -> None:
        """
        Run protoc command to generate MoonBit code from proto files.

        Args:
            proto_dir: Directory containing proto files
            output_dir: Directory for generated output
            project_name: Name of the project for generated code
            proto_files: Proto file(s) to process
            username: Username for generated code (default: "username")
            include_path: Additional include path for protoc (optional)
        """
        cmd = [
            "protoc",
            f"--plugin=protoc-gen-mbt={self.config.plugin_exe}",
            f"--proto_path={proto_dir}",
        ]

        # Add user-specified include path if provided
        if include_path:
            cmd.append(f"--proto_path={include_path}")

        cmd.extend([
            f"--mbt_out={output_dir}",
            f"--mbt_opt=paths=source_relative,project_name={project_name},username={username}",
        ])
        cmd.extend(proto_files)
        self.runner.run(cmd, description=f"Generating {project_name} with protoc")

    def run_moon_workflow(
        self,
        work_dir: Path,
        steps: list[str],
    ) -> None:
        """
        Run a series of moon commands in sequence.

        Args:
            work_dir: Directory where moon commands should run
            steps: List of command names ('update', 'install', 'fmt', 'test', 'check', 'info')
        """
        for step in steps:
            if step == "update":
                self.moon.update(work_dir)
            elif step == "install":
                self.moon.install(work_dir)
            elif step == "fmt":
                self.moon.fmt(work_dir)
            elif step == "test":
                self.moon.test(work_dir)
            elif step == "test_update":
                self.moon.test_update(work_dir)
            elif step == "check":
                self.moon.check(work_dir)
            elif step == "info":
                self.moon.info(work_dir)
            else:
                self.runner.logger.warning(f"Unknown moon command: {step}")
