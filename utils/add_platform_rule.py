#!/usr/bin/python3

import argparse
import subprocess
import pathlib
import sys
import textwrap
import os
import time

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

$ utils/add_platform_rule.py create --rule=ocp_proxy_has_ca \
  --type="proxies.config" --name="cluster" \
  --yamlpath=".spec.trustedCA.name" --match="[a-zA-Z0-9]*"
creating check for "/apis/config.openshift.io/v1/proxies/cluster" with yamlpath ".spec.trustedCA.name" satisfying match of "[a-zA-Z0-9]*"
wrote applications/openshift/ocp_proxy_has_ca/rule.yml

$ mkdir -p /tmp/apis/config.openshift.io/v1/proxies/
$ oc get proxies.config/cluster -o yaml > /tmp/apis/config.openshift.io/v1/proxies/cluster
$ utils/add_platform_rule.py test --rule=ocp_proxy_has_ca
testing rule ocp_proxy_has_ca locally
Title
        None
Rule
        xccdf_org.ssgproject.content_rule_ocp_proxy_has_ca
Ident
        CCE-84209-6
Result
        pass

$ utils/add_platform_rule.py cluster-test --rule=ocp_proxy_has_ca
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

PLATFORM_RULE_DIR = 'applications/openshift'
OSCAP_TEST_IMAGE = 'quay.io/compliance-operator/openscap-ocp:1.3.4'
OSCAP_CMD_OPTS = 'oscap xccdf eval --verbose INFO --fetch-remote-resources --profile xccdf_org.ssgproject.content_profile_test --results-arf /tmp/report-arf.xml /content/ssg-ocp4-ds.xml'
PROFILE_PATH = 'ocp4/profiles/test.profile'

MOCK_VERSION = ('''status:
  versions:
  - name: operator
    version: 4.6.0-0.ci-2020-06-15-112708
  - name: openshift-apiserver
    version: 4.6.0-0.ci-2020-06-15-112708
''')

RULE_TEMPLATE = ('''prodtype: ocp4

title: {TITLE}

description: {DESC}

rationale: TBD

identifiers: {{}}

severity: {SEV}

warnings:
- general: |-
    {{{{{{ openshift_cluster_setting("{URL}") | indent(4) }}}}}}

template:
  name: yamlfile_value
  vars:
    ocp_data: "true"{ENTITY_CHECK}{CHECK_EXISTENCE}
    filepath: {URL}
    yamlpath: "{YAMLPATH}"
    values:
    - value: "{MATCH}"{CHECK_TYPE}
''')


def operation_value(value):
    if value:
        return '\n      operation: "pattern match"\n      type: "string"'
    else:
        return ''


def entity_value(value):
    if value is not None:
        return '\n    entity_check: "%s"' % value
    else:
        return ''

def check_existence_value(value):
    if value is not None:
        return '\n    check_existence: "%s"' % value
    else:
        return ''


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
spec:
  scanType: Platform
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


@needs_oc
def createFunc(args):
    url = args.url
    retries = 0
    namespace_flag = ''
    if args.namespace is not None:
        namespace_flag = '-n ' + args.namespace

    group_path = os.path.join(PLATFORM_RULE_DIR, args.group)
    if args.group:
        if not os.path.isdir(group_path):
            print("ERROR: The specified group '%s' doesn't exist in the '%s' directory" % (
                args.group, PLATFORM_RULE_DIR))
            return 0

    rule_path = os.path.join(group_path, args.rule)
    while url is None and retries < 5:
        retries += 1
        ret_code, output = subprocess.getstatusoutput(
            'oc get %s/%s -o template="{{.metadata.selfLink}}" %s' % (args.type, args.name, namespace_flag))
        if ret_code != 0:
            print('error running oc, check connection to the cluster: %d\n %s' % (
                ret_code, output))
            continue
        if len(output) > 0 and '/api' in output:
            url = output

    if url == None:
        print('there was a problem finding the URL from the oc debug output. Hint: override this automatic check with --url')
        return 1

    print('* Creating check for "%s" with yamlpath "%s" satisfying match of "%s"' % (
        url, args.yamlpath, args.match))
    rule_yaml_path = os.path.join(rule_path, 'rule.yml')

    pathlib.Path(rule_path).mkdir(parents=True, exist_ok=True)
    with open(rule_yaml_path, 'w') as f:
        f.write(RULE_TEMPLATE.format(URL=url, TITLE=args.title, SEV=args.severity, IDENT=args.identifiers,
                                     DESC=args.description, YAMLPATH=args.yamlpath, MATCH=args.match,
                                     NEGATE=str(args.negate).lower(),
                                     CHECK_TYPE=operation_value(args.regex),
                                     CHECK_EXISTENCE=check_existence_value(args.check_existence),
                                     ENTITY_CHECK=entity_value(args.match_entity)))
    print('* Wrote ' + rule_yaml_path)
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
        "find %s -name '%s' -type d" % (PLATFORM_RULE_DIR, args.rule))
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
            ['utils/build_ds_container.sh', '-P', 'ocp4', '-P', 'rhcos4'])
        if buildp.returncode != 0:
            try:
                os.remove(PROFILE_PATH)
            except OSError:
                pass
            return 1

    ret_code, _ = subprocess.getstatusoutput(
        'oc delete compliancescans/test')
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
            input=TEST_SCAN_TEMPLATE.format(PROFILE=profile).encode())
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
            'oc get compliancescans/test -o template="{{.status.phase}} {{.status.result}}"')
        if output is not None:
            print('> Output from last phase check: %s' % output)
        if output.startswith('DONE'):
            scan_result = output[5:]
            break
        if time.time() >= timeout:
            break
        time.sleep(2)

    if scan_result == None:
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
    if not os.path.exists(version_dir):
        pathlib.Path(version_dir).mkdir(parents=True, exist_ok=True)
        with open(version_dir + '/openshift-apiserver', 'w') as f:
            f.write(MOCK_VERSION)

    pod_cmd = 'podman run -it --security-opt label=disable -v "%s:/content" -v "%s:/kubernetes-api-resources" %s %s' % (args.contentdir,
                                                                                                                        args.objectdir, OSCAP_TEST_IMAGE, OSCAP_CMD_OPTS)
    print(subprocess.getoutput(pod_cmd))


