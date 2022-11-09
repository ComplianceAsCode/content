from .ext.boolean import boolean

# Monkey-patch pkg_resources.safe_name function to keep underscores intact
# Setuptools recognize the issue: https://github.com/pypa/setuptools/issues/2522
import pkg_resources
import re
pkg_resources.safe_name = lambda name: re.sub('[^A-Za-z0-9_.]+', '-', name)


# We don't support ~= to avoid confusion with boolean operator NOT (~)
SPEC_SYMBOLS = ['<', '>', '=', '!', ',', '[', ']']

VERSION_SYMBOLS = ['.', '-', '_', '*']

SPEC_OP_ID_TRANSLATION = {
    '==': 'eq',
    '!=': 'ne',
    '>': 'gt',
    '<': 'le',
    '>=': 'gt_or_eq',
    '<=': 'le_or_eq',
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


class Symbol(boolean.Symbol):
    """
    Base class for boolean symbols

    Sub-class it and pass to the `Algebra` as `symbol_cls` to enrich
    expression elements with domain-specific methods.

    The `as_id` method will generate an unique string identifier usable as
    an XML id based on the properties of the entity.
    """

    def __init__(self, obj):
        super(Symbol, self).__init__(obj)
        self.spec = pkg_resources.Requirement.parse(obj)
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

    def as_id(self):
        id_str = self.name
        for (op, ver) in self.spec.specs:
            id_str += '_{0}_{1}'.format(SPEC_OP_ID_TRANSLATION.get(op, 'unknown_spec_op'), ver)
        if self.spec.extras:
            id_str += '_' + self.spec.extras[0]
        return id_str

    def as_dict(self):
        res = {'id': self.as_id(), 'name': self.name, 'arg': ''}
        if self.spec.extras:
            res['arg'] = self.spec.extras[0]
        return res

    @property
    def arg(self):
        return self.spec.extras[0] if self.spec.extras else None

    @property
    def specs(self):
        return self.spec.specs

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
