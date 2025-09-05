import os

import pytest

import ssg.jinja


def get_definitions_with_substitution(subs_dict=None):
    if subs_dict is None:
        subs_dict = dict()

    definitions = os.path.join(os.path.dirname(__file__), "data", "definitions.jinja")
    ssg.jinja.update_substitutions_dict(definitions, subs_dict)
    return subs_dict


def test_macro_presence():
    actual_defs = get_definitions_with_substitution()
    assert "expand_to_bar" in actual_defs
    assert actual_defs["expand_to_bar"]() == "bar"


def test_macro_expansion():
    incomplete_defs = get_definitions_with_substitution()
    assert incomplete_defs["expand_to_global_var"]() == ""

    complete_defs = get_definitions_with_substitution(dict(global_var="value"))
    assert complete_defs["expand_to_global_var"]() == "value"
