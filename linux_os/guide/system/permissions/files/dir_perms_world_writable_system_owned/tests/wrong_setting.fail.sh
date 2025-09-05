#!/bin/bash
# remediation = none

useradd testUser

mkdir -p testDir

chown testUser  testDir/

chmod 777 testDir/
