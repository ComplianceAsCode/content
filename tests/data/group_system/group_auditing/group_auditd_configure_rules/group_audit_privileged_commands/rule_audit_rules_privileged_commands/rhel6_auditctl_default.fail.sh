#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_pci-dss
# remediation = bash

# auditctl is default for rhel6
# This is a trick to fail setup of this test in rhel7 systems
ls /etc/sysconfig/auditd
