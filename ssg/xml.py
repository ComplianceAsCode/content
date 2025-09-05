"""
Common functions for processing XML in SSG
"""

from __future__ import absolute_import
from __future__ import print_function
import collections

import platform
import re

from .constants import (
    xml_version, oval_header, timestamp, PREFIX_TO_NS, XCCDF11_NS, XCCDF12_NS)
from .constants import (
    datastream_namespace,
    oval_namespace,
    stig_ns,
    cat_namespace,
    xlink_namespace,
    ocil_namespace,
    cpe_language_namespace,
)


try:
    from xml.etree import cElementTree as ElementTree
except ImportError:
    from xml.etree import ElementTree as ElementTree


def oval_generated_header(product_name, schema_version, ssg_version):
    """
    Generates an OVAL header for a given product.

    Args:
        product_name (str): The name of the product.
        schema_version (str): The version of the OVAL schema.
        ssg_version (str): The version of the SCAP Security Guide (SSG).

    Returns:
        str: A string containing the OVAL header with the provided product name, schema version,
             SSG version, Python version, and the current timestamp.
    """
    return xml_version + oval_header + \
        """
    <generator>
        <oval:product_name>%s from SCAP Security Guide</oval:product_name>
        <oval:product_version>ssg: %s, python: %s</oval:product_version>
        <oval:schema_version>%s</oval:schema_version>
        <oval:timestamp>%s</oval:timestamp>
    </generator>""" % (product_name, ssg_version, platform.python_version(),
                       schema_version, timestamp)


def register_namespaces(ns=None):
    """
    Register all possible namespaces.

    This function registers XML namespaces for use with the ElementTree module.
    If no namespaces are provided, it defaults to using the PREFIX_TO_NS dictionary.

    Args:
        ns (dict, optional): A dictionary mapping prefixes to namespace URIs.
                             If None, the function uses the PREFIX_TO_NS dictionary.

    Raises:
        Exception: Catches all exceptions, which may occur if using an old version of Python.
                   This is non-essential and will be silently ignored.
    """
    try:
        if ns is None:
            ns = PREFIX_TO_NS
        for prefix, uri in ns.items():
            ElementTree.register_namespace(prefix, uri)
    except Exception:
        # Probably an old version of Python
        # Doesn't matter, as this is non-essential.
        pass


def get_namespaces_from(file):
    """
    Extracts and returns a dictionary of XML namespaces from the given file.

    Args:
        file (str or file-like object): The path to the XML file or a file-like object containing
                                        XML data.

    Returns:
        dict: A dictionary where the keys are namespace prefixes and the values are namespace URIs.
              Returns an empty dictionary if an error occurs during parsing.

    Return dictionary of namespaces in file. Return empty dictionary in case of error.
    """
    result = {}
    try:
        result = {
            key: value
            for _, (key, value) in ElementTree.iterparse(file, events=["start-ns"])
        }
    except Exception:
        # Probably an old version of Python
        # Doesn't matter, as this is non-essential.
        pass
    finally:
        return result


def open_xml(filename):
    """
    Open and parse an XML file.

    This function registers all possible namespaces and then parses the XML file specified by the
    given filename, returning the resulting XML tree.

    Args:
        filename (str): The path to the XML file to be parsed.

    Returns:
        xml.etree.ElementTree.ElementTree: The parsed XML tree.

    Raises:
        xml.etree.ElementTree.ParseError: If there is an error parsing the XML file.
    """
    register_namespaces()
    return ElementTree.parse(filename)


def parse_file(filename):
    """
    Parses an XML file and returns the root element of the ElementTree.

    Args:
        filename (str): The path to the XML file to be parsed.

    Returns:
        xml.etree.ElementTree.Element: The root element of the parsed XML tree.
    """
    tree = open_xml(filename)
    return tree.getroot()


def map_elements_to_their_ids(tree, xpath_expr):
    """
    Given an ElementTree and an XPath expression, iterate through matching elements and create 1:1
    id->element mapping.

    Args:
        tree (ElementTree): The XML tree to search within.
        xpath_expr (str): The XPath expression to match elements.

    Raises:
        AssertionError: If a matching element doesn't have the ``id`` attribute.

    Returns:
        dict: A dictionary mapping element IDs to their corresponding elements.
    """
    aggregated = {}
    for element in tree.findall(xpath_expr):
        element_id = element.get("id")
        assert element_id is not None
        aggregated[element_id] = element
    return aggregated


