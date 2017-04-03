## SSG Test Suite
This directory contains SSG Test Suite, effort separate to the main SSG code.
Goal of this Test Suite is primarily to ensure Remediation scripts are usable,
and to define scenarios in which these should work.

Priority is to provide very simple system of test scenarios, easily extendable
so everyone contributing remediation can also provide cases where this
remediation works.

## Prerequisites
For the Test Suite to work, you need to have libvirt domains prepared for testing.

### Domain preparation
1. Install domain, preferably in user space
1. Use ```virbr0``` as a bridge for domain network
1. Import ssh key to the machine
1. Setup repo, so machine can install and uninstall packages
1. Install ```openscap-scanner``` package

*NOTE*: Create snapshot after all these steps, to manually revert in case the
test suite breaks something and fails to revert.


## Running test suite
When domain is prepared, running the test suite is simple.
```perform_remediation_checks.sh``` has one parameter, called CHOICE. Understand
it as a substring of ```rule directory``` you want to execute. So for example
if you call
```./perform_remediation_checks.sh gpgcheck```
only break script with path containing gpgcheck substring will be tested.

Script also consumes ```DOMAIN``` environment variable, for cases you want to use
one different to default ```REM_RHEL7```.

Complete logging is performed into directory results_<timestamp>

## How it works
In directory ```data``` are further subdirectories, with three types of files in
them.

#### tailoring.xml
This file defines anchor point for search - everything in it's directory is used
together with the tailoring. Usually, the tailoring contains only one rule enabled,
which is the one tested.

NOTE: tailoring.xml has to contain only one profile, preferably ```standard```.

#### (something).break.sh
Single break scenario, for example removing configuration file, or alternating
value in it. Breaks fresh system, and remediation is performed right afterwards.

NOTE: If you want to test remediation on default settings, use ```clean.break.sh```
NOTE2: For now, no libraries are supported.


#### (anything).prepare.sh
All prepare scripts are executed before the breakage, so it can get machine to
most convenient state for the break script testing. For example ```aide```
preparation script installs aide, as most break scripts needs it installed anyway.

## Example of incorporating new test scenario
Let's show how to add test scenario for Red Hat Bugzilla 1392679.

Bugzilla is about ```sshd_config``` being not altered correctly. Thus:
1. Create appropriate directory within ```data/``` directory tree (further
referenced as *DIR*).
1. Create tailoring.xml via scap-workbench, with profile being Standard, and only
one rule, ```xccdf_org.ssgproject.content_rule_sshd_disable_kerb_auth``` being
enabled. Name of the profile is not relevant. Put it in *DIR*.
1. put ```clean.break.sh``` into *DIR*
1. no preparation script is necessary this time
1. put few break scripts - for example removing the line, commenting it, etc.
1. ????
1. PROFIT (nothing more to do)
