import collections
import logging
import os

import ssg.yaml
import ssg.utils

class Control():
    def __init__(self, control_dict):
        self.id = ssg.utils.required_key(control_dict, "id")
        self.title = control_dict.get("title")
        self.description = control_dict.get("description")
        self.automated = control_dict.get("automated", False)
        self.rules = control_dict.get("rules", [])
        self.related_rules = control_dict.get("related_rules", [])
        self.note = control_dict.get("note")


class Policy():
    def __init__(self, filepath):
        self.id = None
        self.filepath = filepath
        self.controls = {}
    
    def _parse_controls_tree(self, tree):
        for node in tree:
            control = Control(node)
            if "controls" in node:
                for sc in self._parse_controls_tree(node["controls"]):
                    yield sc
                    control.rules.extend(sc.rules)
                    control.related_rules.extend(sc.related_rules)
            yield control

    
    def load(self):
        yaml_contents = ssg.yaml.open_and_expand(self.filepath)
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
    def __init__(self, controls_dir):
        self.controls_dir = os.path.abspath(controls_dir)
        self.policies = {}

    def load(self):
        for filename in os.listdir(self.controls_dir):
            logging.info("Found file %s" % (filename))
            filepath = os.path.join(self.controls_dir, filename)
            policy = Policy(filepath)
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