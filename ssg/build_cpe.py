"""
Common functions for building CPEs
"""

from __future__ import absolute_import
from __future__ import print_function
import os
import sys
import ssg.id_translate

from .constants import oval_namespace
from .constants import PREFIX_TO_NS
from .utils import required_key, apply_formatting_on_dict_values
from .xml import ElementTree as ET
from .boolean_expression import Algebra, Symbol, Function
from .entities.common import XCCDFEntity, Templatable
from .yaml import convert_string_to_bool


class CPEDoesNotExist(Exception):
    pass


class ProductCPEs(object):
    """
    Reads from the disk all the yaml CPEs related to a product
    and provides them in a structured way.
    """

    def __init__(self):

        self.cpes_by_id = {}
        self.cpes_by_name = {}
        self.product_cpes = {}
        self.platforms = {}
        self.cpe_oval_href = ""
        self.algebra = Algebra(
            symbol_cls=CPEALCheckFactRef, function_cls=CPEALLogicalTest)

    def load_product_cpes(self, env_yaml):
        self.cpe_oval_href = "ssg-" + env_yaml["product"] + "-cpe-oval.xml"
        try:
            product_cpes_list = env_yaml["cpes"]
            self.load_product_cpes_from_list(product_cpes_list)
        except KeyError as exc:
            raise Exception("Product %s does not define 'cpes'" % (env_yaml["product"]))

    def load_product_cpes_from_list(self, product_cpes_list):
        for cpe_dict_repr in product_cpes_list:
            for cpe_id, cpe in cpe_dict_repr.items():
                # these product CPEs defined in product.yml are defined
                # differently than CPEs in shared/applicability/*.yml
                # therefore we have to place the ID at the place where it is expected
                cpe["id_"] = cpe_id
                cpe_item = CPEItem.get_instance_from_full_dict(cpe)
                cpe_item.is_product_cpe = True
                self.add_cpe_item(cpe_item)

    def load_content_cpes(self, env_yaml):
        cpes_root = required_key(env_yaml, "cpes_root")
        if not os.path.isabs(cpes_root):
            cpes_root = os.path.join(env_yaml["product_dir"], cpes_root)
        self.load_cpes_from_directory_tree(cpes_root, env_yaml)

    def load_cpes_from_list(self, cpes_list):
        for cpe_dict_repr in cpes_list:
            for cpe_id, cpe in cpe_dict_repr.items():
                cpe["id_"] = cpe_id
                cpe_item = CPEItem.get_instance_from_full_dict(cpe)
                self.add_cpe_item(cpe_item)

    def load_cpes_from_directory_tree(self, root_path, env_yaml):
        for dir_item in sorted(os.listdir(root_path)):
            dir_item_path = os.path.join(root_path, dir_item)
            if not os.path.isfile(dir_item_path):
                continue

            _, ext = os.path.splitext(os.path.basename(dir_item_path))
            if ext != '.yml':
                sys.stderr.write(
                    "Encountered file '%s' while looking for content CPEs, "
                    "extension '%s' is unknown. Skipping..\n"
                    % (dir_item, ext)
                )
                continue

            cpe_item = CPEItem.from_yaml(dir_item_path, env_yaml)
            self.add_cpe_item(cpe_item)

    def add_cpe_item(self, cpe_item):
        self.cpes_by_id[cpe_item.id_] = cpe_item
        self.cpes_by_name[cpe_item.name] = cpe_item
        if cpe_item.is_product_cpe:
            self.product_cpes[cpe_item.id_] = cpe_item

    def get_cpe(self, cpe_id_or_name):
        try:
            if CPEItem.is_cpe_name(cpe_id_or_name):
                return self.cpes_by_name[cpe_id_or_name]
            else:
                if CPEALCheckFactRef.cpe_id_is_parametrized(cpe_id_or_name):
                    cpe_id_or_name = CPEALCheckFactRef.get_base_name_of_parametrized_cpe_id(
                        cpe_id_or_name)
                return self.cpes_by_id[cpe_id_or_name]
        except KeyError:
            raise CPEDoesNotExist("CPE %s is not defined" % cpe_id_or_name)

    def add_resolved_cpe_items_from_platform(self, platform):
        for fact_ref in platform.get_fact_refs():
            if fact_ref.arg:  # the CPE item is parametrized
                try:
                    # if there already exists a CPE item with factref's ID
                    # we can just use it right away, no new CPE items need to be created
                    cpe = self.get_cpe_for_fact_ref(fact_ref)
                    fact_ref.cpe_name = cpe.name
                except CPEDoesNotExist:
                    # if the CPE item with factref's ID does not exist
                    # it means that we need to create a new CPE item
                    # which will have parameters in place
                    cpe = self.get_cpe(fact_ref.cpe_name)
                    new_cpe = cpe.create_resolved_cpe_item_for_fact_ref(fact_ref)
                    self.add_cpe_item(new_cpe)
                    fact_ref.cpe_name = new_cpe.name

    def get_cpe_for_fact_ref(self, fact_ref):
        return self.get_cpe(fact_ref.as_id())

    def get_cpe_name(self, cpe_id):
        cpe = self.get_cpe(cpe_id)
        return cpe.name

    def get_product_cpe_names(self):
        return [cpe.name for cpe in self.product_cpes.values()]


