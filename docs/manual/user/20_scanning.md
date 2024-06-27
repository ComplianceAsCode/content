# Scanning
## Running a Scan with OpenSCAP

### Command Line Interface (CLI)
This document outlines the usage of OpenSCAP, a command-line utility packaged within Fedora and Red Hat Enterprise Linux which allows users to load, scan, validate, edit, and export SCAP documents.

See also [OpenSCAP User Manual](https://static.open-scap.org/openscap-1.3/oscap_user_manual.html) for instructions how to use OpenSCAP.
Additional details regarding OpenSCAP can be found on the project homepage located at [open-scap.org](http://open-scap.org/).

Five arguments to OpenSCAP are needed to perform a system scan against the upstream a profile:

* `--profile`
  * Mandatory, identifies which profile to scan against

* `--results`
  * Optional, indicates location to place ARF XML formatted results

* `--report`
  * Optional, indicates location to place HTML formatted results

* data stream location
  * Mandatory, identifies location of SCAP source data stream file

Putting these arguments together, a properly formatted command would be:

```
$ sudo oscap xccdf eval --profile stig \
--results /tmp/results.xml \
--report /tmp/report.html \
/usr/share/xml/scap/ssg/content/ssg-rhel9-ds.xml
```

While the scan is running, you will see output similar to the following on your screen:

```
Title   Install AIDE
Rule    package_aide_installed
Ident   CCE-83457-2
Result  fail

Title   Configure Periodic Execution of AIDE
Rule    aide_periodic_cron_checking
Ident   CCE-83437-4
Result  notchecked

Title   Verify File Permissions with RPM
Rule    rpm_verify_permissions
Ident   CCE-90840-0
Result  fail

Title   Verify File Hashes with RPM
Rule    rpm_verify_hashes
Ident   CCE-90841-8
Result  pass
```

### Results Interpretation

#### HTML Results

Just open the `/tmp/report.html` file in your favorite browser.

#### XML Results

Looking at the `/tmp/results.xml` file, you will notice lines similar to those below:

```xml
    <rule-result idref="ensure_gpgcheck_globally_activated" time="2023-02-16T10:03:43" severity="high" weight="1.000000">
      <result>pass</result>
      <ident system="http://cce.mitre.org">CCE-83457-2</ident>
      <check system="http://oval.mitre.org/XMLSchema/oval-definitions-5">
        <check-content-ref name="oval:ssg:def:413" href="ssg-rhel9-oval.xml"/>
      </check>
    </rule-result>
    ......
    <rule-result idref="package_aide_installed" time="2023-02-16T10:03:43" severity="medium" weight="1.000000">
      <result>pass</result>
      <ident system="http://cce.mitre.org">CCE-90843-4</ident>
      <fix xmlns:xhtml="http://www.w3.org/1999/xhtml" system="urn:xccdf:fix:script:sh">
        yum -y install aide
      </fix>
      <check system="http://oval.mitre.org/XMLSchema/oval-definitions-5">
        <check-content-ref name="oval:ssg:def:245" href="ssg-rhel9-oval.xml"/>
      </check>
    </rule-result>
```

The XML above can be parsed as follows:

XCCDF Rule Elements

|        XML Tag        | Meaning                                                                                                                                                |
|:---------------------:|:-------------------------------------------------------------------------------------------------------------------------------------------------------|
|    `<rule-result>`    | Identifies which XCCDF rule the result reflects                                                                                                        |
|      `<result>`       | Pass/Fail/Not Applicable                                                                                                                               |
|        `<fix>`        | Remediation actions, in bash, which will configure the system to be in compliance with the XCCDF rule.                                                 |
|   `<check system>`    | Identifies which version of OVAL the check was authored against.                                                                                       |
| `<check-content-ref>` | Corresponding OVAL check name (`name`) and source OVAL file (`href`) this check came from. For general purpose users, this information can be ignored. |

### Remediation

#### Bash Scripts

A Bash remediation script for each profile is shipped in `scap-security-guide` package.
The scripts can be found in `/usr/share/scap-security-guide/bash/` or if you build the project from source in `./build/bash`.

Moreover, ComplianceAsCode embeds bash remediation scripts into the SCAP content. This allows for SCAP compatible tools to extract these remediation scripts to aid in potential remediation of system misconfigurations.

OpenSCAP, the CLI delivered with Fedora, Red Hat Enterprise Linux systems and other Linux distributions, contains the ability to transform XML results into an executable script.
The syntax to generate a remediation script is:


```
$ oscap xccdf generate fix \
--result-id xccdf_org.open-scap_testresult_{profile-name} \
/root/ssg-results.xml
```


Replace `{profile-name}` with the profile the system was scanned against. For example, for `stig`:

```
$ oscap xccdf generate fix \
--result-id xccdf_org.open-scap_testresult_stig \
/root/ssg-results.xml
```

You will receive output similar to the following:

```
$ oscap xccdf generate fix \
--result-id xccdf_org.open-scap_testresult_stig \
/root/ssg-results.xml

#!/bin/bash
# OpenSCAP fix generator output for benchmark: DRAFT Guide
# to the Secure Configuration of Red Hat Enterprise Linux 8

# XCCDF rule: set_sysctl_net_ipv4_conf_default_rp_filter
# CCE-26915-9
#
# Set runtime for net.ipv4.conf.default.rp_filter
#
sysctl -q -n -w net.ipv4.conf.default.rp_filter=1

#
# If net.ipv4.conf.default.rp_filter present in
# /etc/sysctl.conf, change value to "1"
# else, add "net.ipv4.conf.default.rp_filter = 1" to /etc/sysctl.conf
#
if grep --silent ^net.ipv4.conf.default.rp_filter /etc/sysctl.conf ; then sed -i \
 's/^net.ipv4.conf.default.rp_filter.*/net.ipv4.conf.default.rp_filter \
 = 1/g' /etc/sysctl.conf
else
echo "" >> /etc/sysctl.conf
echo "# Set net.ipv4.conf.default.rp_filter to 1 per \
 security requirements" >> /etc/sysctl.conf
echo "net.ipv4.conf.default.rp_filter = 1" >> /etc/sysctl.conf
fi

# XCCDF rule: uninstall_xinetd
# CCE-27005-8
if rpm -qa | grep -q xinetd; then
yum -y remove xinetd
fi

# generated: 2013-07-05T13:56:30-04:00
# END OF SCRIPT
```

This output could be redirected to a bash script, or built into your RHEL provisioning process (e.g. the %post section of a kickstart).

#### Ansible Playbooks

ComplianceAsCode embeds Ansible remediation scripts into the SCAP content.
This allows for SCAP compatible tools to extract these remediation scripts to aid in potential remediation of system misconfigurations.

You can create these playbooks by running:

```
$ oscap xccdf generate fix --profile stig --fix-type ansible /usr/share/xml/scap/ssg/content/ssg-rhel9-ds.xml > ssg-rhel9-stig.yml
```

IMPORTANT: The minimum version of Ansible must be at the latest supported version.
See [Red Hat Ansible Engine Life Cycle Page](https://access.redhat.com/support/policy/updates/ansible-engine) for information on the supported Ansible versions.

## Other Scanners
### Security Content Automation Protocol (SCAP) Compliance Checker (SCC)
Funded by the Internal Revenue Service, the National Security Agency, and other United States government agencies Naval Information Warfare Center (NIWC) Atlantic has authored a SCAP Compliance Checker (SCC).
The NIWC SCC tool is available to the general public.
The NIWC SCC website is [www.niwcatlantic.navy.mil/scap](https://www.niwcatlantic.navy.mil/scap/).
The SCC tool is available for download at [public.cyber.mil/stigs/scap](https://public.cyber.mil/stigs/scap/).
