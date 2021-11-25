from .ext.boolean import boolean
import pkg_resources
import re


# We don't support ~= to avoid confusion with boolean operator NOT (~)
SPECIFIER_SYMBOLS = ['<', '>', '=', '!', ',']

VERSION_SYMBOLS = ['.', '-', '_', '*']

SPECIFIER_OP_ID_TRANSLATION = {
    '==': 'eq',
    '!=': 'ne',
    '>': 'gt',
    '<': 'le',
    '>=': 'gt_or_eq',
    '<=': 'le_or_eq',
}

# monkeypatch pkg_resources.safe_name function to keep underscores in tact
# it is overcoming this issue: https://github.com/pypa/setuptools/issues/2522
def safe_name(name):
    return re.sub('[^A-Za-z0-9_.]+', '-', name)

pkg_resources.safe_name = safe_name

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
        val = kwargs.get(self.spec.key, False)
        if len(self.spec.specs):
            if type(val) is str:
                return val in self.spec
            return False
        return bool(val)

    def __lt__(self, other):
        return self.as_id() < other.as_id()

    def as_id(self):
        name = self.spec.key
        for (op, ver) in self.spec.specs:
            name += '_{0}_{1}'.format(SPECIFIER_OP_ID_TRANSLATION.get(op, 'unknown_spec_op'), ver)
        return name

    @property
    def name(self):
        return self.spec.key

    @property
    def specs(self):
        return self.spec.specs


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
        super(Algebra, self).__init__(allowed_in_token=VERSION_SYMBOLS+SPECIFIER_SYMBOLS,
                                      Symbol_class=symbol_cls,
                                      NOT_class=not_cls, AND_class=and_cls, OR_class=or_cls)
