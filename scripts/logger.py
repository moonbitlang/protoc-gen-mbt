#!/usr/bin/env python3
"""
Logging configuration for MoonBit protobuf test scripts.

This module provides colored logging formatters and setup functions
for consistent logging across all test scripts.
"""

import logging
import sys
from typing import Optional


class ColoredFormatter(logging.Formatter):
    """Colored log formatter for terminal output."""
    
    # ANSI color codes
    COLORS = {
        'DEBUG': '\033[36m',    # Cyan
        'INFO': '\033[32m',     # Green
        'WARNING': '\033[33m',  # Yellow
        'ERROR': '\033[31m',    # Red
        'CRITICAL': '\033[35m', # Magenta
    }
    RESET = '\033[0m'
    
    def format(self, record):
        """Format log record with colors."""
        log_color = self.COLORS.get(record.levelname, self.RESET)
        record.levelname = f"{log_color}{record.levelname}{self.RESET}"
        record.msg = f"{log_color}{record.msg}{self.RESET}"
        return super().format(record)


def setup_colored_logger(name: str, level: int = logging.INFO) -> logging.Logger:
    """
    Set up a logger with colored output.
    
    Args:
        name: Logger name (usually __name__)
        level: Logging level (default: INFO)
    
    Returns:
        Configured logger with colored formatter
    """
    logger = logging.getLogger(name)
    logger.setLevel(level)
    
    # Remove existing handlers to avoid duplicates
    for handler in logger.handlers[:]:
        logger.removeHandler(handler)
    
    # Create console handler with colored formatter
    handler = logging.StreamHandler(sys.stdout)
    handler.setFormatter(ColoredFormatter('%(levelname)s: %(message)s'))
    logger.addHandler(handler)
    
    # Prevent propagation to root logger to avoid duplicate messages
    logger.propagate = False
    
    return logger


def setup_all_colored_loggers(level: int = logging.INFO):
    """
    Set up colored logging for all relevant loggers including modules.
    
    This function configures the root logger with colored output,
    which will be inherited by all child loggers.
    
    Args:
        level: Logging level (default: INFO)
    """
    # Set up root logger with colored formatter
    root_logger = logging.getLogger()
    root_logger.setLevel(level)
    
    # Remove existing handlers to avoid duplicates
    for handler in root_logger.handlers[:]:
        root_logger.removeHandler(handler)
    
    # Add colored handler to root logger
    handler = logging.StreamHandler(sys.stdout)
    handler.setFormatter(ColoredFormatter('%(levelname)s: %(message)s'))
    root_logger.addHandler(handler)


def get_logger(name: str, level: int = logging.INFO) -> logging.Logger:
    """
    Get a logger with the specified name.
    
    This function assumes that setup_all_colored_loggers() has been called
    to configure the root logger with colored formatting.
    
    Args:
        name: Logger name (usually __name__)
        level: Logging level (default: INFO)
    
    Returns:
        Logger instance that will use the root logger's colored formatter
    """
    logger = logging.getLogger(name)
    logger.setLevel(level)
    return logger
