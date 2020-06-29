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

    @classmethod
    def from_control_dict(cls, control_dict):
        control = cls()
        control.title = control_dict.get("title")
        control.description = control_dict.get("description")
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
    
    def _parse_controls_tree(self, tree):
        for node in tree:
            control = Control.from_control_dict(node)
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