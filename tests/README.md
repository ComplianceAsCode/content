# SSG Test Suite

This directory contains SSG Test Suite, effort separate to the main SSG code.
Goal of this Test Suite is primarily to ensure Remediation scripts are usable,
and to define scenarios in which these should work.

Priority is to provide very simple system of test scenarios, easily extendable
so everyone contributing remediation can also provide cases where this
remediation works.

## Prerequisites

You can use the more powerful VM-based tests, or more lightweight container-based tests.

For the Test Suite to work, you need to have libvirt domains prepared for
testing.
SSG Test Suite currently does not provide automated provisioning of domains.
You can use kickstart usable for Red Hat Enterprise Linux 7 (and of course
CentOS 7) and Fedora in `kickstarts` directory, which installs machine capable of
running tests with SSG Test Suite.

If you want to use your own domain, make sure `openscap-1.2.15` and
`qemu-guest-agent` are installed there, `root` is accessible via ssh and that
packages packages can be installed (for RHEL7, it means subscription enabled).
For testing Ansible remediations, it is sufficient to have `root` accessible via
ssh on the libvirt domain and have Ansible installed on the host machine.

### Domain preparation


1. Install domain, using provided kickstart

   To install the domain via graphical install, supply boot option:  
   `inst.ks=https://raw.githubusercontent.com/ComplianceAsCode/content/master/tests/kickstarts/rhel_centos_7.cfg`.
   And the installation will be guided by the kickstart.

   To install the domain via command line, you can use script `./install_vm.py`. Common usage will look like:
   ```
   ./install_vm.py --domain test-suite-fedora --distro fedora
   ```

1. Import ssh key to the machine and make sure that you can use them to log in
   as the `root` superuser.
1. In case of installing a RHEL domain, setup subscription so that the machine can install and uninstall packages.

*NOTE*: Create snapshot after all these steps, to manually revert in case the
test suite breaks something and fails to revert. Do not use snapshot names
starting with `ssg_`.

## Executing the test suite

### Common options

- `--datastream`: Path to the datastream that you want to use for scanning.
  It will be transferred to the scanned VM via SSH.
- `--xccdf-id`: Also known as `Ref-ID`, it is the identifier of benchmark within
  the datastream.  It can be obtained by running `oscap info` over the
  datastream XML and searching for `Ref-ID` strings.
- `--mode`: Can be either `online` or `offline`, which corresponds either to
  online or offline scanning mode. Online scanning mode uses `oscap-ssh`, while
  offline scanning is backend-specific.
  As offline scanning examines the filesystem of the container or VM, it may require
  extended privileges.
- `--help`: This will get you the invocation help.

VM-based tests:

- `--libvirt`: Accepts two arguments - `hypervisor` and `domain`.
  - `hypervisor`: Typically, you will use the `qemu:///system` value.
  - `domain`: `libvirt` domain, which is basically name of the virtual machine.

Container-based tests:

- `--docker`: Uses Docker as container engine. Accepts the base image name.
- `--container`: Uses Podman as container engine. Accepts the base image name.

### Profile-based testing

In this operation mode, you specify the `profile` command and you supply the
profile ID as a positional argument.  The test suite then runs scans over the
target domain and remediates it based on particular profile.

An example invocation may look like this:

```
./test_suite.py profile --libvirt qemu:///system ssg-test-suite-centos --datastream ../build/ssg-centos7-ds.xml --xccdf-id scap_org.open-scap_cref_ssg-rhel7-xccdf-1.2.xml profile-id
```

`profile-id` is matched by the suffix so it is the same as the `oscap` tool
works (you can use `oscap info --profiles` to see available profiles).

### Rule-based testing

In this mode, you specify the `rule` command and you supply part of the rule
title as a positional argument.  Unlike the profile mode, here each rule from
the matching rule set is addressed independently, one-by-one.

Rule-based testing enables to perform two kinds of tests:

