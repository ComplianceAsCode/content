package v1alpha1

import (
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
)

type ComplianceCheckStatus string

// ComplianceCheckResultLabel defines a label that will be included in the
// ComplianceCheckResult objects. It indicates the result in an easy-to-find
// way.
const ComplianceCheckResultStatusLabel = "compliance.openshift.io/check-status"
const ComplianceCheckResultSeverityLabel = "compliance.openshift.io/check-severity"

const (
	// The check ran to completion and passed
	CheckResultPass ComplianceCheckStatus = "PASS"
	// The check ran to completion and failed
	CheckResultFail ComplianceCheckStatus = "FAIL"
	// The check ran to completion and found something not severe enough to be considered error
	CheckResultInfo ComplianceCheckStatus = "INFO"
	// The check ran, but could not complete properly
	CheckResultError ComplianceCheckStatus = "ERROR"
	// The check didn't run because it is not applicable or not selected
	CheckResultSkipped ComplianceCheckStatus = "SKIP"
	// The check didn't yield a usable result
	CheckResultNoResult ComplianceCheckStatus = ""
)

type ComplianceCheckResultSeverity string

const (
	CheckResultSeverityUnknown ComplianceCheckResultSeverity = "unknown"
	CheckResultSeverityInfo    ComplianceCheckResultSeverity = "info"
	CheckResultSeverityLow     ComplianceCheckResultSeverity = "low"
	CheckResultSeverityMedium  ComplianceCheckResultSeverity = "medium"
	CheckResultSeverityHigh    ComplianceCheckResultSeverity = "high"
)

// +k8s:deepcopy-gen:interfaces=k8s.io/apimachinery/pkg/runtime.Object

// ComplianceCheckResult represent a result of a single compliance "test"
// +kubebuilder:resource:path=compliancecheckresults,scope=Namespaced
// +kubebuilder:printcolumn:name="Status",type="string",JSONPath=`.status`
// +kubebuilder:printcolumn:name="Severity",type="string",JSONPath=`.severity`
type ComplianceCheckResult struct {
	metav1.TypeMeta   `json:",inline"`
	metav1.ObjectMeta `json:"metadata,omitempty"`

	// A unique identifier of a check
	ID string `json:"id"`
	// The result of a check
	Status ComplianceCheckStatus `json:"status"`
	// The severity of a check status
	Severity ComplianceCheckResultSeverity `json:"severity"`
	// A human-readable check description, what and why it does
	Description string `json:"description,omitempty"`
}

// +k8s:deepcopy-gen:interfaces=k8s.io/apimachinery/pkg/runtime.Object

// ComplianceCheckResultList contains a list of ComplianceCheckResult
type ComplianceCheckResultList struct {
	metav1.TypeMeta `json:",inline"`
	metav1.ListMeta `json:"metadata,omitempty"`
	Items           []ComplianceCheckResult `json:"items"`
}

func init() {
	SchemeBuilder.Register(&ComplianceCheckResult{}, &ComplianceCheckResultList{})
}
