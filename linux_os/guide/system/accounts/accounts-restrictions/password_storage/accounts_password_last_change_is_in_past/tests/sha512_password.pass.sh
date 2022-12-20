#!/bin/bash

{
echo 'test1:$6$kcOnRq/5$NUEYPuyL.wghQwWssXRcLRFiiru7f5JPV6GaJhNC2aK5F3PZpE/BCCtwrxRc/AInKMNX3CdMw11m9STiql12f/:18793:0:99999:7:::'
echo 'locked1:!:18793:0:99999:7:::'
echo 'locked2:!!:18793:0:99999:7:::'
echo 'locked3:!*:18793:0:99999:7:::'
echo 'locked4:*:18793:0:99999:7:::'
echo 'locked5:!locked:18793:0:99999:7:::'
} >> /etc/shadow
