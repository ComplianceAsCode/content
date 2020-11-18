---
title: Request a new SCAP rule
about: Use this template to ask for a new SCAP rule. Please fill in as much information as possible.
labels: new_rule
---
## Which products and profiles does the rule apply to?

example: fedora, rhel8, OSPP profile

## Describe the configuration setting enforced by this rule.

example: The default Grub2 command line for the Linux operating system must
contain the audit=1 argument. In case of Fedora, the file /boot/grub2/grubenv
contains line in form:

```
kernelopts=<arguments_separated_by_spaces>
```

One of present arguments must be audit=1.

## Why is the configuration security relevant?

example: This configuration ensures that all auditable processes are audited
already during the boot process even before the Auditd starts. This means that
potential malicious activity is monitored during boot process.

## How to check the configuration?

example:

```
sudo grep 'kernelopts.*audit=1.*' /boot/grub2/grubenv
```

### Is it order dependent? (does it need to be at certain place in the file?

example: The audit=1 argument can be at any place within the list of arguments
for the Linux kernel. There should be only one line starting with kernelopts=.
Only one occurence of audit=1 should occur. There should not be any audit=0 in
the list of arguments.

### What is correct and incorrect syntax?

example:

```
kernelopts=arg1 arg2 audit=1 arg3
```

## How to remediate

example: Ensure that the argument is present in the kernelopts=... line.

###Does any command need to be run?

example: The following command may be used:

```
sudo grub2-editenv - set "$(grub2-editenv - list | grep kernelopts) audit=1"
```

## Are there going to be other rules like this one in the future? Is it worth creating template? (similar configuration format, similar remediation process...)

example: Yes, there will be more checks for Grub2 kernel command line arguments.

## Are there any caveats to be considered when testing?

example: Yes. This configuration works only on systems with Grub2 bootloader.
Hardware not supported by Grub2 should be covered by a separate rule.

## Is the configuration loaded directly by the <software> or is it stored in some intermediate database (similar to dconf)? (We want to edit the lowest level possible, if appropriate)

example: The file is loaded by Grub2 directly. The file should not be edited manually but only through grub2-editenv command.

## Is it possible to check / remediate this configuration in offline mode? (scanning containers or offline systems)

example: This option can be checked in offline mode.

##  Please provide security policy references if possible e.g. STIG

example: srg: SRG-OS-000254-GPOS-00095

hipaa: 164.308(a)(1)(ii)(D),164.308(a)(5)(ii)(C),164.310(a)(2)(iv),164.310(d)(2)(iii),164.312(b)
