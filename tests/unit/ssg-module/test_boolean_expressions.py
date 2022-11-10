import pytest

from ssg import boolean_expression
from xml.dom import expatbuilder


class PlatformFunction(boolean_expression.Function):
    def as_cpe_lang_xml(self):
        return '<cpe-lang:logical-test negate="' + ('true' if self.is_not() else 'false') + \
               '" operator="' + ('OR' if self.is_or() else 'AND') + '">' + \
               ''.join([arg.as_cpe_lang_xml() for arg in self.args]) + "</cpe-lang:logical-test>"


class PlatformSymbol(boolean_expression.Symbol):
    def as_cpe_lang_xml(self):
        return '<cpe-lang:fact-ref name="cpe:/a:' + self.name + ':' + ':'.join([v for (op, v) in self.version_definitions]) + '"/>'


class PlatformAlgebra(boolean_expression.Algebra):
    def __init__(self):
        super(PlatformAlgebra, self).__init__(symbol_cls=PlatformSymbol, function_cls=PlatformFunction)

    @staticmethod
    def as_cpe_lang_xml(expr):
        s = '<cpe-lang:platform id="' + expr.as_id() + '">' + expr.as_cpe_lang_xml() + '</cpe-lang:platform>'
        # A primitive but simple way to pretty-print an XML string
        return expatbuilder.parseString(s, False).toprettyxml()


@pytest.fixture
def algebra():
    return PlatformAlgebra()


@pytest.fixture
def expression1(algebra):
    return algebra.parse(u'(oranges==2.0 | banana) and not ~apple + !pie', simplify=True)


def test_dyn():
    alg = boolean_expression.Algebra(symbol_cls=PlatformSymbol, function_cls=PlatformFunction)
    exp = alg.parse('not banana and not apple or anything')
    assert str(exp) == '(~banana&~apple)|anything'
    assert str(exp.simplify()) == 'anything|(~apple&~banana)'


def test_id(expression1):
    assert str(expression1.as_id()) == 'apple_and_banana_or_oranges_eq_2.0_or_not_pie'


def test_cnf(algebra, expression1):
    assert str(algebra.cnf(expression1)) == '(apple|~pie)&(banana|oranges==2.0|~pie)'


def test_dnf(algebra, expression1):
    assert str(algebra.dnf(expression1)) == '(apple&banana)|(apple&oranges==2.0)|~pie'


def test_as_cpe_xml(algebra, expression1):
    xml = algebra.as_cpe_lang_xml(algebra.dnf(expression1))
    assert xml == """<?xml version="1.0" ?>
<cpe-lang:platform id="apple_and_banana_or_apple_and_oranges_eq_2.0_or_not_pie">
\t<cpe-lang:logical-test negate="false" operator="OR">
\t\t<cpe-lang:logical-test negate="false" operator="AND">
\t\t\t<cpe-lang:fact-ref name="cpe:/a:apple:"/>
\t\t\t<cpe-lang:fact-ref name="cpe:/a:banana:"/>
\t\t</cpe-lang:logical-test>
\t\t<cpe-lang:logical-test negate="false" operator="AND">
\t\t\t<cpe-lang:fact-ref name="cpe:/a:apple:"/>
\t\t\t<cpe-lang:fact-ref name="cpe:/a:oranges:2.0"/>
\t\t</cpe-lang:logical-test>
\t\t<cpe-lang:logical-test negate="true" operator="AND">
\t\t\t<cpe-lang:fact-ref name="cpe:/a:pie:"/>
\t\t</cpe-lang:logical-test>
\t</cpe-lang:logical-test>
</cpe-lang:platform>
"""


def test_underscores_and_dashes_in_name(algebra):
    exp = algebra.parse(u'not_s390x_arch and dashed-name')
    assert exp(**{'not_s390x_arch': True, 'dashed-name': True})

def test_expression_with_parameter(algebra):
    exp = algebra.parse(u'package[test] and os_release[rhel]')
    assert exp(**{"package[test]": True, "os_release[rhel]": True})



def test_evaluate_simple_boolean_ops(algebra):
    exp = algebra.parse(u'(oranges | banana) and not not apple or !pie')
    assert exp(**{'oranges': True, 'apple': True, 'pie': True})
    assert not exp(**{'oranges': True, 'apple': False, 'pie': True})


def test_evaluate_simple_version_ops(algebra):
    exp = algebra.parse(u'oranges==2')
    assert exp(**{'oranges': '2'})
    assert exp(**{'oranges': '2.0'})
    assert exp(**{'oranges': '2.0.0'})
    assert not exp(**{'oranges': '2.0.1'})
    assert not exp(**{'oranges': '3.0'})
    assert not exp(**{'oranges': True})


def test_evaluate_advanced_version_ops(algebra):
    exp = algebra.parse(u'oranges>=1.0,<3.0 and oranges!=2.6')
    assert exp(**{'oranges': '2'})
    assert exp(**{'oranges': '2.9'})
    assert exp(**{'oranges': '2.0.1'})
    assert exp(**{'oranges': '2.9.0-rc'})
    assert not exp(**{'oranges': '3.0'})
    assert not exp(**{'oranges': '0.9.999'})
    assert not exp(**{'oranges': '0.9.999_beta_2'})
    assert not exp(**{'oranges': '2.6.0'})

def test_as_id(algebra):
    exp1 = algebra.parse(u'package')
    exp2 = algebra.parse(u'package[test]')
    assert exp1.as_id() == "package"
    assert exp2.as_id() == "package_test"

def test_as_dict(algebra):
    exp1 = algebra.parse(u'package')
    exp1_dict = {
        "arg": "",
        "id": "package",
        "name": "package"
    }
    exp2 = algebra.parse(u'package[test]')
    exp2_dict = {
        "arg": "test",
        "id": "package_test",
        "name": "package"
    }
    assert exp1.as_dict() == exp1_dict
    assert exp2.as_dict() == exp2_dict
