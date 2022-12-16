import pytest

from ssg import utils


def test_is_applicable():
    assert utils.is_applicable('all', 'rhel7')
    assert utils.is_applicable('multi_platform_all', 'rhel7')
    assert utils.is_applicable('rhel7', 'rhel7')
    assert utils.is_applicable('multi_platform_rhel', 'rhel7')
    assert utils.is_applicable('Red Hat Enterprise Linux 7', 'rhel7')

    assert not utils.is_applicable('fedora,multi_platform_ubuntu', 'rhel7')
    assert not utils.is_applicable('ol7', 'rhel7')
    assert not utils.is_applicable('alinux2,alinux3,anolis8,fedora,debian10,debian11,uos20',
                                       'rhel7')


def test_is_applicable_for_product():
    assert utils.is_applicable_for_product("multi_platform_all", "rhel7")
    assert utils.is_applicable_for_product("multi_platform_rhel", "rhel7")
    assert utils.is_applicable_for_product("multi_platform_rhel,multi_platform_ol", "rhel7")
    assert utils.is_applicable_for_product("Red Hat Enterprise Linux 7", "rhel7")
    assert not utils.is_applicable_for_product("Red Hat Enterprise Linux 7", "rhel8")
    assert not utils.is_applicable_for_product("multi_platform_ol", "rhel7")


def test_map_name():
    mn = utils.map_name

    assert mn('multi_platform_rhel') == 'Red Hat Enterprise Linux'
    assert mn('rhel') == 'Red Hat Enterprise Linux'
    assert mn('rhel7') == 'Red Hat Enterprise Linux'

    with pytest.raises(RuntimeError):
        mn('not-a-platform')

    with pytest.raises(RuntimeError):
        mn('multi_platform_all')


def test_parse_name():
    pn = utils.parse_name

    n, v = pn("rhel7")
    assert n == "rhel"
    assert v == "7"

    n, v = pn("rhel")
    assert n == "rhel"
    assert not v


def test_merge_dicts():
    left = {1: 2}
    right = {"red fish": "blue fish"}
    merged_expected = {1: 2, "red fish": "blue fish"}
    merged_actual = utils.merge_dicts(left, right)

    assert merged_actual == merged_expected
    assert 1 in left
    assert "red fish" not in left
    assert "red fish" in right
    assert 1 not in right


def test_required_key():
    rk = utils.required_key
    _dict = {'something': 'some_value',
             'something_else': 'other_value'}

    assert rk(_dict, 'something') == 'some_value'
    assert rk(_dict, 'something_else') == 'other_value'

    with pytest.raises(ValueError):
        rk(_dict, 'not-in-dict')


def test_subset_dict():
    _dict = {1: 2, "red fish": "blue fish"}

    _keys = [1]
    assert utils.subset_dict(_dict, _keys) == {1: 2}
    assert _keys == [1]
    assert _dict == {1: 2, "red fish": "blue fish"}

    assert utils.subset_dict(_dict, ["red fish"]) == {"red fish": "blue fish"}
    assert utils.subset_dict(_dict, [1, "red fish"]) == _dict
    assert utils.subset_dict(_dict, []) == dict()


def test_apply_formatting_on_dict_values():
    embedded_dict = {
        "nothing to replace": "test",
        "replace": "some text {arg}",
    }
    source_dict = {
        "nothing to replace": "test",
        "replace everything": "{arg}",
        "replace only part": "{arg} and some text",
        "multiple replaces": "test1 {arg} test2 {arg}",
        "integer": 42,
        "float": 3.14,
        "list": [1, "2"],
        "embedded dictionary": embedded_dict,
        "ignored key": "{arg}"
    }
    dict_with_replacements = {
        "arg": "replaced"
    }
    ignored_keys = ["ignored key"]
    result = utils.apply_formatting_on_dict_values(source_dict, dict_with_replacements, ignored_keys)
    assert result["nothing to replace"] == "test"
    assert result["replace everything"] == "replaced"
    assert result["replace only part"] == "replaced and some text"
    assert result["multiple replaces"] == "test1 replaced test2 replaced"
    assert result["integer"] == 42
    assert result["float"] == 3.14
    assert result["list"] == [1, "2"]
    assert result["ignored key"] == "{arg}"
    res_embedded_dict = result["embedded dictionary"]
    assert res_embedded_dict["nothing to replace"] == "test"
    assert res_embedded_dict["replace"] == "some text replaced"


def test_comparison_conversions():
    assert utils.comparison_to_oval('!=') == 'not equal'
    with pytest.raises(KeyError):
        assert utils.comparison_to_oval('~')

    assert utils.escape_comparison('!=') == 'ne'
    with pytest.raises(KeyError):
        assert utils.escape_comparison('~')


def test_ver_spec_evr_dict_to_str():
    v = utils.VersionSpecifier.evr_dict_to_str(
        {'epoch': '0', 'version': '1.22.333', 'release': '4444'}
    )
    assert v == '0:1.22.333-4444'

    v = utils.VersionSpecifier.evr_dict_to_str(
        {'epoch': None, 'version': '1.22.333', 'release': None},
        True
    )
    assert v == '0:1.22.333-0'

    v = utils.VersionSpecifier.evr_dict_to_str(
        {'epoch': None, 'version': '1.22.333', 'release': None},
        False
    )
    assert v == '1.22.333'

    with pytest.raises(KeyError):
        v = utils.VersionSpecifier.evr_dict_to_str({'version': '1.22.333'})


def test_ver_specs():
    evr123 = {'epoch': None, 'version': '1.2.3', 'release': None}
    evr20 = {'epoch': None, 'version': '2.0', 'release': None}

    vs_set1 = utils.VersionSpecifierSet([utils.VersionSpecifier('>=', evr123),
                                             utils.VersionSpecifier('<', evr20),
                                             utils.VersionSpecifier('<', evr20)])
    vs_set2 = utils.VersionSpecifierSet([utils.VersionSpecifier('<', evr20),
                                             utils.VersionSpecifier('>=', evr123)])

    assert vs_set1 == vs_set2
    assert vs_set1.title == vs_set2.title
    assert vs_set1.cpe_id == vs_set2.cpe_id
    assert vs_set1.oval_id == vs_set2.oval_id

    assert vs_set1.title == 'less than 2.0 and greater than or equal 1.2.3'
    assert vs_set2.title == 'less than 2.0 and greater than or equal 1.2.3'
    assert vs_set1.cpe_id == 'le:2.0:gt_or_eq:1.2.3'
    assert vs_set2.cpe_id == 'le:2.0:gt_or_eq:1.2.3'
    assert vs_set1.oval_id == 'le_2_0_gt_or_eq_1_2_3'
    assert vs_set2.oval_id == 'le_2_0_gt_or_eq_1_2_3'

    # We support only VersionSpecifier objects as members of VersionSpecifierSet
    with pytest.raises(ValueError):
        utils.VersionSpecifierSet([utils.VersionSpecifier('>=', evr123), '1.2.3'])
