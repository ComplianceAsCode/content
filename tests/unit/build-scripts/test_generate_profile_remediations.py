import collections
import os
import sys
import xml.etree.ElementTree as ET

import pytest

sys.path.insert(
    0, os.path.join(os.path.dirname(__file__), "..", "..", "..", "build-scripts")
)
import generate_profile_remediations as gpr

XCCDF_NS = "http://checklists.nist.gov/xccdf/1.2"
DS_NS = "http://scap.nist.gov/schema/scap/source/1.2"
OSCAP_PROFILE = "xccdf_org.ssgproject.content_profile_"
OSCAP_RULE = "xccdf_org.ssgproject.content_rule_"
BASH_SYSTEM = "urn:xccdf:fix:script:sh"
ANSIBLE_SYSTEM = "urn:xccdf:fix:script:ansible"
HUMMINGBIRD_SYSTEM = "urn:xccdf:fix:script:hummingbird"


def _x(tag):
    """Wrap a tag name with the XCCDF namespace."""
    return "{%s}%s" % (XCCDF_NS, tag)


# ---------------------------------------------------------------------------
# Tests for comment()
# ---------------------------------------------------------------------------

def test_comment_single_line():
    assert gpr.comment("hello") == "# hello\n"


def test_comment_multi_line():
    result = gpr.comment("line1\nline2")
    assert result == "# line1\n# line2\n"


def test_comment_skips_blank_lines():
    result = gpr.comment("line1\n\nline2\n")
    assert result == "# line1\n# line2\n"


def test_comment_empty_string():
    assert gpr.comment("") == ""


# ---------------------------------------------------------------------------
# Tests for indent()
# ---------------------------------------------------------------------------

def test_indent_level_zero():
    result = gpr.indent("hello\nworld\n", 0)
    assert result == "hello\nworld\n"


def test_indent_level_four():
    result = gpr.indent("a\nb\n", 4)
    assert result == "    a\n    b\n"


def test_indent_multi_line():
    result = gpr.indent("x\ny\nz\n", 2)
    assert result == "  x\n  y\n  z\n"


# ---------------------------------------------------------------------------
# Tests for extract_ansible_vars()
# ---------------------------------------------------------------------------

def test_extract_ansible_vars_match():
    snippet = (
        "- name: XCCDF Value some_val # promote to variable\n"
        "  set_fact:\n"
        "    my_var: !!str my_value\n"
        "  tags:\n"
        "    - always\n"
    )
    result = gpr.extract_ansible_vars(snippet)
    assert result == collections.OrderedDict([("my_var", "my_value")])


def test_extract_ansible_vars_multiple():
    snippet = (
        "- name: XCCDF Value val1 # promote to variable\n"
        "  set_fact:\n"
        "    var_a: !!str 10\n"
        "  tags:\n"
        "    - always\n"
        "some task here\n"
        "- name: XCCDF Value val2 # promote to variable\n"
        "  set_fact:\n"
        "    var_b: !!str 20\n"
        "  tags:\n"
        "    - always\n"
    )
    result = gpr.extract_ansible_vars(snippet)
    assert list(result.keys()) == ["var_a", "var_b"]
    assert result["var_a"] == "10"
    assert result["var_b"] == "20"


def test_extract_ansible_vars_no_match():
    result = gpr.extract_ansible_vars("just some text")
    assert result == collections.OrderedDict()


# ---------------------------------------------------------------------------
# Tests for ansible_vars_to_string()
# ---------------------------------------------------------------------------

def test_ansible_vars_to_string():
    variables = collections.OrderedDict([("var1", "val1"), ("var2", "val2")])
    result = gpr.ansible_vars_to_string(variables)
    assert result == "    var1: val1\n    var2: val2\n"


def test_ansible_vars_to_string_empty():
    assert gpr.ansible_vars_to_string({}) == ""


# ---------------------------------------------------------------------------
# Tests for ansible_tasks_to_string()
# ---------------------------------------------------------------------------

def test_ansible_tasks_to_string():
    tasks = ["task1", "task2", "task3"]
    result = gpr.ansible_tasks_to_string(tasks)
    assert "task1" in result
    assert "task2" in result
    assert "task3" in result


# ---------------------------------------------------------------------------
# Tests for get_selected_rules()
# ---------------------------------------------------------------------------

