import os.path

_DIR = os.path.dirname(__file__)
_SSG_PREFIX = 'xccdf_org.ssgproject.content_'


def iterate_over_rules():
    """Iterate over directories beginning with "rule_".

    Returns:
    dir_name -- absolute path to the rule directory
    rule -- full rule id as it is present in datastream
    files -- list of files in the directory
    """
    for dir_name, directories, files in os.walk(_DIR):
        leaf_dir = os.path.basename(dir_name)
        if leaf_dir.startswith('rule_'):
            yield dir_name, _SSG_PREFIX + leaf_dir, files
