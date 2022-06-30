from .ext.boolean import boolean
from .ext.packaging import requirements, version
import uuid
import ssg.utils


# We don't support ~= to avoid confusion with boolean operator NOT (~)
SPEC_SYMBOLS = ['<', '>', '=', '!', ',', '[', ']']

VERSION_SYMBOLS = ['.', '-', '_', ':', '~', '^']

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


def version_to_pep440(ver):
    return ver.replace(':', '!').replace('~', '+').replace('^', '+')


def pep440_to_version(ver):
    return ver.replace('!', ':').replace('+', '~')


def specifier_to_id(spec):
    op, ver = spec
    return '{0}_{1}'.format(SPEC_OP_ID_TRANSLATION.get(op, 'eq'), ssg.utils.escape_id(ver))


def get_platform_id(expr):
    req = requirements.Requirement(version_to_pep440(expr))
    return req.name


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
        self.req = requirements.Requirement(version_to_pep440(obj))
        self.obj = self.req

    def __call__(self, **kwargs):
        full_name = self.name
        if self.req.extras:
            full_name += '[' + ','.join(self.req.extras) + ']'
        val = kwargs.get(full_name, False)
        if len(self.specs):
            if type(val) is str:
                return version_to_pep440(val) in self.req.specifier
            return False
        return bool(val)

    def __hash__(self):
        return hash(self.as_id())

    def __lt__(self, other):
        return self.as_id() < other.as_id()

    def __eq__(self, other):
        return hash(self) == hash(other)

    def as_id(self):
        id_str = self.name
        if self.req.extras:
            id_str += '_' + '_'.join(self.req.extras)
        for spec in sorted(self.specs):
            id_str += '_' + specifier_to_id(spec)
        return id_str

    def as_uuid(self):
        return str(uuid.uuid5(uuid.NAMESPACE_X500, self.as_id()))

    def as_dict(self):
        res = {
            'id': self.as_id(),
            'name': self.name,
            'arg': self.arg,
            'ver_str': '',
            'ver_cpe': '',
            'specs': []
        }

        if self.specs:
            res['ver_str'] = ' and '.join(['{0} {1}'.format(
                SPEC_OP_OVAL_EVR_STRING_TRANSLATION.get(op, 'equals'), pep440_to_version(ver))
                for op, ver in self.specs])
            res['ver_cpe'] = ':'.join(['{0}:{1}'.format(
                SPEC_OP_ID_TRANSLATION.get(op, 'eq'), pep440_to_version(ver))
                for op, ver in self.specs])

        for spec in self.specs:
            op, ver = spec
            v = version.Version(ver)
            res['specs'].append({
                'id': specifier_to_id(spec),
                'op': op,
                'ver': pep440_to_version(ver),
                'evr_op': SPEC_OP_OVAL_EVR_STRING_TRANSLATION.get(op, 'equals'),
                'evr_ver': str(v.epoch) + ':'
                + '.'.join(str(x) for x in v.release) + '-'
                + (str(v.post) if v.post else '0')
            })

        return res

    @property
    def specs(self):
        return [(spec.operator, spec.version) for spec in self.req.specifier]

    @property
    def arg(self):
        return ','.join(self.req.extras) if self.req.extras else None

    @property
    def name(self):
        return self.req.name


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
        super(
            Algebra, self).__init__(
                allowed_in_token=VERSION_SYMBOLS + SPEC_SYMBOLS,
                Symbol_class=symbol_cls, NOT_class=not_cls, AND_class=and_cls, OR_class=or_cls)
