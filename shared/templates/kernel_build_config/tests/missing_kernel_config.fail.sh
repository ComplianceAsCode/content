# remediation = none
#!/bin/bash

sed -i "/{{{ CONFIG | upper }}}.*/d" /boot/config-*