- Check tests: The system is set up into a compliant, or a non-compliant state.

  Typically, the compliant state is different from the default or
  post-remediation state. The scanner is supposed to correctly identify the
  state of the system, so it is checked against false positives and false
  negatives.

- Remediation tests: The system is set up into a non-compliant state, and
  remediation is performed.

If you would like to evaluate the rule `rule_sysctl_net_ipv4_conf_default_secure_redirects`:

```
./test_suite.py rule --libvirt qemu:///system ssg-test-suite-centos --datastream ../build/ssg-centos7-ds.xml --xccdf-id scap_org.open-scap_cref_ssg-rhel7-xccdf-1.2.xml ipv4_conf_default_secure_redirects
```

Notice there is not full rule name used on the command line.
Test suite runs every rule, which contains given substring in the name.
So all that is needed is to use unique substring.

### How rule validation scenarios work

In directory `data` are directories mirroring `group/group/.../rule`
structure of datastream. In reality, only name of the rule directory needs to be
correct, group structure is currently not used.

Scenarios are currently supported only in `bash`. And type of scenario is
defined by its file name.

#### (something).pass.sh

Success scenario - script is expected to prepare machine in such way that the
rule is expected to pass.

#### (something).fail.sh

Fail scenario - script is expected to break machine so the rule fails. Test
Suite than, if initial scan successfully fails, tries to remediate machine and
expects success.

#### (something).sh

Support files, that are available to the scenarios during their runtime. Can
be used as common libraries.

### Scenarios format

Scenarios are simple bash scripts. The scenarios start with a header which provides metadata.
The header consists of comments (starting by `#`). Possible values are:
- `platform` is a comma-separated list of platforms where the test scenario can be run. This is similar to `platform` used in our remediations. Examples of values: `multi_platform_rhel`, `Red Hat Enterprise Linux 7`, `multi_platform_all`. If `platform` is not specified in the header, `multi_platform_all` is assumed.
- `profiles` is a comma-separated list of profiles which are using this scenario.
- `remediation` is a comma-separated list of allowed remediation types (eg. `bash`, `ansible`, `none`).
  The `none` value means that the tested rule has no implemented remediation.
- `templates` has no effect at the moment.

Example of a scenario:

```
#!/bin/bash
#
# platform = Red Hat Enterprise Linux 7, multi_platform_fedora
# profiles = xccdf_org.ssgproject.content_profile_ospp

echo "KerberosAuthentication yes" >> /etc/ssh/sshd_config
```

After the header arbitrary bash commands follow.

## Example of incorporating new test scenario

