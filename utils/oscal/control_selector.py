"""Abstract and concrete classes for control selection to extract control responses."""

import os
from abc import ABC, abstractmethod
from typing import Any, Dict, List

from ssg.controls import ControlsManager, Control


class ControlSelector(ABC):
    @abstractmethod
    def __init__(self) -> None:
        raise NotImplementedError

    @abstractmethod
    def get_controls(self) -> List[Control]:
        raise NotImplementedError


class PolicyControlSelector(ControlSelector):
    """Select controls from a policy with optional filtering by level."""

    def __init__(
        self,
        control: str,
        ssg_root: str,
        env_yaml: Dict[str, Any],
        filter_by_level: str = "",
    ) -> None:
        """
        Initialize the PolicyControlSelector.

        Args:
            control: The policy id.
            ssg_root: The path to the root of the ssg directory.
            env_yaml: The environment yaml.
            filter_by_level: Optional level to filter by.
        """
        controls_dir = os.path.join(ssg_root, "controls")
        controls_manager = ControlsManager(controls_dir=controls_dir, env_yaml=env_yaml)
        controls_manager.load()
        if control not in controls_manager.policies:
            raise ValueError(f"Policy {control} not found in controls")

        self.controls: List[Control] = list()
        if filter_by_level:
            policy = controls_manager.policies[control]
            if filter_by_level not in policy.levels_by_id.keys():
                raise ValueError(
                    f"Level {filter_by_level} not found in policy {control}"
                )
            self.controls = controls_manager.get_all_controls_of_level(
                control, filter_by_level
            )
        else:
            self.controls = controls_manager.get_all_controls(control)

    def get_controls(self) -> List[Control]:
        """Get the controls."""
        return self.controls