class CPEList(object):
    """
    Represents the cpe-list element from the CPE standard.
    """

    prefix = "cpe-dict"
    ns = PREFIX_TO_NS[prefix]

    def __init__(self):
        self.cpe_items = []

    def add(self, cpe_item):
        self.cpe_items.append(cpe_item)

    def to_xml_element(self, cpe_oval_file):
        cpe_list = ET.Element("{%s}cpe-list" % CPEList.ns)
        cpe_list.set("xmlns:xsi", "http://www.w3.org/2001/XMLSchema-instance")
        cpe_list.set("xsi:schemaLocation",
                     "http://cpe.mitre.org/dictionary/2.0 "
                     "http://cpe.mitre.org/files/cpe-dictionary_2.1.xsd")

        self.cpe_items.sort(key=lambda cpe: cpe.name)
        for cpe_item in self.cpe_items:
            cpe_list.append(cpe_item.to_xml_element(cpe_oval_file))

        return cpe_list

    def to_file(self, file_name, cpe_oval_file):
        root = self.to_xml_element(cpe_oval_file)
        tree = ET.ElementTree(root)
        tree.write(file_name, encoding="utf-8")


class CPEItem(XCCDFEntity, Templatable):
    """
    Represents the cpe-item element from the CPE standard.
    """

    KEYS = dict(
        name=lambda: "",
        check_id=lambda: "",
        bash_conditional=lambda: "",
        ansible_conditional=lambda: "",
        is_product_cpe=lambda: False,
        versioned=lambda: False,
        args=lambda: {},
        ** XCCDFEntity.KEYS
    )
    KEYS.update(**Templatable.KEYS)

    MANDATORY_KEYS = [
        "name",
    ]

    prefix = "cpe-dict"
    ns = PREFIX_TO_NS[prefix]

    @property
    def cpe_oval_short_def_id(self):
        return self.check_id or self.id_

    @property
    def cpe_oval_def_id(self):
        translator = ssg.id_translate.IDTranslator("ssg")
        full_id = translator.generate_id(
            "{" + oval_namespace + "}definition", self.cpe_oval_short_def_id)
        return full_id

    def to_xml_element(self, cpe_oval_filename):
        cpe_item = ET.Element("{%s}cpe-item" % CPEItem.ns)
        cpe_item.set('name', self.name)

        cpe_item_title = ET.SubElement(cpe_item, "{%s}title" % CPEItem.ns)
        cpe_item_title.set('xml:lang', "en-us")
        cpe_item_title.text = self.title

        cpe_item_check = ET.SubElement(cpe_item, "{%s}check" % CPEItem.ns)
        cpe_item_check.set('system', oval_namespace)
        cpe_item_check.set('href', cpe_oval_filename)
        cpe_item_check.text = self.cpe_oval_short_def_id
        return cpe_item

    @classmethod
    def from_yaml(cls, yaml_file, env_yaml=None, product_cpes=None):
        cpe_item = super(CPEItem, cls).from_yaml(yaml_file, env_yaml, product_cpes)
        if cpe_item.is_product_cpe:
            cpe_item.is_product_cpe = convert_string_to_bool(cpe_item.is_product_cpe)
        if cpe_item.versioned:
            cpe_item.versioned = convert_string_to_bool(cpe_item.versioned)
        return cpe_item

    def set_template_variables(self, *sources):
        if self.is_templated():
            self.template["vars"] = {}
            for source in sources:
                self.template["vars"].update(source)

    def create_resolved_cpe_item_for_fact_ref(self, fact_ref):
        if fact_ref.has_version_specs():
            if not self.versioned:
                raise ValueError("CPE entity '{0}' does not support version specifiers: "
                                 "{1}".format(self.id_, fact_ref.cpe_name))
        try:
            resolved_parameters = self.args[fact_ref.arg]
        except KeyError:
            raise KeyError(
                "The {0} CPE item does not support the argument {1}. "
                "Following arguments are supported: {2}".format(
                    self.id_, fact_ref.arg, [a for a in self.args.keys()]))
        resolved_parameters.update(fact_ref.as_dict())
        cpe_item_as_dict = self.represent_as_dict()
        cpe_item_as_dict["args"] = None
        cpe_item_as_dict["id_"] = fact_ref.as_id()
        new_associated_cpe_item_as_dict = apply_formatting_on_dict_values(
            cpe_item_as_dict, resolved_parameters)
        new_associated_cpe_item = CPEItem.get_instance_from_full_dict(
            new_associated_cpe_item_as_dict)
        new_associated_cpe_item.set_template_variables(resolved_parameters)
        return new_associated_cpe_item

    @staticmethod
    def is_cpe_name(cpe_id_or_name):
        return cpe_id_or_name.startswith("cpe:")

    def set_conditional(self, language, content):
        if language == "ansible":
            self.ansible_conditional = content
        elif language == "bash":
            self.bash_conditional = content
        else:
            raise RuntimeError(
                "The language {0} is not supported as conditional for CPE".format(language))