Let's show how to add test scenario for
[Red Hat Bugzilla 1392679](https://bugzilla.redhat.com/show_bug.cgi?id=1392679)
(already included).

Bugzilla is about `sshd_config` being not altered correctly. Thus:

1. Create appropriate directory within `data/` directory tree (in this case
  `data/group_services/group_ssh/group_ssh_server/rule_sshd_disable_kerb_auth`
  further referenced as *DIR*).
1. put few fail scripts - for example removing the line, commenting it, etc.
 into *DIR*
1. put pass script into *DIR*
1. ????
1. PROFIT (nothing more to do)

Now, you can perform validation check with command

```
./test_suite.py rule --libvirt qemu:///system ssg-test-suite-centos --datastream ../build/ssg-centos7-ds.xml --xccdf-id scap_org.open-scap_cref_ssg-rhel7-xccdf-1.2.xml rule_sshd_disable_kerb_auth
```

## Container backends

You can also run the tests in a container. There are 2 container backends, Podman and Docker, supported.

To use container backends, use the following options on the command line:

- Podman - `--container <base image name>`
- Docker - `--docker <base image name>`

To obtain the base image, you can use `test_suite-*` Dockerfiles in the `Dockerfiles` directory to build it.
We recommend to use RHEL-based containers, as the test suite is optimized for testing the RHEL content.

To use Podman backend, you need to have:

- `podman` package installed, and
- rights that allow you to start/stop containers and to create images.

To use Docker backend, you need to have:

- the [docker](https://pypi.org/project/docker/) Python module installed. You may have to use `pip` to install it on older distributions s.a. RHEL 7, running `pip install --user docker` as `root` will do the trick of installing it only for the `root` user.
- the Docker service running, and
- rights that allow you to start/stop containers and to create images.
  This level of rights is considered to be insecure, so it is recommended to run the test suite in a VM.
  You can accomplish this by creating a `docker` group, then add yourself in it and restart `docker`.


### Building the base image

The container image you want to use with the tests needs to be prepared, so it can scan itself, and that it can accept connections and data.
Following services need to be supported:

- `sshd` (`openssh-server` needs to be installed, server host keys have to be in place, root's `.ssh/authorized_keys` are set up with correct permissions)
- `scp` (`openssh-clients` need to be installed - `scp` requires more than a ssh server on the server-side)
- `oscap` (`openscap-scanner` - the container has to be able to scan itself)
- You may want to include another packages, as base images tend to be bare-bone and tests may require more packages to be present.

#### Using Podman

NOTE: With Podman, you have to run all the operations as root. Podman supports rootless containers, but the test suite internally uses a container exposing a TCP port. As of Podman version 0.12.1.2, port bindings are not yet supported by rootless containers.

The root user therefore needs an key without passphrase, so it can log in to the container without any additional interaction.
Root user typically doesn't have a SSH key, or it has one without a passphrase.
Use this test to find out whether it has a key:

```
sudo test -f /root/.ssh/id_rsa && echo "Root user already has an id_rsa key" || echo "Root user has no id_rsa key"
```

If there is no key, it is safe to create one:

```
ssh-keygen -f id_rsa -N ""
sudo mkdir -p /root/.ssh
sudo chmod go-rwx /root/.ssh
sudo mv id_rsa* /root/.ssh
```

In any case, `root` now has an `id_rsa` key without passphrase, so let's build the container.
Go into the `Dockerfiles` directory of the project, and execute the following:

```
public_key="$(sudo cat /root/.ssh/id_rsa.pub)"
podman build --build-arg CLIENT_PUBLIC_KEY="$public_key" -t ssg_test_suite -f test_suite-rhel .
```

#### Using Docker

The procedure is same as using Podman, you just swap the `podman` call with `sudo docker`.

### Running the tests

This is an example to run test scenarios for rule `rule_sshd_disable_kerb_auth`:

Using Podman:

```
./test_suite.py rule --container ssg_test_suite --datastream ../build/ssg-centos7-ds.xml --xccdf-id scap_org.open-scap_cref_ssg-rhel7-xccdf-1.2.xml rule_sshd_disable_kerb_auth
```

Using Docker:

```
./test_suite.py rule --docker ssg_test_suite --datastream ../build/ssg-centos7-ds.xml --xccdf-id scap_org.open-scap_cref_ssg-rhel7-xccdf-1.2.xml rule_sshd_disable_kerb_auth
```

Also, as containers may get any IP address, a conflict may appear in your local client's `known_hosts` file.
You might have a version of `oscap-ssh` that doesn't support ssh connection customization at the client-side, so it may be a good idea to disable known hosts checks for all hosts if you are testing on a VM or under a separate user.
You can do that by putting following lines in your `$HOME/.ssh/config` file:

```
StrictHostKeyChecking no
UserKnownHostsFile /dev/null
```

## Analysis of results

The rule tests results are saved as `results.json` into the corresponding log directory.
You can then analyze those results by running e.g.

```
python analyze_results.py $(find . -name results.json)
```

The tool will print some general statistics and it will give you more detailed information about
scenarios that yielded different results.
Sometimes, different results may have been caused by different test environments, whereas sometimes
the security content is different, and those scans can be identified by respective scanning dates only.