def test_get_selected_rules_basic():
    rule_id = OSCAP_RULE + "test_rule"
    xml = (
        '<Profile xmlns="%s">'
        '<select idref="%s" selected="true"/>'
        '<select idref="%s" selected="false"/>'
        '</Profile>' % (XCCDF_NS, rule_id, OSCAP_RULE + "other_rule")
    )
    profile = ET.fromstring(xml)
    result = gpr.get_selected_rules(profile)
    assert result == {rule_id}


def test_get_selected_rules_filters_non_rules():
    xml = (
        '<Profile xmlns="%s">'
        '<select idref="not_a_rule" selected="true"/>'
        '<select idref="%s" selected="true"/>'
        '</Profile>' % (XCCDF_NS, OSCAP_RULE + "real_rule")
    )
    profile = ET.fromstring(xml)
    result = gpr.get_selected_rules(profile)
    assert result == {OSCAP_RULE + "real_rule"}


def test_get_selected_rules_empty_profile():
    xml = '<Profile xmlns="%s"/>' % XCCDF_NS
    profile = ET.fromstring(xml)
    assert gpr.get_selected_rules(profile) == set()


# ---------------------------------------------------------------------------
# Tests for get_value_refinenements()
# ---------------------------------------------------------------------------

def test_get_value_refinements_basic():
    xml = (
        '<Profile xmlns="%s">'
        '<refine-value idref="val1" selector="sel1"/>'
        '<refine-value idref="val2" selector="sel2"/>'
        '</Profile>' % XCCDF_NS
    )
    profile = ET.fromstring(xml)
    result = gpr.get_value_refinenements(profile)
    assert result == {"val1": "sel1", "val2": "sel2"}


def test_get_value_refinements_empty():
    xml = '<Profile xmlns="%s"/>' % XCCDF_NS
    profile = ET.fromstring(xml)
    assert gpr.get_value_refinenements(profile) == {}


# ---------------------------------------------------------------------------
# Tests for get_remediation()
# ---------------------------------------------------------------------------

def test_get_remediation_matching_system():
    xml = (
        '<Rule xmlns="%s">'
        '<fix system="%s">echo fix</fix>'
        '</Rule>' % (XCCDF_NS, BASH_SYSTEM)
    )
    rule = ET.fromstring(xml)
    result = gpr.get_remediation(rule, BASH_SYSTEM)
    assert result is not None
    assert result.text == "echo fix"


def test_get_remediation_non_matching_system():
    xml = (
        '<Rule xmlns="%s">'
        '<fix system="%s">echo fix</fix>'
        '</Rule>' % (XCCDF_NS, BASH_SYSTEM)
    )
    rule = ET.fromstring(xml)
    assert gpr.get_remediation(rule, ANSIBLE_SYSTEM) is None


def test_get_remediation_no_fix():
    xml = '<Rule xmlns="%s"/>' % XCCDF_NS
    rule = ET.fromstring(xml)
    assert gpr.get_remediation(rule, BASH_SYSTEM) is None


# ---------------------------------------------------------------------------
# Tests for get_variable_values()
# ---------------------------------------------------------------------------

def test_get_variable_values_with_selectors():
    xml = (
        '<Value xmlns="%s">'
        '<value selector="low">10</value>'
        '<value selector="high">100</value>'
        '</Value>' % XCCDF_NS
    )
    variable = ET.fromstring(xml)
    result = gpr.get_variable_values(variable)
    assert result == {"low": "10", "high": "100"}


def test_get_variable_values_default_selector():
    xml = (
        '<Value xmlns="%s">'
        '<value>42</value>'
        '</Value>' % XCCDF_NS
    )
    variable = ET.fromstring(xml)
    result = gpr.get_variable_values(variable)
    assert result[gpr.DEFAULT_SELECTOR] == "42"


def test_get_variable_values_empty_text():
    xml = (
        '<Value xmlns="%s">'
        '<value selector="empty"/>'
        '</Value>' % XCCDF_NS
    )
    variable = ET.fromstring(xml)
    result = gpr.get_variable_values(variable)
    # When value.text is None, the code sets values[selector] = ""
    assert "empty" in result
    assert result["empty"] == ""


# ---------------------------------------------------------------------------
# Tests for get_all_variables()
# ---------------------------------------------------------------------------