class CPEALLogicalTest(Function):

    prefix = "cpe-lang"
    ns = PREFIX_TO_NS[prefix]

    def to_xml_element(self):
        cpe_test = ET.Element("{%s}logical-test" % CPEALLogicalTest.ns)
        cpe_test.set('operator', ('OR' if self.is_or() else 'AND'))
        cpe_test.set('negate', ('true' if self.is_not() else 'false'))
        # Logical tests must go first, therefore we separate tests and factrefs
        tests = [t for t in self.args if isinstance(t, CPEALLogicalTest)]
        factrefs = [f for f in self.args if isinstance(f, CPEALCheckFactRef)]
        for obj in tests + factrefs:
            cpe_test.append(obj.to_xml_element())

        return cpe_test

    def enrich_with_cpe_info(self, cpe_products):
        for arg in self.args:
            arg.enrich_with_cpe_info(cpe_products)

    def to_bash_conditional(self):
        child_bash_conds = [
            a.to_bash_conditional() for a in self.args
            if a.to_bash_conditional() != '']

        if not child_bash_conds:
            return ""

        cond = ""
        if self.is_not():
            cond += "! "
            op = " "
        cond += "( "
        if self.is_or():
            op = " || "
        elif self.is_and():
            op = " && "
        cond += op.join(child_bash_conds)
        cond += " )"
        return cond

    def to_ansible_conditional(self):
        child_ansible_conds = [
            a.to_ansible_conditional() for a in self.args
            if a.to_ansible_conditional() != '']

        if not child_ansible_conds:
            return ""

        cond = ""
        if self.is_not():
            cond += "not "
            op = " "
        cond += "( "
        if self.is_or():
            op = " or "
        elif self.is_and():
            op = " and "
        cond += op.join(child_ansible_conds)
        cond += " )"
        return cond


class CPEALCheckFactRef(Symbol):

    prefix = "cpe-lang"
    ns = PREFIX_TO_NS[prefix]

    def __init__(self, obj):
        super(CPEALCheckFactRef, self).__init__(obj)
        self.cpe_name = obj  # we do not want to modify original name used for platforms
        self.bash_conditional = ""
        self.ansible_conditional = ""

    def enrich_with_cpe_info(self, cpe_products):
        self.cpe_oval_href = cpe_products.cpe_oval_href
        cpe_item = cpe_products.get_cpe(self.cpe_name)
        self.bash_conditional = cpe_item.bash_conditional
        self.ansible_conditional = cpe_item.ansible_conditional
        self.cpe_name = cpe_products.get_cpe_name(self.cpe_name)
        self.cpe_oval_def_id = cpe_item.cpe_oval_def_id

    def to_xml_element(self):
        el = ET.Element("{%s}check-fact-ref" % CPEALCheckFactRef.ns)
        el.set("system", oval_namespace)
        el.set("href", self.cpe_oval_href)
        el.set("id-ref", self.cpe_oval_def_id)
        return el

    def to_bash_conditional(self):
        return self.bash_conditional

    def to_ansible_conditional(self):
        return self.ansible_conditional

    @staticmethod
    def cpe_id_is_parametrized(cpe_id):
        return Symbol.is_parametrized(cpe_id)

    @staticmethod
    def get_base_name_of_parametrized_cpe_id(cpe_id):
        """
        If given a parametrized platform name such as package[test],
        it returns the package part only.
        """
        return Symbol.get_base_of_parametrized_name(cpe_id)


def extract_subelement(objects, sub_elem_type):
    """
    From a collection of element objects, return the value of
    the first attribute of name sub_elem_type found.

    This is useful when the object is a single element and
    we wish to query some external reference identifier
    in the subtree of that element.
    """

    for obj in objects:
        for subelement in obj.iter():
            if subelement.get(sub_elem_type):
                sub_element = subelement.get(sub_elem_type)
                return sub_element


def extract_env_obj(objects, local_var):
    """
    From a collection of objects, return the object with id matching
    the object_ref of the local variable.

    NOTE: This assumes that a local variable can only reference one object.
    Which is not true, variables can reference multiple objects.
    But this assumption should work for OVAL checks for CPEs,
    as they are not that complicated.
    """

    for obj in objects:
        env_id = extract_subelement(local_var, 'object_ref')
        if env_id == obj.get('id'):
            return obj

    return None


def extract_referred_nodes(tree_with_refs, tree_with_ids, attrname):
    """
    Return the elements in tree_with_ids which are referenced
    from tree_with_refs via the element attribute 'attrname'.
    """

    reflist = []
    elementlist = []

    for element in tree_with_refs.iter():
        value = element.get(attrname)
        if value is not None:
            reflist.append(value)

    for element in tree_with_ids.iter():
        if element.get("id") in reflist:
            elementlist.append(element)

    return elementlist
