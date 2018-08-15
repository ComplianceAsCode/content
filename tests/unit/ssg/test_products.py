import os

import pytest

import ssg.products


def test_get_all():
    ssg_root = os.path.abspath(os.path.join(os.path.dirname(__file__), "../../.."))
    products = ssg.products.get_all(ssg_root)

    assert "fedora" in products.linux
    assert "fedora" not in products.other

    assert "rhel7" in products.linux
    assert "rhel7" not in products.other

    assert "jre" in products.other
    assert "jre" not in products.linux
