## SSG Test Suite
This directory contains SSG Test Suite, effort separate to the main SSG code.
Goal of this Test Suite is primarily to ensure Remediation scripts are usable,
and to define scenarios in which these should work.

Priority is to provide very simple system of test scenarios, easily extendable
so everyone contributing remediation can also provide cases where this
remediation works.

## Prerequisites
For the Test Suite to work, you need to have libvirt domains prepared for testing.
SSG Test Suite currently does not provide automated provisioning of domains.
You can use kickstart usable for Red Hat Enterprise Linux 7 (and of course CentOS 7) in
`kickstarts` directory, which installs machine to be capable of building openscap
and builds and installs the latest upstream code.

If you want to use your own domain, make sure `openscap-1.2.15` and `qemu-guest-agent`
are installed there, `root` is accessible via ssh and that `yum` command is able
to install packages. For testing Ansible remediations, it is sufficient to have `root`
accessible via ssh on the libvirt domain and have Ansible installed on the host machine.

### Domain preparation (example CentOS)
1. Install domain, using `kickstarts/rhel_centos_7.cfg`
   Typically, you supply a boot option `inst.ks=https://raw.githubusercontent.com/OpenSCAP/scap-security-guide/master/tests/kickstarts/rhel_centos_7.cfg`.
1. Import ssh key to the machine and make sure that you can use them to log in as the `root` superuser.
1. Setup repo, so machine can install and uninstall packages.

*NOTE*: Create snapshot after all these steps, to manually revert in case the
test suite breaks something and fails to revert. Do not use snapshot names
starting with `ssg_`

## Executing the test suite

### Common options

- `--hypervisor`: Typically, you will use the `qemu:///system` value.
- `--domain`: `libvirt` domain, which is basically name of the virtual machine.
- `--datastream`: Path to the datastream that you want to use for scanning.
  It will be transferred to the scanned VM via SSH.
- `--xccdf-id`: Also known as `Ref-ID`, it is the identifier of benchmark within the datastream.
  It can be obtained by running `oscap info` over the datastream XML and searching for `Ref-ID` strings.
- `--help`: This will get you the invocation help.

### Profile-based testing
In this operation mode, you specify the `profile` command and you supply the profile ID as a positional argument.
The test suite then runs scans over the target domain and remediates it based on particular profile.

An example invocation may look like this:

```
./test_suite.py profile --hypervisor qemu:///system --domain ssg-test-suite-centos --datastream ssg-centos7-ds.xml --xccdf-id xccdf-id profile-id
```

Note that the `profile-id` is not matched by the suffix (as opposed to how the `oscap` tool works), so specify it literally (use `oscap info --profiles` to see available profiles).

### Rule-based testing
In this mode, you specify the `rule` command and you supply part of the rule title as a positional argument.
Unlike the profile mode, here each rule from the matching rule set is addressed independently, one-by-one.

Rule-based testing enables to perform two kinds of tests:

- Check tests: The system is set up into a compliant, or a non-compliant state.

  Typically, the compliant state is different from the default or post-remediation state.
  The scanner is supposed to correctly identify the state of the system, so it is checked against false positives and false negatives.

- Remediation tests: The system is set up into a non-compliant state, and remediation is performed.

If you would like to evaluate the rule `rule_sysctl_net_ipv4_conf_default_secure_redirects`:

```
./test_suite.py rule --hypervisor qemu:///system --domain ssg-test-suite-centos --datastream ./ssg-centos7-ds.xml ipv4_conf_default_secure_redirects
```

Notice there is not full rule name used on the command line.
Test suite runs every rule, which contains given substring in the name.
So all that is needed is to use unique substring.

## How rule validation scenarios work
In directory `data` are directories mirroring `group/group/.../rule`
structure of datastream. In reality, only name of the rule directory needs to be
correct, group structure is currently not used.

Scenarios are currently supported only in `bash`. And type of scenario is
defined by its file name.

#### (something).pass.sh
Success scenario - script is expected to prepare machine in such way that the rule is expected to pass.

#### (something).fail.sh
Fail scenario - script is expected to break machine so the rule fails. Test Suite
than, if initial scan successfully fails, tries to remediate machine and expects
success.

#### (something).sh
Support files, that are available to the scenarios during their runtime. Can
be used as common libraries.

## Example of incorporating new test scenario
Let's show how to add test scenario for Red Hat Bugzilla 1392679 (already included)

Bugzilla is about `sshd_config` being not altered correctly. Thus:
1. Create appropriate directory within `data/` directory tree (in this case
```data/group_services/group_ssh/group_ssh_server/rule_sshd_disable_kerb_auth```
further referenced as *DIR*).
1. put few fail scripts - for example removing the line, commenting it, etc. into *DIR*
1. put pass script into *DIR*
1. ????
1. PROFIT (nothing more to do)

Now, you can perform validation check with command

```
./test_suite.py rule --hypervisor qemu:///system --domain ssg-test-suite-centos --datastream ./ssg-centos7-ds.xml rule_sshd_disable_kerb_auth
```
