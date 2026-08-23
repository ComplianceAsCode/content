#!/bin/bash

echo "newuser:*:1001:1001::/home/newuser:/bin/bash" >> /etc/passwd
echo "newuser:!:20111:0:99999:7:::" >> /etc/shadow
echo "/bin/bash" >> /etc/shells
