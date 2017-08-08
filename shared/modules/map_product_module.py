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

    if "chromium" in version:
        return CHROMIUM
    if "fedora" in version:
        return FEDORA
    if "firefox" in version:
        return FIREFOX
    if "jre" in version:
        return JRE
    if "rhel" in version:
        return RHEL
    if "webmin" in version:
        return WEBMIN
    if "debian" in version:
        return DEBIAN
    if "ubuntu" in version:
        return UBUNTU
    if "rhevm" in version:
        return RHEVM
    if "eap" in version:
        return EAP
    if "fuse" in version:
        return FUSE
    if "opensuse" in version:
        return OPENSUSE
    if "sle" in version:
        return SUSE
    if "wrlinux" in version:
        return WRLINUX

    raise RuntimeError("Can't map version '%s' to any known product!"
                       % (version))
