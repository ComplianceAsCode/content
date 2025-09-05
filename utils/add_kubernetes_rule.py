#!/usr/bin/python3

import argparse
import subprocess
import sys
import textwrap
import os
import re
import time
import yaml

from ssg.utils import mkdir_p

class JinjaString(str):
    pass

def jinja_string_representer(dumper, data):
    # yuumasato: The Jinja syntax is not compatible with YAML as curly braces are special characters.
    # So we use an exotic token to mark where opening and closing Jinja tags would be, they are substituted
    # by actual `{{{` and `}}}` right before being written to file.
    # A the moment this is restricted to macro calls, but could be expanded to conditionals as well.
    sanitized = re.sub(r"{{{", "JiNjA_OpEn", data)
    sanitized = re.sub(r"}}}", "JiNjA_ClOsE", sanitized)
    return dumper.represent_scalar(u'tag:yaml.org,2002:str', sanitized, style="|")

yaml.add_representer(JinjaString, jinja_string_representer)

PROG_DESC = (''' Create and test content files for Kubernetes API checks.

This script is intended to help content writers create a new application check
for OCP4/Kubernetes.

- The 'create' subcommand creates the initial files for a new rule and fetches
  the raw URL of the object in question (unless you specify the URL).

- The 'test' subcommand builds your content locally and tests directly using an
  openscap podman container. The scan container will test against yaml files
  staged under --objectdir.

- The 'cluster-test' subcommand pushes the content to your cluster, and then
  runs a Platform scan for your rule with compliance-operator.

Example workflow:

$ utils/add_kubernetes_rule.py create --rule=ocp_proxy_has_ca \
  --type="proxies.config" --name="cluster" \
  --yamlpath=".spec.trustedCA.name" --match="[a-zA-Z0-9]*"
creating check for "/apis/config.openshift.io/v1/proxies/cluster" with yamlpath ".spec.trustedCA.name" satisfying match of "[a-zA-Z0-9]*"
wrote applications/openshift/ocp_proxy_has_ca/rule.yml

$ mkdir -p /tmp/apis/config.openshift.io/v1/proxies/
$ oc get proxies.config/cluster -o yaml > /tmp/apis/config.openshift.io/v1/proxies/cluster
$ utils/add_kubernetes_rule.py test --rule=ocp_proxy_has_ca
testing rule ocp_proxy_has_ca locally
Title
        None
Rule
        xccdf_org.ssgproject.content_rule_ocp_proxy_has_ca
Ident
        CCE-84209-6
Result
        pass

$ utils/add_kubernetes_rule.py cluster-test --rule=ocp_proxy_has_ca
testing rule ocp_proxy_has_ca in-cluster
deploying compliance-operator
pushing image build to cluster
waiting for cleanup from previous test run
output from last phase check: LAUNCHING NOT-AVAILABLE
output from last phase check: RUNNING NOT-AVAILABLE
output from last phase check: AGGREGATING NOT-AVAILABLE
output from last phase check: DONE COMPLIANT
COMPLIANT

''')

OCP_RULE_DIR = 'applications/openshift'
OSCAP_TEST_IMAGE = 'quay.io/compliance-operator/openscap-ocp:1.3.4'
OSCAP_CMD_TEMPLATE = 'oscap xccdf eval --verbose %s --fetch-remote-resources --profile xccdf_org.ssgproject.content_profile_test --results-arf /tmp/report-arf.xml /content/ssg-ocp4-ds.xml'
PROFILE_PATH = 'products/ocp4/profiles/test.profile'

MOCK_VERSION = ('''status:
  versions:
  - name: operator
    version: 4.6.0-0.ci-2020-06-15-112708
  - name: openshift-apiserver
    version: 4.6.0-0.ci-2020-06-15-112708
''')


def set_operation_value(value, template_vars):
    if value:
        template_vars['operation'] = 'pattern match'
        template_vars['type'] = 'string'

def set_entity_value(value, template_vars):
    if value is not None:
        template_vars['entity_check'] = value

def set_check_existence_value(value, template_vars):
    if value is not None:
        template_vars['check_existence'] = value

