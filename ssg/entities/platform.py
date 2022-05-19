from ..xml import ElementTree as ET
from ..build_cpe import CPEALLogicalTest, CPEALFactRef

from . import common


class Platform(common.XCCDFEntity):

    KEYS = dict(
        name=lambda: "",
        original_expression=lambda: "",
        xml_content=lambda: "",
        bash_conditional=lambda: "",
        ansible_conditional=lambda: "",
        ** common.XCCDFEntity.KEYS
    )

    MANDATORY_KEYS = [
        "name",
        "xml_content",
        "original_expression",
        "bash_conditional",
        "ansible_conditional"
    ]

    XML_PREFIX = "cpe-lang"

    @classmethod
    def from_text(cls, expression, product_cpes):
        if not product_cpes:
            return None
        test = product_cpes.algebra.parse(
            expression, simplify=True)
        id = test.as_id()
        platform = cls(id)
        platform.test = test
        platform.test.enrich_with_cpe_info(product_cpes)
        platform.name = id
        platform.original_expression = expression
        platform.xml_content = platform.get_xml()
        platform.bash_conditional = platform.test.to_bash_conditional()
        platform.ansible_conditional = platform.test.to_ansible_conditional()
        return platform

    def get_xml(self):
        cpe_platform = ET.Element("{%s}platform" % self.XML_NS)
        cpe_platform.set('id', self.name)
        # in case the platform contains only single CPE name, fake the logical test
        # we have to athere to CPE specification
        if isinstance(self.test, CPEALFactRef):
            cpe_test = ET.Element("{%s}logical-test" % CPEALLogicalTest.ns)
            cpe_test.set('operator', 'AND')
            cpe_test.set('negate', 'false')
            cpe_test.append(self.test.to_xml_element())
            cpe_platform.append(cpe_test)
        else:
            cpe_platform.append(self.test.to_xml_element())
        xmlstr = ET.tostring(cpe_platform).decode()
        return xmlstr

    def to_xml_element(self):
        return self.xml_content

    def to_bash_conditional(self):
        return self.bash_conditional

    def to_ansible_conditional(self):
        return self.ansible_conditional

    @classmethod
    def from_yaml(cls, yaml_file, env_yaml=None, product_cpes=None):
        platform = super(Platform, cls).from_yaml(yaml_file, env_yaml)
        platform.xml_content = ET.fromstring(platform.xml_content)
        # if we did receive a product_cpes, we can restore also the original test object
        # it can be later used e.g. for comparison
        if product_cpes:
            platform.test = product_cpes.algebra.parse(
                platform.original_expression, simplify=True)
        return platform

    def __eq__(self, other):
        if not isinstance(other, Platform):
            return False
        else:
            return self.test == other.test


def add_platform_if_not_defined(platform, product_cpes):
    # check if the platform is already in the dictionary. If yes, return the existing one
    for p in product_cpes.platforms.values():
        if platform == p:
            return p
    product_cpes.platforms[platform.id_] = platform
    return platform