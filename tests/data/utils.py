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
            files -- list of files in the directory
    """
    for dir_name, directories, files in os.walk(_DIR):
        leaf_dir = os.path.basename(dir_name)
        rel_dir = '.' + dir_name[len(_DIR):]
        if leaf_dir.startswith('rule_'):
            result = Rule(rel_dir, _SSG_PREFIX + leaf_dir, files)
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