def set_template_vars(value, template_vars):
    for var in value.split(","):
        key, value = var.strip().split(":")
        template_vars[key.strip()] = value.strip()

PROFILE_TEMPLATE = ('''documentation_complete: true

title: 'Test Profile for {RULE_NAME}'

platform: ocp4

description: Test Profile
selections:
- {RULE_NAME}
''')


TEST_SCAN_TEMPLATE = ('''apiVersion: compliance.openshift.io/v1alpha1
kind: ComplianceScan
metadata:
  name: test
  namespace: {NAMESPACE}
spec:
  scanType: {TYPE}
  profile: {PROFILE}
  content: ssg-ocp4-ds.xml
  contentImage: image-registry.openshift-image-registry.svc:5000/openshift-compliance/openscap-ocp4-ds:latest
  debug: true
''')


def needs_oc(func):
    def wrapper(args):
        if which('oc') is None:
            print('oc is required for this command.')
            return 1

        return func(args)
    return wrapper


def needs_working_cluster(func):
    def wrapper(args):
        ret_code, output = subprocess.getstatusoutput(
            'oc whoami')
        if ret_code != 0:
            print("* Error connecting to cluster")
            print(output)
            return ret_code

        return func(args)
    return wrapper

def which(program):
    fpath, fname = os.path.split(program)
    if fpath:
        if os.path.isfile(fpath) and os.access(fpath, os.X_OK):
            return program
    else:
        for path in os.environ["PATH"].split(os.pathsep):
            exe_file = os.path.join(path, program)
            if os.path.isfile(exe_file) and os.access(exe_file, os.X_OK):
                return exe_file

    return None


def create_base_rule(args, url=None, node_rule=False):
    rule_yaml = dict()
    rule_yaml['documentation_complete'] = True
    rule_yaml['title'] = args.title
    if node_rule:
        rule_yaml['platform'] = 'ocp4-node'
    rule_yaml['description'] = args.description
    rule_yaml['rationale'] = 'TBD'
    rule_yaml['identifiers'] = dict()
    rule_yaml['severity'] = args.severity
    if args.jqfilter:
        rule_yaml['warnings'] = [{'general': JinjaString("{{{ openshift_filtered_cluster_setting({'%s': '%s'}) | indent(4) }}}" % (url, args.jqfilter))}]
    elif url:
        rule_yaml['warnings'] = [{'general': JinjaString('{{{ openshift_cluster_setting("%s") | indent(4) }}}' % (url))}]
    rule_yaml['template'] = dict()

    return rule_yaml


def save_rule(rule_yaml_path, rule_yaml):
    with open(rule_yaml_path, 'w') as f:
        yaml_contents = yaml.dump(rule_yaml, None, indent=4, sort_keys=False, canonical=False, default_flow_style=False, width=120)
        # Adds a blank line between keys
        formatted_yaml_contents = re.sub(r"\n(\w+:.*)", r"\n\n\1", yaml_contents)

        # Replace placeholders for CaC/content Jinja2 expressions
        formatted_yaml_contents = re.sub(r"JiNjA_OpEn", r"{{{", formatted_yaml_contents)
        formatted_yaml_contents = re.sub(r"JiNjA_ClOsE", r"}}}", formatted_yaml_contents)

        f.write(formatted_yaml_contents)
    print('* Wrote ' + rule_yaml_path)


def createNodeRuleFunc(args):
    group_path = os.path.join(OCP_RULE_DIR, args.group)
    if args.group:
        if not os.path.isdir(group_path):
            print("ERROR: The specified group '%s' doesn't exist in the '%s' directory" % (
                args.group, OCP_RULE_DIR))
            return 0

    rule_path = os.path.join(group_path, args.rule)
    rule_yaml_path = os.path.join(rule_path, 'rule.yml')

    mkdir_p(rule_path)

    rule_yaml = create_base_rule(args)

    template = rule_yaml['template']
    template['name'] = args.template

    template['vars'] = dict()
    template_vars = set_template_vars(args.template_vars, template['vars'])

    save_rule(rule_yaml_path, rule_yaml)
    return 0


