"""Extract parameters from var files."""

import logging
import os
from typing import Any, Dict, Generator

import ssg.build_yaml
from ssg.utils import required_key

from utils.oscal import get_benchmark_root, LOGGER_NAME

logger = logging.getLogger(LOGGER_NAME)

VAR_FILE_EXTENSION = ".var"


def find_var_files(directory: str) -> Generator[str, None, None]:
    """Yield all files in a directory with a given extension."""
    for root, _, files in os.walk(directory):
        for file in files:
            if file.endswith(VAR_FILE_EXTENSION):
                yield os.path.join(root, file)


class ParamInfo:
    """Stores parameter information."""

    def __init__(self, param_id: str, description: str) -> None:
        """Initialize."""
        self._id = param_id
        self._description = description
        self._value = ""
        self._options: Dict[str, str] = dict()

    @property
    def id(self) -> str:
        """Get the id."""
        return self._id

    @property
    def description(self) -> str:
        """Get the description."""
        return self._description

    @property
    def selected_value(self) -> str:
        """Get the selected value."""
        return self._value

    @property
    def options(self) -> Dict[str, str]:
        """Get the options."""
        return self._options

    def set_selected_value(self, value: str) -> None:
        """Set the selected value."""
        self._value = value

    def set_options(self, value: Dict[str, str]) -> None:
        """Set the options."""
        self._options = value


class ParameterExtractor:
    """To extract parameters from var files"""

    def __init__(self, root: str, env_yaml: Dict[str, Any]) -> None:
        """Initialize."""
        self.root = root
        self.env_yaml = env_yaml

        product = required_key(env_yaml, "product")
        benchmark_root = get_benchmark_root(root, product)
        self.param_files_for_product: Dict[str, str] = dict()
        for file in find_var_files(benchmark_root):
            param_id = os.path.basename(file).replace(VAR_FILE_EXTENSION, "")
            self.param_files_for_product[param_id] = file

        # Store any previously loaded parameters here
        self._params_by_id: Dict[str, ParamInfo] = dict()

    def get_params_for_id(self, param_id: str) -> ParamInfo:
        """Get the parameter information for a parameter id."""
        if param_id not in self._params_by_id:
            param_obj: ParamInfo = self._load_param_info(param_id)
            self._params_by_id[param_id] = param_obj
            return param_obj
        return self._params_by_id[param_id]

    def get_all_selected_values(self) -> Dict[str, str]:
        """Get all of the selected values for each stored parameter."""
        return {
            param_id: param_obj.selected_value
            for param_id, param_obj in self._params_by_id.items()
        }

    def _load_param_info(self, param_id: str) -> ParamInfo:
        """Load the param from the var file."""
        try:
            file = self.param_files_for_product[param_id]
            value_yaml = ssg.build_yaml.Value.from_yaml(file, self.env_yaml)
            parameter_id = os.path.basename(file).replace(VAR_FILE_EXTENSION, "")
            default = required_key(value_yaml.options, "default")
            param_obj = ParamInfo(
                parameter_id,
                value_yaml.description.replace("\n", " ").strip(),
            )
            param_obj.set_selected_value(default)
            param_obj.set_options(value_yaml.options)
            logger.info(f"Adding parameter {parameter_id}")
            return param_obj
        except KeyError as e:
            raise ValueError(f"Could not find parameter {param_id}: {e}")
        except ValueError as e:
            logger.warning(f"Var file {file} has missing fields: {e}")
            return param_obj
