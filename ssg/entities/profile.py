from collections import defaultdict

from .profile_base import Profile


class ResolvableProfile(Profile):
    def __init__(self, * args, ** kwargs):
        super(ResolvableProfile, self).__init__(* args, ** kwargs)
        self.resolved = False

    def _controls_ids_to_controls(self, controls_manager, policy_id, control_id_list):
        items = [controls_manager.get_control(policy_id, cid) for cid in control_id_list]
        return items

    def resolve_controls(self, controls_manager):
        pass

    def extend_by(self, extended_profile):
        self.update_with(extended_profile)

    def resolve_selections_with_rules(self, rules_by_id):
        selections = set()
        for rid in self.selected:
            if rid not in rules_by_id:
                continue
            rule = rules_by_id[rid]
            if not self.rule_filter(rule):
                continue
            selections.add(rid)
        self.selected = list(selections)

    def resolve(self, all_profiles, rules_by_id, controls_manager=None):
        if self.resolved:
            return

        if controls_manager:
            self.resolve_controls(controls_manager)

        self.resolve_selections_with_rules(rules_by_id)

        if self.extends:
            if self.extends not in all_profiles:
                msg = (
                    "Profile {name} extends profile {extended}, but "
                    "only profiles {known_profiles} are available for resolution."
                    .format(name=self.id_, extended=self.extends,
                            known_profiles=list(all_profiles.keys())))
                raise RuntimeError(msg)
            extended_profile = all_profiles[self.extends]
            extended_profile.resolve(all_profiles, rules_by_id, controls_manager)

            self.extend_by(extended_profile)

        self.selected = [s for s in set(self.selected) if s not in self.unselected]

        self.unselected = []
        self.extends = None

        self.selected = sorted(self.selected)

        for rid in self.selected:
            if rid not in rules_by_id:
                msg = (
                    "Rule {rid} is selected by {profile}, but the rule is not available. "
                    "This may be caused by a discrepancy of prodtypes."
                    .format(rid=rid, profile=self.id_))
                raise ValueError(msg)

        self.resolved = True


class ProfileWithInlinePolicies(ResolvableProfile):
    def __init__(self, * args, ** kwargs):
        super(ProfileWithInlinePolicies, self).__init__(* args, ** kwargs)
        self.controls_by_policy = defaultdict(list)

    def apply_selection(self, item):
        # ":" is the delimiter for controls but not when the item is a variable
        if ":" in item and "=" not in item:
            policy_id, control_id = item.split(":", 1)
            self.controls_by_policy[policy_id].append(control_id)
        else:
            super(ProfileWithInlinePolicies, self).apply_selection(item)

    def _process_controls_ids_into_controls(self, controls_manager, policy_id, controls_ids):
        controls = []
        for cid in controls_ids:
            if not cid.startswith("all"):
                controls.extend(
                    self._controls_ids_to_controls(controls_manager, policy_id, [cid]))
            elif ":" in cid:
                _, level_id = cid.split(":", 1)
                controls.extend(
                    controls_manager.get_all_controls_of_level(policy_id, level_id))
            else:
                controls.extend(
                    controls_manager.get_all_controls(policy_id))
        return controls

    def resolve_controls(self, controls_manager):
        for policy_id, controls_ids in self.controls_by_policy.items():
            controls = self._process_controls_ids_into_controls(
                controls_manager, policy_id, controls_ids)

            for c in controls:
                self.update_with(c)
