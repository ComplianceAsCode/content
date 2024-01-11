import collections
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


class Control(ssg.entities.common.SelectionHandler, ssg.entities.common.XCCDFEntity):
    KEYS = dict(
        id=str,
        levels=list,
        notes=str,
        title=str,
        description=str,
        rationale=str,
        automated=str,
        status=None,
        mitigation=str,
        artifact_description=str,
        status_justification=str,
        fixtext=str,
        check=str,
        tickets=list,
        original_title=str,
        related_rules=list,
        rules=list,
        controls=list,
    )

    MANDATORY_KEYS = {
        "title",
    }

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
        self.controls = []
        self.tickets = []
        self.original_title = ""
        self.related_rules = []
        self.rules = []

    def __hash__(self):
        """ Controls are meant to be unique, so using the
        ID should suffice"""
        return hash(self.id)

    @classmethod
    def _check_keys(cls, control_dict):
        for key in control_dict.keys():
            # Rules shouldn't be in KEYS that data is in selections
            if key not in cls.KEYS.keys() and key not in ['rules', ]:
                raise ValueError("Key %s is not allowed in a control file." % key)

    @classmethod
    def from_control_dict(cls, control_dict, env_yaml=None, default_level=["default"]):
        cls._check_keys(control_dict)
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
        control.tickets = control_dict.get('tickets')
        control.original_title = control_dict.get('original_title')
        control.related_rules = control_dict.get('related_rules')
        control.rules = control_dict.get('rules')

        if control.status == "automated":
            control.automated = "yes"
        if control.automated not in ["yes", "no", "partially"]:
            msg = (
                "Invalid value '%s' of automated key in control "
                "%s '%s'. Can be only 'yes', 'no', 'partially'."
                % (control.automated,  control.id, control.title))
            raise ValueError(msg)
        control.levels = control_dict.get("levels", default_level)
        if type(control.levels) is not list:
            msg = "Levels for %s must be an array" % control.id
            raise ValueError(msg)
        control.notes = control_dict.get("notes", "")
        selections = control_dict.get("rules", {})

        control.selections = selections

        control.related_rules = control_dict.get("related_rules", [])
        control.rules = control_dict.get("rules", [])
        return control

    def represent_as_dict(self):
        data = super(Control, self).represent_as_dict()
        data["rules"] = self.selections
        data["controls"] = self.controls
        return data


class Level(ssg.entities.common.XCCDFEntity):
    KEYS = dict(
        id=lambda: str,
        inherits_from=lambda: None,
    )

    def __init__(self):
        self.id = None
        self.inherits_from = None

    @classmethod
    def from_level_dict(cls, level_dict):
        level = cls()
        level.id = ssg.utils.required_key(level_dict, "id")
        level.inherits_from = level_dict.get("inherits_from")
        return level


