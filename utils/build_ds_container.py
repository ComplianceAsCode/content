#!/usr/bin/python3

import argparse
import logging as log
import os
import shutil
import subprocess
import sys
import tempfile
import time
import uuid

import yaml


DESCRIPTION = '''
A tool for building compliance content for Kubernetes clusters.

This tool supports building ComplianceAsCode content locally or remotely on an
existing kubernetes cluster. This script requires Git, OpenShift CLI,
Kubernetes CLI, Podman CLI, and PyYAML.

'''


parser = argparse.ArgumentParser(
    formatter_class=argparse.ArgumentDefaultsHelpFormatter,
    description=DESCRIPTION)
parser.add_argument(
    '-n', '--namespace',
    help='Build image in the given namespace.',
    default='openshift-compliance')
parser.add_argument(
    '-p', '--create-profile-bundles',
    help='Create ProfileBundle objects for the image.',
    action='store_true',
    default=False)
parser.add_argument(
    '-c', '--build-in-cluster',
    help=(
        'Build content in-cluster. Note that this option ignores the '
        '--product and --debug flags.'),
    action='store_true',
    default=False)
parser.add_argument(
    '-i', '--push-content-image',
    help=(
        'Do not build any content. Create profile bundles from the referenced k8s content image'),
    )
parser.add_argument(
    '-d', '--debug',
    help=(
        'Provide debug output during the build process. This option is '
        'ignored when building content in the cluster using '
        '--build-in-cluster.'),
    action='store_true',
    default=False)
parser.add_argument(
    '-P', '--product',
    help=(
        'The product(s) to build. This option can be provided multiple times. '
        'This option is ignored when building content in the cluster using '
        '--build-in-cluster.'),
    default=['ocp4', 'rhcos4'],
    dest='products',
    nargs='*')
parser.add_argument(
    '-r', '--repository',
    help=(
        'The container image repository to use for images containing built '
        'content. Images pushed to this repository must have a tag, which '
        'you can specify with the --container-image-tag argument. If you do '
        'not supply a tag, one will be generated for you. It is recommended '
        'that you properly tag built images for production use. '
        'Auto-generated tags are primarily useful for development workflows. '
        'This script assumes you have authenticated to the image repository '
        'if necessary (e.g, `podman login quay.io`).'))
parser.add_argument(
    '-t', '--container-image-tag',
    help='A unique tag for the container image.')
args = parser.parse_args()

CAPTURE_OUTPUT = not args.debug
DEBUG_LEVEL = log.INFO
if args.debug:
    DEBUG_LEVEL = log.DEBUG


log.basicConfig(
    format='%(asctime)s:%(levelname)s: %(message)s', level=DEBUG_LEVEL)


# FIXME(lbragstad): Remove this and replace it with operating system utils if
# possible.
command = ['git', 'rev-parse', '--show-toplevel']
result = subprocess.run(command, capture_output=True, check=True)
# Convert the file path from bytes to unicode since we might manipulate it
# later. Also, strip off any newlines.
REPO_PATH = result.stdout.decode().strip()


def ensure_namespace_exists():
    """Function that ensures there is a namespace for the content."""
    if args.namespace == 'openshift-compliance':
        namespace_file = os.path.join(
            REPO_PATH, 'ocp-resources', 'compliance-operator-ns.yaml')
        subprocess.run(
            ['oc', 'apply', '-f', namespace_file],
            capture_output=CAPTURE_OUTPUT)
        log.debug(f'Created namespace {args.namespace}')
    else:
        log.debug(f'Assuming {args.namespace} namespace exists.')


def build_content_locally(products):
    """Build compliance content locally for a list of products.

    :param products: list of strings
    """

    build_binary_path = os.path.join(REPO_PATH, 'build_product')
    command = [build_binary_path] + products
    if args.debug:
        command.append('--debug')
    subprocess.run(command, check=True, capture_output=CAPTURE_OUTPUT)
    log.info(f'Successfully built content for {", ".join(products)}')


# NOTE(lbragstad): This could use something like podman-py.
def build_container_image():
    """Use Podman to build a container image for the content."""
    dockerfile_path = os.path.join(
        REPO_PATH, '/Dockerfiles/compliance_operator_content.Dockerfile')
    command = [
        'podman', 'build', '-f', dockerfile_path, '-t',
        'localcontentbuild:latest', '.']
    subprocess.run(command, check=True, capture_output=CAPTURE_OUTPUT)
    log.info('Successfully built container image')


# NOTE(lbragstad): This could use something like podman-py.
def push_container_to_repository(repository, tag):
    """Push a container image to an image repository.

    :param repository: string representing the location of the repository
    :param tag: string representing the container image tag
    """
    repository_string = repository + ':' + tag
    command = [
        'podman', 'push', 'localhost/localcontentbuild:latest',
        repository_string]
    result = subprocess.run(command, capture_output=True)
    if result.returncode == 0:
        log.info(f'Pushed image to {repository}:{tag}')
    elif result.returncode == 125:
        log.error(
            'Failed to push container image due to authentication issues. '
            'Make sure you have authenticated to the registry before '
            'running this script.')
        sys.exit(2)
    else:
        log.error(f'Failed to push container image to {repository_string}')
        sys.exit(2)


def setup_remote_build_resources():
    """Create an ImageStream and BuildConfig to build content in cluster.

    This method is only intended to run on OpenShift clusters since it relies
    on ImageStreams and BuildConfigs, which are not available in vanilla
    Kubernetes deployments.
    """
    remote_resources_file = os.path.join(
        REPO_PATH, 'ocp-resources', 'ds-build-remote.yaml')
    command = ['oc', 'apply', '-n', args.namespace, '-f', remote_resources_file]
    subprocess.run(command, check=True, capture_output=CAPTURE_OUTPUT)


