from __future__ import absolute_import
from __future__ import print_function

import os
import sys
import re
from xml.sax.saxutils import unescape

import ssg.build_yaml

try:
    from urllib.parse import quote
except ImportError:
    from urllib import quote

languages = ["anaconda", "ansible", "bash", "oval", "puppet", "ignition", "kubernetes"]

lang_to_ext_map = {
    "anaconda": ".anaconda",
    "ansible": ".yml",
    "bash": ".sh",
    "oval": ".xml",
    "puppet": ".pp",
    "ignition": ".yml",
    "kubernetes": ".yml"
}

def sanitize_input(string):
    return re.sub(r'[\W_]', '_', string)

templates = dict()


def template(langs):
    def decorator_template(func):
        func.langs = langs
        templates[func.__name__] = func
        return func
    return decorator_template


# Callback functions for processing template parameters and/or validating them


@template(["ansible", "bash", "oval"])
def accounts_password(data, lang):
    if lang == "oval":
        data["sign"] = "-?" if data["variable"].endswith("credit") else ""
    return data


@template(["ansible", "bash", "oval"])
def auditd_lineinfile(data, lang):
    missing_parameter_pass = data["missing_parameter_pass"]
    if missing_parameter_pass == "true":
        missing_parameter_pass = True
    elif missing_parameter_pass == "false":
        missing_parameter_pass = False
    data["missing_parameter_pass"] = missing_parameter_pass
    return data


@template(["ansible", "bash", "oval", "kubernetes"])
def audit_rules_dac_modification(data, lang):
    return data


@template(["ansible", "bash", "oval"])
def audit_rules_file_deletion_events(data, lang):
    return data


@template(["ansible", "bash", "oval", "kubernetes"])
def audit_rules_login_events(data, lang):
    path = data["path"]
    name = re.sub(r'[-\./]', '_', os.path.basename(os.path.normpath(path)))
    data["name"] = name
    if lang == "oval":
        data["path"] = path.replace("/", "\\/")
    return data


@template(["ansible", "bash", "oval"])
def audit_rules_path_syscall(data, lang):
    if lang == "oval":
        pathid = re.sub(r'[-\./]', '_', data["path"])
        # remove root slash made into '_'
        pathid = pathid[1:]
        data["pathid"] = pathid
    return data


@template(["ansible", "bash", "oval", "kubernetes"])
def audit_rules_privileged_commands(data, lang):
    path = data["path"]
    name = re.sub(r"[-\./]", "_", os.path.basename(path))
    data["name"] = name
    if lang == "oval":
        data["id"] = data["_rule_id"]
        data["title"] = "Record Any Attempts to Run " + name
        data["path"] = path.replace("/", "\\/")
    elif lang == "kubernetes":
        npath = path.replace("/", "_")
        if npath[0] == '_':
            npath = npath[1:]
        data["normalized_path"] = npath
    return data

@template(["ansible", "bash", "oval"])
def audit_rules_rule_file(data, lang):
    return data


@template(["ansible", "bash", "oval"])
def audit_rules_unsuccessful_file_modification(data, lang):
    return data


@template(["oval"])
def audit_rules_unsuccessful_file_modification_o_creat(data, lang):
    return data


@template(["oval"])
def audit_rules_unsuccessful_file_modification_o_trunc_write(data, lang):
    return data


@template(["oval"])
def audit_rules_unsuccessful_file_modification_rule_order(data, lang):
    return data


@template(["ansible", "bash", "oval"])
def audit_rules_usergroup_modification(data, lang):
    path = data["path"]
    name = re.sub(r'[-\./]', '_', os.path.basename(path))
    data["name"] = name
    if lang == "oval":
        data["path"] = path.replace("/", "\\/")
    return data


@template(["ansible", "bash", "oval"])
def audit_file_contents(data, lang):
    if lang == "oval":
        pathid = re.sub(r'[-\./]', '_', data["filepath"])
        # remove root slash made into '_'
        pathid = pathid[1:]
        data["filepath_id"] = pathid

    # The build system converts "<",">" and "&" for us
    if lang == "bash" or lang == "ansible":
        data["contents"] = unescape(data["contents"])
    return data


def _file_owner_groupowner_permissions_regex(data):
    data["is_directory"] = data["filepath"].endswith("/")
    if "missing_file_pass" not in data:
        data["missing_file_pass"] = False
    if "file_regex" in data and not data["is_directory"]:
        raise ValueError(
            "Used 'file_regex' key in rule '{0}' but filepath '{1}' does not "
            "specify a directory. Append '/' to the filepath or remove the "
            "'file_regex' key.".format(data["_rule_id"], data["filepath"]))