SSG_XHTML_TAGS = [
    'table', 'tr', 'th', 'td', 'ul', 'li', 'ol',
    'p', 'code', 'strong', 'b', 'em', 'i', 'pre', 'br', 'hr', 'small',
]


def add_xhtml_namespace(data):
    """
    Given an XML blob, adds the XHTML namespace to all relevant tags.

    This function performs two main transformations:
    1. It transforms <tt> tags into <code> tags.
    2. It adds the XHTML prefix to specified elements.

    Args:
        data (str): The XML data as a string.

    Returns:
        str: The modified XML data with XHTML namespaces added.
    """
    # The use of lambda in the lines below is a workaround for https://bugs.python.org/issue1519638
    # I decided for this approach to avoid adding workarounds in the matching regex, this way only
    # the substituted part contains the workaround.
    # Transform <tt> in <code>
    data = re.sub(r'<(\/)?tt(\/)?>',
                  lambda m: r'<' + (m.group(1) or '') + 'code' + (m.group(2) or '') + '>', data)
    # Adds xhtml prefix to elements: <tag>, </tag>, <tag/>
    return re.sub(r'<(\/)?((?:%s).*?)(\/)?>' % "|".join(SSG_XHTML_TAGS),
                  lambda m: r'<' + (m.group(1) or '') + 'xhtml:' +
                  (m.group(2) or '') + (m.group(3) or '') + '>',
                  data)


def determine_xccdf_tree_namespace(tree):
    """
    Determines the XCCDF namespace of the given XML tree.

    Args:
        tree (xml.etree.ElementTree.ElementTree): The XML tree to examine.

    Returns:
        str: The XCCDF namespace URI.

    Raises:
        ValueError: If the root element of the tree is not recognized as a Benchmark element from
                    either XCCDF 1.1 or XCCDF 1.2 namespaces.
    """
    root = tree.getroot()
    if root.tag == "{%s}Benchmark" % XCCDF11_NS:
        xccdf_ns = XCCDF11_NS
    elif root.tag == "{%s}Benchmark" % XCCDF12_NS:
        xccdf_ns = XCCDF12_NS
    else:
        raise ValueError("Unknown root element '%s'" % root.tag)
    return xccdf_ns


def get_element_tag_without_ns(xml_tag):
    """
    Extracts the tag name from an XML element, removing any namespace.

    Args:
        xml_tag (str): The XML tag with namespace.

    Returns:
        str: The XML tag without the namespace.

    Raises:
        AttributeError: If the input string does not match the expected pattern.
    """
    return re.search(r'^{.*}(.*)', xml_tag).group(1)


def get_element_namespace(self):
    """
    Extracts the namespace from the root element's tag.

    The method uses a regular expression to search for a namespace pattern in the root element's
    tag. The namespace is expected to be enclosed in curly braces at the beginning of the tag.

    Returns:
        str: The namespace extracted from the root element's tag.

    Raises:
        AttributeError: If the root element's tag does not match the expected pattern.
    """
    return re.search(r'^{(.*)}.*', self.root.tag).group(1)


