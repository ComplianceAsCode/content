#!/bin/bash

# This scenario is a regression test for https://bugzilla.redhat.com/show_bug.cgi?id=2169857

echo "Storage='persistent'" > "/etc/systemd/journald.conf"
