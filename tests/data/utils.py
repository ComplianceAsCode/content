import os
import os.path
import tarfile
import collections

_DIR = os.path.dirname(__file__)
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
            files -- list of executable .sh files in the
            directory containing the test scenarios in Bash
    """
    for dir_name, directories, files in os.walk(_DIR):
        leaf_dir = os.path.basename(dir_name)
        rel_dir = '.' + dir_name[len(_DIR):]
        if leaf_dir.startswith('rule_'):
            # Filter out everything except the shell test scenarios.
            # Other files in rule directories are editor swap files
            # or other content than a test case.
            scripts = filter(lambda x: x.endswith(".sh"), files)
            result = Rule(rel_dir, _SSG_PREFIX + leaf_dir, scripts)
            yield result


def _exclude_utils(tarinfo):
    file_name = tarinfo.name
    if file_name in ['./__init__.py', './utils.py']:
        return None
    if file_name.endswith('pyc'):
        return None
    if file_name.endswith('swp'):
        return None
    return tarinfo


def create_tarball(tar_dir):
    archive_path = os.path.join(tar_dir, _TAR_BASENAME)
    with tarfile.TarFile.open(archive_path, 'w') as tarball:
        tarball.add(_DIR, arcname='.', filter=_exclude_utils)
    return archive_path
