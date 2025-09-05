This directory contains SSG Test Suite, effort separate to the main SSG code.
Goal of this Test Suite is primarily to ensure Remediation scripts are usable,
and to define scenarios in which these should work.

Priority is to provide very simple system of test scenarios, easily extendable
so everyone contributing remediation can also provide cases where this
remediation works.

The Test Suite executes the scans, remediations, and test scenarios on VMs or containers.\
To test content using VMs, *Libvirt backend* is used;\
to test content using containers, either *Podman* or *Docker* backend can be used.

Once a domain or container is prepared it can be used indefinitely.\
The Test Suite can perform tests focused on a profile or a specific rule.\
Typically, for a test run, a sequence of scan, remediation and scan is peformed.

# How to prepare a backend for testing
For the Test Suite to work, you need to have a backend image prepared for testing.\
You can use a powerful full-blown VM backend, or a lightweight container backend.

SSG Test Suite currently does not provide automated provisioning of VMs or containers.

## Libvirt backend

To use Libvirt backend, you need to have:

- These packages installed in your host
  - `openssh-clients`
  - `libvirt`
  - `libvirt-daemon`
  - `python2-libvirt/python3-libvirt`
  - `virt-install`      (recommended, used by `install_vm.py` script)
  - `libvirt-client`    (optional, to manage VMs via console)
  - `virt-manager`      (optional, to manage VMs via GUI)
  - `virt-viewer`       (optional, to access graphical console of VMs)
  - `ansible`           (required if remediating via Ansible)
  - `edk2-ovmf`         (required if you want to install UEFI based machine)
- A VM that fullfils following requirements:
  - Package `qemu-guest-agent` installed
  - Package `openscap` version 1.2.15 or higher installed
  - `root` can login via ssh (it is recommended to setup key-based authentication)
  - `root` can install packages (for RHEL7, it means subscription enabled).

An easy way to install your VM is via `install_vm.py` script. It will setup a VM\
according to the requirements, including configuration of a key for SSH login.

Common usage looks like:
```
$ python install_vm.py --domain test-suite-fedora --distro fedora
```

By default, the key at `~/.ssh/id_rsa.pub` is used. You can change default key used via `--ssh-pubkey` option.

By default, the VM will be created on the user hypervisor, i.e. `qemu:///session`.
For Test Suite this should be enough, in case you need the VM to reside under `qemu:///system`, use the install script with `--libvirt qemu:///system`.

When installing a RHEL VM, you will still need to subscribe it. You can also run installation and provide custom URLs pointing to your repositories:
```
$ python install_vm.py --domain test-suite-rhel8 --distro rhel8 --url http://baseos_repo_addr --extra-repo http://appstream_repo_addr
```

By default, the script creates a BIOS based machine. If you need to create UEFI
based machine, supply the `--uefi normal` or `--uefi secureboot` command line
argument. The script will create UEFI based machine and make necessary changes
to partitioning scheme. Note that the Libvirt backend cannot make snapshots of
UEFI based machines. Therefore, you can't use them with SSG test suite.

*TIP*: Create a snapshot as soon as your VM is setup. This way, you can manually revert
in case the test suite breaks something and fails to revert. Do not use snapshot names starting with `ssg_`.\
You can create a snapshot using `virsh` or `virt-manager`.

## Container backends

There are 2 container backends supported, Podman and Docker.

The container image needs to be prepared so it can accept ssh connections from `root`, and run OpenSCAP scan.\
The image needs to fulfil the following requirements:

  - Package `openssh-server` installed
    - `root`'s `.ssh/authorized_keys` is setup with correct permissions
    - the container's server host keys have to be in place
  - Packages `scp` and `openssh-clients` are installed
    - `scp` requires more than a ssh server on the server-side
  - Package `openscap-scanner` version 1.2.15 or higher installed
  - You may want to include other packages, as base images tend to be bare-bone and tests may require more packages to be present.

You can use `test_suite-*` Dockerfiles in the [`content/Dockerfiles`](../Dockerfiles) directory to build the images.
We recommend to use RHEL-based containers, as the test suite is optimized for testing the RHEL content.

### Podman

To use Podman backend, you need to have:

- `podman` package installed

#### Building podman base image
The Test Suite will log in to the container via SSH, so, if you don't have an SSH key pair, lets setup a key without passphrase, so the procedure could happen without any additional interaction. You can skip this step if you already have an SSH key pair.

```
ssh-keygen -N ""
```

