package machineconfiguration

import (
	machineconfigurationv1 "github.com/openshift/machine-config-operator/pkg/apis/machineconfiguration.openshift.io/v1"
	"k8s.io/apimachinery/pkg/runtime"
)

// GroupName defines the API group for machineconfiguration.
const GroupName = "machineconfiguration.openshift.io"

var (
	SchemeBuilder = runtime.NewSchemeBuilder(machineconfigurationv1.Install)
	// Install is a function which adds every version of this group to a scheme
	Install = SchemeBuilder.AddToScheme
)
