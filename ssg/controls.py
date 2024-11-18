"""
Common functions for processing Controls in SSG
"""

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
    """
    The Status class represents various statuses that can be assigned to controls.

    Attributes:
        SUPPORTED (str): Indicates the control is supported for the relevant products but is not enabled by default.
        PLANNED (str): Indicates that maintainers plan to work on the control in the near future.
        PENDING (str): Indicates the control is not yet automated and there is no plan to work on it soon.
        PARTIAL (str): Indicates the control is partially automated but requires additional work for full automation.
        NOT_APPLICABLE (str): Indicates the control is not applicable for the products that are being evaluated or targeted by the policy.
        MANUAL (str): Indicates the control requires manual intervention and is not expected to be automated.
        INHERENTLY_MET (str): Indicates the control is inherently met.
            This means that the control is satisfied by the nature of the system or environment,
            without requiring additional configuration or actions.
        DOES_NOT_MEET (str): Indicates the control does not meet requirements.
        DOCUMENTATION (str): Indicates the control is related to documentation.
        AUTOMATED (str): Indicates the control is fully automated.
    """
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
        """
        Retrieve a list of valid status constants.

        Returns:
            list: A list containing the valid status constants defined in the class.
        """
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
        """
        Create a control status from the given control information.

        Args:
            cls (Type): The class type that this method is called on.
            ctrl (str): The control identifier.
            status (str or None): The status of the control.

        Returns:
            str: The status of the control if valid, otherwise cls.PENDING.

        Raises:
            InvalidStatus: If the given status is not in the list of valid statuses.
        """
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
        """
        Returns the string representation of the object.

        Returns:
            str: The status of the object.
        """
        return self.status

    def __eq__(self, other):
        """
        Compare the current instance with another object for equality.

        Args:
            other (object): The object to compare with. It can be an instance of Status or a string.

        Returns:
            bool: True if the objects are considered equal, False otherwise.
        """
        if isinstance(other, Status):
            return self.status == other.status
        elif isinstance(other, str):
            return self.status == other
        return False


class Control(ssg.entities.common.SelectionHandler, ssg.entities.common.XCCDFEntity):
    """
    Represents a control entity with various attributes and methods to handle control-related operations.

    Attributes:
        KEYS (dict): A dictionary defining the expected keys and their types.
        MANDATORY_KEYS (set): A set of keys that are mandatory for a control.
    """
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
        """
        Returns the hash value of the control object.

        Controls are meant to be unique, so using the ID should suffice.

        Returns:
            int: The hash value of the control object based on its ID.
        """
        return hash(self.id)

    @classmethod
    def _check_keys(cls, control_dict):
        """
        Checks if the keys in the control_dict are valid according to the class KEYS.

        Args:
            cls: The class that contains the KEYS attribute.
            control_dict (dict): The dictionary containing control keys to be checked.

        Raises:
            ValueError: If a key in control_dict is not found in cls.KEYS and is not a rule id.
        """
        for key in control_dict.keys():
            # 'rules' should not be in KEYS because the data for rules is handled separately in selections.
            if key not in cls.KEYS.keys() and key not in ['rules', ]:
                raise ValueError("Key %s is not allowed in a control file." % key)

    @classmethod
    def from_control_dict(cls, control_dict, env_yaml=None, default_level=["default"]):
        """
        Create a control instance from a dictionary of control attributes.

        Args:
            cls: The class itself.
            control_dict (dict): A dictionary containing control attributes.
            env_yaml (optional): Environment YAML configuration (default is None).
            default_level (list, optional): Default level for the control (default is ["default"]).

        Returns:
            An instance of the control class populated with attributes from the control_dict.

        Raises:
            ValueError: If the 'automated' key has an invalid value or if 'levels' is not a list.
        """
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
        """
        Represents the Control object as a dictionary.

        This method overrides the `represent_as_dict` method from the superclass.
        It adds the `rules` and `controls` attributes to the dictionary representation.

        Returns:
            dict: A dictionary representation of the Control object, including
                  the `rules` and `controls` attributes.
        """
        data = super(Control, self).represent_as_dict()
        data["rules"] = self.selections
        data["controls"] = self.controls
        return data

    def add_references(self, reference_type, rules):
        """
        Adds references to the specified rules based on the given reference type.

        Args:
            reference_type (str): The type of reference to add.
            rules (dict): A dictionary of rules where the key is the rule id and the value is the
                          rule object.

        Raises:
            ValueError: If there is a duplicate listing of a rule in the control.
        """
        for selection in self.selections:
            if "=" in selection:
                continue
            rule = rules.get(selection)
            if not rule:
                continue
            try:
                rule.add_control_reference(reference_type, self.id)
            except ValueError as exc:
                msg = (
                    "Please remove any duplicate listing of rule '%s' in "
                    "control '%s'." % (
                        rule.id_, self.id))
                raise ValueError(msg)


