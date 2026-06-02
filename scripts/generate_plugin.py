import sys

from workflow import ProjectConfig, CommandRunner, WorkflowExecutor
from logger import get_logger

logger = get_logger(__name__)

# Initialize configuration
config = ProjectConfig()
runner = CommandRunner(logger)
executor = WorkflowExecutor(config, runner)


def main():
    logger.info(f"Project root: {config.project_root}")

    try:
        # Step 1: Build plugin
        executor.build_plugin()

        # Step 2: Generate plugin code from proto
        proto_file = config.plugin_dir / "plugin.proto"
        if not proto_file.exists():
            logger.error(f"plugin.proto not found: {proto_file}")
            sys.exit(1)

        executor.run_protoc(
            config.plugin_dir,
            config.project_root,
            "plugin",
            [proto_file.name, "google/protobuf/descriptor.proto"],
            username="moonbitlang",
        )

        # Step 3: Convert generated JSON config to current moon format.
        executor.moon.fmt(config.plugin_dir, paths=["moon.mod.json"])

        # Step 4: Add the async dependency required by plugin tests.
        executor.runner.run(
            [
                "moon",
                "-C",
                str(config.plugin_dir),
                "add",
                "moonbitlang/async@0.18.0",
            ],
            cwd=config.project_root,
            description="Adding async dependency to plugin module",
        )

        # Step 5: Run moon workflow
        executor.run_moon_workflow(
            config.plugin_dir,
            ["check", "test", "fmt", "info"],
        )

        logger.info("Plugin code generation completed successfully.")

    except Exception as e:
        logger.error(f"Error: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()
