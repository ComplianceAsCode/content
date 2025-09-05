#!/bin/bash
# remediation = None

groupadd testGrp

mkdir -p testDir

chgrp testGrp  testDir/

chmod 777 testDir/
