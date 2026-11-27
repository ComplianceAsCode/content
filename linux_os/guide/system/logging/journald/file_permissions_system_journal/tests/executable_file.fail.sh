#!/bin/bash
# platform = multi_platform_ubuntu

MACHINE_ID="$(cat /etc/machine-id)"
JOURNAL_DIR="/var/log/journal/${MACHINE_ID}"
JOURNAL_FILE="${JOURNAL_DIR}/user-1000@0005f97cd4a8c9b5-f088232c3718485a.journal~"

mkdir -p "${JOURNAL_DIR}"
touch "${JOURNAL_FILE}"
chown root:systemd-journal "${JOURNAL_FILE}"
chmod 0750 "${JOURNAL_FILE}"
