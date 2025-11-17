#!/usr/bin/env python3
"""
Logging configuration for MoonBit protobuf test scripts.

This module provides colored logging formatters and setup functions
for consistent logging across all test scripts.
"""

import logging
import sys


class ColoredFormatter(logging.Formatter):
    """Colored log formatter for terminal output."""

    # ANSI color codes
    COLORS = {
        "DEBUG": "\033[36m",  # Cyan
        "INFO": "\033[32m",  # Green
        "WARNING": "\033[33m",  # Yellow
        "ERROR": "\033[31m",  # Red
        "CRITICAL": "\033[35m",  # Magenta
    }
    RESET = "\033[0m"

    def format(self, record):
        """Format log record with colors."""
        log_color = self.COLORS.get(record.levelname, self.RESET)
        record.levelname = f"{log_color}{record.levelname}{self.RESET}"
        record.msg = f"{log_color}{record.msg}{self.RESET}"
        return super().format(record)


_HANDLER = None


def _get_colored_handler() -> logging.Handler:
    """Get or create the singleton colored handler."""
    global _HANDLER
    if _HANDLER is None:
        _HANDLER = logging.StreamHandler(sys.stdout)
        _HANDLER.setFormatter(ColoredFormatter("%(levelname)s: %(message)s"))
    return _HANDLER


def get_logger(name: str, level: int = logging.INFO) -> logging.Logger:
    """
    Get a logger with the specified name.

    Uses a singleton handler to avoid duplicate logging handlers.

    Args:
        name: Logger name (usually __name__)
        level: Logging level (default: INFO)

    Returns:
        Logger instance configured with colored formatter
    """
    logger = logging.getLogger(name)
    logger.setLevel(level)

    # Add handler only if this logger doesn't have one
    if not logger.handlers:
        logger.addHandler(_get_colored_handler())

    return logger
