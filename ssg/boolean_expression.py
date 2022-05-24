from .ext.boolean import boolean

# Monkey-patch pkg_resources.safe_name function to keep underscores intact
# Setuptools recognize the issue: https://github.com/pypa/setuptools/issues/2522
import pkg_resources
import re
import uuid
import ssg.utils

pkg_resources.safe_name = lambda name: re.sub('[^A-Za-z0-9_.]+', '-', name)

# We don't support ~= to avoid confusion with boolean operator NOT (~)
SPEC_SYMBOLS = ['<', '>', '=', '!', ',', '[', ']']

VERSION_SYMBOLS = ['.', '-', '_', ':']

SPEC_OP_ID_TRANSLATION = {
    '==': 'eq',
    '!=': 'ne',
    '>': 'gt',
    '<': 'le',
    '>=': 'gt_or_eq',
    '<=': 'le_or_eq',
}

SPEC_OP_OVAL_EVR_STRING_TRANSLATION = {
    '==': 'equals',
    '!=': 'not equal',
    '>': 'greater than',
    '<': 'less than',
    '>=': 'greater than or equal',
    '<=': 'less than or equal',
}


class Function(boolean.Function):
    """
    Base class for boolean functions

    Sub-class it and pass to the `Algebra` as `function_cls` to enrich
    expression elements with domain-specific methods.

    Provides `is_and`, `is_or` and `is_not` methods to distinguish instances
    between different boolean functions.

    The `as_id` method will generate an unique string identifier usable as
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

    def as_uuid(self):
        return str(uuid.uuid5(uuid.NAMESPACE_X500, self.as_id()))


class Symbol(boolean.Symbol):
    """
    Base class for boolean symbols

    Subclass it and pass to the `Algebra` as `symbol_cls` to enrich
    expression elements with domain-specific methods.

    The `as_id` method will generate an unique string identifier usable as
    an XML id based on the properties of the entity.
    """

    def __init__(self, obj):
        super(Symbol, self).__init__(obj)
        self.spec = pkg_resources.Requirement.parse(obj.replace(':', '!'))
        self.obj = self.spec

    def __call__(self, **kwargs):
        full_name = self.name
        if self.spec.extras:
            full_name += '[' + self.spec.extras[0] + ']'
        val = kwargs.get(full_name, False)
        if len(self.spec.specs):
            if type(val) is str:
                return val in self.spec
            return False
        return bool(val)

    def __lt__(self, other):
        return self.as_id() < other.as_id()

    @staticmethod
    def _spec_id(spec):
        op, ver = spec
        return '{0}_{1}'.format(SPEC_OP_ID_TRANSLATION.get(op, 'eq'), ssg.utils.escape_id(ver))

    def as_id(self):
        id_str = self.name
        if self.spec.extras:
            id_str += '_' + self.spec.extras[0]
        for spec in sorted(self.spec.specs):
            id_str += '_' + self._spec_id(spec)
        return id_str

    def as_uuid(self):
        return str(uuid.uuid5(uuid.NAMESPACE_X500, self.as_id()))

    def as_dict(self):
        res = {'id': self.as_id(), 'name': self.name, 'arg': '', 'ver_str': '', 'ver_cpe': '', 'specs': []}

        if self.spec.specs:
            res['ver_str'] = ' and '.join([
                '{0} {1}'.format(SPEC_OP_OVAL_EVR_STRING_TRANSLATION.get(op, 'equals'), ver.replace('!', ':'))
                for op, ver in self.spec.specs])
            res['ver_cpe'] = ':'.join([ver.replace('!', ':') for op, ver in self.spec.specs])

        if self.spec.extras:
            res['arg'] = self.spec.extras[0]

        for spec in self.spec.specs:
            op, ver = spec
            version = pkg_resources.parse_version(ver)
            res['specs'].append({
                'id': self._spec_id(spec),
                'op': op,
                'ver': ver.replace('!', ':'),
                'evr_op': SPEC_OP_OVAL_EVR_STRING_TRANSLATION.get(op, 'equals'),
                'evr_ver': str(version.epoch) + ':'
                           + '.'.join(str(x) for x in version.release) + '-'
                           + (str(version.post) if version.post else '0')
            })

        return res

    @property
    def arg(self):
        return self.spec.extras[0] if self.spec.extras else None

    @property
    def name(self):
        return self.spec.project_name


class Algebra(boolean.BooleanAlgebra):
    """
    Base class for boolean algebra

    Algebra class will parse and evaluate boolean expressions,
    where operators could be any combination of "~, &, |, !, *, +, not, and, or"
    and variable symbols could contain version specifiers as described
    in PEP440 and PEP508.

    Limitations:
    - no white space is allowed inside specifier expressions;
    - ~= specifier operator is not supported (along with '*' as a part of the version).

    For example: "(oranges>=2.0.8,<=5 | banana) and ~apple + !pie[beef]"
    """

    def __init__(self, symbol_cls, function_cls):
        not_cls = type('FunctionNOT', (function_cls, boolean.NOT), {})
        and_cls = type('FunctionAND', (function_cls, boolean.AND), {})
        or_cls = type('FunctionOR', (function_cls, boolean.OR), {})
        super(Algebra, self).__init__(allowed_in_token=VERSION_SYMBOLS + SPEC_SYMBOLS,
                                      Symbol_class=symbol_cls,
                                      NOT_class=not_cls, AND_class=and_cls, OR_class=or_cls)
