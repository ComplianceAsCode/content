import pytest

import os
import re
import ssg.build_cpe
import ssg.xml
from ssg.yaml import open_raw

ET = ssg.xml.ElementTree
DATADIR = os.path.abspath(os.path.join(os.path.dirname(__file__), "data"))


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


#############################################
# Unit tests for ProductCPEs.get_cpe() method
#############################################
#
# Note that there are 2 types of CPE definitions that differ by the source they
# come from:
# * Product CPEs, loaded from product YAML
# * Content CPEs, loaded from directory specified by the `cpes_root` key in
#   product YML, usually from the `/applicability` directory
#
# This test case test that both types are used by the ProductCPEs class and
# that both CPE types are handled equally.
def test_product_cpes():

    # CPEs are loaded from `DATADIR/product.yml` but also from
    # `DATADIR/applicability` because `DATADIR/product.yml` references the
    # `DATADIR/applicability` directory in the `cpes_root` key
    product_yaml_path = os.path.join(DATADIR, "product.yml")
    product_yaml = open_raw(product_yaml_path)
    product_yaml["product_dir"] = os.path.dirname(product_yaml_path)
    product_cpes = ssg.build_cpe.ProductCPEs(product_yaml)

    # get a product CPE by name and verify it's loaded
    # this CPE is defined in `DATADIR/product.yml`
    rhel7_cpe = product_cpes.get_cpe("rhel7")
    assert(rhel7_cpe.name == "cpe:/o:redhat:enterprise_linux:7")
    assert(rhel7_cpe.title == "Red Hat Enterprise Linux 7")
    assert(rhel7_cpe.check_id == "installed_OS_is_rhel7")
    assert(rhel7_cpe.bash_conditional == "")
    assert(rhel7_cpe.ansible_conditional == "")

    # get CPE by ID and verify it's loaded, the get_cpe method should return
    # the same object as when CPE name was used above
    rhel7_cpe_2 = product_cpes.get_cpe("cpe:/o:redhat:enterprise_linux:7")
    assert(rhel7_cpe_2.name == rhel7_cpe.name)
    assert(rhel7_cpe_2.title == rhel7_cpe.title)
    assert(rhel7_cpe_2.check_id == rhel7_cpe.check_id)
    assert(rhel7_cpe_2.bash_conditional == rhel7_cpe.bash_conditional)
    assert(rhel7_cpe_2.ansible_conditional == rhel7_cpe.ansible_conditional)

    # get a content CPE by name and verify it's loaded
    # this CPE is defined in `DATADIR/applicability/virtualization.yml`
    cpe1 = product_cpes.get_cpe("machine")
    assert(cpe1.name == "cpe:/a:machine")
    assert(cpe1.title == "Bare-metal or Virtual Machine")
    assert(cpe1.check_id == "installed_env_is_a_machine")
    assert(cpe1.ansible_conditional == "ansible_virtualization_type not in [\"docker\", \"lxc\", \"openvz\", \"podman\", \"container\"]")
    assert(cpe1.bash_conditional == "[ ! -f /.dockerenv ] && [ ! -f /run/.containerenv ]")

    # get CPE by ID and verify it's loaded, the get_cpe method should return
    # the same object as when CPE name was used above
    cpe2 = product_cpes.get_cpe("cpe:/a:machine")
    assert(cpe2.name == cpe1.name)
    assert(cpe2.title == cpe1.title)
    assert(cpe2.check_id == cpe1.check_id)
    assert(cpe2.ansible_conditional == cpe1.ansible_conditional)
    assert(cpe2.bash_conditional == cpe1.bash_conditional)
