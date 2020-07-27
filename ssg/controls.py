import collections
import logging
import os

import ssg.yaml
import ssg.utils


class Control():
    def __init__(self):
        self.id = None
        self.rules = []
        self.variables = {}
        self.level = ""

    @classmethod
    def from_control_dict(cls, control_dict, default_level=""):
        control = cls()
        control.title = control_dict.get("title")
        control.description = control_dict.get("description")
        control.level = control_dict.get("level", default_level)
        control.automated = control_dict.get("automated", False)
        selections = control_dict.get("rules", [])
        for item in selections:
            if "=" in item:
                varname, value = item.split("=", 1)
                control.variables[varname] = value
            else:
                control.rules.append(item)
        control.related_rules = control_dict.get("related_rules", [])
        control.note = control_dict.get("note")
        control.id = ssg.utils.required_key(control_dict, "id")
        control.title = control_dict.get("title")
        control.description = control_dict.get("description")
        control.automated = control_dict.get("automated", False)
        return control


class Policy():
    def __init__(self, filepath, env_yaml=None):
        self.id = None
        self.env_yaml = env_yaml
        self.filepath = filepath
        self.controls = {}
        self.levels = []
        self.level_value = {}

    def _parse_controls_tree(self, tree):
        default_level = ""
        if self.levels:
            default_level = self.levels[0]

        for node in tree:
            control = Control.from_control_dict(node, default_level=default_level)
            if "controls" in node:
                for sc in self._parse_controls_tree(node["controls"]):
                    yield sc
                    control.rules.extend(sc.rules)
                    control.variables.update(sc.variables)
                    control.related_rules.extend(sc.related_rules)
            yield control

    def load(self):
        yaml_contents = ssg.yaml.open_and_expand(self.filepath, self.env_yaml)
        self.id = ssg.utils.required_key(yaml_contents, "id")

        self.levels = yaml_contents.get("levels", ["default"])
        for i, level in enumerate(self.levels):
            self.level_value[level] = i

        controls_tree = ssg.utils.required_key(yaml_contents, "controls")
        self.controls = {
            c.id: c for c in self._parse_controls_tree(controls_tree)}

    def get_control(self, control_id):
        try:
            c = self.controls[control_id]
            return c
        except KeyError:
            msg = "%s not found in policy %s" % (
                control_id, self.id
            )
            raise ValueError(msg)


class ControlsManager():
    def __init__(self, controls_dir, env_yaml=None):
        self.controls_dir = os.path.abspath(controls_dir)
        self.env_yaml = env_yaml
        self.policies = {}

    def load(self):
        if not os.path.exists(self.controls_dir):
            return
        for filename in os.listdir(self.controls_dir):
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

    def _get_policy_level_value(self, policy, level_id):
        if not level_id:
            return 0

        if level_id not in policy.levels:
            msg = (
                "Control level {level_id} not compatible with policy {policy_id}"
                .format(level_id=level_id, policy_id=policy_id)
            )
            raise ValueError(msg)
        return policy.level_value[level_id]

    def get_all_controls_of_level_at_least(self, policy_id, level_id=None):
        policy = self._get_policy(policy_id)
        level = self._get_policy_level_value(policy, level_id)

        all_policy_controls = self.get_all_controls(policy_id)
        eligible_controls = [
                c for c in all_policy_controls
                if policy.level_value[c.level] <= level]
        return eligible_controls

    def get_all_controls(self, policy_id):
        policy = self._get_policy(policy_id)
        return policy.controls.values()
