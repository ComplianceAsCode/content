FROM registry.redhat.io/ubi9/ubi:latest AS builder

# The build tooling requires python, and the openscap-utils package to build
# the content.
RUN yum -y install python3 cmake make python3-pyyaml python3-jinja2 openscap-scanner

WORKDIR /go/src/github.com/ComplianceAsCode/content
COPY . .


# Disable all profiles so we don't accidentally ship a profile we don't intend to ship
RUN find . -name "*.profile" -exec sed -i 's/\(documentation_complete: \).*/\1false/' '{}' \;
# Enable the default.profiles as they maintain a list rules to be added to the datastream
RUN find . -name "default\.profile" -exec sed -i 's/\(documentation_complete: \).*/\1true/' '{}' \;

# Choose profile to enable for all architectures
RUN sed -i 's/\(documentation_complete: \).*/\1true/' \
    products/ocp4/profiles/pci-dss-node-3-2.profile \
    products/ocp4/profiles/pci-dss-3-2.profile \
    products/ocp4/profiles/pci-dss-node-4-0.profile \
    products/ocp4/profiles/pci-dss-4-0.profile \
    products/ocp4/profiles/pci-dss-node.profile \
    products/ocp4/profiles/pci-dss.profile \
    products/ocp4/profiles/cis-node.profile \
    products/ocp4/profiles/cis.profile \
    products/ocp4/profiles/cis-node-1-4.profile \
    products/ocp4/profiles/cis-1-4.profile \
    products/ocp4/profiles/cis-node-1-5.profile \
    products/ocp4/profiles/cis-1-5.profile \
    products/ocp4/profiles/moderate-node.profile \
    products/ocp4/profiles/moderate.profile \
    products/ocp4/profiles/moderate-node-rev-4.profile \
    products/ocp4/profiles/moderate-rev-4.profile

# Only enable for x86_64
RUN if [ "$(uname -m)" = "x86_64" ]; then \
	sed -i 's/\(documentation_complete: \).*/\1true/' products/ocp4/profiles/e8.profile && \
        sed -i 's/\(documentation_complete: \).*/\1true/' products/ocp4/profiles/high.profile && \
        sed -i 's/\(documentation_complete: \).*/\1true/' products/ocp4/profiles/high-node.profile && \
        sed -i 's/\(documentation_complete: \).*/\1true/' products/ocp4/profiles/high-rev-4.profile && \
        sed -i 's/\(documentation_complete: \).*/\1true/' products/ocp4/profiles/high-node-rev-4.profile && \
	sed -i 's/\(documentation_complete: \).*/\1true/' products/ocp4/profiles/nerc-cip.profile && \
	sed -i 's/\(documentation_complete: \).*/\1true/' products/ocp4/profiles/nerc-cip-node.profile && \
	sed -i 's/\(documentation_complete: \).*/\1true/' products/rhcos4/profiles/moderate.profile && \
        sed -i 's/\(documentation_complete: \).*/\1true/' products/rhcos4/profiles/high.profile && \
	sed -i 's/\(documentation_complete: \).*/\1true/' products/rhcos4/profiles/moderate-rev-4.profile && \
        sed -i 's/\(documentation_complete: \).*/\1true/' products/rhcos4/profiles/high-rev-4.profile && \
	sed -i 's/\(documentation_complete: \).*/\1true/' products/rhcos4/profiles/e8.profile && \
	sed -i 's/\(documentation_complete: \).*/\1true/' products/rhcos4/profiles/nerc-cip.profile && \
	sed -i 's/\(documentation_complete: \).*/\1true/' products/ocp4/profiles/pci-dss-node.profile && \
	sed -i 's/\(documentation_complete: \).*/\1true/' products/ocp4/profiles/pci-dss.profile && \
	sed -i 's/\(documentation_complete: \).*/\1true/' products/ocp4/profiles/pci-dss-node-3-2.profile && \
	sed -i 's/\(documentation_complete: \).*/\1true/' products/ocp4/profiles/pci-dss-3-2.profile && \
	sed -i 's/\(documentation_complete: \).*/\1true/' products/ocp4/profiles/stig.profile && \
	sed -i 's/\(documentation_complete: \).*/\1true/' products/ocp4/profiles/stig-node.profile && \
	sed -i 's/\(documentation_complete: \).*/\1true/' products/rhcos4/profiles/stig.profile && \
	sed -i 's/\(documentation_complete: \).*/\1true/' products/ocp4/profiles/stig-v1r1.profile && \
	sed -i 's/\(documentation_complete: \).*/\1true/' products/ocp4/profiles/stig-node-v1r1.profile && \
	sed -i 's/\(documentation_complete: \).*/\1true/' products/rhcos4/profiles/stig-v1r1.profile && \
	sed -i 's/\(documentation_complete: \).*/\1true/' products/ocp4/profiles/stig-v2r1.profile && \
	sed -i 's/\(documentation_complete: \).*/\1true/' products/ocp4/profiles/stig-node-v2r1.profile && \
	sed -i 's/\(documentation_complete: \).*/\1true/' products/rhcos4/profiles/stig-v2r1.profile; \
    elif [ "$(uname -m)" = "ppc64le" ]; then \
        find products/rhcos4 -name "*stig*.profile" | xargs sed -i 's/\(documentation_complete: \).*/\1true/' && \
        find products/ocp4 -name "*stig*.profile" | xargs sed -i 's/\(documentation_complete: \).*/\1true/' ; \
	fi

# OCPBUGS-32794: Ensure stability of rules shipped
# Before building the content we re-enable all profiles as hidden, this will include any rule selected
# by these profiles in the data stream without creating a profile for them.
RUN grep -lr 'documentation_complete: false' ./products | xargs -I '{}' \
    sed -i -e 's/\(documentation_complete: \).*/\1true/' -e '/documentation_complete/a hidden: true' {}

# Build the OpenShift and RHCOS content for x86 architectures. Only build
# OpenShift content for ppc64le and s390x architectures.
RUN if [ "$(uname -m)" = "x86_64" ] || [ "$(uname -m)" = "ppc64le" ]; then \
        ./build_product ocp4 rhcos4 --datastream-only; \
        else ./build_product ocp4 --datastream-only; \
        fi

FROM registry.redhat.io/ubi9/ubi-micro:latest

LABEL \
        io.k8s.display-name="Compliance Content" \
        io.k8s.description="OpenSCAP content for the compliance-operator." \
        io.openshift.tags="openshift,compliance,security" \
        com.redhat.delivery.appregistry="false" \
        maintainer="Red Hat ISC <isc-team@redhat.com>" \
        License="GPLv2+" \
        name="openshift-compliance-content" \
        com.redhat.component="openshift-compliance-content-container" \
        io.openshift.maintainer.product="OpenShift Container Platform" \
        io.openshift.maintainer.component="Compliance Operator"
        # Implement this using Konflux dynamic labels
        # version=1.6.1-dev

WORKDIR /
COPY --from=builder /go/src/github.com/ComplianceAsCode/content/build/ssg-*-ds.xml .
