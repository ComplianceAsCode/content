from .ext.boolean import boolean
import ssg.utils

# Monkey-patch pkg_resources.safe_name function to keep underscores intact
# Setuptools recognize the issue: https://github.com/pypa/setuptools/issues/2522
import pkg_resources
import re
pkg_resources.safe_name = lambda name: re.sub('[^A-Za-z0-9_.]+', '-', name)


# We don't support ~= to avoid confusion with boolean operator NOT (~)
SPEC_SYMBOLS = ['<', '>', '=', '!', ',', '[', ']']

VERSION_SYMBOLS = ['.', '-', '_', '*']


def _evr_from_tuple(version_tuple):
    # This is a version tuple from setuptools 0.9.8
    # 1.22.33-444 -> '00000011', '00000022', '00000033', '*final-', '00000444', '*final')
    if isinstance(version_tuple, tuple):
        # TODO: We do not support `epoch` at this moment, it is always 0
        evr = {'epoch': '0', 'version': None, 'release': '0'}
        component = 'version'
        elements = []
        for el in version_tuple:
            if el.startswith('*'):
                evr[component] = '.'.join(elements if elements else '0')
                elements = []
                if el.endswith('final-'):
                    component = 'release'
                    continue
                if el.endswith('final'):
                    break
            elements.append(str(int(el)))
        return evr


def _evr_from_version_object(version_object):
    if isinstance(version_object, pkg_resources.packaging.version.Version):
        # TODO: We do not support `epoch` at this moment, it is always 0
        return {'epoch': '0',
                'version': version_object.base_version,
                'release': str(version_object.post) if version_object.post else '0'}
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
    ver = pkg_resources.parse_version(version)
    return _get_evr(ver)


def _version_specifier_to_id(spec):
    op, ver = spec
    return '{0}_{1}'.format(ssg.utils.escape_comparison(op), ssg.utils.escape_id(ver))


def _evr_to_str(evr):
    return '{epoch}:{version}-{release}'.format(**evr)


class Function(boolean.Function):
    """
    Base class for boolean functions

    Subclass it and pass to the `Algebra` as `function_cls` to enrich
    expression elements with domain-specific methods.

    Provides `is_and`, `is_or` and `is_not` methods to distinguish instances
    between different boolean functions.

    The `as_id` method will generate a unique string identifier usable as
    an XML id based on the properties of the entity.
    """

    def is_and(self):
        return isinstance(self, boolean.AND)

    def is_or(self):
        return isinstance(self, boolean.OR)

    def is_not(self):
        return isinstance(self, boolean.NOT)

    def as_id(self):
        if self.is_not():
            return 'not_{0}'.format(self.args[0].as_id())
        op = 'unknown_bool_op'
        if self.is_and():
            op = 'and'
        if self.is_or():
            op = 'or'
        return '_{0}_'.format(op).join([arg.as_id() for arg in self.args])


class Symbol(boolean.Symbol):
    """
    Base class for boolean symbols

    Subclass it and pass to the `Algebra` as `symbol_cls` to enrich
    expression elements with domain-specific methods.

    The `as_id` method will generate a unique string identifier usable as
    an XML id based on the properties of the entity.
    """

    def __init__(self, obj):
        super(Symbol, self).__init__(obj)
        self.requirement = pkg_resources.Requirement.parse(obj)
        self.obj = self.requirement

    def __call__(self, **kwargs):
        full_name = self.name
        if self.arg:
            full_name += '[' + self.arg + ']'
        val = kwargs.get(full_name, False)
        if self.ver_specs:
            if type(val) is str:
                return val in self.requirement
            return False
        return bool(val)

    def __hash__(self):
        return hash(self.as_id())

    def __eq__(self, other):
        return hash(self) == hash(other)

    def __lt__(self, other):
        return self.as_id() < other.as_id()

    def as_id(self):
        id_str = self.name
        if self.arg:
            id_str += '_' + self.arg
        for spec in sorted(self.ver_specs):
            id_str += '_' + _version_specifier_to_id(spec)
        return id_str

    def as_dict(self):
        res = {'id': self.as_id(), 'name': self.name, 'arg': '',
               'ver_title': '', 'ver_cpe': '', 'ver_specs': []}

        if self.arg:
            res['arg'] = self.arg

        if self.ver_specs:
            res['ver_title'] = ' and '.join(['{0} {1}'.format(
                ssg.utils.comparison_to_oval(op), ver)
                for op, ver in self.ver_specs])

            res['ver_cpe'] = ':'.join(['{0}:{1}'.format(
                ssg.utils.escape_comparison(op), ver)
                for op, ver in self.ver_specs])

            for spec in self.ver_specs:
                op, ver = spec
                evr = _parse_version_into_evr(ver)
                res['ver_specs'].append({
                    'id': _version_specifier_to_id(spec),
                    'op': op,
                    'ver': ver,
                    'evr_op': ssg.utils.comparison_to_oval(op),
                    'evr_ver': _evr_to_str(evr)
                })

        return res

    @property
    def ver_specs(self):
        return self.requirement.specs

    @property
    def arg(self):
        return self.requirement.extras[0] if self.requirement.extras else None

    @property
    def name(self):
        return self.requirement.project_name

    @staticmethod
    def is_parametrized(name):
        return bool(pkg_resources.Requirement.parse(name).extras)

    @staticmethod
    def get_base_of_parametrized_name(name):
        """
        If given a parametrized platform name such as package[test],
        it returns the package part only.
        """
        return pkg_resources.Requirement.parse(name).project_name


class Algebra(boolean.BooleanAlgebra):
    """
    Base class for boolean algebra

    Algebra class will parse and evaluate boolean expressions,
    where operators could be any combination of "~, &, |, !, *, +, not, and, or"
    and variable symbols could contain version specifiers as described
    in PEP440 and PEP508.

    Limitations:
    - no white space is allowed inside specifier expressions;
    - ~= specifier operator is not supported.

    For example: "(oranges>=2.0.8,<=5 | banana) and ~apple + !pie"
    """

    def __init__(self, symbol_cls, function_cls):
        not_cls = type('FunctionNOT', (function_cls, boolean.NOT), {})
        and_cls = type('FunctionAND', (function_cls, boolean.AND), {})
        or_cls = type('FunctionOR', (function_cls, boolean.OR), {})
        super(Algebra, self).__init__(allowed_in_token=VERSION_SYMBOLS+SPEC_SYMBOLS,
                                      Symbol_class=symbol_cls,
                                      NOT_class=not_cls, AND_class=and_cls, OR_class=or_cls)
