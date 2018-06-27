from __future__ import absolute_import
from __future__ import print_function

import re

# SSG Makefile to official product name mapping
_version_name_map = {
    'chromium': 'Google Chromium Browser',
    'fedora': 'Fedora',
    'firefox': 'Mozilla Firefox',
    'jre': 'Java Runtime Environment',
    'rhel-osp': 'Red Hat OpenStack Platform',
    'rhel': 'Red Hat Enterprise Linux',
    'debian': 'Debian',
    'ubuntu': 'Ubuntu',
    'eap': 'JBoss Enterprise Application Platform',
    'fuse': 'JBoss Fuse',
    'opensuse': 'openSUSE',
    'sle': 'SUSE Linux Enterprise',
    'wrlinux': 'Wind River Linux',
    'ol': 'Oracle Linux',
    'ocp': 'Red Hat OpenShift Container Platform',
}

multi_list = ["rhel", "fedora", "rhel-osp", "debian", "ubuntu",
              "wrlinux", "opensuse", "sle", "ol", "ocp"]

PRODUCT_NAME_PARSER = re.compile(r"([a-zA-Z\-]+)([0-9]+)")


def parse_name(product):
    _product = product
    _product_version = None
    match = PRODUCT_NAME_PARSER.match(product)

    if match:
        _product = match.group(1)
        _product_version = match.group(2)

    return _product, _product_version


def map_name(version):
    """Maps SSG Makefile internal product name to official product name"""

    if version.startswith("multi_platform_"):
        trimmed_version = version[len("multi_platform_"):]
        if trimmed_version not in multi_list:
            raise RuntimeError(
                "%s is an invalid product version. If it's multi_platform the "
                "suffix has to be from (%s)."
                % (version, ", ".join(multi_list))
            )
        return map_name(trimmed_version)

    # By sorting in reversed order, keys which are a longer version of other keys are
    # visited first (e.g., rhel-osp vs. rhel)
    for key in sorted(_version_name_map, reverse=True):
        if version.startswith(key):
            return _version_name_map[key]

    raise RuntimeError("Can't map version '%s' to any known product!"
                       % (version))