class XMLElement(object):
    """
    Represents a generic element read from an XML file.

    Attributes:
        ns (dict): A dictionary mapping namespace prefixes to their respective URIs.
        root (Element): The root element of the XML structure.
        content_xccdf_ns (str): The XCCDF version namespace determined from the XML.
    """
    ns = {
        "ds": datastream_namespace,
        "xccdf-1.1": XCCDF11_NS,
        "xccdf-1.2": XCCDF12_NS,
        "oval": oval_namespace,
        "catalog": cat_namespace,
        "xlink": xlink_namespace,
        "ocil": ocil_namespace,
        "cpe-lang": cpe_language_namespace,
    }

    def __init__(self, root):
        self.root = root
        self._determine_xccdf_version()

    def get_attr(self, attr):
        """
        Retrieve the value of an attribute from the root element.

        Args:
            attr (str): The name of the attribute to retrieve.

        Returns:
            str or None: The value of the attribute if it exists, otherwise None.
        """
        return self.root.get(attr)

    def get_namespace(self):
        """
        Extracts and returns the XML namespace from the root tag of the XML document.

        Returns:
            str: The namespace URI extracted from the root tag.

        Raises:
            AttributeError: If the root tag does not contain a namespace.
        """
        return re.search(r'^{(.*)}.*', self.root.tag).group(1)

    def _determine_xccdf_version(self):
        """
        Determines the XCCDF version based on the XML namespace.

        This method sets the `content_xccdf_ns` attribute to either "xccdf-1.1" or "xccdf-1.2"
        depending on the namespace returned by the `get_namespace` method.

        If the namespace matches `self.ns["xccdf-1.1"]`, the version is set to "xccdf-1.1".
        Otherwise, it defaults to "xccdf-1.2".
        """
        if self.get_namespace() == self.ns["xccdf-1.1"]:
            self.content_xccdf_ns = "xccdf-1.1"
        else:
            self.content_xccdf_ns = "xccdf-1.2"


class XMLContent(XMLElement):
    """
    XMLContent is a class that represents a Data Stream or an XCCDF Benchmark read from an XML file.

    Attributes:
        check_engines (list): A list of tuples containing check engine names and their corresponding XML tags.
    """
    check_engines = [("OVAL", "oval:oval_definitions"), ("OCIL", "ocil:ocil")]

    def __init__(self, root):
        super(XMLContent, self).__init__(root)
        self.component_refs = self.get_component_refs()
        self.uris = self.get_uris()
        self.components = self._find_all_component_contents()

    def get_component_refs(self):
        """
        Extracts and returns a dictionary of component references from the XML data.

        This method searches for all "ds:component-ref" elements within "ds:checks" elements in
        the XML data stream. It retrieves the "href" attribute from the "xlink" namespace and the
        "id" attribute from each "ds:component-ref" element and stores them in a dictionary.

        Returns:
            dict: A dictionary where the keys are the "href" attributes and the values are the
                 "id" attributes of the "ds:component-ref" elements.
        """
        component_refs = dict()
        for ds in self.root.findall("ds:data-stream", self.ns):
            checks = ds.find("ds:checks", self.ns)
            for component_ref in checks.findall("ds:component-ref", self.ns):
                component_ref_href = component_ref.get("{%s}href" % (self.ns["xlink"]))
                component_ref_id = component_ref.get("id")
                component_refs[component_ref_href] = component_ref_id
        return component_refs

    def get_uris(self):
        """
        Extracts URIs and their corresponding names from the XML data.

        This method searches through the XML structure defined in `self.root` for data streams,
        checklists, and catalogs to find URI elements. It then extracts the 'uri' and 'name'
        attributes from each URI element and stores them in a dictionary.

        Returns:
            dict: A dictionary where the keys are URI strings and the values are the corresponding
                  names.
        """
        uris = dict()
        for ds in self.root.findall("ds:data-stream", self.ns):
            checklists = ds.find("ds:checklists", self.ns)
            catalog = checklists.find(".//catalog:catalog", self.ns)
            for uri in catalog.findall("catalog:uri", self.ns):
                uri_uri = uri.get("uri")
                uri_name = uri.get("name")
                uris[uri_uri] = uri_name
        return uris

    def is_benchmark(self):
        """
        Determines if the root tag of the XML document is a Benchmark tag.

        This method checks if the root tag of the XML document matches the Benchmark tag for
        either the "xccdf-1.2" or "xccdf-1.1" namespace. If the root tag matches the "xccdf-1.2"
        namespace, it returns True. If the root tag matches the "xccdf-1.1" namespace, it sets the
        content_xccdf_ns attribute to "xccdf-1.1" and returns True.

        Returns:
            bool: True if the root tag is a Benchmark tag for either "xccdf-1.2" or "xccdf-1.1"
                  namespace, False otherwise.
        """
        if self.root.tag == "{%s}Benchmark" % (self.ns["xccdf-1.2"]):
            return True
        elif self.root.tag == "{%s}Benchmark" % (self.ns["xccdf-1.1"]):
            self.content_xccdf_ns = "xccdf-1.1"
            return True

    def get_benchmarks(self):
        """
        Extracts and yields XMLBenchmark objects from the XML tree.

        This method searches for 'ds:component' elements in the XML tree. If no such elements are
        found, it checks if the root element is a benchmark and yields an XMLBenchmark object if
        true. Otherwise, it iterates over each 'ds:component' element and searches for 'Benchmark'
        elements within the component, yielding an XMLBenchmark object for each found benchmark.

        Yields:
            XMLBenchmark: An instance of XMLBenchmark for each found benchmark in the XML tree.
        """
        ds_components = self.root.findall("ds:component", self.ns)
        if not ds_components:
            # The content is not a DS, maybe it is just an XCCDF Benchmark
            if self.is_benchmark():
                yield XMLBenchmark(self.root)
        for component in ds_components:
            for benchmark in component.findall("%s:Benchmark" % self.content_xccdf_ns, self.ns):
                yield XMLBenchmark(benchmark)

    def find_benchmark(self, id_):
        """
        Finds and returns an XMLBenchmark object for the given benchmark ID.

        This method searches for a benchmark with the specified ID within the XML structure.
        It first looks for "ds:component" elements and checks if any of them contain a "Benchmark"
        element with the given ID. If no "ds:component" elements are found, it checks if the root
        element is a benchmark itself.

        Args:
            id_ (str): The ID of the benchmark to find.

        Returns:
            XMLBenchmark: An XMLBenchmark object if a benchmark with the given ID is found,
                          otherwise None.
        """
        ds_components = self.root.findall("ds:component", self.ns)
        if not ds_components:
            # The content is not a DS, maybe it is just an XCCDF Benchmark
            if self.is_benchmark():
                return XMLBenchmark(self.root)
        for component in ds_components:
            benchmark = component.find("%s:Benchmark[@id='%s']"
                                       % (self.content_xccdf_ns, id_), self.ns)
            if benchmark is not None:
                return XMLBenchmark(benchmark)
        return None

    def _find_all_component_contents(self):
        """
        Finds and collects all component contents from the XML document.

        This method iterates over all components in the XML document, extracts relevant
        information based on predefined check engines, and organizes the data into a dictionary.

        Returns:
            dict: A nested dictionary where the first level keys are check IDs, and the second
                  level keys are filenames. The values are XMLComponent instances representing
                  the component contents.

        Raises:
            KeyError: If a component reference is not found in the URIs.
        """
        component_doc_dict = collections.defaultdict(dict)
        for component in self.root.findall("ds:component", self.ns):
            for check_id, check_tag in self.check_engines:
                def_doc = component.find(check_tag, self.ns)
                if def_doc is None:
                    continue
                comp_id = component.get("id")
                comp_href = "#" + comp_id
                try:
                    filename = self.uris["#" + self.component_refs[comp_href]]
                except KeyError:
                    continue
                xml_component = XMLComponent(def_doc)
                component_doc_dict[check_id][filename] = xml_component
        return component_doc_dict


