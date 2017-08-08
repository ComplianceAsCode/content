import re

# SSG Makefile to official product name mapping
CHROMIUM = 'Google Chromium Browser'
FEDORA = 'Fedora'
FIREFOX = 'Mozilla Firefox'
JRE = 'Java Runtime Environment'
RHEL = 'Red Hat Enterprise Linux'
WEBMIN = 'Webmin'
DEBIAN = 'Debian'
UBUNTU = 'Ubuntu'
RHEVM = 'Red Hat Enterprise Virtualization Manager'
EAP = 'JBoss Enterprise Application Platform'
FUSE = 'JBoss Fuse'
OPENSUSE = 'OpenSUSE'
SUSE = 'SUSE Linux Enterprise'
WRLINUX = 'Wind River Linux'

multi_product_list = ["rhel", "fedora", "rhel-osp", "debian", "ubuntu",
                      "wrlinux", "opensuse", "sle"]

PRODUCT_NAME_PARSER = re.compile("([a-zA-Z\-]+)([0-9]+)")


def parse_product_name(product):
    product_version = None
    match = PRODUCT_NAME_PARSER.match(product)

    if match is not None:
        if isinstance(match.group(1), str) or \
                isinstance(match.group(1), unicode):
            product = match.group(1)
        if match.group(2).isdigit():
            product_version = match.group(2)

    return product, product_version


def map_product(version):
    """Maps SSG Makefile internal product name to official product name"""

    if version.startswith("multi_platform_"):
        trimmed_version = version[len("multi_platform_"):]
        if trimmed_version not in multi_product_list:
            raise RuntimeError(
                "%s is an invalid product version. If it's multi_platform the "
                "suffix has to be from (%s)."
                % (version, ", ".join(multi_product_list))
            )
        return map_product(trimmed_version)

    if version.startswith("chromium"):
        return CHROMIUM
    if version.startswith("fedora"):
        return FEDORA
    if version.startswith("firefox"):
        return FIREFOX
    if version.startswith("jre"):
        return JRE
    if version.startswith("rhel"):
        return RHEL
    if version.startswith("webmin"):
        return WEBMIN
    if version.startswith("debian"):
        return DEBIAN
    if version.startswith("ubuntu"):
        return UBUNTU
    if version.startswith("rhevm"):
        return RHEVM
    if version.startswith("eap"):
        return EAP
    if version.startswith("fuse"):
        return FUSE
    if version.startswith("opensuse"):
        return OPENSUSE
    if version.startswith("sle"):
        return SUSE
    if version.startswith("wrlinux"):
        return WRLINUX

    raise RuntimeError("Can't map version '%s' to any known product!"
                       % (version))
