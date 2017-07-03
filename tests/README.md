## SSG Test Suite
This directory contains SSG Test Suite, effort separate to the main SSG code.
Goal of this Test Suite is primarily to ensure Remediation scripts are usable,
and to define scenarios in which these should work.

Priority is to provide very simple system of test scenarios, easily extendable
so everyone contributing remediation can also provide cases where this
remediation works.

## Prerequisites
For the Test Suite to work, you need to have libvirt domains prepared for testing.

### Domain preparation (example CentOS)
1. Install domain, using kickstarts/centos7.cfg
1. Import ssh key to the machine
1. Setup repo, so machine can install and uninstall packages

*NOTE*: Create snapshot after all these steps, to manually revert in case the
test suite breaks something and fails to revert. Do not use snapshot names
starting with "ssg\_"

## Two modes of operation
SSG Test Suite currently supports two ways of DataStream evaluation. Simpler
one to use is ```profile```, which scans and remedies target domain based on
particular profile.

Second, more complex, is ```rule```, which runs set of validation scenarios
for particular subset of rules. Each rule has its own scenarios, and each
scenario is run separately to eliminate need for cleanup.

## Running test suite in profile mode
Example of evaluation of default profile (common):
```./test_suite.py profile --hypervisor qemu:///system --domain ssg-test-suite-centos --datastream ssg-centos7-ds.xml```
For further options, see
```./test_suite.py profile --help```

## Running test suite in rule mode
Example of evaluation of rule ```rule_sysctl_net_ipv4_conf_default_secure_redirects```:
```./test_suite.py rule --hypervisor qemu:///system --domain ssg-test-suite-centos --datastream ./ssg-centos7-ds.xml ipv4_conf_default_secure_redirects```
Notice there is not full rule name used on the command line. Test suite runs
every rule, which contains given substring in the name. So all that is needed
is to use unique substring.
Again, for further options, see
```./test_suite.py rule --help```

## How rule validation scenarios work
In directory ```data``` are directories mirroring ```group/group/.../rule```
structure of datastream. In reality, only name of the rule directory needs to be
correct, group structure is currently not used.

Scenarios are currently supported only in ```bash```. And type of scenario is
defined by its file name.

#### (something).pass.sh
Success scenario - script is expected to prepare machine in such way for the
rule to pass.

#### (something).fail.sh
Fail scenario - script is expected to break machine so the rule fails. Test Suite
than, if initial scan successfully fails, tries to remediate machine and expects
success.

#### (something).sh
Support files, that are available to the scenarios during their runtime. Can
be used as common libraries.

## Example of incorporating new test scenario
Let's show how to add test scenario for Red Hat Bugzilla 1392679 (already included)

Bugzilla is about ```sshd_config``` being not altered correctly. Thus:
1. Create appropriate directory within ```data/``` directory tree (in this case
```data/group_services/group_ssh/group_ssh_server/rule_sshd_disable_kerb_auth```
further referenced as *DIR*).
1. put few fail scripts - for example removing the line, commenting it, etc. into *DIR*
1. put pass script into *DIR*
1. ????
1. PROFIT (nothing more to do)

Now, you can perform validation check with command
```./test_suite.py rule --hypervisor qemu:///system --domain ssg-test-suite-centos --datastream ./ssg-centos7-ds.xml rule_sshd_disable_kerb_auth```
