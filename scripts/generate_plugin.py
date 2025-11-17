import json
from pathlib import Path
import sys

from common import update_lib_deps
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
        update_lib_deps(config.project_root, config.plugin_dir)

        # Step 3: Update moon.mod.json with async dependency
        mod_json_path = config.plugin_dir / "moon.mod.json"
        with open(mod_json_path) as f:
            module_config = json.load(f)

        module_config["deps"]["moonbitlang/async"] = "0.13.1"

        with open(mod_json_path, "w") as f:
            json.dump(module_config, f, indent=2)

        # Step 4: Update moon.pkg.json with test imports and targets
        pkg_json_path = (
            config.plugin_dir / "src" / "google" / "protobuf" / "compiler" / "moon.pkg.json"
        )
        with open(pkg_json_path) as f:
            json_model = json.load(f)

        json_model["test-import"] = [
            "moonbitlang/async",
            "moonbitlang/async/process",
            "moonbitlang/async/io",
            "moonbitlang/async/pipe",
        ]
        json_model["targets"] = {"top_test.mbt": ["native"]}

        with open(pkg_json_path, "w") as f:
            json.dump(json_model, f, indent=2)

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