class Level(ssg.entities.common.XCCDFEntity):
    """
    Represents a security control level entity.

    Attributes:
        id (str): The unique identifier for the level.
        inherits_from (str or None): The identifier of the level from which this level inherits, if any.

    Args:
        level_dict (dict): A dictionary containing the level data.

    Returns:
        Level: An instance of the Level class.
    """
    KEYS = dict(
        id=lambda: str,
        inherits_from=lambda: None,
    )

    def __init__(self):
        self.id = None
        self.inherits_from = None

    @classmethod
    def from_level_dict(cls, level_dict):
        """
        Create an instance of the class from a dictionary.

        Args:
            level_dict (dict): A dictionary containing the level data.
                               Must include the key "id".
                               May include the key "inherits_from".

        Returns:
            An instance of the class with attributes set according to the dictionary.
        """
        level = cls()
        level.id = ssg.utils.required_key(level_dict, "id")
        level.inherits_from = level_dict.get("inherits_from")
        return level


class Policy(ssg.entities.common.XCCDFEntity):
    """
    Represents a security policy defined in an XCCDF file.

    Attributes:
        id (str): The identifier of the policy.
        env_yaml (dict): The environment YAML configuration.
        filepath (str): The file path to the policy definition.
        controls_dir (str): The directory containing control definitions.
        controls (list): A list of controls associated with the policy.
        controls_by_id (dict): A dictionary mapping control IDs to control objects.
        levels (list): A list of levels defined for the policy.
        levels_by_id (dict): A dictionary mapping level IDs to level objects.
        title (str): The title of the policy.
        source (str): The source of the policy.
        reference_type (str): The type of reference used in the policy.
        product (list): A list of products associated with the policy.
    """
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
        self.reference_type = None
        self.product = None

    def represent_as_dict(self):
        """
        Represents the object as a dictionary.

        Returns:
            dict: A dictionary representation of the policy object, containing the following keys:
                - "id": The ID of the object.
                - "policy": The policy associated with the object.
                - "title": The title of the object.
                - "source": The source of the object.
                - "definition_location": The file path where the object is defined.
                - "controls": A list of dictionaries representing the controls associated with the object.
                - "levels": A list of dictionaries representing the levels associated with the object.
        """
        data = dict()
        data["id"] = self.id
        data["policy"] = self.policy
        data["title"] = self.title
        data["source"] = self.source
        data["definition_location"] = self.filepath
        data["controls"] = [c.represent_as_dict() for c in self.controls]
        data["levels"] = [l.represent_as_dict() for l in self.levels]
        return data

    @property
    def default_level(self):
        """
        Returns the default level.

        If the instance has levels, it returns a list containing the id of the first level.
        Otherwise, it returns a list containing the string "default".

        Returns:
            list: A list containing either the id of the first level or the string "default".
        """
        result = ["default"]
        if self.levels:
            result = [self.levels[0].id]
        return result

    def check_all_rules_exist(self, existing_rules):
        """
        Checks if all rules in the controls exist in the given set of existing rules.

        Args:
            existing_rules (set): A set of existing rule identifiers.

        Raises:
            ValueError: If any control contains rules that do not exist in the given set of
                        existing rules.
        """
        for c in self.controls:
            nonexisting_rules = set(c.selected) - existing_rules
            if nonexisting_rules:
                msg = "Control %s:%s contains nonexisting rule(s) %s" % (
                    self.id, c.id, ", ".join(nonexisting_rules))
                raise ValueError(msg)

    def check_levels_validity(self):
        """
        Validates the levels defined for each control in the policy.

        This function iterates through all controls in the policy and ensures that the levels
        defined for each control are valid according to the policy's defined levels. If the policy
        does not have any levels defined, it implicitly assumes that all controls should have the
        "default" level.

        Raises:
            ValueError: If a control has a level that is not defined in the policy's allowed
                        levels, an error message is raised indicating the invalid level, the
                        control ID, the file path, and the allowed levels.
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
        """
        Remove selections and unselections that are not in the known rules.

        This method updates the `selected` and `unselected` attributes of each control in
        `self.controls` by retaining only those elements that are present in the `known_rules` set.

        Args:
            known_rules (set): A set of known rule identifiers.
        """
        for c in self.controls:
            selections = set(c.selected).intersection(known_rules)
            c.selected = list(selections)
            unselections = set(c.unselected).intersection(known_rules)
            c.unselected = list(unselections)

    def _create_control_from_subtree(self, subtree):
        """
        Creates a Control object from a given subtree.

        Args:
            subtree (dict): The subtree dictionary from which to create the Control object.

        Returns:
            Control: The created Control object.

        Raises:
            RuntimeError: If there is an error parsing the controls from the subtree.
        """
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
        """
        Extracts and records subcontrols from the given controls tree.

        This method processes the controls tree to extract subcontrols and update the current
        control with the extracted subcontrols. It handles both control references (strings) and
        control definitions (dictionaries).

        Args:
            current_control (Control): The control object to be updated with subcontrols.
            controls_tree (dict): The tree structure containing control definitions and references.

        Returns:
            list: A list of extracted subcontrol objects.
        """
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
        """
        Parses a tree structure of controls and returns a list of controls.

        This method iterates through each subtree in the provided tree, creates a control from
        each subtree, extracts and records any subcontrols, and then appends both the subcontrols
        and the main control to the controls list.

        Args:
            tree (iterable): An iterable containing subtrees representing controls.

        Returns:
            list: A list of controls and their subcontrols.
        """
        controls = []

        for control_subtree in tree:
            control = self._create_control_from_subtree(control_subtree)
            subcontrols = self._extract_and_record_subcontrols(control, control_subtree)
            controls.extend(subcontrols)
            controls.append(control)
        return controls

    def save_controls_tree(self, tree):
        """
        Saves the controls tree by parsing the given tree and appending each control to the
        controls list and controls_by_id dictionary.

        Args:
            tree (Any): The tree structure containing controls to be parsed and saved.
        """
        for c in self._parse_controls_tree(tree):
            self.controls.append(c)
            self.controls_by_id[c.id] = c

    def _parse_file_into_control_trees(self, dirname, basename):
        """
        Parses a file into control trees.

        This method reads a YAML file and extracts control trees from it. If the file does not
        have a '.yml' extension or if it starts with a '.', it will either skip processing or
        raise an error.

        Args:
            dirname (str): The directory name where the file is located.
            basename (str): The base name of the file to be parsed.

        Returns:
            list: A list of control trees extracted from the YAML file.

        Raises:
            RuntimeError: If a non-YAML file is found in the controls directory.
        """
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
        """
        Loads control trees from YAML files in a specified subdirectory and appends them to the existing controls tree.

        Args:
            yaml_contents (dict): A dictionary containing the initial controls tree under the key
                                  "controls".

        Returns:
            list: The updated controls tree with additional control trees loaded from the
                  specified subdirectory.
        """
        controls_tree = yaml_contents.get("controls", list())
        files = os.listdir(self.controls_dir)
        for file in files:
            trees = self._parse_file_into_control_trees(self.controls_dir, file)
            controls_tree.extend(trees)
        return controls_tree

    def load(self):
        """
        Loads and processes the YAML configuration file specified by `self.filepath`.

        This method performs the following steps:
        1. Opens and expands the YAML file.
        2. Extracts and sets various attributes from the YAML contents, such as `controls_dir`,
           `id`, `policy`, `title`, `source`, `reference_type`, and `product`.
        3. Processes the `levels` section of the YAML file and populates the `self.levels` and
           `self.levels_by_id` attributes.
        4. Loads the controls tree from the specified directory or directly from the YAML contents.
        5. Saves the controls tree and checks the validity of the levels.

        Raises:
            KeyError: If required keys are missing in the YAML contents.
        """
        yaml_contents = ssg.yaml.open_and_expand(self.filepath, self.env_yaml)
        controls_dir = yaml_contents.get("controls_dir")
        if controls_dir:
            self.controls_dir = os.path.join(os.path.dirname(self.filepath), controls_dir)
        self.id = ssg.utils.required_key(yaml_contents, "id")
        self.policy = ssg.utils.required_key(yaml_contents, "policy")
        self.title = ssg.utils.required_key(yaml_contents, "title")
        self.source = yaml_contents.get("source", "")
        self.reference_type = yaml_contents.get("reference_type", None)
        yaml_product = yaml_contents.get("product", None)
        if isinstance(yaml_product, list):
            self.product = yaml_product
        elif yaml_product is not None:
            self.product = [yaml_product]

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
        """
        Retrieve a control by its ID.

        Args:
            control_id (str): The ID of the control to retrieve.

        Returns:
            Control: The control object associated with the given ID.

        Raises:
            ValueError: If the control ID is not found in the policy.
        """
        try:
            c = self.controls_by_id[control_id]
            return c
        except KeyError:
            msg = "%s not found in policy %s" % (
                control_id, self.id
            )
            raise ValueError(msg)

    def get_level(self, level_id):
        """
        Retrieve a level by its ID.

        Args:
            level_id (str): The ID of the level to retrieve.

        Returns:
            Level: The level object corresponding to the given ID.

        Raises:
            ValueError: If the level ID is not found in the levels_by_id dictionary.
        """
        try:
            lv = self.levels_by_id[level_id]
            return lv
        except KeyError:
            msg = "Level %s not found in policy %s" % (
                level_id, self.id
            )
            raise ValueError(msg)

    def get_level_with_ancestors_sequence(self, level_id):
        """
        Retrieve a sequence of levels starting from the specified level and including all its ancestor levels.

        This method uses an OrderedDict to maintain the order of levels and ensure compatibility
        with Python 2. It starts with the given level and recursively adds all ancestor levels,
        avoiding duplicates.

        Args:
            level_id (str): The ID of the starting level.

        Returns:
            list: A list of levels starting from the specified level and including all its ancestors.
        """
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

    def _check_conflict_in_rules(self, rules):
        """
        Checks for conflicts in the provided rules based on reference types.

        This method iterates through the given rules and checks if any rule contains a reference
        type that conflicts with the reference type provided by the current control. If a conflict
        is found, a ValueError is raised with a descriptive message.

        Args:
            rules (dict): A dictionary where keys are rule IDs and values are rule objects.
                          Each rule object should have a 'references' attribute that is a list
                          of reference types.

        Raises:
            ValueError: If a rule contains a reference type that conflicts with the reference
                        type provided by the current control.
        """
        for rule_id, rule in rules.items():
            if self.reference_type in rule.references:
                msg = (
                    "Rule %s contains %s reference, but this reference "
                    "type is provided by %s controls. Please remove the "
                    "reference from rule.yml." % (
                        rule_id, self.reference_type, self.id))
                raise ValueError(msg)

    def add_references(self, rules):
        """
        Adds references to the controls based on the provided rules.

        This method checks if the reference type is specified and if the current product matches
        the product specified in the environment YAML. It also verifies if the reference type is
        allowed based on the reference URIs defined in the environment YAML. If all checks pass,
        it adds references to the controls by calling the `add_references` method on each control.

        Args:
            rules (dict): A dictionary containing the rules to be applied.

        Raises:
            ValueError: If the reference type is unknown.
        """
        if not self.reference_type:
            return
        product = self.env_yaml["product"]
        if self.product and product not in self.product:
            return
        allowed_reference_types = self.env_yaml["reference_uris"].keys()
        if self.reference_type not in allowed_reference_types:
            msg = "Unknown reference type %s" % (self.reference_type)
            raise(ValueError(msg))
        self._check_conflict_in_rules(rules)
        for control in self.controls_by_id.values():
            control.add_references(self.reference_type, rules)


class ControlsManager():
    """
    Manages the loading, processing, and saving of control policies.

    Attributes:
        controls_dir (str): The directory where control policy files are located.
        env_yaml (str, optional): The environment YAML file.
        existing_rules (dict, optional): Existing rules to check against.
        policies (dict): A dictionary of loaded policies.
    """
    def __init__(self, controls_dir, env_yaml=None, existing_rules=None):
        """
        Initializes the Controls class.

        Args:
            controls_dir (str): The directory where control files are located.
            env_yaml (str, optional): Path to the environment YAML file. Defaults to None.
            existing_rules (dict, optional): Dictionary of existing rules. Defaults to None.
        """
        self.controls_dir = os.path.abspath(controls_dir)
        self.env_yaml = env_yaml
        self.existing_rules = existing_rules
        self.policies = {}

    def load(self):
        """
        Load policies from YAML files in the controls directory.

        This method checks if the controls directory exists. If it does, it loads all YAML files
        in the directory, creates Policy objects from them, and stores them in the `self.policies`
        dictionary using their IDs as keys. After loading all policies, it checks that all rules
        exist and resolves controls.

        Returns:
            None
        """
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
        """
        Checks if all rules exist for each policy.

        This method iterates through all policies and calls the `check_all_rules_exist` method
        on each policy, passing the existing rules as an argument. If `existing_rules` is None,
        the method returns immediately.

        Returns:
            None
        """
        if self.existing_rules is None:
            return
        for p in self.policies.values():
            p.check_all_rules_exist(self.existing_rules)

    def remove_selections_not_known(self, known_rules):
        """
        Remove selections from policies that are not in the known rules.

        This method iterates over all policies and removes any selections that are not present
        in the provided known rules set.

        Args:
            known_rules (iterable): An iterable of known rule identifiers.
        """
        known_rules = set(known_rules)
        for p in self.policies.values():
            p.remove_selections_not_known(known_rules)

    def resolve_controls(self):
        """
        Resolves controls for each policy in the policies dictionary.

        Iterates through each policy and its associated controls, calling the _resolve_control
        method for each control.

        Returns:
            None
        """
        for pid, policy in self.policies.items():
            for control in policy.controls:
                self._resolve_control(pid, control)

    def _get_foreign_subcontrols(self, policy_id, req):
        """
        Retrieve foreign subcontrols based on the given requirement.

        If the requirement starts with "all", it splits the requirement to get the level ID
        and returns all controls of that level for the given policy ID. Otherwise, it returns
        a list containing a single control for the given policy ID and requirement.

        Args:
            policy_id (str): The ID of the policy.
            req (str): The requirement string, which can either start with "all" followed by
                       a level ID or be a specific control requirement.

        Returns:
            list: A list of controls based on the requirement.
        """
        if req.startswith("all"):
            _, level_id = req.split(":", 1)
            return self.get_all_controls_of_level(policy_id, level_id)
        else:
            return [self.get_control(policy_id, req)]

    def _resolve_control(self, pid, control):
        """
        Recursively resolves and updates a control with its subcontrols.

        Args:
            pid (str): The policy ID associated with the control.
            control (Control): The control object to be resolved and updated.

        This method iterates over the subcontrols of the given control. If a subcontrol name
        contains a colon, it is split into a policy ID and a requirement, and the corresponding
        foreign subcontrols are retrieved. Otherwise, the subcontrol is fetched directly. Each
        subcontrol is then recursively resolved and used to update the original control.
        """
        for sub_name in control.controls:
            policy_id = pid
            if ":" in sub_name:
                policy_id, req = sub_name.split(":", 1)
                subcontrols = self._get_foreign_subcontrols(policy_id, req)
            else:
                subcontrols = [self.get_control(policy_id, sub_name)]

            for subcontrol in subcontrols:
                self._resolve_control(policy_id, subcontrol)
                control.update_with(subcontrol)

    def get_control(self, policy_id, control_id):
        """
        Retrieve a specific control from a policy.

        Args:
            policy_id (str): The unique identifier of the policy.
            control_id (str): The unique identifier of the control within the policy.

        Returns:
            Control: The control object associated with the given control_id within the specified policy.

        Raises:
            PolicyNotFoundError: If the policy with the given policy_id does not exist.
            ControlNotFoundError: If the control with the given control_id does not exist within the policy.
        """
        policy = self._get_policy(policy_id)
        control = policy.get_control(control_id)
        return control

    def get_all_controls_dict(self, policy_id):
        """
        Retrieve all controls for a given policy as a dictionary.

        Args:
            policy_id (str): The unique identifier of the policy.

        Returns:
            Dict[str, list]: A dictionary where the keys are control IDs and the values are lists
                             of controls.
        """
        # type: (str) -> typing.Dict[str, list]
        policy = self._get_policy(policy_id)
        return policy.controls_by_id

    def _get_policy(self, policy_id):
        """
        Retrieve a policy by its ID.

        Args:
            policy_id (str): The ID of the policy to retrieve.

        Returns:
            dict: The policy associated with the given ID.

        Raises:
            ValueError: If the policy with the given ID does not exist.
        """
        try:
            policy = self.policies[policy_id]
        except KeyError:
            msg = "policy '%s' doesn't exist" % (policy_id)
            raise ValueError(msg)
        return policy

    def get_all_controls_of_level(self, policy_id, level_id):
        """
        Retrieve all controls associated with a specific policy and level, including inherited levels.

        This method fetches all controls for a given policy and filters them based on the
        specified level and its ancestor levels. Controls from higher levels can override
        variables defined in lower levels.

        Args:
            policy_id (int): The unique identifier of the policy.
            level_id (int): The unique identifier of the level within the policy.

        Returns:
            list: A list of controls that are eligible for the specified level, with variables
                  from higher levels overriding those from lower levels.
        """
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
        """
        Remove specified variables from a control object.

        Args:
            variables_to_remove (list): A list of variable names to be removed from the control.
            control (object): The control object from which variables will be removed.

        Returns:
            object: A new control object with the specified variables removed.
        """
        if not variables_to_remove:
            return control

        new_c = copy.deepcopy(control)
        for var in variables_to_remove:
            del new_c.variables[var]
        return new_c

    def get_all_controls(self, policy_id):
        """
        Retrieve all controls associated with a given policy.

        Args:
            policy_id (str): The unique identifier of the policy.

        Returns:
            list: A list of control objects associated with the specified policy.
        """
        policy = self._get_policy(policy_id)
        return policy.controls_by_id.values()

    def save_everything(self, output_dir):
        """
        Saves all policies to the specified output directory in YAML format.

        Args:
            output_dir (str): The directory where the policy files will be saved.

        Returns:
            None
        """
        ssg.utils.mkdir_p(output_dir)
        for policy_id, policy in self.policies.items():
            filename = os.path.join(output_dir, "{}.{}".format(policy_id, "yml"))
            policy.dump_yaml(filename)

    def add_references(self, rules):
        """
        Add references to the policies and unify them under a single attribute.

        This method first adds all control references into a separate attribute for each policy.
        Then, it unifies them under the `references` attribute. This allows multiple control files
        to add references of the same type while still tracking what references already existed in
        the rule.

        Args:
            rules (dict): A dictionary containing the rules to which references will be added.
        """
        for policy in self.policies.values():
            policy.add_references(rules)
        self._merge_references(rules)

    def _merge_references(self, rules):
        """
        Merges control references for each rule in the provided dictionary of rules.

        Args:
            rules (dict): A dictionary where keys are rule identifiers and values are rule objects.
                          Each rule object must have a method `merge_control_references`.

        Returns:
            None
        """
        for rule in rules.values():
            rule.merge_control_references()
