#!/bin/bash
# platform = Red Hat Enterprise Linux 10

if getent passwd sync >/dev/null; then
    usermod --shell /bin/bash sync
else
    useradd --system --shell /bin/bash sync
fi