*NOTE*: With Podman you don't have to be root in order to run tests and manage containers. But if you prefer to set up your test containers as superuser do keep in mind that root user typically doesn't have an SSH key and you have to create it with *sudo ssh-keygen -N ""* command before moving forward. You can check if your root user has the key with a command like this: *sudo test -f /root/.ssh/id_rsa && echo "Root user already has an id_rsa key" || echo "Root user has no id_rsa key"*

Now when we all set with SSH keys let's build the container. Go into the `Dockerfiles` directory of the project, and execute the following:

```
public_key="$(cat ~/.ssh/id_rsa.pub)"
podman build --build-arg CLIENT_PUBLIC_KEY="$public_key" -t ssg_test_suite -f test_suite-rhel .
```

or just call the `build_test_container.sh` script.

*NOTE*: If you are setting up the suite as superuser (i.e. *sudo podman build ...*) use *public_key="$(sudo cat /root/.ssh/id_rsa.pub)"* instead of the first command.

### Docker

To use Docker backend, you need to have:

- The [docker](https://pypi.org/project/docker/) Python module installed. You may have to use `pip` to install it on older distributions s.a. RHEL 7, running `pip install --user docker` as `root` will do the trick of installing it only for the `root` user.
- the Docker service running, and
- Rights that allow you to start/stop containers and to create images. This is achieved by:
  - using `sudo` with every `docker` command, or;
  - create a `docker` group, then add yourself to it and restart `docker`. Depending on your OS, you may need to logout for the group change to apply.

#### Building docker base image

The procedure is same as using Podman, you just swap the `podman` call with `docker`. But since Docker does not support rootless containers you will have to take superuser route of the guide.

# How to run the tests

To test you profile or rule use `test_suite.py` script. It can take your DataStream, and test it on the specified backend.
The Test Suite can test a whole profile or just a specific rule within a profile.

# Argument summary

Mode of operation, specify one of the following commands;
- `profile`: Evaluate, remediate and evalute again using selected profile
- `rule`: Evaluate a rule, remediate, and evaluate again in context of test scenarios.
- `combined`: Evaluate, remediate, and evaluate again the rules from a profile in context of test scenarios.

Specify backend and image to use:
- To use VM backend, use the following option on the command line:
  - Libvirt - `--libvirt <hypervisor> <domain>`
    - `hypervisor`: Typically, you will use the `qemu:///session`, or `qemu:///system`.
       It depends on where your VM resides.
    - `domain`: `libvirt` domain, which is basically name of the virtual machine.

*NOTE*: It might happen, especially while using other distros than Fedora or RHEL (for example Arch), that you encounter the following error:

```
libvirt: QEMU Driver error : operation failed Failed to take snapshot: Error: Nested VMX virtualization does not support live migration yet
```

This error might be followed by Python tracebacks where the above message is repeated. First make sure that you are running the test suite on the physical machine and that you really DO NOT use nested virtualization by running VM in VM.

If you pass this requirement, it might happen that nested virtualization is enabled for your KVM kernel module. Libvirt will refuse to do live migration in this case. You can check this by running:

```
$ cat /sys/module/kvm_intel/parameters/nested
```

If you see "Y" then the nested virtualization is enabled for the KVM kernel module and it needs to be disabled. This can be done temporarily by running:

```
# modprobe -r kvm_intel
# modprobe kvm_intel nested=0
```

or permanently by putting

```
options kvm_intel nested=0
```

into a file ending with .conf and placed into the /etc/modprobe.d/ directory.

- To use container backends, use the following options on the command line:
  - Podman - `--container <base image name>`
  - Docker - `--docker <base image name>`

Specify DataStream to use:
- `--datastream`: Path to the datastream that you want to use for scanning.
  It will be transferred to the scanned system via SSH.
  The option can be omitted if there is only one datastream in the build directory.

Specify as last argument the id of a profile or rule to be tested.

<!--- Commented until offline support is fixed --->
<!--- - `mode`: Can be either `online` or `offline`, which corresponds either to --->
<!---   online or offline scanning mode. Default is `online`. --->
<!---   Online scanning mode uses `oscap-ssh`, while offline scanning is backend-specific. --->
<!---   As offline scanning examines the filesystem of the container or VM, it may require --->
<!---   extended privileges. --->


<!--- Is there an environmenent variable for that? --->
*Note*:Also, as containers may get any IP address, a conflict may happen in your local client's `known_hosts` file.
You might have a version of `oscap-ssh` that doesn't support ssh connection customization at the client-side, so it may be a good idea to disable known hosts checks for all hosts if you are testing on a VM or under a separate user.
You can do that by putting following lines in your `$HOME/.ssh/config` file:

```
StrictHostKeyChecking no
UserKnownHostsFile /dev/null
```

All logs of Test Suite are stored in `logs` directory. The specific diretory is shown at the beginning of each test run.

## Profile-based testing

In this operation mode, you specify the `profile` command and you supply the
profile ID as a positional argument.  The test suite then runs scans over the
target domain and remediates it based on particular profile.

To test RHEL7 STIG Profile on a VM:
```
./test_suite.py profile --libvirt qemu:///session ssg-test-suite-rhel7 --datastream ../build/ssg-rhel7-ds.xml stig
```

To test Fedora Standard Profile on a Podman container:
```
./test_suite.py profile --container ssg_test_suite --datastream ../build/ssg-fedora-ds.xml standard
```

To test Fedora Standard Profile on a Docker container:
```
./test_suite.py profile --docker ssg_test_suite --datastream ../build/ssg-fedora-ds.xml standard
```

Note that `profile-id` is matched by the suffix, so it works the same as in `oscap` tool
(you can use `oscap info --profiles` to see available profiles).

### Unselecting problematic rules

Sometimes you would like to skip a rule in the profile because they are too slow to test,\
or you know a rule doesn't have a remediation and you get less value by testing it.

For these situations, use `ds_unselect_rules.sh` to unselect these rules in all profiles of the datastream.
It will copy your `datastream` to `/tmp` and unselect rules listed in `rules_list`

```
./ds_unselect_rules.sh <datastream> <rules_list>
```
Where:
- `datastream`: is the DataStream to unselect rules from
- `rules_list`: is a file with list of complete rule IDs, one per line

Example usage:
```
./ds_unselect_rules.sh ../build/ssg-fedora-ds.xml unselect_rules_list
```

*Tip*: file `unselect_rules_list` contains a few typical rules you may want to skip

## Rule-based testing

In this mode, you specify the `rule` command and you supply one or more rule
IDs or wildcards as positional arguments. Unlike the profile mode, here each
rule from the matching rule set is addressed independently, one-by-one.

Rule-based testing enables to perform two kinds of tests:

- Check tests: The system is set up into a compliant, or a non-compliant state.

  Typically, the compliant state is different from the default or
  post-remediation state. The scanner is supposed to correctly identify the
  state of the system, so it is checked against false positives and false
  negatives.

- Remediation tests: The system is set up into a non-compliant state, and
  remediation is performed.

If you would like to evaluate the rule `sshd_disable_kerb_auth`:

Using Libvirt:
```
./test_suite.py rule --libvirt qemu:///system ssg-test-suite-rhel7 --datastream ../build/ssg-rhel7-ds.xml sshd_disable_kerb_auth
```

Using Podman:
```
./test_suite.py rule --container ssg_test_suite --datastream ../build/ssg-rhel7-ds.xml sshd_disable_kerb_auth
```

or just call the `test_rule_in_container.sh` script that passes the backend options for you
in addition to `--remove-machine-only` and `--add-platform`
that remove some testing limitations of the container backend.

Using Docker:
```
./test_suite.py rule --docker ssg_test_suite --datastream ../build/ssg-rhel7-ds.xml sshd_disable_kerb_auth
```

Notice we didn't use full rule name on the command line. The prefix `xccdf_org.ssgproject.content_rule_` is added if not provided.

It is possible to use wildcards, eg `accounts_passwords*` will run test scenarios for all
rules which ID starts with `accounts_passwords`.

### Debug mode

Use `--debug` option, to investigate a test scenario which is not evaluating to expected result.
The Test Suite will pause its execution, and you will be able to SSH into the environment to inspect its state manually.

### How rule validation scenarios work

The test scenarios for a rule are located in `tests` subdirectory in rule directory.


Scenarios are currently supported only in `bash`. And type of scenario is
defined by its file name.

#### (something).pass.sh

Success scenario - script is expected to prepare machine in such way that the
rule is expected to pass.

#### (something).fail.sh

Fail scenario - script is expected to break machine so the rule fails. Test
Suite than, if initial scan fails as expected, tries to remediate machine and
expects evaluation to pass.

#### (something).sh

Support files, these are available to the scenarios during their runtime. Can
be used as common libraries.

## Combined testing mode

In this mode, you are testing the rules selected by a profile, using the contexts provided by each rule's test scenarios.
This mode provides an easy way of performing rule-based testing on all rules that are part of a profile.

Any `# profiles` metadata in the test scenarios will be ignored, the Test Suite will assume that the test scenarios apply for the Profile, since the rule is selected by the profile.

If a rule doesn't have any test scenario, it will be skipped and a `INFO` message printed at the end.

If you would like to test all profile's rules against their test scenarios:
```
./test_suite.py combined --libvirt qemu:///system ssg-test-suite-rhel8 --datastream ../build/ssg-rhel8-ds.xml ospp
```

# How to write new test scenarios

## Scenarios format

Scenarios are simple bash scripts. A scenario starts with a header which provides metadata.
The header consists of comments (starting by `#`). Possible values are:
- `platform` is a comma-separated list of platforms where the test scenario can be run. This is similar to `platform` used in our remediations. Examples of values: `multi_platform_rhel`, `Red Hat Enterprise Linux 7`, `multi_platform_all`. If `platform` is not specified in the header, `multi_platform_all` is assumed.
- `profiles` is a comma-separated list of profiles to which this scenario applies to.
- `remediation` is a string specifying one of the allowed remediation types (eg. `bash`, `ansible`, `none`).
  The `none` value means that the tested rule has no implemented remediation.
- `templates` has no effect at the moment.
- `variables` is a comma-separated list of XCCDF values that sets a different default value for XCCDF variables in a form `<variable name>=<value>`. Typically, you use only one of `profile` or `variables` in scenario metadata - default values are effective only if the variable is not defined using a selector, which is exactly what profiles do.

After the header, bash commands that prepare the scenario follow.

Examples of test scenario:

Using `platform` and `profiles` metadata:

```
#!/bin/bash
#
# platform = Red Hat Enterprise Linux 7,multi_platform_fedora
# profiles = xccdf_org.ssgproject.content_profile_ospp

echo "KerberosAuthentication yes" >> /etc/ssh/sshd_config
```

<<<<<<< HEAD
Multi values in `variables` metadata option:

```
#!/bin/bash
#
# variables = var_accounts_tmout=600,var_example_1=value_example

if grep -q "^TMOUT" /etc/profile; then
  sed -i "s/^TMOUT.*/# TMOUT=600/" /etc/profile
else
  echo "# TMOUT=600" >> /etc/profile
fi
```

# Example of incorporating new test scenario

Let's add test scenarios for rule `accounts_password_minlen_login_defs`

1. Create `tests` directory within rule directory (in this case
  `/linux_os/guide/system/accounts/accounts-restrictions/password_expiration/accounts_password_minlen_login_defs/tests` further referenced as *DIR*).
1. write a few fail scripts - for example removing the line, commenting it, wrong value, etc.
 into *DIR*
1. write a pass script into *DIR* - (some rules can have more than one pass scenario)
1. build the datastream by running `./build_product --datastream-only fedora`
1. run `test_suite.py` with command:
```
./test_suite.py rule --libvirt qemu:///session ssg-test-suite-fedora accounts_password_minlen_login_defs
```
Example of test scenarios for this rule can be found at: [#3697](https://github.com/ComplianceAsCode/content/pull/3697)

# Sharing code among test scenarios

Test scenarios can use files from `/tests/shared` directory. This directory
and its contents is copied to the target VM or container together with the
test scenarios. The path to the directory is accessible in Bash using `$SHARED`
variable.

For example, script `/tests/shared/setup_config_files.sh` can be sourced in
the following way:

```
. $SHARED/setup_config_files.sh
```

If you happen to have many similar test scenarios, consider extracting the
common code to the shared directory.

# Analysis of results

The rule tests results are saved as `results.json` into the corresponding log directory.
You can then analyze those results by running e.g.

```
python analyze_results.py $(find . -name results.json)
```

The tool will print some general statistics and it will give you more detailed information about
scenarios that yielded different results.
Sometimes, different results may have been caused by different test environments, whereas sometimes
the security content is different, and those scans can be identified by respective scanning dates only.

# Known issues

1 - Test suite fails to test rule with the message:

```
Rule <rule_id> has not been evaluated! Wrong profile selected in test scenario?
```

If you are using SCAP 1.3 content (which is built by default) and you are sure that you have selected the rule in the particular profile, it might be that the target scan environment has an OpenSCAP version contains a bug with SCAP 1.3 content. To solve this issue you can either update the OpenSCAP package in the target scan environment to the latest version or build SCAP 1.2 content. To build SCAP 1.2 content check the [SSG Developer Guide](../docs/manual/developer_guide.adoc)