def test_get_all_variables():
    xml = (
        '<Benchmark xmlns="%s">'
        '<Value id="var1"><value>10</value></Value>'
        '<Value id="var2"><value selector="s1">20</value></Value>'
        '</Benchmark>' % XCCDF_NS
    )
    benchmark = ET.fromstring(xml)
    result = gpr.get_all_variables(benchmark)
    assert "var1" in result
    assert "var2" in result
    assert result["var1"][gpr.DEFAULT_SELECTOR] == "10"
    assert result["var2"]["s1"] == "20"


# ---------------------------------------------------------------------------
# Tests for expand_variables()
# ---------------------------------------------------------------------------

def test_expand_variables_no_sub_elements():
    xml = '<fix xmlns="%s" system="%s">echo hello</fix>' % (XCCDF_NS, BASH_SYSTEM)
    fix_el = ET.fromstring(xml)
    result = gpr.expand_variables(fix_el, {}, {})
    assert result == "echo hello"


def test_expand_variables_with_sub_and_matching_selector():
    xml = (
        '<fix xmlns="%s" system="%s">'
        'value='
        '<sub idref="var1"/> done'
        '</fix>' % (XCCDF_NS, BASH_SYSTEM)
    )
    fix_el = ET.fromstring(xml)
    variables = {"var1": {"sel1": "42"}}
    refinements = {"var1": "sel1"}
    result = gpr.expand_variables(fix_el, refinements, variables)
    assert result == "value=42 done"


def test_expand_variables_fallback_to_first_value():
    xml = (
        '<fix xmlns="%s" system="%s">'
        'x='
        '<sub idref="var1"/> end'
        '</fix>' % (XCCDF_NS, BASH_SYSTEM)
    )
    fix_el = ET.fromstring(xml)
    variables = {"var1": {"other": "99"}}
    refinements = {}
    result = gpr.expand_variables(fix_el, refinements, variables)
    assert result == "x=99 end"


def test_expand_variables_default_selector_returns_none():
    xml = (
        '<fix xmlns="%s" system="%s">'
        'x='
        '<sub idref="var1"/>'
        '</fix>' % (XCCDF_NS, BASH_SYSTEM)
    )
    fix_el = ET.fromstring(xml)
    variables = {"var1": {"whatever": "1"}}
    refinements = {"var1": "default"}
    result = gpr.expand_variables(fix_el, refinements, variables)
    assert result is None


# ---------------------------------------------------------------------------
# Minimal data stream XML for ScriptGenerator tests
# ---------------------------------------------------------------------------

MINIMAL_DS_TEMPLATE = """\
<data-stream-collection xmlns="{ds_ns}">
  <component>
    <Benchmark xmlns="{xccdf_ns}" id="test_benchmark">
      <version>1.0</version>
      <Profile id="{profile_id}">
        <title>Test Profile</title>
        <description>A test profile description.</description>
        <select idref="{rule_id}" selected="true"/>
        {refine_values}
      </Profile>
      <Value id="{value_id}">
        <value selector="sel1">42</value>
        <value>default_val</value>
      </Value>
      <Rule id="{rule_id}">
        <fix system="{bash_system}">echo bash_fix</fix>
        <fix system="{ansible_system}">- name: test task
  debug:
    msg: hello</fix>
        <fix system="{hummingbird_system}">echo hummingbird_fix</fix>
      </Rule>
    </Benchmark>
  </component>
</data-stream-collection>
"""

RULE_ID = OSCAP_RULE + "test_rule"
PROFILE_ID = OSCAP_PROFILE + "test_profile"
VALUE_ID = "xccdf_org.ssgproject.content_value_test_var"


@pytest.fixture
def minimal_ds_path(tmp_path):
    ds_content = MINIMAL_DS_TEMPLATE.format(
        ds_ns=DS_NS,
        xccdf_ns=XCCDF_NS,
        profile_id=PROFILE_ID,
        rule_id=RULE_ID,
        value_id=VALUE_ID,
        bash_system=BASH_SYSTEM,
        ansible_system=ANSIBLE_SYSTEM,
        hummingbird_system=HUMMINGBIRD_SYSTEM,
        refine_values="",
    )
    ds_file = tmp_path / "ssg-test-ds.xml"
    ds_file.write_text(ds_content)
    return str(ds_file)


