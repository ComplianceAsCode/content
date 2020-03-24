package v1alpha1

import (
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
)

// ComplianceScanSpecWrapper provides a ComplianceScanSpec and a Name
// +k8s:openapi-gen=true
type ComplianceScanSpecWrapper struct {
	ComplianceScanSpec `json:",inline"`

	// Contains a human readable name for the scan. This is to identify the
	// objects that it creates.
	Name string `json:"name,omitempty"`
}

// ComplianceScanStatusWrapper provides a ComplianceScanStatus and a Name
// +k8s:openapi-gen=true
type ComplianceScanStatusWrapper struct {
	ComplianceScanStatus `json:",inline"`

	// Contains a human readable name for the scan. This is to identify the
	// objects that it creates.
	Name string `json:"name,omitempty"`
}

// +k8s:openapi-gen=true
type ComplianceRemediationNameStatus struct {
	ComplianceRemediationSpecMeta `json:",inline"`
	// Contains a human readable name for the remediation.
	RemediationName string `json:"remediationName"`
	// Contains the name of the scan that generated the remediation
	ScanName string `json:"scanName"`
}

// ComplianceSuiteSpec defines the desired state of ComplianceSuite
// +k8s:openapi-gen=true
type ComplianceSuiteSpec struct {
	// Defines whether or not the remediations should be applied automatically
	AutoApplyRemediations bool `json:"autoApplyRemediations,omitempty"`
	// Contains a list of the scans to execute on the cluster
	// +listType=atomic
	Scans []ComplianceScanSpecWrapper `json:"scans"`
}

// ComplianceSuiteStatus defines the observed state of ComplianceSuite
// +k8s:openapi-gen=true
type ComplianceSuiteStatus struct {
	// +listType=atomic
	ScanStatuses []ComplianceScanStatusWrapper `json:"scanStatuses"`
	// +listType=atomic
	// +optional
	RemediationOverview []ComplianceRemediationNameStatus `json:"remediationOverview,omitempty"`
}

// +k8s:deepcopy-gen:interfaces=k8s.io/apimachinery/pkg/runtime.Object

// ComplianceSuite represents a set of scans that will be applied to the
// cluster. These should help deployers achieve a certain compliance target.
// +k8s:openapi-gen=true
// +kubebuilder:subresource:status
// +kubebuilder:resource:path=compliancesuites,scope=Namespaced
type ComplianceSuite struct {
	metav1.TypeMeta   `json:",inline"`
	metav1.ObjectMeta `json:"metadata,omitempty"`

	// Contains the definition of the suite
	Spec ComplianceSuiteSpec `json:"spec,omitempty"`
	// Contains the current state of the suite
	Status ComplianceSuiteStatus `json:"status,omitempty"`
}

// +k8s:deepcopy-gen:interfaces=k8s.io/apimachinery/pkg/runtime.Object

// ComplianceSuiteList contains a list of ComplianceSuite
type ComplianceSuiteList struct {
	metav1.TypeMeta `json:",inline"`
	metav1.ListMeta `json:"metadata,omitempty"`
	Items           []ComplianceSuite `json:"items"`
}

func init() {
	SchemeBuilder.Register(&ComplianceSuite{}, &ComplianceSuiteList{})
}
