import os

import pytest

from utils.oscal.control_selector import PolicyControlSelector

DATADIR = os.path.join(os.path.dirname(__file__), "data")
TEST_ROOT = os.path.abspath(os.path.join(DATADIR, "test_root"))
TEST_BUILD_CONFIG = os.path.join(DATADIR, "build-config.yml")


def test_control_selector_invalid_level() -> None:
    """Trigger an error when the level filter is invalid."""

    with pytest.raises(ValueError, match="Level fake not found in policy test_policy"):
        PolicyControlSelector(
            control="test_policy",
            ssg_root=TEST_ROOT,
            env_yaml=dict(),
            filter_by_level="fake",
        )
