#!/bin/bash
# remediation = none

groupadd testGrp

mkdir -p testDir

chgrp testGrp  testDir/

chmod 777 testDir/
