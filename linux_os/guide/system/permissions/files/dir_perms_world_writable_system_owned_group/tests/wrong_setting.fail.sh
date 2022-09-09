#!/bin/bash
# remediation = None

groupadd testGrp

mkdir testDir

chgrp testGrp  testDir/

chmod 777 testDir/
