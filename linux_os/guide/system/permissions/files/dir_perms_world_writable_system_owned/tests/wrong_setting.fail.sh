#!/bin/bash
# remediation = None

useradd testUser

mkdir -p testDir

chown testUser  testDir/

chmod 777 testDir/