@template(["ansible", "bash", "oval"])
def file_groupowner(data, lang):
    _file_owner_groupowner_permissions_regex(data)
    if lang == "oval":
        data["fileid"] = data["_rule_id"].replace("file_groupowner", "")
    return data


@template(["ansible", "bash", "oval"])
def file_owner(data, lang):
    _file_owner_groupowner_permissions_regex(data)
    if lang == "oval":
        data["fileid"] = data["_rule_id"].replace("file_owner", "")
    return data


@template(["ansible", "bash", "oval"])
def file_permissions(data, lang):
    _file_owner_groupowner_permissions_regex(data)
    if lang == "oval":
        data["fileid"] = data["_rule_id"].replace("file_permissions", "")
        # build the state that describes our mode
        # mode_str maps to STATEMODE in the template
        mode = data["filemode"]
        fields = [
            'oexec', 'owrite', 'oread', 'gexec', 'gwrite', 'gread',
            'uexec', 'uwrite', 'uread', 'sticky', 'sgid', 'suid']
        mode_int = int(mode, 8)
        mode_str = ""
        for field in fields:
            if mode_int & 0x01 == 1:
                mode_str = (
                    "	<unix:" + field + " datatype=\"boolean\">true</unix:"
                    + field + ">\n" + mode_str)
            else:
                mode_str = (
                    "	<unix:" + field + " datatype=\"boolean\">false</unix:"
                    + field + ">\n" + mode_str)
            mode_int = mode_int >> 1
        data["statemode"] = mode_str
    return data


@template(["ansible", "bash", "oval"])
def grub2_bootloader_argument(data, lang):
    data["arg_name_value"] = data["arg_name"] + "=" + data["arg_value"]
    if lang == "oval":
        # escape dot, this is used in oval regex
        data["escaped_arg_name_value"] = data["arg_name_value"].replace(".", "\\.")
        # replace . with _, this is used in test / object / state ids
        data["sanitized_arg_name"] = data["arg_name"].replace(".", "_")
    return data


@template(["ansible", "bash", "oval"])
def kernel_module_disabled(data, lang):
    return data


@template(["anaconda", "oval"])
def mount(data, lang):
    data["pointid"] = re.sub(r'[-\./]', '_', data["mountpoint"])
    return data


def _mount_option(data, lang):
    if lang == "oval":
        data["pointid"] = re.sub(r"[-\./]", "_", data["mountpoint"]).lstrip("_")
    else:
        data["mountoption"] = re.sub(" ", ",", data["mountoption"])
    return data


@template(["anaconda", "ansible", "bash", "oval"])
def mount_option(data, lang):
    return _mount_option(data, lang)


@template(["ansible", "bash", "oval"])
def mount_option_remote_filesystems(data, lang):
    if lang == "oval":
        data["mountoptionid"] = sanitize_input(data["mountoption"])
    return _mount_option(data, lang)


@template(["anaconda", "ansible", "bash", "oval"])
def mount_option_removable_partitions(data, lang):
    return data


@template(["anaconda", "ansible", "bash", "oval", "puppet"])
def package_installed(data, lang):
    if "evr" in data:
        evr = data["evr"]
        if evr and not re.match(r'\d:\d[\d\w+.]*-\d[\d\w+.]*', evr, 0):
            raise RuntimeError(
                "ERROR: input violation: evr key should be in "
                "epoch:version-release format, but package {0} has set "
                "evr to {1}".format(data["pkgname"], evr))
    return data


@template(["ansible", "bash", "oval"])
def sysctl(data, lang):
    data["sysctlid"] = re.sub(r'[-\.]', '_', data["sysctlvar"])
    if not data.get("sysctlval"):
        data["sysctlval"] = ""
    ipv6_flag = "P"
    if data["sysctlid"].find("ipv6") >= 0:
        ipv6_flag = "I"
    data["flags"] = "SR" + ipv6_flag
    return data


@template(["anaconda", "ansible", "bash", "oval", "puppet"])
def package_removed(data, lang):
    return data


@template(["ansible", "bash", "oval"])
def sebool(data, lang):
    sebool_bool = data.get("sebool_bool", None)
    if sebool_bool is not None and sebool_bool not in ["true", "false"]:
        raise ValueError(
            "ERROR: key sebool_bool in rule {0} contains forbidden "
            "value '{1}'.".format(data["_rule_id"], sebool_bool)
        )
    return data