def setup_local_build_resources():
    """Create an ImageStream and BuildConfig to use locally built content.

    This method is only intended to run on OpenShift clusters since it relies
    on ImageStreams and BuildConfigs, which are not available in vanilla
    Kubernetes deployments.
    """
    local_resources_file = os.path.join(
        REPO_PATH, 'ocp-resources', 'ds-from-local-build.yaml')
    command = ['oc', 'apply', '-n', args.namespace, '-f', local_resources_file]
    subprocess.run(command, check=True, capture_output=CAPTURE_OUTPUT)


def copy_build_files_to_output_directory(output_directory):
    """Copy build resources to a dedicated directory.

    :param output_directory: string representing the directory path
    """
    build_directory = os.path.join(REPO_PATH, 'build')
    for f in os.listdir(build_directory):
        filepath = os.path.join(build_directory, f)
        if os.path.isfile(filepath) and filepath.endswith('-ds.xml'):
            shutil.copy(filepath, output_directory)


def start_build(output_directory):
    """Start an OpenShift build for OpenSCAP content.

    :param output_directory: string representing the directory path
    """
    command = [
        'oc', 'start-build', '-n', args.namespace, 'openscap-ocp4-ds',
        '--from-dir=%s' % output_directory]
    subprocess.run(command, check=True, capture_output=CAPTURE_OUTPUT)


def create_profile_bundles(products, content_image=None):
    """Create ProfileBundle custom resources for built content.

    :param products: a list of strings
    :param content_image: a string representing the repository and tag for
                          content (optional)
    """
    for product in products:
        content_file = 'ssg-' + product + '-ds.xml'
        product_name = 'upstream-' + product
        profile_bundle_update = {
            'apiVersion': 'compliance.openshift.io/v1alpha1',
            'kind': 'ProfileBundle',
            'metadata': {'name': product_name},
            'spec': {
                'contentImage': content_image or 'openscap-ocp4-ds:latest',
                'contentFile': content_file}}
        with tempfile.NamedTemporaryFile() as f:
            yaml.dump(profile_bundle_update, f, encoding='utf-8')
            command = ['kubectl', 'apply', '-n', args.namespace, '-f', f.name]
            subprocess.run(command, check=True, capture_output=CAPTURE_OUTPUT)
    log.info(f'Created profile bundles for {", ".join(products)}')


def get_latest_build():
    """Return the latest version of a build.

    :returns: a string representing the latest version of the build, typically
              an integer
    """
    command = [
        'oc', 'get', 'buildconfigs', '-n', args.namespace, '--no-headers',
        'openscap-ocp4-ds', '-o', 'custom-columns=status:.status.lastVersion']
    build = subprocess.run(command, check=True, capture_output=True).stdout
    return build.decode().strip()


def get_build_status(build):
    """Return the status of a build.

    :param build: a string representing the build version
    :returns: a string representing the build status
    """
    command = [
        'oc', 'get', '-n', args.namespace, 'builds',
        'openscap-ocp4-ds-' + build, '--no-headers', '-o',
        'custom-columns=status:.status.phase']
    status = subprocess.run(command, check=True, capture_output=True).stdout
    return status.decode().strip()


def get_image_repository():
    """Return the image repository for an ImageStream containing content.

    :returns: a string representing the image repository and tag
    """
    command = [
        'oc', 'get', '-n', args.namespace, 'imagestreams', 'openscap-ocp4-ds',
        '--no-headers', '-o', 'custom-columns=repo:.status.dockerImageRepository']
    image_repo = subprocess.run(command, check=True, capture_output=True).stdout
    return image_repo.decode().strip()


if args.push_content_image:
    create_profile_bundles(args.products, args.push_content_image)
    sys.exit(0)

log.info(f'Building content for {", ".join(args.products)}')
ensure_namespace_exists()


if args.repository:
    build_content_locally(args.products)
    build_container_image()

    # generate a container image tag if the user didn't supply one
    if args.container_image_tag:
        tag = args.container_image_tag
    else:
        tag = uuid.uuid4().hex[:16]

    push_container_to_repository(args.repository, tag)
    content_image = args.repository + ':' + tag
    if args.create_profile_bundles:
        create_profile_bundles(args.products, content_image=content_image)
    sys.exit(0)
elif args.build_in_cluster:
    setup_remote_build_resources()
    output_directory = REPO_PATH
else:
    build_content_locally(args.products)
    setup_local_build_resources()
    output_directory = tempfile.mkdtemp()
    copy_build_files_to_output_directory(output_directory)


start_build(output_directory)

# clean up output directory for local builds
if not args.build_in_cluster:
    shutil.rmtree(output_directory)

# wait some time before asking for build status
time.sleep(5)

BUILD = get_latest_build()

while True:
    status = get_build_status(BUILD)
    if status == 'Complete':
        image = get_image_repository()
        log.info(f'Your image is available at {image}')
        break
    elif status == 'Error':
        log.error(f'Build openscap-ocp-ds-{BUILD} failed. Check the log for more information')
        sys.exit(1)
    log.info('Build status: %s', status)
    polling_interval_second = 3
    # allow at least a little time before we fetch the status
    time.sleep(polling_interval_second)

if args.create_profile_bundles:
    create_profile_bundles(args.products)
