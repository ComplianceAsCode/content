#!/bin/bash

# This scenario is a regression test for https://bugzilla.redhat.com/show_bug.cgi?id=2193169

echo -e "[Journal]\nCompress='yes'" > "/etc/systemd/journald.conf"
