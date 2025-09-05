import pytest

from ssg.contributors import _get_contributions_by_canonical_email
from ssg.contributors import _get_contributor_email_mapping
from ssg.contributors import _names_sorted_by_last_name


INPUT = """
    1  David Smith <dsmith@fornax.eclipse.ncsc.mil>
    170  David Smith <dsmith@eclipse.ncsc.mil>
    19  Dave Smith <dsmith@secure-innovations.net>
    2  Deric Crago abc <somebody@gmail.com>
    1  Deric Crago aaa <somebody.else@gmail.com>
    1  Aeric Erago abc <somebody.entirely.else@gmail.com>
    1  Aeric Drago abc <somebody.maybe.else@gmail.com>
    14  nobodyl <nick@null.net>
"""


@pytest.fixture()
def emails():
    return _get_contributions_by_canonical_email(INPUT)


@pytest.fixture()
def authors(emails):
    return _get_contributor_email_mapping(emails)


def test_contributions_aggregation(emails):
    assert "somebody@gmail.com" in emails
    assert "dsmith@secure-innovations.net" not in emails  # <-- Not the canonical email
    assert "nick@null.net" not in emails  # <-- emails is supposed to be ignored


def test_contributors_aggregation(authors):
    assert "Dave Smith" not in authors
    assert "David Smith" in authors


def test_name_sorting(authors):
    authors_names = list(authors.keys())
    sorted_names = _names_sorted_by_last_name(authors_names)
    assert sorted_names[0] == "Deric Crago aaa"
    assert sorted_names[1] == "Deric Crago abc"
    assert sorted_names[2] == "Aeric Drago abc"
    assert sorted_names[3] == "Aeric Erago abc"