class XMLBenchmark(XMLElement):
    """
    Represents an XCCDF Benchmark read from an XML file.

    Attributes:
        root (Element): The root element of the XML document.
    """

    def __init__(self, root):
        super(XMLBenchmark, self).__init__(root)
        self.root = root

    def find_rules(self, rule_id):
        """
        Find and return rules based on the given rule_id.

        Args:
            rule_id (str): The ID of the rule to find. If None, all rules are returned.

        Returns:
            list: A list of XMLRule objects that match the given rule_id.
                  If rule_id is None, returns all rules.

        Raises:
            ValueError: If no rules are found for the given rule_id.
        """
        if rule_id:
            rules = [XMLRule(r) for r in self.root.iterfind(
                ".//%s:Rule[@id='%s']" % (self.content_xccdf_ns, rule_id), self.ns)]
            if len(rules) == 0:
                raise ValueError("Can't find rule %s" % (rule_id))
        else:
            rules = [XMLRule(r) for r in self.root.iterfind(
                ".//%s:Rule" % (self.content_xccdf_ns), self.ns)]
        return rules

    def find_rule(self, rule_id):
        """
        Find and return an XMLRule object for the given rule ID.

        Args:
            rule_id (str): The ID of the rule to find.

        Returns:
            XMLRule: An XMLRule object if the rule is found, otherwise None.
        """
        rule = self.root.find(
                ".//%s:Rule[@id='%s']" % (self.content_xccdf_ns, rule_id), self.ns)
        return XMLRule(rule) if rule else None

    def find_all_cpe_platforms(self, idref):
        """
        Find all CPE platforms with the given idref.

        Args:
            idref (str): The reference ID of the CPE platform to find.

        Returns:
            list: A list of XMLCPEPlatform objects that match the given idref.
        """
        cpes = [XMLCPEPlatform(p) for p in self.root.iterfind(
            ".//cpe-lang:platform[@id='{0}']".format(idref.replace("#", "")), self.ns)]
        return cpes


