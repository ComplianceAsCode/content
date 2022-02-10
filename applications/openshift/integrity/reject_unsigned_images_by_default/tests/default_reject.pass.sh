#!/bin/bash
# remediation = none

mkdir -p /etc/containers/
cat <<EOF > /etc/containers/policy.json
{
  "default": [{"type": "reject"}],
  "transports": {
    "docker": {
      "registry.access.redhat.com": [
        {
          "type": "signedBy",
          "keyType": "GPGKeys",
          "keyPath": "/etc/pki/rpm-gpg/RPM-GPG-KEY-redhat-release"
        }
      ],
      "registry.redhat.io": [
        {
          "type": "signedBy",
          "keyType": "GPGKeys",
          "keyPath": "/etc/pki/rpm-gpg/RPM-GPG-KEY-redhat-release"
        }
      ],
      "image-registry.openshift-image-registry.svc:5000": [{"type": "insecureAcceptAnything"}],
      "quay.io/complianceascode": [{"type": "insecureAcceptAnything"}],
      "quay.io/compliance-operator": [{"type": "insecureAcceptAnything"}],
      "quay.io/keycloak": [{"type": "insecureAcceptAnything"}],
      "quay.io/openshift-release-dev": [{"type": "insecureAcceptAnything"}],
      "registry.build02.ci.openshift.org": [{"type": "insecureAcceptAnything"}],
      "registry.build01.ci.openshift.org": [{"type": "insecureAcceptAnything"}],
      "registry.build03.ci.openshift.org": [{"type": "insecureAcceptAnything"}],
      "registry.build04.ci.openshift.org": [{"type": "insecureAcceptAnything"}]
    }
  }
}
EOF