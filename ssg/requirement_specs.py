"""
Common functions for processing Requirements Specs in SSG
"""
import re
from typing import Tuple, List

from ssg import utils


class RequirementParser:
    """
    A simple parser for package requirements with version specifiers.
    Handles formats like: package[extra]>=1.0,<2.0
    """

    def __init__(self, target_v: str):
        self.target = target_v
        # First, extract package name and extras
        base_match = re.match(
            r'^(?P<name>[a-zA-Z0-9\-_.]+)(?:\[(?P<extra>[a-zA-Z0-9\-_]+)])?(?P<specs>.*)$',
            target_v
        )

        if not base_match:
            raise ValueError(f"Invalid requirement format: {target_v}")

        self.name = base_match.group('name')
        self.extra = base_match.group('extra')
        specs_str = base_match.group('specs')

        # Parse comma-separated version specifiers
        self.specs_list = []
        if specs_str and specs_str.strip():
            for spec in specs_str.split(','):
                spec = spec.strip()
                if spec:
                    spec_match = re.match(r'^(?P<op>[><!~=]+)\s*(?P<ver>.+)$', spec)
                    if spec_match:
                        self.specs_list.append((spec_match.group('op'), spec_match.group('ver')))
                    else:
                        raise ValueError(f"Invalid version specifier: {spec}")

    def __str__(self):
        return self.target

    @property
    def specs(self) -> List[Tuple[str, str]]:
        return self.specs_list

    @property
    def project_name(self) -> str:
        return self.name

    @property
    def extras(self) -> List[str]:
        if self.extra:
            return [self.extra.lower()]
        return []


def parse_version_into_evr(version):
    """
    Parses a version string into its epoch, version, and release components.

    Args:
        version (str): The version string to parse. It should be in the format
                       'epoch:version-release', where 'epoch' and 'release' are optional.

    Returns:
        dict: A dictionary with keys 'epoch', 'version', and 'release', containing the respective
              parts of the version string. If 'epoch' or 'release' are not present in the input
              string, their values will be None.

    Raises:
        ValueError: If the version string does not match the expected format.
    """
    evr = {"epoch": None, "version": None, "release": None}
    match_version = re.match(r'^(?:(\d+):)?(\d[\d\.]*)(?:-(\d*))?$', version)
    if not match_version:
        raise ValueError("Invalid version specifier {0}".format(version))
    evr["epoch"] = match_version.groups()[0]
    evr["version"] = match_version.groups()[1]
    evr["release"] = match_version.groups()[2]
    return evr


def _spec_to_version_specifier(spec):
    """
    Convert a specification tuple into a VersionSpecifier object.

    Args:
        spec (tuple): A tuple containing an operator and a version string.
                      For example, ('>=', '1.0.0').

    Returns:
        VersionSpecifier: An object representing the version specifier.
    """
    op, ver = spec
    evr = parse_version_into_evr(ver)
    return utils.VersionSpecifier(op, evr)


class Requirement:
    """
    A class to represent a package requirement with version specifications.

    Attributes:
        _req (RequirementParser): The parsed requirement object.
        _specs (utils.VersionSpecifierSet): The set of version specifiers for the requirement.
    """
    def __init__(self, obj: str):
        self._req = RequirementParser(obj)
        self._specs = utils.VersionSpecifierSet(
            [_spec_to_version_specifier(spec) for spec in self._req.specs]
        )

    def __contains__(self, item):
        """Check if a version string satisfies the requirement specs."""
        if not self.has_version_specs():
            return False
        return item in self._specs

    def __str__(self):
        return str(self._req)

    def has_version_specs(self):
        """
        Check if the requirement has version specifications.

        Returns:
            bool: True if there are version specifications, False otherwise.
        """
        return bool(self._req.specs)

    @property
    def ver_specs(self):
        """
        Retrieve the specifications.

        Returns:
            dict: The specifications stored in the instance.
        """
        return self._specs

    @property
    def name(self):
        """
        Retrieve the project name from the requirement specifications.

        Returns:
            str: The name of the project.
        """
        return self._req.project_name

    @property
    def arg(self):
        """
        Retrieve the first extra requirement if available.

        Returns:
            The first element in the extras list if it exists, otherwise None.
        """
        return self._req.extras[0] if self._req.extras else None

    @staticmethod
    def is_parametrized(name):
        """
        Check if a package requirement is parametrized.

        A parametrized package requirement includes extras, which are additional features or
        dependencies that can be optionally included.

        Args:
            name (str): The name of the package requirement to check.

        Returns:
            bool: True if the package requirement is parametrized (includes extras),
                  False otherwise.
        """
        return bool(RequirementParser(name).extras)

    @staticmethod
    def get_base_for_parametrized(name):
        """
        Extracts the base project name from a given parameterized package name.

        Args:
            name (str): The parameterized package name to parse.

        Returns:
            str: The base project name of the package.
        """
        return RequirementParser(name).project_name
