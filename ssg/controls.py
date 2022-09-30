import collections
import logging
import os
import copy
from glob import glob

import ssg.entities.common
import ssg.yaml
import ssg.utils


class InvalidStatus(Exception):
    pass


class Status:
    SUPPORTED = "supported"
    PLANNED = "planned"
    PENDING = "pending"
    PARTIAL = "partial"
    NOT_APPLICABLE = "not applicable"
    MANUAL = "manual"
    INHERENTLY_MET = "inherently met"
    DOES_NOT_MEET = "does not meet"
    DOCUMENTATION = "documentation"
    AUTOMATED = "automated"

    def __init__(self, status):
        self.status = status

    @classmethod
    def get_status_list(cls):
        valid_statuses = [
            cls.AUTOMATED,
            cls.DOCUMENTATION,
            cls.DOES_NOT_MEET,
            cls.INHERENTLY_MET,
            cls.MANUAL,
            cls.NOT_APPLICABLE,
            cls.PARTIAL,
            cls.PENDING,
            cls.PLANNED,
            cls.SUPPORTED,
        ]
        return valid_statuses

    @classmethod
    def from_control_info(cls, ctrl, status):
        if status is None:
            return cls.PENDING

        valid_statuses = cls.get_status_list()

        if status not in valid_statuses:
            raise InvalidStatus(
                    "The given status '{given}' in the control '{control}' "
                    "was invalid. Please use one of "
                    "the following: {valid}".format(given=status,
                                                    control=ctrl,
                                                    valid=valid_statuses))
        return status

    def __str__(self):
        return self.status

    def __eq__(self, other):
        if isinstance(other, Status):
            return self.status == other.status
        elif isinstance(other, str):
            return self.status == other
        return False


class Control(ssg.entities.common.SelectionHandler):
    def __init__(self):
        super(Control, self).__init__()
        self.id = None
        self.levels = []
        self.notes = ""
        self.title = ""
        self.description = ""
        self.rationale = ""
        self.automated = ""
        self.status = None
        self.mitigation = ""
        self.artifact_description = ""
        self.status_justification = ""
        self.fixtext = ""
        self.check = ""

    def __hash__(self):
        """ Controls are meant to be unique, so using the
        ID should suffice"""
        return hash(self.id)

    @classmethod
    def from_control_dict(cls, control_dict, env_yaml=None, default_level=["default"]):
        control = cls()
        control.id = ssg.utils.required_key(control_dict, "id")
        control.title = control_dict.get("title")
        control.description = control_dict.get("description")
        control.rationale = control_dict.get("rationale")
        control.status = Status.from_control_info(control.id, control_dict.get("status", None))
        control.automated = control_dict.get("automated", "no")
        control.status_justification = control_dict.get('status_justification')
        control.artifact_description = control_dict.get('artifact_description')
        control.mitigation = control_dict.get('mitigation')
        control.fixtext = control_dict.get('fixtext')
        control.check = control_dict.get('check')
        if control.status == "automated":
            control.automated = "yes"
        if control.automated not in ["yes", "no", "partially"]:
            msg = (
                "Invalid value '%s' of automated key in control "
                "%s '%s'. Can be only 'yes', 'no', 'partially'."
                % (control.automated,  control.id, control.title))
            raise ValueError(msg)
        control.levels = control_dict.get("levels", default_level)
        control.notes = control_dict.get("notes", "")
        selections = control_dict.get("rules", {})

        product = None
        product_dir = None
        benchmark_root = None
        if env_yaml:
            product = env_yaml.get('product', None)
            product_dir = env_yaml.get('product_dir', None)
            benchmark_root = env_yaml.get('benchmark_root', None)
            content_dir = os.path.join(product_dir, benchmark_root)

        control.selections = selections

        control.related_rules = control_dict.get("related_rules", [])
        return control


class Level():
    def __init__(self):
        self.id = None
        self.inherits_from = None

    @classmethod
    def from_level_dict(cls, level_dict):
        level = cls()
        level.id = ssg.utils.required_key(level_dict, "id")
        level.inherits_from = level_dict.get("inherits_from")
        return level

