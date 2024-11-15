"""
Common functions for processing Requirements Specs in SSG
"""

import pkg_resources
import re

from ssg import utils

# Monkey-patch pkg_resources.safe_name function to keep underscores intact
# Setuptools recognize the issue: https://github.com/pypa/setuptools/issues/2522
pkg_resources.safe_name = lambda name: re.sub('[^A-Za-z0-9_.]+', '-', name)
# Monkey-patch pkg_resources.safe_extras function to keep dashes intact
# Setuptools recognize the issue: https://github.com/pypa/setuptools/pull/732
pkg_resources.safe_extra = lambda extra: re.sub('[^A-Za-z0-9.-]+', '_', extra).lower()


def _parse_version_into_evr(version):
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
    evr = _parse_version_into_evr(ver)
    return utils.VersionSpecifier(op, evr)


class Requirement:
    """
    A class to represent a package requirement with version specifications.

    Attributes:
        _req (pkg_resources.Requirement): The parsed requirement object.
        _specs (utils.VersionSpecifierSet): The set of version specifiers for the requirement.
    """
    def __init__(self, obj):
        self._req = pkg_resources.Requirement.parse(obj)
        self._specs = utils.VersionSpecifierSet(
            [_spec_to_version_specifier(spec) for spec in self._req.specs]
        )

    def __contains__(self, item):
        return item in self._req

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
        return bool(pkg_resources.Requirement.parse(name).extras)

    @staticmethod
    def get_base_for_parametrized(name):
        """
        Extracts the base project name from a given parameterized package name.

        Args:
            name (str): The parameterized package name to parse.

        Returns:
            str: The base project name of the package.
        """
        return pkg_resources.Requirement.parse(name).project_name
