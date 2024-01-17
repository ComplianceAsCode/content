from ..controleval import get_parameter_from_yaml


def _get_extends_profile_path(profiles_files, profile_name):
    for profile_path in profiles_files:
        if f"{profile_name}.profile" in profile_path:
            return profile_path
    return None


def _process_extends(profiles_files, file, policies, profile):
    extends = get_parameter_from_yaml(file, "extends")
    if isinstance(extends, str):
        profile_path = _get_extends_profile_path(profiles_files, extends)
        if profile_path is None:
            raise Exception("There is no Extension '{}' Profile.".format(extends))
        profile = get_profile(profiles_files, profile_path, policies, profile)


def _process_selections(file, profile, policies):
    selections = get_parameter_from_yaml(file, "selections")
    for selected in selections:
        if ":" in selected and "=" not in selected:
            profile.add_from_policy(policies, selected)
        else:
            profile.add_rule(selected)
    profile.clean_rules()


def get_profile(profiles_files, file, policies, profile=None):
    if profile is None:
        title = get_parameter_from_yaml(file, "title")
        profile = Profile(file, title)

    _process_extends(profiles_files, file, policies, profile)

    _process_selections(file, profile, policies)
    return profile


class Profile:
    def __init__(self, path, title):
        self.path = path
        self.title = title
        self.rules = []
        self.unselected_rules = []

    def add_rule(self, rule_id):
        if rule_id.startswith("!"):
            self.unselected_rules.append(rule_id)
            return
        if "=" not in rule_id:
            self.rules.append(rule_id)

    def add_rules(self, rules):
        for rule in rules:
            self.add_rule(rule)

    def clean_rules(self):
        for rule in self.unselected_rules:
            rule_ = rule.replace("!", "")
            if rule_ in self.rules:
                self.rules.remove(rule_)

    @staticmethod
    def _get_sel(selected):
        policy = None
        control = None
        level = None
        if selected.count(":") == 2:
            policy, control, level = selected.split(":")
        else:
            policy, control = selected.split(":")
        return policy, control, level

    @staticmethod
    def _get_levels(policy, level):
        levels = [level]
        if policy.levels_by_id.get(level).inherits_from is not None:
            levels.extend(policy.levels_by_id.get(level).inherits_from)
        return levels

    def add_from_policy(self, policies, selected):
        policy_id, control, level = self._get_sel(selected)
        policy = policies[policy_id]

        if control != "all":
            self.add_rules(policy.controls_by_id[control].rules)
            return

        if level is None:
            for control in policy.controls:
                self.add_rules(control.rules)
            return

        levels = self._get_levels(policy, level)
        for control in policy.controls:
            intersection = set(control.levels) & set(levels)
            if len(intersection) >= 1:
                self.add_rules(control.rules)
