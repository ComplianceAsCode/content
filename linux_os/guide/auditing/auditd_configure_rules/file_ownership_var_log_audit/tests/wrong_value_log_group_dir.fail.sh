#!/bin/bash
# packages = audit

source common.sh

groupadd testgroup

mkdir -p "/var/log/audit"
chgrp testgroup "/var/log/audit"
