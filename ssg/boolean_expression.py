"""
Common functions for Boolean Expressions
"""

from ssg.ext.boolean import boolean
from ssg import requirement_specs

# We don't support ~= to avoid confusion with boolean operator NOT (~)
SPEC_SYMBOLS = ['<', '>', '=', '!', ',', '[', ']']
VERSION_SYMBOLS = ['.', '-', '_', ":"]


class Function(boolean.Function):
    """
    Base class for boolean functions.

    This class should be subclassed and passed to the `Algebra` as `function_cls`
    to enrich expression elements with domain-specific methods.
    """
    def is_and(self):
        return isinstance(self, boolean.AND)

    def is_or(self):
        return isinstance(self, boolean.OR)

    def is_not(self):
        return isinstance(self, boolean.NOT)

    def as_id(self):
        """
        Generate a string representation of the boolean expression.

        This method constructs a unique identifier for the boolean expression by recursively
        calling `as_id` on its arguments and combining them with the appropriate boolean operator.

        Returns:
            str: A string representing the boolean expression. If the expression is a negation, it
                 returns 'not_' followed by the identifier of the negated argument. If the
                 expression is a conjunction or disjunction, it returns the identifiers of the
                 arguments joined by '_and_' or '_or_'.
        """
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
    Symbol class represents a boolean symbol with domain-specific methods.

    This class should be subclassed and passed to the `Algebra` as `symbol_cls`
    to enrich expression elements with domain-specific methods.

    Attributes:
        requirement (requirement_specs.Requirement): The requirement object associated with the symbol.
        obj (requirement_specs.Requirement): Alias for the requirement attribute.
    """
    def __init__(self, obj):
        super(Symbol, self).__init__(obj)
        self.requirement = requirement_specs.Requirement(obj)
        self.obj = self.requirement

    def __call__(self, **kwargs):
        full_name = self.name
        if self.arg:
            full_name += '[' + self.arg + ']'
        val = kwargs.get(full_name, False)
        if self.requirement.has_version_specs():
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
        if self.requirement.has_version_specs():
            id_str += '_' + self.requirement.ver_specs.oval_id
        return id_str

    def as_dict(self):
        res = {
            'id': self.as_id(),
            'name': self.name,
            'arg': self.arg,
            'ver_specs': [],
            'ver_specs_id': '',
            'ver_specs_cpe': '',
            'ver_specs_title': '',
        }

        if self.requirement.has_version_specs():
            for ver_spec in sorted(self.requirement.ver_specs):
                res['ver_specs'].append({
                    'id': ver_spec.oval_id,
                    'op': ver_spec.op,
                    'ver': ver_spec.ver,
                    'evr_op': ver_spec.evr_op,
                    'evr_ver': ver_spec.evr_ver,
                    'ev_ver': ver_spec.ev_ver
                })
            res['ver_specs_id'] = self.requirement.ver_specs.oval_id
            res['ver_specs_cpe'] = self.requirement.ver_specs.cpe_id
            res['ver_specs_title'] = self.requirement.ver_specs.title

        return res

    def has_version_specs(self):
        return self.requirement.has_version_specs()

    @property
    def arg(self):
        return self.requirement.arg or ''

    @property
    def name(self):
        return self.requirement.name

    @staticmethod
    def is_parametrized(name):
        return requirement_specs.Requirement.is_parametrized(name)

    @staticmethod
    def get_base_of_parametrized_name(name):
        return requirement_specs.Requirement.get_base_for_parametrized(name)


class Algebra(boolean.BooleanAlgebra):
    """
    Base class for boolean algebra.

    The Algebra class parses and evaluates boolean expressions, where operators
    can be any combination of "~, &, |, !, *, +, not, and, or" and variable symbols
    can contain version specifiers as described in PEP440 and PEP508.
    - No white space is allowed inside specifier expressions.
    - The ~= specifier operator is not supported.

    Limitations:
    - no white space is allowed inside specifier expressions;
    - ~= specifier operator is not supported.

    Example:
        "(oranges>=2.0.8,<=5 | fried[banana]) and !pie[apple]"

    Attributes:
        symbol_cls (class): The class used for symbols in the boolean expressions.
        function_cls (class): The class used for functions in the boolean expressions.
    """
    def __init__(self, symbol_cls, function_cls):
        not_cls = type('FunctionNOT', (function_cls, boolean.NOT), {})
        and_cls = type('FunctionAND', (function_cls, boolean.AND), {})
        or_cls = type('FunctionOR', (function_cls, boolean.OR), {})
        super(Algebra, self).__init__(allowed_in_token=VERSION_SYMBOLS+SPEC_SYMBOLS,
                                      Symbol_class=symbol_cls,
                                      NOT_class=not_cls, AND_class=and_cls, OR_class=or_cls)