class XMLRule(XMLElement):
    """
    Represents an XCCDF Rule read from an XML file.

    Attributes:
        root (Element): The root element of the XML tree.
        content_xccdf_ns (str): The namespace for XCCDF content.
        ns (dict): The namespace dictionary for XML parsing.
    """
    def __init__(self, root):
        super(XMLRule, self).__init__(root)
        self.root = root

    def get_check_element(self, check_system_uri):
        """
        Retrieve a check element from the XML tree based on the given check system URI.

        Args:
            check_system_uri (str): The URI of the check system to find.

        Returns:
            Element: The XML element corresponding to the check system URI, or None if not found.
        """
        return self.root.find(
            "%s:check[@system='%s']" % (self.content_xccdf_ns, check_system_uri), self.ns)

    def get_check_content_ref_element(self, check_element):
        """
        Retrieves the 'check-content-ref' element from the given check element.

        Args:
            check_element (Element): The XML element representing the check.

        Returns:
            Element: The 'check-content-ref' sub-element if found, otherwise None.
        """
        return check_element.find(
            "%s:check-content-ref" % (self.content_xccdf_ns), self.ns)

    def get_fix_element(self, fix_uri):
        """
        Retrieve the 'fix' element from the XML tree based on the provided fix URI.

        Args:
            fix_uri (str): The URI of the fix to be retrieved.

        Returns:
            Element: The XML element corresponding to the fix URI, or None if not found.
        """
        return self.root.find("%s:fix[@system='%s']" % (self.content_xccdf_ns, fix_uri), self.ns)

    def get_version_element(self):
        """
        Retrieve the version element from the XML document.

        This method searches for the version element within the XML document using the specified
        namespace.

        Returns:
            Element: The version element if found, otherwise None.
        """
        return self.root.find("%s:version" % (self.content_xccdf_ns), self.ns)

    def get_all_platform_elements(self):
        """
        Retrieve all platform elements from the XML document.

        This method searches for all elements with the tag 'platform' within the XML
        document's root, using the specified namespace.

        Returns:
            list: A list of all found platform elements.
        """
        return self.root.findall(".//%s:platform" % (self.content_xccdf_ns), self.ns)

    def _get_description_text(self, el):
        """
        Recursively retrieves and constructs the description text from an XML element.

        This method processes the text content of the given XML element, including its children
        and tail text. If the element is a 'sub' element, it replaces it with the 'idref'
        attribute value.

        Args:
            el (xml.etree.ElementTree.Element): The XML element to process.

        Returns:
            str: The constructed description text.
        """
        desc_text = el.text if el.text else ""
        # If a 'sub' element is found, lets replace it with the id of the variable it references
        if get_element_tag_without_ns(el.tag) == "sub":
            desc_text += "'%s'" % el.attrib['idref']
        for desc_el in el:
            desc_text += self._get_description_text(desc_el)
        desc_text += el.tail if el.tail else ""
        return desc_text

    def get_element_text(self, el):
        """
        Extracts and returns the text content of an XML element.

        If the element's tag (without namespace) is "description", it uses a specialized method
        to get the description text. Otherwise, it concatenates all text within the element.

        Args:
            el (xml.etree.ElementTree.Element): The XML element from which to extract text.

        Returns:
            str: The text content of the XML element.
        """
        el_tag = get_element_tag_without_ns(el.tag)
        if el_tag == "description":
            temp_text = self._get_description_text(el)
        else:
            temp_text = "".join(el.itertext())
        return temp_text

    def join_text_elements(self):
        """
        Collects and concatenates text from relevant subelements of the root element.

        This function iterates over the subelements of the root element, collects their text,
        and concatenates it into a single string. It skips certain elements that are not relevant
        for comparison, such as "fix" elements and "reference" elements with specific attributes.
        For each collected text, it injects a line indicating the tag of the element from which
        the text was collected to facilitate tracking.

        Returns:
            str: A concatenated string of text from relevant subelements, with injected lines
                 indicating the source element tags.
        """
        text = ""
        for el in self.root:
            el_tag = get_element_tag_without_ns(el.tag)
            if el_tag == "fix":
                # We ignore the fix element because it has its own dedicated differ
                continue
            if el_tag == "reference" and el.get("href" == stig_ns):
                # We ignore references to DISA Benchmark Rules,
                # they have a format of SV-\d+r\d+_rule
                # and can change for non-text related changes
                continue
            el_text = self.get_element_text(el).strip()
            if el_text:
                text += "\n[%s]:\n" % el_tag
                text += el_text + "\n"

        return text


