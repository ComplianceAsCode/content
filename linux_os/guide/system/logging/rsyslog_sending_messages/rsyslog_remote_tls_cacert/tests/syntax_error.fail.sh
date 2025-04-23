#!/bin/bash
# remediation = none

echo 'global(DefaultNetstreamDriverCAFile="{{{ rsyslog_cafile }}}") *.*' >> /etc/rsyslog.conf
