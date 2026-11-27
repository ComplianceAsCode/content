#!/bin/bash
# packages = audit

source common.sh

groupadd testgroup

touch "/var/log/audit/audit.log"
chgrp testgroup "/var/log/audit/audit.log"