class Policy():
    def __init__(self, filepath, env_yaml=None):
        self.id = None
        self.env_yaml = env_yaml
        self.filepath = filepath
        self.controls_dir = os.path.splitext(filepath)[0]
        self.controls = []
        self.controls_by_id = dict()
        self.levels = []
        self.levels_by_id = dict()
        self.title = ""
        self.source = ""

    def _parse_controls_tree(self, tree):
        default_level = ["default"]
        if self.levels:
            default_level = [self.levels[0].id]

        for node in tree:
            try:
                control = Control.from_control_dict(
                    node, self.env_yaml, default_level=default_level)
            except Exception as exc:
                msg = (
                    "Unable to parse controls from {filename}: {error}"
                    .format(filename=self.filepath, error=str(exc)))
                raise RuntimeError(msg)
            if "controls" in node:
                for sc in self._parse_controls_tree(node["controls"]):
                    yield sc
                    control.update_with(sc)
            yield control

    def load(self):
        yaml_contents = ssg.yaml.open_and_expand(self.filepath, self.env_yaml)
        controls_dir = yaml_contents.get("controls_dir")
        if controls_dir:
            self.controls_dir = os.path.join(os.path.dirname(self.filepath), controls_dir)
        self.id = ssg.utils.required_key(yaml_contents, "id")
        self.title = ssg.utils.required_key(yaml_contents, "title")
        self.source = yaml_contents.get("source", "")

        level_list = yaml_contents.get("levels", [])
        for lv in level_list:
            level = Level.from_level_dict(lv)
            self.levels.append(level)
            self.levels_by_id[level.id] = level

        if os.path.exists(self.controls_dir) and os.path.isdir(self.controls_dir):
            controls_tree = yaml_contents.get("controls", list())
            files = os.listdir(self.controls_dir)
            for file in files:
                if file.endswith('.yml'):
                    full_path = os.path.join(self.controls_dir, file)
                    yaml_contents = ssg.yaml.open_and_expand(full_path, self.env_yaml)
                    for control in yaml_contents['controls']:
                        controls_tree.append(control)
                elif file.startswith('.'):
                    continue
                else:
                    raise RuntimeError("Found non yaml file in %s" % self.controls_dir)
        else:
            controls_tree = ssg.utils.required_key(yaml_contents, "controls")
        for c in self._parse_controls_tree(controls_tree):
            self.controls.append(c)
            self.controls_by_id[c.id] = c

    def get_control(self, control_id):
        try:
            c = self.controls_by_id[control_id]
            return c
        except KeyError:
            msg = "%s not found in policy %s" % (
                control_id, self.id
            )
            raise ValueError(msg)

    def get_level(self, level_id):
        try:
            lv = self.levels_by_id[level_id]
            return lv
        except KeyError:
            msg = "Level %s not found in policy %s" % (
                level_id, self.id
            )
            raise ValueError(msg)

    def get_level_with_ancestors_sequence(self, level_id):
        # use OrderedDict for Python2 compatibility instead of ordered set
        levels = collections.OrderedDict()
        level = self.get_level(level_id)
        levels[level] = ""
        if level.inherits_from:
            for lv in level.inherits_from:
                eligible_levels = [l for l in self.get_level_with_ancestors_sequence(lv) if l not in levels.keys()]
                for l in eligible_levels:
                    levels[l] = ""
        return list(levels.keys())


class ControlsManager():
    def __init__(self, controls_dir, env_yaml=None):
        self.controls_dir = os.path.abspath(controls_dir)
        self.env_yaml = env_yaml
        self.policies = {}

    def load(self):
        if not os.path.exists(self.controls_dir):
            return
        for filename in sorted(glob(os.path.join(self.controls_dir, "*.yml"))):
            logging.info("Found file %s" % (filename))
            filepath = os.path.join(self.controls_dir, filename)
            policy = Policy(filepath, self.env_yaml)
            policy.load()
            self.policies[policy.id] = policy

    def get_control(self, policy_id, control_id):
        try:
            policy = self.policies[policy_id]
        except KeyError:
            msg = "policy '%s' doesn't exist" % (policy_id)
            raise ValueError(msg)
        control = policy.get_control(control_id)
        return control

    def _get_policy(self, policy_id):
        try:
            policy = self.policies[policy_id]
        except KeyError:
            msg = "policy '%s' doesn't exist" % (policy_id)
            raise ValueError(msg)
        return policy

    def get_all_controls_of_level(self, policy_id, level_id):
        policy = self._get_policy(policy_id)
        levels = policy.get_level_with_ancestors_sequence(level_id)
        all_policy_controls = self.get_all_controls(policy_id)
        eligible_controls = []
        already_defined_variables = set()
        # we will go level by level, from top to bottom
        # this is done to enable overriding of variables by higher levels
        for lv in levels:
            for control in all_policy_controls:
                if lv.id not in control.levels:
                    continue

                variables = set(control.variables.keys())

                variables_to_remove = variables.intersection(already_defined_variables)
                already_defined_variables.update(variables)

                new_c = self._get_control_without_variables(variables_to_remove, control)
                eligible_controls.append(new_c)

        return eligible_controls

    @staticmethod
    def _get_control_without_variables(variables_to_remove, control):
        if not variables_to_remove:
            return control

        new_c = copy.deepcopy(control)
        for var in variables_to_remove:
            del new_c.variables[var]
        return new_c

    def get_all_controls(self, policy_id):
        policy = self._get_policy(policy_id)
        return policy.controls_by_id.values()
