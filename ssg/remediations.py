from collections import defaultdict, namedtuple
from .jinja import process_file_with_macros as jinja_process_file
from .jinja import process_string_with_macros as jinja_process_string

REMEDIATION_TO_EXT_MAP = {
    'anaconda': '.anaconda',
    'ansible': '.yml',
    'bash': '.sh',
    'puppet': '.pp',
    'ignition': '.yml',
    'kubernetes': '.yml',
    'blueprint': '.toml'
}

FILE_GENERATED_HASH_COMMENT = '# THIS FILE IS GENERATED'

REMEDIATION_CONFIG_KEYS = ['complexity', 'disruption', 'platform', 'reboot',
                           'strategy']


def split_remediation_content_and_metadata(fix_file):
    remediation_contents = []
    config = defaultdict(lambda: None)

    # Assignment automatically escapes shell characters for XML
    for line in fix_file.splitlines():
        if line.startswith(FILE_GENERATED_HASH_COMMENT):
            continue

        if line.startswith('#') and line.count('=') == 1:
            (key, value) = line.strip('#').split('=')
            if key.strip() in REMEDIATION_CONFIG_KEYS:
                config[key.strip()] = value.strip()
                continue

        # If our parsed line wasn't a config item, add it to the
        # returned file contents. This includes when the line
        # begins with a '#' and contains an equals sign, but
        # the "key" isn't one of the known keys from
        # REMEDIATION_CONFIG_KEYS.
        remediation_contents.append(line)

    contents = "\n".join(remediation_contents)
    remediation = namedtuple('remediation', ['contents', 'config'])
    return remediation(contents=contents, config=config) #defaultdict(lambda: None)


def parse_from_string_with_jinja(string, env_yaml):
    """
    Parses a remediation from a string. As remediations contain jinja macros,
    we need a env_yaml context to process these. In practice, no remediations
    use jinja in the configuration, so for extracting only the configuration,
    env_yaml can be an abritrary product.yml dictionary.

    If the logic of configuration parsing changes significantly, please also
    update ssg.fixes.parse_platform(...).
    """

    fix_file = jinja_process_string(string, env_yaml)
    return split_remediation_content_and_metadata(fix_file)


def parse_from_file_with_jinja(file_path, env_yaml):
    """
    Parses a remediation from a file. As remediations contain jinja macros,
    we need a env_yaml context to process these. In practice, no remediations
    use jinja in the configuration, so for extracting only the configuration,
    env_yaml can be an abritrary product.yml dictionary.

    If the logic of configuration parsing changes significantly, please also
    update ssg.fixes.parse_platform(...).
    """

    fix_file = jinja_process_file(file_path, env_yaml)
    return split_remediation_content_and_metadata(fix_file)


def parse_from_file_without_jinja(file_path):
    """
    Parses a remediation from a file. Doesn't process the Jinja macros.
    This function is useful in build phases in which all the Jinja macros
    are already resolved.
    """
    with open(file_path, "r") as f:
        f_str = f.read()
        return split_remediation_content_and_metadata(f_str)