class XMLComponent(XMLElement):
    """
    Represents the element of the Datastream component that has relevant content.

    This makes it easier to access contents pertaining to a SCAP component.
    """
    def __init__(self, root):
        super(XMLComponent, self).__init__(root)

    def find_oval_definition(self, def_id):
        """
        Find and return an OVAL definition by its ID.

        Args:
            def_id (str): The ID of the OVAL definition to find.

        Returns:
            XMLOvalDefinition: An instance of XMLOvalDefinition representing the found definition.

        Raises:
            AttributeError: If the definitions or definition element is not found.
        """
        definitions = self.root.find("oval:definitions", self.ns)
        definition = definitions.find("oval:definition[@id='%s']" % (def_id), self.ns)
        return XMLOvalDefinition(definition)

    def find_ocil_questionnaire(self, def_id):
        """
        Finds and returns an OCIL questionnaire by its definition ID.

        Args:
            def_id (str): The definition ID of the OCIL questionnaire to find.

        Returns:
            XMLOcilQuestionnaire: An instance of XMLOcilQuestionnaire representing the found
                                  questionnaire.

        Raises:
            AttributeError: If the 'ocil:questionnaires' or 'ocil:questionnaire' elements are not
                            found.
        """
        questionnaires = self.root.find("ocil:questionnaires", self.ns)
        questionnaire = questionnaires.find(
            "ocil:questionnaire[@id='%s']" % def_id, self.ns)
        return XMLOcilQuestionnaire(questionnaire)

    def find_ocil_test_action(self, test_action_ref):
        """
        Finds and returns an OCIL test action based on the provided reference ID.

        Args:
            test_action_ref (str): The reference ID of the test action to find.

        Returns:
            XMLOcilTestAction: An instance of XMLOcilTestAction representing the found test action.

        Raises:
            AttributeError: If the test action is not found in the XML structure.
        """
        test_actions = self.root.find("ocil:test_actions", self.ns)
        test_action = test_actions.find(
            "ocil:boolean_question_test_action[@id='%s']" % test_action_ref, self.ns)
        return XMLOcilTestAction(test_action)

    def find_ocil_boolean_question(self, question_id):
        """
        Find an OCIL boolean question by its ID.

        Args:
            question_id (str): The ID of the boolean question to find.

        Returns:
            XMLOcilQuestion: An instance of XMLOcilQuestion representing the found boolean question.

        Raises:
            AttributeError: If the question is not found or if the XML structure is incorrect.
        """
        questions = self.root.find("ocil:questions", self.ns)
        question = questions.find(
            "ocil:boolean_question[@id='%s']" % question_id, self.ns)
        return XMLOcilQuestion(question)

    def find_boolean_question(self, ocil_id):
        """
        Finds and returns the text of a boolean question from an OCIL questionnaire.

        Args:
            ocil_id (str): The ID of the OCIL questionnaire.

        Returns:
            str: The text of the boolean question.

        Raises:
            ValueError: If the OCIL questionnaire, test action, or boolean question does not exist.
        """
        questionnaire = self.find_ocil_questionnaire(ocil_id)
        if questionnaire is None:
            raise ValueError("OCIL questionnaire %s doesn't exist" % ocil_id)
        test_action_ref = questionnaire.get_test_action_ref_element().text
        test_action = self.find_ocil_test_action(test_action_ref)
        if test_action is None:
            raise ValueError(
                "OCIL boolean_question_test_action %s doesn't exist" % (
                    test_action_ref))
        question_id = test_action.get_attr("question_ref")
        question = self.find_ocil_boolean_question(question_id)
        if question is None:
            raise ValueError(
                "OCIL boolean_question %s doesn't exist" % question_id)
        question_text = question.get_question_test_element()
        return question_text.text