@template(["ansible", "bash", "oval", "puppet", "ignition", "kubernetes"])
def service_disabled(data, lang):
    if "packagename" not in data:
        data["packagename"] = data["servicename"]
    if "daemonname" not in data:
        data["daemonname"] = data["servicename"]
    if "mask_service" not in data:
        data["mask_service"] = "true"
    return data


@template(["ansible", "bash", "oval", "puppet"])
def service_enabled(data, lang):
    if "packagename" not in data:
        data["packagename"] = data["servicename"]
    if "daemonname" not in data:
        data["daemonname"] = data["servicename"]
    return data


@template(["ansible", "bash", "oval", "kubernetes"])
def sshd_lineinfile(data, lang):
    missing_parameter_pass = data["missing_parameter_pass"]
    if missing_parameter_pass == "true":
        missing_parameter_pass = True
    elif missing_parameter_pass == "false":
        missing_parameter_pass = False
    data["missing_parameter_pass"] = missing_parameter_pass
    return data


@template(["ansible", "bash", "oval"])
def shell_lineinfile(data, lang):
    value = data["value"]
    if value[0] in ("'", '"') and value[0] == value[-1]:
        msg = (
            "Value >>{value}<< of shell variable '{varname}' "
            "has been supplied with quotes, please fix the content - "
            "shell quoting is handled by the check/remediation code."
            .format(value=value, varname=data["parameter"]))
        raise Exception(msg)
    missing_parameter_pass = data.get("missing_parameter_pass", "false")
    if missing_parameter_pass == "true":
        missing_parameter_pass = True
    elif missing_parameter_pass == "false":
        missing_parameter_pass = False
    data["missing_parameter_pass"] = missing_parameter_pass
    no_quotes = False
    if data["no_quotes"] == "true":
        no_quotes = True
    data["no_quotes"] = no_quotes
    return data


@template(["ansible", "bash", "oval"])
def timer_enabled(data, lang):
    if "packagename" not in data:
        data["packagename"] = data["timername"]
    return data


@template(["oval"])
def yamlfile_value(data, lang):
    data["negate"] = data.get("negate", "false") == "true"
    data["ocp_data"] = data.get("ocp_data", "false") == "true"
    return data


@template(["oval"])
def bls_entries_option(data, lang):
    data["arg_name_value"] = data["arg_name"] + "=" + data["arg_value"]
    if lang == "oval":
        # escape dot, this is used in oval regex
        data["escaped_arg_name_value"] = data["arg_name_value"].replace(".", "\\.")
        # replace . with _, this is used in test / object / state ids
        data["sanitized_arg_name"] = data["arg_name"].replace(".", "_")
    return data


@template(["oval"])
def zipl_bls_entries_option(data, lang):
    return bls_entries_option(data, lang)


