#!/bin/bash

# Remove any existing password hashes that are not SHA-512 (e.g., yescrypt on RHEL10)
# This ensures the test starts with a clean state and only SHA-512 hashes remain
sed -i '/:\$[^6]/d' /etc/shadow

{
echo 'test1:$6$kcOnRq/5$NUEYPuyL.wghQwWssXRcLRFiiru7f5JPV6GaJhNC2aK5F3PZpE/BCCtwrxRc/AInKMNX3CdMw11m9STiql12f/:18793:0:99999:7:::'
echo 'locked1:!:18793:0:99999:7:::'
echo 'locked2:!!:18793:0:99999:7:::'
echo 'locked3:!*:18793:0:99999:7:::'
echo 'locked4:*:18793:0:99999:7:::'
echo 'locked5:!locked:18793:0:99999:7:::'
echo 'locked6:!!$6$.2mKSYajcpiOnmC7$2/H9H9vGwhlqKuRH7Jbn8UdwvOtz8KBx.QRYlYIvFy0BGPozWSI6xAoA8p.QA7yIOA/goUrV2X7pjSE762gwh1::0:99999:7:::'
} >> /etc/shadow
