import pytest

import ssg.entities.common as common


def test_make_items_product_specific_not_overwriting_qualified_entries_with_unqualified():
    a_dict_with_a_mix_of_qualified_and_unqualified_entries = {
        "name": "Name: ?",
        "name@foo": "Name: Foo",
    }
    qualifier = "foo"

    with pytest.raises(ValueError):
        common.make_items_product_specific(a_dict_with_a_mix_of_qualified_and_unqualified_entries,
                                           qualifier, allow_overwrites=False)


def test_make_items_product_specific_for_unqualified_entry_order_dependent_behaviour_regression():
    # With this order of elements in the dictionary a qualified element would be overwritten
    # by an unqualified one if we don't take special precautions. This behaviour depends on
    # the order in which elements are emitted. Since Python 3.6 it follows the order
    # of initialization (guaranteed since 3.7). In Python 2.7 this particular set of values is kept
    # in the required order, so the test behaviour is stable in all versions that we care about.
    a_dict_with_a_mix_of_qualified_and_unqualified_entries = {
        "name@foo": "Name: Foo",
        "name": "Name: ?",
    }
    qualifier = "foo"

    normal_dict = common.make_items_product_specific(
        a_dict_with_a_mix_of_qualified_and_unqualified_entries, qualifier,
        allow_overwrites=True)
    assert normal_dict == {'name': 'Name: Foo'}
