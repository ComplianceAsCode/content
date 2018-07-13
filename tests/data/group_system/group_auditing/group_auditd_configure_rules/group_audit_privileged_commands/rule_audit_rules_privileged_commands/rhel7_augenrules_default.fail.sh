#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_pci-dss
# remediation = bash

# augenrules is default for rhel7
# This is a trick to fail setup of this test in rhel6 systems
ls  /usr/lib/systemd/system/auditd.service
