#!/bin/bash

echo "testuser:x:1001:1001::/home/testuser:/bin/bash" >> /etc/passwd
echo 'testuser:$6$exIFis0tobKRcGBk$b.UR.Z8h96FdxJ1bgA/vhdnp0Lsm488swdILNguQX/5qH5hdmClyYb5xk3TpELXWzr4JOiTlHfRkPsXSjMPjv0:20111:0:99999:7:::' >> /etc/shadow
echo "/bin/bash" >> /etc/shells
