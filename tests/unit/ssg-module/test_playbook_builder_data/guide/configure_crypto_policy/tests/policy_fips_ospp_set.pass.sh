#!/bin/bash
# platform = Oracle Linux 8,Oracle Linux 9,Red Hat Enterprise Linux 8,Red Hat Enterprise Linux 9
# profiles = ospp
# packages = crypto-policies-scripts

update-crypto-policies --set "FIPS:OSPP"
