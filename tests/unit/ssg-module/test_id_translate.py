import pytest

import ssg.id_translate


def test__split_namespace():
    sn = ssg.id_translate._split_namespace

    ns, n = sn("{oval}board")
    assert ns == "oval"
    assert n == "board"

    ns, n = sn("{oval#magic}board")
    assert ns == "oval"
    assert n == "board"

    ns, n = sn("nonamespace")
    assert not ns
    assert n == "nonamespace"

    ns, n = sn("{}emptynamespace")
    assert not ns
    assert n == "emptynamespace"
