import pytest

import os
import re
import ssg.build_cpe
import ssg.xml

ET = ssg.xml.ElementTree


def test_extract_element():
    obj = """<?xml version="1.0"?>
    <variables>
        <var>
            <subelement>
                <random id="test">This</random>
            </subelement>
        </var>
        <var>
            <subelement>
                <random random="not-me">That</random>
            </subelement>
        </var>
    </variables>
    """
    tree = ET.fromstring(obj)

    assert ssg.build_cpe.extract_subelement(tree, 'id') == 'test'
    assert ssg.build_cpe.extract_subelement(tree, 'random') == 'not-me'
    assert ssg.build_cpe.extract_subelement(tree, 'missing') is None
    assert ssg.build_cpe.extract_subelement(tree, 'subelement') is None


def test_extract_env_obj():
    local_var_text = """
    <var>
        <subelement>
            <random object_ref="magical">elements</random>
        </subelement>
    </var>
    """
    local_var = ET.fromstring(local_var_text)

    local_var_missing_text = """
    <var>
        <subelement>
            <random object_ref="nothing">here</random>
        </subelement>
    </var>
    """
    local_var_missing = ET.fromstring(local_var_missing_text)

    objects_text = """
    <objects>
        <object id="something">something</object>
        <object id="magical">magical</object>
        <object id="here">here</object>
    </objects>
    """
    objects = ET.fromstring(objects_text)

    present = ssg.build_cpe.extract_env_obj(objects, local_var)
    assert present is not None
    assert present.text == 'magical'

    missing = ssg.build_cpe.extract_env_obj(objects, local_var_missing)
    assert missing is None


def test_extract_referred_nodes():
    tree_with_refs_text = """
    <references>
        <reference object_ref="something_borrowed" />
        <reference object_ref="something_missing" />
    </references>
    """
    tree_with_refs = ET.fromstring(tree_with_refs_text)

    tree_with_ids_text = """
    <objects>
        <object id="something_old">Brno</object>
        <object id="something_new">Boston</object>
        <object id="something_borrowed">Source Code</object>
        <object id="something_blue">Fedora</object>
    </objects>
    """
    tree_with_ids = ET.fromstring(tree_with_ids_text)

    results = ssg.build_cpe.extract_referred_nodes(tree_with_refs, tree_with_ids, 'object_ref')

    assert len(results) == 1
    assert results[0].text == 'Source Code'
