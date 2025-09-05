#!/bin/bash

cat << EOF | oc apply -f -
---
apiVersion: machineconfiguration.openshift.io/v1
kind: MachineConfig
metadata:
  labels:
    machineconfiguration.openshift.io/role: master
  name: 75-master-chrony-servers
spec:
  config:
    ignition:
      version: 3.1.0
    storage:
      files:
      - contents:
          source: data:,pool%202.rhel.pool.ntp.org%20iburst%0A%0Aserver%200.rhel.pool.ntp.org%20minpoll%204%20maxpoll%2010%0Aserver%201.rhel.pool.ntp.org%20minpoll%204%20maxpoll%2010%0Aserver%202.rhel.pool.ntp.org%20minpoll%204%20maxpoll%2010%0Aserver%203.rhel.pool.ntp.org%20minpoll%204%20maxpoll%2010
        mode: 0600
        path: /etc/chrony.d/10-rhel-pool-and-servers.conf
        overwrite: true
---
apiVersion: machineconfiguration.openshift.io/v1
kind: MachineConfig
metadata:
  labels:
    machineconfiguration.openshift.io/role: worker
  name: 75-worker-chrony-servers
spec:
  config:
    ignition:
      version: 3.1.0
    storage:
      files:
      - contents:
          source: data:,pool%202.rhel.pool.ntp.org%20iburst%0A%0Aserver%200.rhel.pool.ntp.org%20minpoll%204%20maxpoll%2010%0Aserver%201.rhel.pool.ntp.org%20minpoll%204%20maxpoll%2010%0Aserver%202.rhel.pool.ntp.org%20minpoll%204%20maxpoll%2010%0Aserver%203.rhel.pool.ntp.org%20minpoll%204%20maxpoll%2010
        mode: 0600
        path: /etc/chrony.d/10-rhel-pool-and-servers.conf
        overwrite: true
EOF