@needs_oc
def createPlatformRuleFunc(args):
    url = args.url
    retries = 0
    namespace_flag = ''
    if args.namespace is not None:
        namespace_flag = '-n ' + args.namespace
    elif args.all_namespaces:
        namespace_flag = '-A'

    group_path = os.path.join(OCP_RULE_DIR, args.group)
    if args.group:
        if not os.path.isdir(group_path):
            print("ERROR: The specified group '%s' doesn't exist in the '%s' directory" % (
                args.group, OCP_RULE_DIR))
            return 0

    rule_path = os.path.join(group_path, args.rule)
    while url is None and retries < 5:
        retries += 1
        cmdstr = 'oc get %s' % (args.type)

        if args.name:
            cmdstr += ' ' + args.name

        cmdstr += ' %s --loglevel=6' % (namespace_flag)

        print("Running: " + cmdstr)
        ret_code, output = subprocess.getstatusoutput(cmdstr)

        if ret_code != 0:
            print('error running oc, check connection to the cluster: %d\n %s' % (
                ret_code, output))
            continue

        fetch_line = ""
        url_part = ""
        lines = output.splitlines()
        for line in lines:
            if 'GET' in line:
                fetch_line = line
                break

        if len(fetch_line) > 0:
            # extract the object url from the debug line
            full_url = fetch_line[fetch_line.index("GET"):].split(" ")[1]
            url_part = full_url[full_url.rfind("/api"):]

        if len(url_part) > 0 and '/api' in url_part:
            url = url_part

    if url is None:
        print('there was a problem finding the URL from the oc debug output. Hint: override this automatic check with --url')
        return 1

    print('* Creating check for "%s" with yamlpath "%s" satisfying match of "%s"' % (
        url, args.yamlpath, args.match))
    rule_yaml_path = os.path.join(rule_path, 'rule.yml')

    mkdir_p(rule_path)

    rule_yaml = create_base_rule(args, url)

    template = rule_yaml['template']
    template['name'] = 'yamlfile_value'

    template['vars'] = dict()
    template_vars = template['vars']
    template_vars['ocp_data'] = "true"
    if args.jqfilter:
        template_vars['filepath'] = JinjaString("{{{ openshift_filtered_path('%s', '%s') }}}" % (url, args.jqfilter))
    else:
        template_vars['filepath'] = url
    template_vars['yamlpath'] = args.yamlpath

    set_entity_value(args.match_entity, template_vars)
    set_check_existence_value(args.check_existence, template_vars)

    if args.match:
        value_dict = dict()
        value_dict['value'] = args.match
        set_operation_value(args.regex, value_dict)

        template_vars['values'] = [value_dict]
    else:
        template_vars['xccdf_variable'] = args.variable

    save_rule(rule_yaml_path, rule_yaml)

    return 0


def createTestProfile(rule):
    # create a solo profile for rule
    with open(PROFILE_PATH, 'w') as f:
        f.write(PROFILE_TEMPLATE.format(RULE_NAME=rule))


