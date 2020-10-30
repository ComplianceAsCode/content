import pytest

import ssg.utils


def test_is_applicable():
    assert ssg.utils.is_applicable('all', 'rhel7')
    assert ssg.utils.is_applicable('multi_platform_all', 'rhel7')
    assert ssg.utils.is_applicable('rhel7', 'rhel7')
    assert ssg.utils.is_applicable('multi_platform_rhel', 'rhel7')
    assert ssg.utils.is_applicable('Red Hat Enterprise Linux 7', 'rhel7')

    assert ssg.utils.is_applicable('all', 'rhosp13')
    assert ssg.utils.is_applicable('multi_platform_rhosp', 'rhosp13')
    assert ssg.utils.is_applicable('rhosp13', 'rhosp13')
    assert ssg.utils.is_applicable('Red Hat OpenStack Platform 13', 'rhosp13')
    assert not ssg.utils.is_applicable('rhel7', 'rhosp13')

    assert not ssg.utils.is_applicable('rhosp13', 'rhel7')
    assert not ssg.utils.is_applicable('fedora,multi_platform_ubuntu', 'rhel7')
    assert not ssg.utils.is_applicable('ol7', 'rhel7')
    assert not ssg.utils.is_applicable('fedora,debian9,debian10', 'rhel7')


def test_is_applicable_for_product():
    assert ssg.utils.is_applicable_for_product("multi_platform_all", "rhel7")
    assert ssg.utils.is_applicable_for_product("multi_platform_rhel", "rhel7")
    assert ssg.utils.is_applicable_for_product("multi_platform_rhel,multi_platform_ol", "rhel7")
    assert ssg.utils.is_applicable_for_product("Red Hat Enterprise Linux 7", "rhel7")
    assert not ssg.utils.is_applicable_for_product("Red Hat Enterprise Linux 7", "rhel8")
    assert not ssg.utils.is_applicable_for_product("multi_platform_ol", "rhel7")


def test_map_name():
    mn = ssg.utils.map_name

    assert mn('multi_platform_rhel') == 'Red Hat Enterprise Linux'
    assert mn('rhel') == 'Red Hat Enterprise Linux'
    assert mn('rhel7') == 'Red Hat Enterprise Linux'
    assert mn('rhosp') == 'Red Hat OpenStack Platform'
    assert mn('rhosp13') == 'Red Hat OpenStack Platform'

    with pytest.raises(RuntimeError):
        mn('not-a-platform')

    with pytest.raises(RuntimeError):
        mn('multi_platform_all')


def test_parse_name():
    pn = ssg.utils.parse_name

    n, v = pn("rhel7")
    assert n == "rhel"
    assert v == "7"

    n, v = pn("rhel")
    assert n == "rhel"
    assert not v

    n, v = pn("rhosp13")
    assert n == "rhosp"
    assert v == "13"


def test_merge_dicts():
    left = {1: 2}
    right = {"red fish": "blue fish"}
    merged_expected = {1: 2, "red fish": "blue fish"}
    merged_actual = ssg.utils.merge_dicts(left, right)

    assert merged_actual == merged_expected
    assert 1 in left
    assert "red fish" not in left
    assert "red fish" in right
    assert 1 not in right


def test_required_key():
    rk = ssg.utils.required_key
    _dict = {'something': 'some_value',
             'something_else': 'other_value'}

    assert rk(_dict, 'something') == 'some_value'
    assert rk(_dict, 'something_else') == 'other_value'

    with pytest.raises(ValueError):
        rk(_dict, 'not-in-dict')


def test_subset_dict():
    _dict = {1: 2, "red fish": "blue fish"}

    _keys = [1]
    assert ssg.utils.subset_dict(_dict, _keys) == {1: 2}
    assert _keys == [1]
    assert _dict == {1: 2, "red fish": "blue fish"}

    assert ssg.utils.subset_dict(_dict, ["red fish"]) == {"red fish": "blue fish"}
    assert ssg.utils.subset_dict(_dict, [1, "red fish"]) == _dict
    assert ssg.utils.subset_dict(_dict, []) == dict()
