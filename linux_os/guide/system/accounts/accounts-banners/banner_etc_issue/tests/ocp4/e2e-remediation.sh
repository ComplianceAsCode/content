#!/bin/bash

cat << EOF | oc apply -f -
---
apiVersion: machineconfiguration.openshift.io/v1
kind: MachineConfig
metadata:
  labels:
    machineconfiguration.openshift.io/role: master
  name: 75-master-etc-issue
spec:
  config:
    ignition:
      version: 3.1.0
    storage:
      files:
      - contents:
          source: data:,You%20are%20accessing%20a%20U.S.%20Government%20%28USG%29%20Information%20System%20%28IS%29%20that%20is%20%0Aprovided%20for%20USG-authorized%20use%20only.%20By%20using%20this%20IS%20%28which%20includes%20any%20%0Adevice%20attached%20to%20this%20IS%29%2C%20you%20consent%20to%20the%20following%20conditions%3A%0A%0A-The%20USG%20routinely%20intercepts%20and%20monitors%20communications%20on%20this%20IS%20for%20%0Apurposes%20including%2C%20but%20not%20limited%20to%2C%20penetration%20testing%2C%20COMSEC%20monitoring%2C%20%0Anetwork%20operations%20and%20defense%2C%20personnel%20misconduct%20%28PM%29%2C%20law%20enforcement%20%0A%28LE%29%2C%20and%20counterintelligence%20%28CI%29%20investigations.%0A%0A-At%20any%20time%2C%20the%20USG%20may%20inspect%20and%20seize%20data%20stored%20on%20this%20IS.%0A%0A-Communications%20using%2C%20or%20data%20stored%20on%2C%20this%20IS%20are%20not%20private%2C%20are%20subject%20%0Ato%20routine%20monitoring%2C%20interception%2C%20and%20search%2C%20and%20may%20be%20disclosed%20or%20used%20%0Afor%20any%20USG-authorized%20purpose.%0A%0A-This%20IS%20includes%20security%20measures%20%28e.g.%2C%20authentication%20and%20access%20controls%29%20%0Ato%20protect%20USG%20interests--not%20for%20your%20personal%20benefit%20or%20privacy.%0A%0A-Notwithstanding%20the%20above%2C%20using%20this%20IS%20does%20not%20constitute%20consent%20to%20PM%2C%20LE%20%0Aor%20CI%20investigative%20searching%20or%20monitoring%20of%20the%20content%20of%20privileged%20%0Acommunications%2C%20or%20work%20product%2C%20related%20to%20personal%20representation%20or%20services%20%0Aby%20attorneys%2C%20psychotherapists%2C%20or%20clergy%2C%20and%20their%20assistants.%20Such%20%0Acommunications%20and%20work%20product%20are%20private%20and%20confidential.%20See%20User%20%0AAgreement%20for%20details.
        mode: 0644
        path: /etc/issue.d/legal-notice
        overwrite: true
---
apiVersion: machineconfiguration.openshift.io/v1
kind: MachineConfig
metadata:
  labels:
    machineconfiguration.openshift.io/role: worker
  name: 75-worker-etc-issue
spec:
  config:
    ignition:
      version: 3.1.0
    storage:
      files:
      - contents:
          source: data:,You%20are%20accessing%20a%20U.S.%20Government%20%28USG%29%20Information%20System%20%28IS%29%20that%20is%20%0Aprovided%20for%20USG-authorized%20use%20only.%20By%20using%20this%20IS%20%28which%20includes%20any%20%0Adevice%20attached%20to%20this%20IS%29%2C%20you%20consent%20to%20the%20following%20conditions%3A%0A%0A-The%20USG%20routinely%20intercepts%20and%20monitors%20communications%20on%20this%20IS%20for%20%0Apurposes%20including%2C%20but%20not%20limited%20to%2C%20penetration%20testing%2C%20COMSEC%20monitoring%2C%20%0Anetwork%20operations%20and%20defense%2C%20personnel%20misconduct%20%28PM%29%2C%20law%20enforcement%20%0A%28LE%29%2C%20and%20counterintelligence%20%28CI%29%20investigations.%0A%0A-At%20any%20time%2C%20the%20USG%20may%20inspect%20and%20seize%20data%20stored%20on%20this%20IS.%0A%0A-Communications%20using%2C%20or%20data%20stored%20on%2C%20this%20IS%20are%20not%20private%2C%20are%20subject%20%0Ato%20routine%20monitoring%2C%20interception%2C%20and%20search%2C%20and%20may%20be%20disclosed%20or%20used%20%0Afor%20any%20USG-authorized%20purpose.%0A%0A-This%20IS%20includes%20security%20measures%20%28e.g.%2C%20authentication%20and%20access%20controls%29%20%0Ato%20protect%20USG%20interests--not%20for%20your%20personal%20benefit%20or%20privacy.%0A%0A-Notwithstanding%20the%20above%2C%20using%20this%20IS%20does%20not%20constitute%20consent%20to%20PM%2C%20LE%20%0Aor%20CI%20investigative%20searching%20or%20monitoring%20of%20the%20content%20of%20privileged%20%0Acommunications%2C%20or%20work%20product%2C%20related%20to%20personal%20representation%20or%20services%20%0Aby%20attorneys%2C%20psychotherapists%2C%20or%20clergy%2C%20and%20their%20assistants.%20Such%20%0Acommunications%20and%20work%20product%20are%20private%20and%20confidential.%20See%20User%20%0AAgreement%20for%20details.
        mode: 0644
        path: /etc/issue.d/legal-notice
        overwrite: true
EOF
