import pytest

from ssg import boolean_expression


@pytest.fixture
def algebra():
    return boolean_expression.Algebra(symbol_cls=boolean_expression.Symbol, function_cls=boolean_expression.Function)


@pytest.fixture
def expression1(algebra):
    return algebra.parse(u'(oranges==2.0 | banana) and not ~apple + !pie', simplify=True)


def test_expression1_id(expression1):
    assert str(expression1.as_id()) == 'apple_and_banana_or_oranges_eq_2_0_or_not_pie'
    assert str(expression1.as_uuid()) == '314ed18f-90e5-5d59-9842-cc64fdd2e520'
    assert str(expression1.simplify()) == '(apple&(banana|oranges==2.0))|~pie'


def test_expression1_cnf_dnf(algebra, expression1):
    assert str(algebra.cnf(expression1)) == '(apple|~pie)&(banana|oranges==2.0|~pie)'
    assert str(algebra.dnf(expression1)) == '(apple&banana)|(apple&oranges==2.0)|~pie'


def test_dynamic_algebra():
    alg = boolean_expression.Algebra(symbol_cls=boolean_expression.Symbol, function_cls=boolean_expression.Function)
    exp = alg.parse('not banana and not apple or anything')
    assert str(exp) == '(~banana&~apple)|anything'
    assert str(exp.simplify()) == 'anything|(~apple&~banana)'


def test_underscores_and_dashes_in_name(algebra):
    exp = algebra.parse(u'not_s390x_arch and dashed-name')
    assert exp(**{'not_s390x_arch': True, 'dashed-name': True})


def test_evaluate_simple_boolean_ops(algebra):
    exp = algebra.parse(u'(oranges | banana) and not not apple or !pie')
    assert exp(**{'oranges': True, 'apple': True, 'pie': True})
    assert not exp(**{'oranges': True, 'apple': False, 'pie': True})


def test_args(algebra):
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


def test_evaluate_full_version_ops(algebra):
    exp = algebra.parse(u'oranges==1:2.3.0-1')
    assert exp(**{'oranges': '1:2.3-1'})
    exp = algebra.parse(u'oranges>=2,<3')
    assert exp(**{'oranges': '2.1'})
    assert not exp(**{'oranges': '3.0'})


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


def test_complex_versions(algebra):
    exp = algebra.parse(u'oranges[fresh]==1.0~p1-10')
    assert exp(**{'oranges[fresh]': '1.0~p1-10'})
    exp = algebra.parse(u'oranges[fresh]>1.0~BETA2')
    assert exp(**{'oranges[fresh]': '1.1'})
    assert exp(**{'oranges[fresh]': '1.0'})
    exp = algebra.parse(u'oranges[fresh]>=1.0^20210203gbbbccc0-1')
    assert exp(**{'oranges[fresh]': '1.0.1'})
