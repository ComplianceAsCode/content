import os
import os.path
import re
import tarfile
import collections

_DIR = os.path.dirname(__file__)
_TEMPLATE_SCENARIOS_DIR = os.path.join(_DIR, "templates")
_TAR_BASENAME = 'data.tar'
_SSG_PREFIX = 'xccdf_org.ssgproject.content_'

Rule = collections.namedtuple(
    "Rule", ["directory", "id", "files"])


def iterate_over_rules():
    """Iterate over directories beginning with "rule_".

    Returns:
        Named tuple having these fields:
            directory -- absolute path to the rule directory
            id -- full rule id as it is present in datastream
            files -- list of files in the directory
    """
    for dir_name, directories, files in os.walk(_DIR):
        leaf_dir = os.path.basename(dir_name)
        rel_dir = '.' + dir_name[len(_DIR):]
        print(rel_dir)
        if leaf_dir.startswith('rule_'):
            result = Rule(rel_dir, _SSG_PREFIX + leaf_dir, files)
            yield result
        if rel_dir.startswith('./templates/'):
            result = Rule(rel_dir, leaf_dir, files)
            yield result


def _exclude_utils(file_name):
    if file_name in ['./__init__.py', './utils.py']:
        return True
    if file_name.endswith('pyc'):
        return True
    if file_name.endswith('swp'):
        return True
    return False


def create_tarball(tar_dir):
    archive_path = os.path.join(tar_dir, _TAR_BASENAME)
    with tarfile.TarFile.open(archive_path, 'w') as tarball:
        tarball.add(_DIR, arcname='.', exclude=_exclude_utils)
    return archive_path


def _get_template_dir(template):
    """Return the dir with test scenarios for a template"""
    template_dir = os.path.join(_TEMPLATE_SCENARIOS_DIR, template)

    if not os.path.exists(template_dir):
        msg = "Template scenario directory {} not found, expected {} to exist.".format(template, template_dir)
        raise RuntimeError(msg)

    return template_dir


def _get_template_rule_name(script):
    """Return name of the script.
    Used to get rule to check template scenario.
    """
    result = re.search('(.*)\.[^.]*\.[^.]*$', script)
    if result is None:
        return None
    return result.group(1)


def get_template_rules(template):
    """ Return list of rules in template tests."""

    template_dir = _get_template_dir(template)

    rules = []
    for scenario_file in os.listdir(template_dir):
        files = []
        if os.path.isfile(os.path.join(template_dir, scenario_file)):
            files.append(scenario_file)
            rel_dir = '.' + template_dir[len(_DIR):]
            rules.append(Rule(rel_dir, _SSG_PREFIX + _get_template_rule_name(scenario_file), files))

    return rules