def main():
    parser = argparse.ArgumentParser(
        prog="add_platform_rule.py",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        description=textwrap.dedent(PROG_DESC))
    subparser = parser.add_subparsers(
        dest='subcommand', title='subcommands', help='pick one')
    create_parser = subparser.add_parser(
        'create', help='Bootstrap the XML and YML files under %s for a new check.' % PLATFORM_RULE_DIR)
    create_parser.add_argument(
        '--rule', required=True, help='The name of the rule to create. Required.')
    create_parser.add_argument(
        '--group', default="", help='The group directory of the rule to create.')
    create_parser.add_argument(
        '--name', required=True, help='The name of the Kubernetes object to check. Required.')
    create_parser.add_argument(
        '--type', required=True, help='The type of Kubernetes object, e.g., configmap. Required.')
    create_parser.add_argument('--yamlpath', required=True,
                               help='The yaml-path of the element to match against.')
    create_parser.add_argument(
        '--match', required=True, help='A string value or regex providing the matching criteria. Required')
    create_parser.add_argument(
        '--namespace', help='The namespace of the Kubernetes object (optional for cluster-scoped objects)', default=None)
    create_parser.add_argument(
        '--title', help='A short description of the check.')
    create_parser.add_argument(
        '--url', help='The direct api path (metadata.selfLink) of the object, which overrides --type --name and --namespace options.')
    create_parser.add_argument(
        '--description', help='A human-readable description of the provided matching criteria.')
    create_parser.add_argument(
        '--regex', default=False, action="store_true", help='treat the --match value as a regex')
    create_parser.add_argument(
        '--match-entity', help='the entity_check value to apply, i.e., "all", "at least one", "none exist"')
    create_parser.add_argument(
        '--check-existence', help='check_existence` value for the `yamlfilecontent_test`.')
    create_parser.add_argument(
        '--negate', default=False, action="store_true", help='negate the given matching criteria (does NOT match). Default is false.')
    create_parser.add_argument(
        '--identifiers', default="TBD", help='an identifier for the rule (CCE number)')
    create_parser.add_argument(
        '--severity', default="unknown", help='the severity of the rule.')
    create_parser.set_defaults(func=createFunc)

    cluster_test_parser = subparser.add_parser(
        'cluster-test', help='Test a rule on a running OCP cluster using the compliance-operator.')
    cluster_test_parser.add_argument(
        '--rule', required=True, help='The name of the rule to test. Required.')
    cluster_test_parser.add_argument(
        '--skip-deploy', default=False, action="store_true", help='Skip deploying the compliance-operator. Default is to deploy.')
    cluster_test_parser.add_argument(
        '--skip-build', default=False, action="store_true", help='Skip building and pushing the datastream. Default is true.')
    cluster_test_parser.set_defaults(func=clusterTestFunc)

    test_parser = subparser.add_parser(
        'test', help='Test a rule locally against a directory of mocked object files using podman and an oscap container.')
    test_parser.add_argument('--rule', required=True,
                             help='The name of the rule to test.')
    test_parser.add_argument(
        '--contentdir', default="./build", help='The path to the directory containing the datastream')
    test_parser.add_argument(
        '--skip-build', default=False, action="store_true", help='Skip building the datastream. Default is false.')
    test_parser.add_argument('--objectdir', default="/tmp",
                             help='The path to a directory structure of yaml objects to test against.')
    test_parser.set_defaults(func=testFunc)

    args = parser.parse_args()

    return args.func(args)


if __name__ == "__main__":
    sys.exit(main())