class Policy(ssg.entities.common.XCCDFEntity):
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

    def represent_as_dict(self):
        data = dict()
        data["id"] = self.id
        data["title"] = self.title
        data["source"] = self.source
        data["definition_location"] = self.filepath
        data["controls"] = [c.represent_as_dict() for c in self.controls]
        data["levels"] = [l.represent_as_dict() for l in self.levels]
        return data

    @property
    def default_level(self):
        result = ["default"]
        if self.levels:
            result = [self.levels[0].id]
        return result

    def check_all_rules_exist(self, existing_rules):
        for c in self.controls:
            nonexisting_rules = set(c.selected) - existing_rules
            if nonexisting_rules:
                msg = "Control %s:%s contains nonexisting rule(s) %s" % (
                    self.id, c.id, ", ".join(nonexisting_rules))
                raise ValueError(msg)

    def check_levels_validity(self):
        """
        This function goes through all controls in the policy and checks if all
        levels defined for individual controls are valid for the policy.
        If the policy has no levels defined, then all controls should have the
        "default" level defined (this is defined implicitly).
        """
        for c in self.controls:
            expected_levels = [lvl.id for lvl in self.levels]
            for lvl in c.levels:
                if lvl not in expected_levels:
                    msg = ("Invalid level {0} used in control {1} "
                           "defined at {2}. Allowed levels are: {3}".format(
                            lvl, c.id, self.filepath, expected_levels))
                    raise ValueError(msg)

    def remove_selections_not_known(self, known_rules):
        for c in self.controls:
            selections = set(c.selected).intersection(known_rules)
            c.selected = list(selections)
            unselections = set(c.unselected).intersection(known_rules)
            c.unselected = list(unselections)

    def _create_control_from_subtree(self, subtree):
        try:
            control = Control.from_control_dict(
                subtree, self.env_yaml, default_level=self.default_level)
        except Exception as exc:
            msg = (
                "Unable to parse controls from {filename}: {error}"
                .format(filename=self.filepath, error=str(exc)))
            raise RuntimeError(msg)
        return control

    def _extract_and_record_subcontrols(self, current_control, controls_tree):
        subcontrols = []
        if "controls" not in controls_tree:
            return subcontrols

        for control_def_or_ref in controls_tree["controls"]:
            if isinstance(control_def_or_ref, str):
                control_ref = control_def_or_ref
                current_control.controls.append(control_ref)
                continue
            control_def = control_def_or_ref
            for sc in self._parse_controls_tree([control_def]):
                current_control.controls.append(sc.id)
                current_control.update_with(sc)
                subcontrols.append(sc)
        return subcontrols

    def _parse_controls_tree(self, tree):
        controls = []

        for control_subtree in tree:
            control = self._create_control_from_subtree(control_subtree)
            subcontrols = self._extract_and_record_subcontrols(control, control_subtree)
            controls.extend(subcontrols)
            controls.append(control)
        return controls

    def save_controls_tree(self, tree):
        for c in self._parse_controls_tree(tree):
            self.controls.append(c)
            self.controls_by_id[c.id] = c

    def _parse_file_into_control_trees(self, dirname, basename):
        controls_trees = []
        if basename.endswith('.yml'):
            full_path = os.path.join(dirname, basename)
            yaml_contents = ssg.yaml.open_and_expand(full_path, self.env_yaml)
            for control in yaml_contents['controls']:
                controls_trees.append(control)
        elif basename.startswith('.'):
            pass
        else:
            raise RuntimeError("Found non yaml file in %s" % self.controls_dir)
        return controls_trees

    def _load_from_subdirectory(self, yaml_contents):
        controls_tree = yaml_contents.get("controls", list())
        files = os.listdir(self.controls_dir)
        for file in files:
            trees = self._parse_file_into_control_trees(self.controls_dir, file)
            controls_tree.extend(trees)
        return controls_tree

    def load(self):
        yaml_contents = ssg.yaml.open_and_expand(self.filepath, self.env_yaml)
        controls_dir = yaml_contents.get("controls_dir")
        if controls_dir:
            self.controls_dir = os.path.join(os.path.dirname(self.filepath), controls_dir)
        self.id = ssg.utils.required_key(yaml_contents, "id")
        self.title = ssg.utils.required_key(yaml_contents, "title")
        self.source = yaml_contents.get("source", "")

        default_level_dict = {"id": "default"}
        level_list = yaml_contents.get("levels", [default_level_dict])
        for lv in level_list:
            level = Level.from_level_dict(lv)
            self.levels.append(level)
            self.levels_by_id[level.id] = level

        if os.path.exists(self.controls_dir) and os.path.isdir(self.controls_dir):
            controls_tree = self._load_from_subdirectory(yaml_contents)
        else:
            controls_tree = ssg.utils.required_key(yaml_contents, "controls")
        self.save_controls_tree(controls_tree)
        self.check_levels_validity()

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
    def __init__(self, controls_dir, env_yaml=None, existing_rules=None):
        self.controls_dir = os.path.abspath(controls_dir)
        self.env_yaml = env_yaml
        self.existing_rules = existing_rules
        self.policies = {}

    def load(self):
        if not os.path.exists(self.controls_dir):
            return
        for filename in sorted(glob(os.path.join(self.controls_dir, "*.yml"))):
            filepath = os.path.join(self.controls_dir, filename)
            policy = Policy(filepath, self.env_yaml)
            policy.load()
            self.policies[policy.id] = policy
        self.check_all_rules_exist()
        self.resolve_controls()

    def check_all_rules_exist(self):
        if self.existing_rules is None:
            return
        for p in self.policies.values():
            p.check_all_rules_exist(self.existing_rules)

    def remove_selections_not_known(self, known_rules):
        known_rules = set(known_rules)
        for p in self.policies.values():
            p.remove_selections_not_known(known_rules)

    def resolve_controls(self):
        for pid, policy in self.policies.items():
            for control in policy.controls:
                self._resolve_control(pid, control)

    def _resolve_control(self, pid, control):
        for sub_name in control.controls:
            policy_id = pid
            if ":" in sub_name:
                policy_id, sub_name = sub_name.split(":", 1)
            subcontrol = self.get_control(policy_id, sub_name)
            self._resolve_control(pid, subcontrol)
            control.update_with(subcontrol)

    def get_control(self, policy_id, control_id):
        policy = self._get_policy(policy_id)
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

    def save_everything(self, output_dir):
        ssg.utils.mkdir_p(output_dir)
        for policy_id, policy in self.policies.items():
            filename = os.path.join(output_dir, "{}.{}".format(policy_id, "yml"))
            policy.dump_yaml(filename)
