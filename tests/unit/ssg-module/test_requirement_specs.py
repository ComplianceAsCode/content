import pytest

from ssg import requirement_specs


def test_parse_version_into_evr():
    v = requirement_specs._parse_version_into_evr('1.22.333-4444')
    assert v == {'epoch': None, 'version': '1.22.333', 'release': '4444'}

    v = requirement_specs._parse_version_into_evr('0')
    assert v == {'epoch': None, 'version': '0', 'release': None}

    v = requirement_specs._parse_version_into_evr('0-1')
    assert v == {'epoch': None, 'version': '0', 'release': '1'}

    # Empty version is not the same as version '0'.
    with pytest.raises(ValueError):
        v = requirement_specs._parse_version_into_evr('')

    # we do not support letters anywhere for now

    with pytest.raises(ValueError):
        v = requirement_specs._parse_version_into_evr('1.0.0-r2')
    with pytest.raises(ValueError):
        v = requirement_specs._parse_version_into_evr('b1')

    # some more tests to ensure that the regex is correct
    with pytest.raises(ValueError):
        v = requirement_specs._parse_version_into_evr('0:')
    with pytest.raises(ValueError):
        v = requirement_specs._parse_version_into_evr('-1')
    with pytest.raises(ValueError):
        v = requirement_specs._parse_version_into_evr(':')
    with pytest.raises(ValueError):
        v = requirement_specs._parse_version_into_evr('-')