class XMLOvalDefinition(XMLComponent):
    """
    A class to represent an OVAL definition in XML format.

    Attributes:
        root (xml.etree.ElementTree.Element): The root element of the XML document.
        ns (dict): A dictionary of XML namespaces.
    """
    def __init__(self, root):
        super(XMLOvalDefinition, self).__init__(root)

    def get_criteria_element(self):
        """
        Retrieves the first 'oval:criteria' element from the XML document.

        Returns:
            xml.etree.ElementTree.Element: The first 'oval:criteria' element found in the XML
            document, or None if no such element is found.
        """
        return self.root.find("oval:criteria", self.ns)

    def get_elements(self):
        """
        Extracts and returns a list of elements from the criteria element.

        The method iterates over the children of the criteria element and identifies the tag of
        each child. Depending on the tag, it extracts relevant attributes and appends them to the
        elements list as tuples.

        Returns:
            list: A list of tuples where each tuple contains the element type and its associated
              attribute value. The possible element types and their attributes are:
              - ("criteria", operator)
              - ("criterion", test_id)
              - ("extend_definition", extend_def_id)
        """
        criteria = self.get_criteria_element()
        elements = []
        for child in criteria.iter():  # iter recurses
            el_tag = get_element_tag_without_ns(child.tag)
            if el_tag == "criteria":
                operator = child.get("operator")
                elements.append(("criteria", operator))
            elif el_tag == "criterion":
                test_id = child.get("test_ref")
                elements.append(("criterion", test_id))
            elif el_tag == "extend_definition":
                extend_def_id = child.get("definition_ref")
                elements.append(("extend_definition", extend_def_id))
        return elements


class XMLOcilQuestionnaire(XMLComponent):
    """
    A class to represent an OCIL Questionnaire in XML format.

    Attributes:
        root (Element): The root element of the XML structure.
        ns (dict): A dictionary of XML namespaces.
    """
    def __init__(self, root):
        super(XMLOcilQuestionnaire, self).__init__(root)

    def get_test_action_ref_element(self):
        """
        Retrieves the test action reference element from the XML.

        This method searches for the 'ocil:test_action_ref' element within the 'ocil:actions'
        section of the XML document using the specified namespace.

        Returns:
            Element: The found 'ocil:test_action_ref' element, or None if not found.
        """
        return self.root.find(
            "ocil:actions/ocil:test_action_ref", self.ns)


class XMLOcilTestAction(XMLComponent):
    """
    A class to represent an OCIL Test Action in XML format.

    Attributes:
        root (Element): The root element of the XML structure.
    """
    def __init__(self, root):
        super(XMLOcilTestAction, self).__init__(root)


class XMLOcilQuestion(XMLComponent):
    """
    A class to represent an OCIL question in XML format.

    Attributes:
        root (Element): The root element of the XML structure.
        ns (dict): The namespace dictionary for XML parsing.
    """
    def __init__(self, root):
        super(XMLOcilQuestion, self).__init__(root)

    def get_question_test_element(self):
        """
        Retrieves the 'question_text' element from the XML tree.

        This method searches for the 'question_text' element within the XML tree using the
        specified namespace.

        Returns:
            Element: The 'question_text' element if found, otherwise None.
        """
        return self.root.find("ocil:question_text", self.ns)


class XMLCPEPlatform(XMLElement):
    """
    A class to represent an XML CPE Platform element.

    Attributes:
        root (xml.etree.ElementTree.Element): The root element of the XML tree.
    """
    def __init__(self, root):
        super(XMLCPEPlatform, self).__init__(root)

    def find_all_check_fact_ref_elements(self):
        return self.root.findall(".//cpe-lang:check-fact-ref", self.ns)