@pytest.fixture
def ds_path_with_refinement(tmp_path):
    refine = '<refine-value idref="%s" selector="sel1"/>' % VALUE_ID
    ds_content = MINIMAL_DS_TEMPLATE.format(
        ds_ns=DS_NS,
        xccdf_ns=XCCDF_NS,
        profile_id=PROFILE_ID,
        rule_id=RULE_ID,
        value_id=VALUE_ID,
        bash_system=BASH_SYSTEM,
        ansible_system=ANSIBLE_SYSTEM,
        hummingbird_system=HUMMINGBIRD_SYSTEM,
        refine_values=refine,
    )
    ds_file = tmp_path / "ssg-test-ds.xml"
    ds_file.write_text(ds_content)
    return str(ds_file)


def _make_generator(ds_path, tmp_path, language="bash"):
    output_dir = str(tmp_path / "output")
    os.makedirs(output_dir, exist_ok=True)
    return gpr.ScriptGenerator(language, "test_product", ds_path, output_dir)


# ---------------------------------------------------------------------------
# Tests for ScriptGenerator.get_output_file_path()
# ---------------------------------------------------------------------------

def test_get_output_file_path_bash(minimal_ds_path, tmp_path):
    sg = _make_generator(minimal_ds_path, tmp_path, "bash")
    profile_el = ET.fromstring(
        '<Profile xmlns="%s" id="%s"/>' % (XCCDF_NS, PROFILE_ID)
    )
    path = sg.get_output_file_path(profile_el)
    assert path.endswith("test_product-script-test_profile.sh")


def test_get_output_file_path_ansible(minimal_ds_path, tmp_path):
    sg = _make_generator(minimal_ds_path, tmp_path, "ansible")
    profile_el = ET.fromstring(
        '<Profile xmlns="%s" id="%s"/>' % (XCCDF_NS, PROFILE_ID)
    )
    path = sg.get_output_file_path(profile_el)
    assert path.endswith("test_product-playbook-test_profile.yml")


def test_get_output_file_path_hummingbird(minimal_ds_path, tmp_path):
    sg = _make_generator(minimal_ds_path, tmp_path, "hummingbird")
    profile_el = ET.fromstring(
        '<Profile xmlns="%s" id="%s"/>' % (XCCDF_NS, PROFILE_ID)
    )
    path = sg.get_output_file_path(profile_el)
    assert path.endswith("test_product-script-test_profile.sh")


# ---------------------------------------------------------------------------
# Tests for ScriptGenerator.create_header()
# ---------------------------------------------------------------------------

def _make_profile_el():
    xml = (
        '<Profile xmlns="%s" id="%s">'
        '<title>My Title</title>'
        '<description>My description.</description>'
        '</Profile>' % (XCCDF_NS, PROFILE_ID)
    )
    return ET.fromstring(xml)


def test_create_header_bash(minimal_ds_path, tmp_path):
    sg = _make_generator(minimal_ds_path, tmp_path, "bash")
    header = sg.create_header(_make_profile_el())
    assert header.startswith("#!/usr/bin/env bash\n")
    assert "Bash Remediation Script" in header
    assert "My Title" in header
    assert PROFILE_ID in header
    assert "oscap xccdf generate fix" in header


def test_create_header_ansible(minimal_ds_path, tmp_path):
    sg = _make_generator(minimal_ds_path, tmp_path, "ansible")
    header = sg.create_header(_make_profile_el())
    assert header.startswith("---\n")
    assert "Ansible Playbook" in header
    assert "ansible-playbook" in header


def test_create_header_hummingbird(minimal_ds_path, tmp_path):
    sg = _make_generator(minimal_ds_path, tmp_path, "hummingbird")
    header = sg.create_header(_make_profile_el())
    assert header.startswith("#!/usr/bin/env bash\n")
    assert "Hummingbird" in header
    assert "RUN remediation-script.sh" in header


# ---------------------------------------------------------------------------
# Tests for ScriptGenerator.generate_bash_rule_remediation()
# ---------------------------------------------------------------------------

def test_generate_bash_rule_remediation_with_fix(minimal_ds_path, tmp_path):
    sg = _make_generator(minimal_ds_path, tmp_path, "bash")
    output = sg.generate_bash_rule_remediation(RULE_ID, (1, 5), {})
    assert "BEGIN fix" in output
    assert "1 / 5" in output
    assert RULE_ID in output
    assert "echo bash_fix" in output
    assert "END fix" in output