class Builder(object):
    """
    Class for building all templated content for a given product.

    To generate content from templates, pass the env_yaml, path to the
    directory with resolved rule YAMLs, path to the directory that contains
    templates, path to the output directory for checks and a path to the
    output directory for remediations into the constructor. Then, call the
    method build() to perform a build.
    """
    def __init__(
            self, env_yaml, resolved_rules_dir, templates_dir,
            remediations_dir, checks_dir):
        self.env_yaml = env_yaml
        self.resolved_rules_dir = resolved_rules_dir
        self.templates_dir = templates_dir
        self.remediations_dir = remediations_dir
        self.checks_dir = checks_dir
        self.output_dirs = dict()
        for lang in languages:
            if lang == "oval":
                # OVAL checks need to be put to a different directory because
                # they are processed differently than remediations later in the
                # build process
                output_dir = self.checks_dir
            else:
                output_dir = self.remediations_dir
            dir_ = os.path.join(output_dir, lang)
            self.output_dirs[lang] = dir_

    def preprocess_data(self, template, lang, raw_parameters):
        """
        Processes template data using a callback before the data will be
        substituted into the Jinja template.
        """
        template_func = templates[template]
        parameters = template_func(raw_parameters.copy(), lang)
        # TODO: Remove this right after the variables in templates are renamed
        # to lowercase
        uppercases = dict()
        for k, v in parameters.items():
            uppercases[k.upper()] = v
        return uppercases

    def build_lang(
            self, rule_id, template_name, template_vars, lang, local_env_yaml):
        """
        Builds templated content for a given rule for a given language.
        Writes the output to the correct build directories.
        """
        template_func = templates[template_name]
        if lang not in template_func.langs:
            return
        template_file_name = "template_{0}_{1}".format(
            lang.upper(), template_name)
        template_file_path = os.path.join(
            self.templates_dir, template_file_name)
        if not os.path.exists(template_file_path):
            raise RuntimeError(
                "Rule {0} wants to generate {1} content from template {2}, "
                "but file {3} which provides this template does not "
                "exist.".format(
                    rule_id, lang, template_name, template_file_path)
            )
        ext = lang_to_ext_map[lang]
        output_file_name = rule_id + ext
        output_filepath = os.path.join(
            self.output_dirs[lang], output_file_name)
        template_parameters = self.preprocess_data(
            template_name, lang, template_vars)
        jinja_dict = ssg.utils.merge_dicts(local_env_yaml, template_parameters)
        filled_template = ssg.jinja.process_file_with_macros(
            template_file_path, jinja_dict)
        with open(output_filepath, "w") as f:
            f.write(filled_template)

    def get_langs_to_generate(self, rule):
        """
        For a given rule returns list of languages that should be generated
        from templates. This is controlled by "template_backends" in rule.yml.
        """
        if "backends" in rule.template:
            backends = rule.template["backends"]
            for lang in backends:
                if lang not in languages:
                    raise RuntimeError(
                        "Rule {0} wants to generate unknown language '{1}"
                        "from a template.".format(rule.id_, lang)
                    )
            langs_to_generate = []
            for lang in languages:
                backend = backends.get(lang, "on")
                if backend == "on":
                    langs_to_generate.append(lang)
            return langs_to_generate
        else:
            return languages

    def build_rule(self, rule_id, rule_title, template, langs_to_generate):
        """
        Builds templated content for a given rule for selected languages,
        writing the output to the correct build directories.
        """
        try:
            template_name = template["name"]
        except KeyError:
            raise ValueError(
                "Rule {0} is missing template name under template key".format(
                    rule_id))
        if template_name not in templates:
            raise ValueError(
                "Rule {0} uses template {1} which does not exist.".format(
                    rule_id, template_name))
        try:
            template_vars = template["vars"]
        except KeyError:
            raise ValueError(
                "Rule {0} does not contain mandatory 'vars:' key under "
                "'template:' key.".format(rule_id))
        # Add the rule ID which will be reused in OVAL templates as OVAL
        # definition ID so that the build system matches the generated
        # check with the rule.
        template_vars["_rule_id"] = rule_id
        # checks and remediations are processed with a custom YAML dict
        local_env_yaml = self.env_yaml.copy()
        local_env_yaml["rule_id"] = rule_id
        local_env_yaml["rule_title"] = rule_title
        local_env_yaml["products"] = self.env_yaml["product"]
        for lang in langs_to_generate:
            self.build_lang(
                rule_id, template_name, template_vars, lang, local_env_yaml)

    def build_extra_ovals(self):
        declaration_path = os.path.join(self.templates_dir, "extra_ovals.yml")
        declaration = ssg.yaml.open_raw(declaration_path)
        for oval_def_id, template in declaration.items():
            langs_to_generate = ["oval"]
            # Since OVAL definition ID in shorthand format is always the same
            # as rule ID, we can use it instead of the rule ID even if no rule
            # with that ID exists
            self.build_rule(
                oval_def_id, oval_def_id, template, langs_to_generate)

    def build_all_rules(self):
        for rule_file in os.listdir(self.resolved_rules_dir):
            rule_path = os.path.join(self.resolved_rules_dir, rule_file)
            try:
                rule = ssg.build_yaml.Rule.from_yaml(rule_path, self.env_yaml)
            except ssg.build_yaml.DocumentationNotComplete:
                # Happens on non-debug build when a rule is "documentation-incomplete"
                continue
            if rule.template is None:
                # rule is not templated, skipping
                continue
            langs_to_generate = self.get_langs_to_generate(rule)
            self.build_rule(
                rule.id_, rule.title, rule.template, langs_to_generate)

    def build(self):
        """
        Builds all templated content for all languages, writing
        the output to the correct build directories.
        """

        for dir_ in self.output_dirs.values():
            if not os.path.exists(dir_):
                os.makedirs(dir_)

        self.build_extra_ovals()
        self.build_all_rules()
