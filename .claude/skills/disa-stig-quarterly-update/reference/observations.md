# Caveats that aren't obvious from the diff or the source

## Remediations can be undone by system daemons on reboot

Some daemons overwrite files as part of their startup sequence, resetting modes or content a
remediation just set. Canonical example: `augenrules --load` hardcodes `chmod 0640
${DestinationFile}` whenever it rewrites `/etc/audit/audit.rules`. A remediation that sets `0600`
survives until the next `auditd` restart that touches the file, at which point `augenrules`
resets it to `0640`.

General pattern: if a daemon or package post-install script overwrites a file on boot or service
restart, a one-shot remediation won't survive a reboot. Check whether the file is owned by a
daemon that runs on startup; if so, a persistent fix is needed - a systemd dropin, a config file
the daemon reads, or a daemon reload that accepts the new value directly. CaC does not patch
files under `/usr/bin/`, `/usr/sbin/`, `/usr/lib/`, or any other package-managed path; a bug in a
system script belongs upstream, and the CaC remediation must work around it without waiting for
that fix.

## Contest ansible vs bash asymmetry

Contest runs ansible once, reboots once, then scans. Bash runs once, reboots, runs again,
reboots again, then scans. The second bash pass can produce a passing scan even when the
underlying problem (a daemon rewriting the file) would fail ansible. A rule that passes in bash
Contest but fails in ansible Contest on the same remediation logic usually means the end state is
correct but doesn't survive one boot cycle without a second pass - the fix is a persistent
mechanism, not reapplying the same one-shot command.

## SELinux and systemd units in remediations

An `ExecStartPost=` in a systemd dropin runs in the service's own SELinux domain (e.g. `auditd_t`
for `auditd.service`), not `init_t` - a dropin that `chmod`s or `install`s a file in that domain
needs no custom SELinux policy.

A `systemd.path` unit with `PathChanged=` is different: the watch is set up by `systemd` (as
`init_t`) calling `inotify_add_watch()`. If the watched directory carries a label like
`auditd_etc_t`, SELinux may deny the `watch` permission for `init_t` - often silently, via a
`dontaudit` rule that won't show in the audit log under normal conditions. To expose it: `semodule
-DB` to disable dontaudit rules, reproduce, then check `ausearch -m avc`. A `PathChanged=`
approach that only works with `setenforce 0` will not survive a reboot, since systemd sets up
path watches during boot while SELinux is already enforcing.

## Container environments

`auditd` doesn't run inside containers, and `kernel-core` is absent since containers share the
host kernel. Any remediation installing a systemd dropin or reloading `auditd` must be guarded to
skip that step in containers: `rpm -q kernel-core` in Bash, `"kernel-core" in
ansible_facts.packages` in Ansible. Without the guard, `systemctl` fails to reach a host-side
`auditd` from inside the container. A plain file-mode task (`chmod`, or the `file` Ansible module)
still runs fine in containers and needs no guard.

## Reviewer style requests vs STIG requirements

Reviewers sometimes ask for more than the STIG diff requires: extra ownership enforcement,
additional validation, stricter defaults, explanatory comments. Treat these as optional unless
the reviewer says they're blocking. Verify any such request against the raw STIG diff before
implementing it - "for completeness" signals a style preference, "the STIG requires" or "this
blocks merge" signals a hard requirement. Implementing unrequested changes without checking can
introduce scope creep and conflict with other PRs touching the same file.

## CentOS Stream failures and Contest waivers

Contest also runs against CentOS Stream in addition to RHEL. A failure that reproduces only on
CentOS Stream, with a known root cause unrelated to RHEL, does not block STIG compliance work -
the STIG applies to RHEL, and RHEL results are the deciding signal. File a GitHub issue and open a
Contest PR to waive the affected test on CentOS; CentOS results after a waiver are informational
only.