@needs_oc
@needs_working_cluster
def clusterTestFunc(args):

    print('* Testing rule %s in-cluster' % args.rule)

    findout = subprocess.getoutput(
        "find %s -name '%s' -type d" % (OCP_RULE_DIR, args.rule))
    if findout == "":
        print('ERROR: no rule for %s, run "create" first' % args.rule)
        return 1

    if not args.skip_deploy:
        subprocess.run("utils/deploy_compliance_operator.sh")

    if not args.skip_build:
        createTestProfile(args.rule)
        print('* Pushing image build to cluster')
        # execute the build_ds_container script
        buildp = subprocess.run(
            ['utils/build_ds_container.py', '-P', 'ocp4', 'rhcos4'])
        if buildp.returncode != 0:
            try:
                os.remove(PROFILE_PATH)
            except OSError:
                pass
            return 1

    ret_code, _ = subprocess.getstatusoutput(
        'oc delete -n {NAMESPACE} compliancescans/test'.format(NAMESPACE=args.namespace))
    if ret_code == 0:
        # if previous compliancescans were actually deleted, wait a bit to allow resources to clean up.
        print('* Waiting for cleanup from a previous test run')
        time.sleep(20)

    # create a single-rule scan
    print("* Running scan with rule '%s'" % args.rule)
    profile = 'xccdf_org.ssgproject.content_profile_test'
    apply_cmd = ['oc', 'apply', '-f', '-']
    with subprocess.Popen(apply_cmd, stdin=subprocess.PIPE, stdout=subprocess.PIPE) as proc:
        _, err = proc.communicate(
            input=TEST_SCAN_TEMPLATE.format(PROFILE=profile, TYPE=args.scantype, NAMESPACE=args.namespace).encode())
        if proc.returncode != 0:
            print('Error applying scan object: %s' % err)
            try:
                os.remove(PROFILE_PATH)
            except OSError:
                pass
            return 1

    # poll for the DONE result
    timeout = time.time() + 120   # A couple of minutes is generous for the platform scan.
    scan_result = None
    while True:
        ret_code, output = subprocess.getstatusoutput(
            'oc get -n {NAMESPACE} compliancescans/test -o template="{{{{.status.phase}}}} {{{{.status.result}}}}"'.format(NAMESPACE=args.namespace))
        if output is not None:
            print('> Output from last phase check: %s' % output)
        if output.startswith('DONE'):
            scan_result = output[5:]
            break
        if time.time() >= timeout:
            break
        time.sleep(2)

    if scan_result is None:
        print('ERROR: Timeout waiting for scan to finish')
        return 1

    print("* The result is '%s'" % scan_result)
    return 0


def testFunc(args):
    if which('podman') is None:
        print('podman is required')
        return 1

    print('testing rule %s locally' % args.rule)

    if not args.skip_build:
        createTestProfile(args.rule)
        ret_code, out = subprocess.getstatusoutput('./build_product --datastream-only ocp4')
        if ret_code != 0:
            print('build failed: %s' % out)
            return 1

    # mock a passing result for the implicit ocp4 version check
    version_dir = args.objectdir + '/apis/config.openshift.io/v1/clusteroperators'
    mock_version_file = os.path.join(version_dir, 'openshift-apiserver')
    if not os.path.exists(mock_version_file):
        mkdir_p(version_dir)
        with open(mock_version_file, 'w') as f:
            f.write(MOCK_VERSION)

    oscap_cmd_opts = OSCAP_CMD_TEMPLATE % (args.verbosity)
    pod_cmd = 'podman run -it --security-opt label=disable -v "%s:/content" -v "%s:/kubernetes-api-resources" %s %s' % (args.contentdir,
                                                                                                                        args.objectdir, OSCAP_TEST_IMAGE, oscap_cmd_opts)
    print(subprocess.getoutput(pod_cmd))


