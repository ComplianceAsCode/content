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
EAP = 'JBoss EAP'
FUSE = 'JBoss Fuse'
OPENSUSE = 'OpenSUSE'
SUSE = 'SUSE Linux Enterprise'
WRLINUX = 'Wind River Linux'

multi_product_list = ['rhel', 'fedora', 'rhel-osp', 'debian', 'ubuntu', 'wrlinux', 'sle']


def parse_product_name(product):
    product_version = None
    r = re.compile("([a-zA-Z\-]+)([0-9]+)")
    match = r.match(product)

    if match is not None:
         if isinstance(match.group(1), str) or isinstance(match.group(1), unicode):
             product = match.group(1)
         if match.group(2).isdigit():
             product_version = match.group(2)

    return product, product_version


def map_product(version):
    """Maps SSG Makefile internal product name to official product name"""

    product_name = None

    if re.findall('chromium', version):
        product_name = CHROMIUM
    if re.findall('fedora', version):
        product_name = FEDORA
    if re.findall('firefox', version):
        product_name = FIREFOX
    if re.findall('jre', version):
        product_name = JRE
    if re.findall('rhel', version):
        product_name = RHEL
    if re.findall('webmin', version):
        product_name = WEBMIN
    if re.findall('debian', version):
        product_name = DEBIAN
    if re.findall('ubuntu', version):
        product_name = UBUNTU
    if re.findall('rhevm', version):
        product_name = RHEVM
    if re.findall('eap', version):
        product_name = EAP
    if re.findall('fuse', version):
        product_name = FUSE
    if re.findall('opensuse', version):
        product_name = OPENSUSE
    if re.findall('sle', version):
        product_name = SUSE
    if re.findall('wrlinux', version):
        product_name = WRLINUX

    if product_name is None:
        raise RuntimeError("Can't map version '%s' to any known product!"
                           % (version))

    return product_name
