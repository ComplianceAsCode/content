import logging

from .general import OVALBaseObject
from .oval_definition_references import OVALDefinitionReference
from .oval_entities import (
    load_definition,
    load_object,
    load_state,
    load_test,
    load_variable,
)


class ExceptionDuplicateOVALEntity(Exception):
    pass


def _is_external_variable(component):
    return "external_variable" in component.tag


def _handle_existing_id(component, component_dict):
    # ID is identical, but OVAL entities are semantically different =>
    # report and error and exit with failure
    # Fixes: https://github.com/ComplianceAsCode/content/issues/1275
    if (
        component != component_dict[component.id_]
        and not _is_external_variable(component)
        and not _is_external_variable(component_dict[component.id_])
    ):
        # This is an error scenario - since by skipping second
        # implementation and using the first one for both references,
        # we might evaluate wrong requirement for the second entity
        # => report an error and exit with failure in that case
        # See
        #   https://github.com/ComplianceAsCode/content/issues/1275
        # for a reproducer and what could happen in this case
        raise ExceptionDuplicateOVALEntity(
            (
                "ERROR: it's not possible to use the same ID: {} for two semantically"
                " different OVAL entities:\nFirst entity:\n{}\nSecond entity:\n{}\n"
                "Use different ID for the second entity!!!\n"
            ).format(
                component.id_,
                str(component),
                str(component_dict[component.id_]),
            )
        )
    elif not _is_external_variable(component):
        # If OVAL entity is identical, but not external_variable, the
        # implementation should be rewritten each entity to be present
        # just once
        logging.info(
            (
                "OVAL ID {} is used multiple times and should represent "
                "the same elements.\nRewrite the OVAL checks. Place the identical IDs"
                " into their own definition and extend this definition by it."
            ).format(component.id_)
        )


def add_oval_component(component, component_dict):
    if component.id_ not in component_dict:
        component_dict[component.id_] = component
    else:
        _handle_existing_id(component, component_dict)


def _copy_component(destination, source_of_components):
    for component in source_of_components.values():
        add_oval_component(component, destination)


def _remove_keys_from_dict(dict_, to_remove):
    for k in to_remove:
        dict_.pop(k, None)


def _keep_keys_in_dict(dict_, to_keep):
    to_remove = [key for key in dict_ if key not in to_keep]
    _remove_keys_from_dict(dict_, to_remove)


def _save_referenced_vars(ref, entity):
    ref.save_variables(entity.get_variable_references())


def _save_definitions_references(ref, definition):
    if definition.criteria:
        ref.save_tests(definition.criteria.get_test_references())
        ref.save_definitions(definition.criteria.get_extend_definition_references())


def _save_test_references(ref, test):
    ref.save_object(test.object_ref)
    ref.save_states(test.state_refs)


def _save_object_references(ref, object_):
    _save_referenced_vars(ref, object_)
    ref.save_states(object_.get_state_references())
    ref.save_objects(object_.get_object_references())


def _save_variable_references(ref, variable):
    _save_referenced_vars(ref, variable)
    ref.save_objects(variable.get_object_references())


class OVALContainer(OVALBaseObject):
    def __init__(self):
        super(OVALContainer, self).__init__("")
        self.definitions = {}
        self.tests = {}
        self.objects = {}
        self.states = {}
        self.variables = {}
        self.MAP_COMPONENT_DICT = {
            "definitions": self.definitions,
            "tests": self.tests,
            "objects": self.objects,
            "states": self.states,
            "variables": self.variables,
        }

    def _call_function_for_every_component(self, _function, object_):
        _function(self.definitions, object_.definitions)
        _function(self.tests, object_.tests)
        _function(self.objects, object_.objects)
        _function(self.states, object_.states)
        _function(self.variables, object_.variables)

    def load_definition(self, oval_definition_xml_el):
        definition = load_definition(oval_definition_xml_el)
        add_oval_component(definition, self.definitions)

    def load_test(self, oval_test_xml_el):
        test = load_test(oval_test_xml_el)
        add_oval_component(test, self.tests)

    def load_object(self, oval_object_xml_el):
        object_ = load_object(oval_object_xml_el)
        add_oval_component(object_, self.objects)

    def load_state(self, oval_state_xml_element):
        state = load_state(oval_state_xml_element)
        add_oval_component(state, self.states)

    def load_variable(self, oval_variable_xml_element):
        variable = load_variable(oval_variable_xml_element)
        add_oval_component(variable, self.variables)

    def add_content_of_container(self, container):
        self._call_function_for_every_component(_copy_component, container)

    @staticmethod
    def _skip_if_is_none(value, component_id):
        raise NotImplementedError()

    def _process_component(self, ref, type_, function_save_refs):
        source = self.MAP_COMPONENT_DICT.get(type_)
        to_process, id_getter = ref.get_to_process_dict_and_id_getter(type_)
        while to_process:
            id_ = id_getter()
            entity = source.get(id_)
            if self._skip_if_is_none(entity, id_):
                continue
            function_save_refs(ref, entity)

    def _process_definition_references(self, ref):
        self._process_component(
            ref,
            "definitions",
            _save_definitions_references,
        )

    def _process_test_references(self, ref):
        self._process_component(
            ref,
            "tests",
            _save_test_references,
        )

    def _process_object_references(self, ref):
        self._process_component(
            ref,
            "objects",
            _save_object_references,
        )

    def _process_state_references(self, ref):
        self._process_component(
            ref,
            "states",
            _save_referenced_vars,
        )

    def _process_variable_references(self, ref):
        self._process_component(
            ref,
            "variables",
            _save_variable_references,
        )

    def _process_objects_states_variables_references(self, ref):
        while (
            ref.to_process_objects or ref.to_process_states or ref.to_process_variables
        ):
            self._process_object_references(ref)
            self._process_state_references(ref)
            self._process_variable_references(ref)

    def get_all_references_of_definition(self, definition_id):
        if definition_id not in self.definitions:
            raise ValueError(
                "ERROR: OVAL definition '{}' doesn't exist.".format(definition_id)
            )
        ref = OVALDefinitionReference(definition_id)
        self._process_definition_references(ref)
        self._process_test_references(ref)
        self._process_objects_states_variables_references(ref)
        return ref

    def keep_referenced_components(self, ref):
        self._call_function_for_every_component(_keep_keys_in_dict, ref)

    def _translate(self, translator, dict_, store_defname=False):
        for component_id in list(dict_.keys()):
            component = dict_[component_id]
            component.translate_id(translator, store_defname)
            translated_id = translator.generate_id(component.tag_name, component_id)
            del dict_[component_id]
            dict_[translated_id] = component

    def translate_id(self, translator, store_defname=False):
        for dict_ in self.MAP_COMPONENT_DICT.values():
            self._translate(translator, dict_, store_defname)
