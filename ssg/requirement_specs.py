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
    evr = {"epoch": None, "version": None, "release": None}
    match_version = re.match(r'^(\d[\d\.]*)(?:-(\d*))?$', version)
    if not match_version:
        raise ValueError("Invalid version specifier {0}".format(version))
    evr["version"] = match_version.groups()[0]
    evr["release"] = match_version.groups()[1]
    return evr


def _spec_to_version_specifier(spec):
    op, ver = spec
    evr = _parse_version_into_evr(ver)
    return utils.VersionSpecifier(op, evr)


class Requirement:
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
        return bool(self._req.specs)

    @property
    def ver_specs(self):
        return self._specs

    @property
    def name(self):
        return self._req.project_name

    @property
    def arg(self):
        return self._req.extras[0] if self._req.extras else None

    @staticmethod
    def is_parametrized(name):
        return bool(pkg_resources.Requirement.parse(name).extras)

    @staticmethod
    def get_base_for_parametrized(name):
        return pkg_resources.Requirement.parse(name).project_name
