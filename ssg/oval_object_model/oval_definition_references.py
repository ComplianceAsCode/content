def _process(list_, to_process_list):
    id_ = to_process_list.pop()
    if id_ not in list_:
        list_.append(id_)
    return id_


def _save(id_, list_, to_process_list):
    if id_ not in list_:
        list_.append(id_)
        to_process_list.append(id_)


def _save_multiple(list_of_ids, list_, to_process_list):
    for id_ in list_of_ids:
        _save(id_, list_, to_process_list)


class OVALDefinitionReference:
    def __init__(self, definition_id=None):
        self.definitions = []
        self.to_process_definitions = []
        if definition_id is not None:
            self.definitions.append(definition_id)
            self.to_process_definitions.append(definition_id)

        self.tests = []
        self.objects = []
        self.states = []
        self.variables = []

        self.to_process_tests = []
        self.to_process_objects = []
        self.to_process_states = []
        self.to_process_variables = []

    def is_done(self):
        return (
            len(self.to_process_definitions) == 0
            and len(self.to_process_tests) == 0
            and len(self.to_process_objects) == 0
            and len(self.to_process_states) == 0
            and len(self.to_process_variables) == 0
        )

    def __iadd__(self, other):
        self.definitions.extend(other.definitions)
        self.tests.extend(other.tests)
        self.objects.extend(other.objects)
        self.states.extend(other.states)
        self.variables.extend(other.variables)
        return self

    def __repr__(self):
        return str(self.__dict__)

    def get_to_process_dict_and_id_getter(self, key):
        MAP_ID_GETTERS = {
            "definitions": self.process_definition,
            "tests": self.process_test,
            "objects": self.process_object,
            "states": self.process_state,
            "variables": self.process_variable,
        }
        MAP_TO_PROCESS = {
            "definitions": self.to_process_definitions,
            "tests": self.to_process_tests,
            "objects": self.to_process_objects,
            "states": self.to_process_states,
            "variables": self.to_process_variables,
        }
        return (MAP_TO_PROCESS.get(key), MAP_ID_GETTERS.get(key))

    def process_definition(self):
        return _process(self.definitions, self.to_process_definitions)

    def save_definition(self, id_):
        _save(id_, self.definitions, self.to_process_definitions)

    def save_definitions(self, definition_ids):
        _save_multiple(definition_ids, self.definitions, self.to_process_definitions)

    def process_test(self):
        return _process(self.tests, self.to_process_tests)

    def save_test(self, id_):
        _save(id_, self.tests, self.to_process_tests)

    def save_tests(self, test_ids):
        _save_multiple(test_ids, self.tests, self.to_process_tests)

    def process_object(self):
        return _process(self.objects, self.to_process_objects)

    def save_object(self, id_):
        _save(id_, self.objects, self.to_process_objects)

    def save_objects(self, object_ids):
        _save_multiple(object_ids, self.objects, self.to_process_objects)

    def process_state(self):
        return _process(self.states, self.to_process_states)

    def save_state(self, id_):
        _save(id_, self.states, self.to_process_states)

    def save_states(self, state_ids):
        _save_multiple(state_ids, self.states, self.to_process_states)

    def process_variable(self):
        return _process(self.variables, self.to_process_variables)

    def save_variable(self, id_):
        _save(id_, self.variables, self.to_process_variables)

    def save_variables(self, variable_ids):
        _save_multiple(variable_ids, self.variables, self.to_process_variables)
