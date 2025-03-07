#!/bin/bash
if [ -f "/etc/tmpfiles.d/rootconf.conf" ]; then
  rm /etc/tmpfiles.d/rootconf.conf
fi
