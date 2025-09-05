from ssg.ext.boolean import boolean
from ssg import requirement_specs

# We don't support ~= to avoid confusion with boolean operator NOT (~)
SPEC_SYMBOLS = ['<', '>', '=', '!', ',', '[', ']']
VERSION_SYMBOLS = ['.', '-', '_']


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
                    'evr_ver': ver_spec.evr_ver
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
    Base class for boolean algebra

    Algebra class will parse and evaluate boolean expressions,
    where operators could be any combination of "~, &, |, !, *, +, not, and, or"
    and variable symbols could contain version specifiers as described
    in PEP440 and PEP508.

    Limitations:
    - no white space is allowed inside specifier expressions;
    - ~= specifier operator is not supported.

    For example: "(oranges>=2.0.8,<=5 | fried[banana]) and !pie[apple]"
    """

    def __init__(self, symbol_cls, function_cls):
        not_cls = type('FunctionNOT', (function_cls, boolean.NOT), {})
        and_cls = type('FunctionAND', (function_cls, boolean.AND), {})
        or_cls = type('FunctionOR', (function_cls, boolean.OR), {})
        super(Algebra, self).__init__(allowed_in_token=VERSION_SYMBOLS+SPEC_SYMBOLS,
                                      Symbol_class=symbol_cls,
                                      NOT_class=not_cls, AND_class=and_cls, OR_class=or_cls)
