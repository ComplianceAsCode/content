import pkg_resources
import re

from ssg import utils

# Monkey-patch pkg_resources.safe_name function to keep underscores intact
# Setuptools recognize the issue: https://github.com/pypa/setuptools/issues/2522
pkg_resources.safe_name = lambda name: re.sub('[^A-Za-z0-9_.]+', '-', name)
# Monkey-patch pkg_resources.safe_extras function to keep dashes intact
# Setuptools recognize the issue: https://github.com/pypa/setuptools/pull/732
pkg_resources.safe_extra = lambda extra: re.sub('[^A-Za-z0-9.-]+', '_', extra).lower()


def _add_version_element(elements, el):
    elements.append(str(int(el)))


def _add_version_elements_to_evr_component(evr, elements, component):
    evr[component] = '.'.join(elements if elements else ['0'])
    elements = []


def _select_next_component(el):
    if el.endswith('final-'):
        return 'release'
    if el.endswith('final'):
        return None


def _evr_from_tuple_for_sure(version_tuple):
    # TODO: We do not support `epoch` at this moment, it is always None
    evr = {'epoch': None, 'version': None, 'release': None}
    component = 'version'
    elements = []
    for el in version_tuple:
        if el.startswith('*'):
            _add_version_elements_to_evr_component(evr, elements, component)
            component = _select_next_component(el)
            if component is None:
                break
            continue
        _add_version_element(elements, el)
    return evr


def _evr_from_tuple(version_tuple):
    # This is a version tuple from setuptools 0.9.8
    # 1.22.33-444 -> ('00000011', '00000022', '00000033', '*final-', '00000444', '*final')
    if isinstance(version_tuple, tuple):
        return _evr_from_tuple_for_sure(version_tuple)
    raise ValueError('Invalid object: %s, '
                     'expected: tuple' % repr(version_tuple))


def _evr_from_version_object_for_sure(version_object):
    # TODO: We do not support `epoch` at this moment, it is always None
    if hasattr(version_object, 'post'):
        post = version_object.post
    elif hasattr(version_object, '_version') and hasattr(version_object._version, 'post'):
        # There was a range of versions around 40.8 of setuptools
        # where `post` hasn't been a public property of the Version class.
        # In _version it has structure of ('post', 12) for version 1.2.3-12.
        post = version_object._version.post[1] if version_object._version.post else None
    else:
        raise ValueError('Invalid pkg_resources.packaging.version.Version object: '
                         'no Version.post or Version._version.post attributes.'
                         'Current version of setuptools is not supported.')
    return {'epoch': None,
            'version': version_object.base_version,
            'release': str(post) if post else None}


def _evr_from_version_object(version_object):
    if isinstance(version_object, pkg_resources.packaging.version.Version):
        return _evr_from_version_object_for_sure(version_object)
    raise ValueError('Invalid version object: %s, '
                     'expected: pkg_resources.packaging.version.Version' % repr(version_object))


def _get_evr(version_something):
    # Function should be redefined in accordance with setuptools behaviour. See below.
    raise Exception("No EVR parser defined!")


try:
    from pkg_resources import packaging
    # We are using modern setuptools, packaging.version.Version is available
    # and is used as the result of parse_version() function.
    _get_evr = _evr_from_version_object
except ImportError:
    # We are using old setuptools (Python 2.7 / 0.9.8) the parse_version() function
    # returns a tuple object.
    _get_evr = _evr_from_tuple


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
