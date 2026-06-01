import os
import pytest
import ssg.rule_yaml

data_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), "data"))


def test_read_file_list():
    path = os.path.join(data_dir, 'ssg_rule_yaml.txt')
    contents = ssg.rule_yaml.read_file_list(path)

    assert isinstance(contents, list)
    assert len(contents) == 1
    assert contents[0] == 'testing'


class TestSortSectionKeys:
    """Tests for sort_section_keys function."""

    def test_single_line_keys_sorted(self):
        file_contents = [
            "identifiers:",
            "    cce@rhel9: CCE-90000-0",
            "    cce@rhel8: CCE-80000-0",
            "",
        ]
        result = ssg.rule_yaml.sort_section_keys(
            "test.yml", file_contents, "identifiers"
        )
        assert result == [
            "identifiers:",
            "    cce@rhel8: CCE-80000-0",
            "    cce@rhel9: CCE-90000-0",
            "",
        ]

    def test_already_sorted_unchanged(self):
        file_contents = [
            "identifiers:",
            "    cce@rhel8: CCE-80000-0",
            "    cce@rhel9: CCE-90000-0",
            "",
        ]
        result = ssg.rule_yaml.sort_section_keys(
            "test.yml", file_contents, "identifiers"
        )
        assert result == file_contents

    def test_multi_line_values_sorted(self):
        file_contents = [
            "references:",
            "    nist: CM-6,CM-6(1),",
            "        AC-2",
            "    cis@rhel9: 1.2.3",
            "",
        ]
        result = ssg.rule_yaml.sort_section_keys(
            "test.yml", file_contents, "references"
        )
        assert result == [
            "references:",
            "    cis@rhel9: 1.2.3",
            "    nist: CM-6,CM-6(1),",
            "        AC-2",
            "",
        ]

    def test_multi_line_values_multiple_continuations(self):
        file_contents = [
            "references:",
            "    zz_last: value_z",
            "    aa_first: line1,",
            "        line2,",
            "        line3",
            "",
        ]
        result = ssg.rule_yaml.sort_section_keys(
            "test.yml", file_contents, "references"
        )
        assert result == [
            "references:",
            "    aa_first: line1,",
            "        line2,",
            "        line3",
            "    zz_last: value_z",
            "",
        ]

    def test_section_not_found_returns_unchanged(self):
        file_contents = [
            "identifiers:",
            "    cce@rhel9: CCE-90000-0",
            "",
        ]
        result = ssg.rule_yaml.sort_section_keys(
            "test.yml", file_contents, "nonexistent"
        )
        assert result == file_contents

    def test_single_subkey_unchanged(self):
        file_contents = [
            "identifiers:",
            "    cce@rhel9: CCE-90000-0",
            "",
        ]
        result = ssg.rule_yaml.sort_section_keys(
            "test.yml", file_contents, "identifiers"
        )
        assert result == file_contents

    def test_empty_section_unchanged(self):
        """Section with key but no subkeys (value is None) is skipped."""
        file_contents = [
            "references:",
            "",
            "identifiers:",
            "    cce@rhel9: CCE-90000-0",
            "",
        ]
        result = ssg.rule_yaml.sort_section_keys(
            "test.yml", file_contents, "references"
        )
        assert result == file_contents

    def test_preserves_surrounding_content(self):
        file_contents = [
            "title: My Rule",
            "identifiers:",
            "    cce@rhel9: CCE-90000-0",
            "    cce@rhel8: CCE-80000-0",
            "",
            "severity: medium",
        ]
        result = ssg.rule_yaml.sort_section_keys(
            "test.yml", file_contents, "identifiers"
        )
        assert result == [
            "title: My Rule",
            "identifiers:",
            "    cce@rhel8: CCE-80000-0",
            "    cce@rhel9: CCE-90000-0",
            "",
            "severity: medium",
        ]

    def test_duplicated_key_raises(self):
        """YAML parser deduplicates keys, so we need raw lines with a key
        that the parser kept as one entry but appears twice in the text."""
        file_contents = [
            "references:",
            "    nist: CM-6",
            "    cis@rhel9: 1.2.3",
            "    nist: AC-2",
            "",
        ]
        with pytest.raises(ValueError, match="duplicated key"):
            ssg.rule_yaml.sort_section_keys(
                "test.yml", file_contents, "references"
            )

    def test_custom_sort_func(self):
        """Reverse sort should put zz_last before aa_first."""
        file_contents = [
            "references:",
            "    aa_first: val_a",
            "    zz_last: val_z",
            "",
        ]
        result = ssg.rule_yaml.sort_section_keys(
            "test.yml", file_contents, "references",
            sort_func=lambda k: k[::-1]
        )
        # Reversed keys: 'tsrif_aa' < 'tsal_zz', so aa_first still first?
        # No: reversed 'aa_first' = 'tsrif_aa', 'zz_last' = 'tsal_zz'
        # 'tsal_zz' < 'tsrif_aa', so zz_last sorts before aa_first
        assert result == [
            "references:",
            "    zz_last: val_z",
            "    aa_first: val_a",
            "",
        ]

    def test_multiple_sections(self):
        file_contents = [
            "identifiers:",
            "    cce@rhel9: CCE-90000-0",
            "    cce@rhel8: CCE-80000-0",
            "",
            "references:",
            "    nist: CM-6",
            "    cis@rhel9: 1.2.3",
            "",
        ]
        result = ssg.rule_yaml.sort_section_keys(
            "test.yml", file_contents, ["identifiers", "references"]
        )
        assert result == [
            "identifiers:",
            "    cce@rhel8: CCE-80000-0",
            "    cce@rhel9: CCE-90000-0",
            "",
            "references:",
            "    cis@rhel9: 1.2.3",
            "    nist: CM-6",
            "",
        ]

    def test_multi_line_values_both_keys(self):
        """Both keys have multi-line values and need reordering."""
        file_contents = [
            "references:",
            "    zz_ref: val1,",
            "        val2",
            "    aa_ref: val3,",
            "        val4,",
            "        val5",
            "",
        ]
        result = ssg.rule_yaml.sort_section_keys(
            "test.yml", file_contents, "references"
        )
        assert result == [
            "references:",
            "    aa_ref: val3,",
            "        val4,",
            "        val5",
            "    zz_ref: val1,",
            "        val2",
            "",
        ]