def main():
    parser = argparse.ArgumentParser(
        prog="add_kubernetes_rule.py",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        description=textwrap.dedent(PROG_DESC))
    subparser = parser.add_subparsers(
        dest='subcommand', title='subcommands', help='pick one')
    create_parser = subparser.add_parser(
        'create', help='Bootstrap the XML and YML files under %s for a new check.' % OCP_RULE_DIR)

    common_rule_args = argparse.ArgumentParser(add_help=False)
    common_rule_args.add_argument(
        '--rule', required=True, help='The name of the rule to create. Required.')
    common_rule_args.add_argument(
        '--group', default="", help='The group directory of the rule to create.')
    common_rule_args.add_argument(
        '--name', help='The name of the Kubernetes object to check.')
    common_rule_args.add_argument(
        '--title', help='A short description of the check.')
    common_rule_args.add_argument(
        '--description', help='A human-readable description of the provided matching criteria.')
    common_rule_args.add_argument(
        '--severity', default="unknown", help='the severity of the rule.')
    common_rule_args.add_argument(
        '--identifiers', default="TBD", help='an identifier for the rule (CCE number)')
    common_rule_args.add_argument(
        '--jqfilter', default="", help='A JQ filter to select the data passed down for OVAL evaluation.')

    type_parser = create_parser.add_subparsers(dest='rule types', title='Creates a rule', help='Types of rules')
    platform_parser = type_parser.add_parser('platform', help='Creates a Platform rule',  parents=[common_rule_args])
    platform_parser.add_argument('--yamlpath',
                               help='The yaml-path of the element to match against.')
    value_or_variable = platform_parser.add_mutually_exclusive_group()
    value_or_variable.add_argument(
        '--match', help='A string value or regex providing the matching criteria. One of "match" or "variable" are required')
    value_or_variable.add_argument(
        '--variable', help='A string name of the XCCDF variable to with the value to check for. Mutually exclusive with "match" option')
    platform_parser.add_argument(
        '--namespace', help='The namespace of the Kubernetes object (optional for cluster-scoped objects)', default=None)
    platform_parser.add_argument(
        '--all-namespaces', action="store_true", help='The namespace of the Kubernetes object (optional for cluster-scoped objects)',
        default=False)
    platform_parser.add_argument(
        '--type', required=True, help='The type of Kubernetes object, e.g., configmap. Required.')
    platform_parser.add_argument(
        '--url', help='The direct api path (metadata.selfLink) of the object, which overrides --type --name and --namespace options.')
    platform_parser.add_argument(
        '--regex', default=False, action="store_true", help='treat the --match value as a regex')
    platform_parser.add_argument(
        '--match-entity', help='the entity_check value to apply, i.e., "all", "at least one", "none exist"')
    platform_parser.add_argument(
        '--check-existence', help='check_existence` value for the `yamlfilecontent_test`.')
    platform_parser.add_argument(
        '--negate', default=False, action="store_true", help='negate the given matching criteria (does NOT match). Default is false.')
    platform_parser.set_defaults(func=createPlatformRuleFunc)

    node_parser = type_parser.add_parser('node', help='Creates a Node rule',  parents=[common_rule_args])
    node_parser.add_argument(
        '--template',  help='The tempate to use in a Node rule')
    node_parser.add_argument(
        '--template-vars',  help='The inputs for the template, coma separated')
    node_parser.set_defaults(func=createNodeRuleFunc)

    cluster_test_parser = subparser.add_parser(
        'cluster-test', help='Test a rule on a running OCP cluster using the compliance-operator.')
    cluster_test_parser.add_argument(
        '--rule', required=True, help='The name of the rule to test. Required.')
    cluster_test_parser.add_argument(
        '--skip-deploy', default=False, action="store_true", help='Skip deploying the compliance-operator. Default is to deploy.')
    cluster_test_parser.add_argument(
        '--skip-build', default=False, action="store_true", help='Skip building and pushing the data stream. Default is true.')
    cluster_test_parser.add_argument(
        '--scan-type', help='Type of scan to execute.', dest="scantype",
        default="Platform",
        choices=["Node", "Platform"])
    cluster_test_parser.add_argument(
        '--namespace', help='Namespace where compliance operator is installed. Default is "openshift-compliance".', dest="namespace", default="openshift-compliance"
    )
    cluster_test_parser.set_defaults(func=clusterTestFunc)

    test_parser = subparser.add_parser(
        'test', help='Test a rule locally against a directory of mocked object files using podman and an oscap container.')
    test_parser.add_argument('--rule', required=True,
                             help='The name of the rule to test.')
    test_parser.add_argument(
        '--contentdir', default="./build", help='The path to the directory containing the data stream')
    test_parser.add_argument(
        '--skip-build', default=False, action="store_true", help='Skip building the data stream. Default is false.')
    test_parser.add_argument('--objectdir', default="/tmp",
                             help='The path to a directory structure of yaml objects to test against.')
    test_parser.add_argument('--verbosity', default="INFO",
                             choices=['INFO', 'DEVEL'],
                             help='How verbose should OpenScap be')
    test_parser.set_defaults(func=testFunc)

    args = parser.parse_args()

    return args.func(args)


if __name__ == "__main__":
    sys.exit(main())
