import ssg.xml

import os
import xml.etree.ElementTree as ET

data_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), "data"))
data_stream_path = os.path.join(data_dir, "simple_data_stream.xml")


def test_xml_content():
    root = ET.parse(data_stream_path).getroot()
    xml_content = ssg.xml.XMLContent(root)
    expected_component_refs = {
        "#scap_org.open-scap_comp_test_single_rule.oval.xml":
            "scap_org.open-scap_cref_test_single_rule.oval.xml",
        "#scap_org.open-scap_comp_cpe.oval.xml":
            "scap_org.open-scap_cref_cpe.oval.xml"
        }
    assert xml_content.component_refs == expected_component_refs
    expected_uris = {
        "#scap_org.open-scap_cref_test_single_rule.oval.xml":
            "test_single_rule.oval.xml",
        "#scap_org.open-scap_cref_cpe.oval.xml":
            "cpe.oval.xml"
        }
    assert xml_content.uris == expected_uris
    assert "OVAL" in xml_content.components
    assert "test_single_rule.oval.xml" in xml_content.components["OVAL"]
    assert "cpe.oval.xml" in xml_content.components["OVAL"]
    xml_component = xml_content.components["OVAL"]["test_single_rule.oval.xml"]
    assert type(xml_component) is ssg.xml.XMLComponent