def test_generate_bash_rule_remediation_missing_fix(minimal_ds_path, tmp_path):
    sg = _make_generator(minimal_ds_path, tmp_path, "bash")
    fake_rule = OSCAP_RULE + "nonexistent"
    sg.remediations[fake_rule] = None
    output = sg.generate_bash_rule_remediation(fake_rule, (1, 1), {})
    assert "FIX FOR THIS RULE" in output
    assert "IS MISSING" in output


# ---------------------------------------------------------------------------
# Tests for ScriptGenerator.generate_hummingbird_rule_remediation()
# ---------------------------------------------------------------------------

def test_generate_hummingbird_rule_remediation_with_fix(minimal_ds_path, tmp_path):
    sg = _make_generator(minimal_ds_path, tmp_path, "hummingbird")
    output = sg.generate_hummingbird_rule_remediation(RULE_ID, {})
    assert "BEGIN fix" in output
    assert "echo hummingbird_fix" in output
    assert "END fix" in output


def test_generate_hummingbird_rule_remediation_no_fix(minimal_ds_path, tmp_path):
    sg = _make_generator(minimal_ds_path, tmp_path, "hummingbird")
    fake_rule = OSCAP_RULE + "nonexistent"
    sg.remediations[fake_rule] = None
    output = sg.generate_hummingbird_rule_remediation(fake_rule, {})
    assert output == ""


# ---------------------------------------------------------------------------
# Tests for ScriptGenerator.generate_ansible_rule_remediation()
# ---------------------------------------------------------------------------

def test_generate_ansible_rule_remediation_with_fix(minimal_ds_path, tmp_path):
    sg = _make_generator(minimal_ds_path, tmp_path, "ansible")
    fix_el = sg.remediations[RULE_ID]
    rule_vars, tasks = sg.generate_ansible_rule_remediation(fix_el, {})
    assert isinstance(rule_vars, dict)
    assert isinstance(tasks, list)


def test_generate_ansible_rule_remediation_no_fix(minimal_ds_path, tmp_path):
    sg = _make_generator(minimal_ds_path, tmp_path, "ansible")
    rule_vars, tasks = sg.generate_ansible_rule_remediation(None, {})
    assert rule_vars == {}
    assert tasks == []


# ---------------------------------------------------------------------------
# Tests for ScriptGenerator.create_output_linear()
# ---------------------------------------------------------------------------

def test_create_output_linear_bash(minimal_ds_path, tmp_path):
    sg = _make_generator(minimal_ds_path, tmp_path, "bash")
    benchmark_xpath = "./{%s}component/{%s}Benchmark" % (DS_NS, XCCDF_NS)
    profile_xpath = benchmark_xpath + "/{%s}Profile" % XCCDF_NS
    profile = sg.ds.find(profile_xpath)
    output = sg.create_output_linear(profile)
    assert "#!/usr/bin/env bash" in output
    assert "echo bash_fix" in output
    assert "NEWROOT" not in output


def test_create_output_linear_hummingbird(minimal_ds_path, tmp_path):
    sg = _make_generator(minimal_ds_path, tmp_path, "hummingbird")
    benchmark_xpath = "./{%s}component/{%s}Benchmark" % (DS_NS, XCCDF_NS)
    profile_xpath = benchmark_xpath + "/{%s}Profile" % XCCDF_NS
    profile = sg.ds.find(profile_xpath)
    output = sg.create_output_linear(profile)
    assert 'NEWROOT="$1"' in output
    assert "echo hummingbird_fix" in output


# ---------------------------------------------------------------------------
# Tests for ScriptGenerator.generate_remediation_scripts()
# ---------------------------------------------------------------------------

def test_generate_remediation_scripts_creates_files(minimal_ds_path, tmp_path):
    sg = _make_generator(minimal_ds_path, tmp_path, "bash")
    sg.generate_remediation_scripts()
    output_dir = str(tmp_path / "output")
    files = os.listdir(output_dir)
    assert len(files) == 1
    assert files[0].endswith(".sh")
    content = open(os.path.join(output_dir, files[0])).read()
    assert "echo bash_fix" in content


def test_generate_remediation_scripts_ansible(minimal_ds_path, tmp_path):
    sg = _make_generator(minimal_ds_path, tmp_path, "ansible")
    sg.generate_remediation_scripts()
    output_dir = str(tmp_path / "output")
    files = os.listdir(output_dir)
    assert len(files) == 1
    assert files[0].endswith(".yml")
