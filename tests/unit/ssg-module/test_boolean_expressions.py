import pytest

from ssg import boolean_expression


@pytest.fixture
def algebra():
    return boolean_expression.Algebra(
        symbol_cls=boolean_expression.Symbol, function_cls=boolean_expression.Function)


@pytest.fixture
def expression1(algebra):
    return algebra.parse(u'(oranges | banana) and not ~apple + !pie', simplify=True)


def test_dynamic_algebra():
    alg = boolean_expression.Algebra(
        symbol_cls=boolean_expression.Symbol, function_cls=boolean_expression.Function)
    exp = alg.parse('not banana and not apple or anything')
    assert str(exp) == '(~banana&~apple)|anything'
    assert str(exp.simplify()) == 'anything|(~apple&~banana)'


def test_compare_expressions(algebra):
    exp1 = algebra.parse('banana1 and apple1')
    exp2 = algebra.parse('apple1 and banana1')
    assert exp1 == exp2


def test_cnf(algebra, expression1):
    assert str(algebra.cnf(expression1)) == '(apple|~pie)&(banana|oranges|~pie)'


def test_dnf(algebra, expression1):
    assert str(algebra.dnf(expression1)) == '(apple&banana)|(apple&oranges)|~pie'


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


def test_args_non_versioned(algebra):
    exp = algebra.parse(u'oranges[aaa] | oranges[bbb]')
    assert exp(**{'oranges[aaa]': True, 'oranges[bbb]': True})
    assert not exp(**{'oranges[zzz]': True})
    assert not exp(**{'oranges': True})


def test_args_and_version(algebra):
    exp = algebra.parse(u'oranges[aaa] & oranges[bbb]>=2')
    assert exp(**{'oranges[aaa]': True, 'oranges[bbb]': '2'})
    assert not exp(**{'oranges[aaa]': True, 'oranges[bbb]': '1'})
    assert not exp(**{'oranges[zzz]': True})
    assert not exp(**{'oranges': True})
    assert not exp(**{'oranges[bbb,zzz]': True})


def test_evaluate_simple_version_ops(algebra):
    exp = algebra.parse(u'oranges==2')
    assert exp(**{'oranges': '2'})
    assert exp(**{'oranges': '2.0'})
    assert exp(**{'oranges': '2.0.0'})
    assert not exp(**{'oranges': '2.0.1'})
    assert not exp(**{'oranges': '3.0'})
    assert not exp(**{'oranges': True})
    assert not exp(**{'oranges': 2})
    assert not exp(**{'oranges': 2.0})


def test_evaluate_advanced_version_ops(algebra):
    exp = algebra.parse(u'oranges>=1.0,<3.0 and oranges!=2.6')
    assert exp(**{'oranges': '2'})
    assert exp(**{'oranges': '2.9'})
    assert exp(**{'oranges': '2.0.1'})
    assert exp(**{'oranges': '2.9.0-1'})
    assert not exp(**{'oranges': '3.0'})
    assert not exp(**{'oranges': '0.9.999'})
    assert not exp(**{'oranges': '2.6.0'})


