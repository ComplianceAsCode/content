#!/bin/bash
# platform = Oracle Linux 10,Red Hat Enterprise Linux 10

{
echo 'test1:$y$j9T$F8yGM6FNeIn6V3k/MbAlU.$vtKD4DPmq.sSMBYmSPHqxQ42r/cTNfMc1yGa/qGKL3D:18793:0:99999:7:::'
echo 'test2:$6$kcOnRq/5$NUEYPuyL.wghQwWssXRcLRFiiru7f5JPV6GaJhNC2aK5F3PZpE/BCCtwrxRc/AInKMNX3CdMw11m9STiql12f/:18793:0:99999:7:::'
echo 'locked1:!:18793:0:99999:7:::'
echo 'locked2:!!:18793:0:99999:7:::'
echo 'locked3:!*:18793:0:99999:7:::'
echo 'locked4:*:18793:0:99999:7:::'
echo 'locked5:!locked:18793:0:99999:7:::'
echo 'locked6:!!$6$.2mKSYajcpiOnmC7$2/H9H9vGwhlqKuRH7Jbn8UdwvOtz8KBx.QRYlYIvFy0BGPozWSI6xAoA8p.QA7yIOA/goUrV2X7pjSE762gwh1:18793:0:99999:7:::'
echo 'locked7:!!$y$j9T$AAAABBBBCCCCDDDDEEEEEE$FFFGGGHHHIIIJJJKKKLLLMMMNNNOOOPPPQQQRRRSSSTTTUUUVVVWWWXXXYYYZZZ:18793:0:99999:7:::'
} >> /etc/shadow
