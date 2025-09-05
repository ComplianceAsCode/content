package v1alpha1

import (
	"strings"

	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
)

type ComplianceCheckStatus string

// ComplianceCheckResultLabel defines a label that will be included in the
// ComplianceCheckResult objects. It indicates the result in an easy-to-find
// way.
const ComplianceCheckResultStatusLabel = "compliance.openshift.io/check-status"
const ComplianceCheckResultSeverityLabel = "compliance.openshift.io/check-severity"

// ComplianceCheckInconsistentLabel signifies that the check's results were not consistent
// across the target nodes
const ComplianceCheckInconsistentLabel = "compliance.openshift.io/inconsistent-check"

// ComplianceCheckResultRuleAnnotation exposes the DNS-friendly name of a rule as a label.
// This provides a way to link a result to a Rule object.
const ComplianceCheckResultRuleAnnotation = "compliance.openshift.io/rule"

// ComplianceCheckResultInconsistentSourceAnnotation is only used with an Inconsistent check result
// It either lists statuses of nodes that differ from ComplianceCheckResultMostCommonAnnotation or,
// if the most common state does not exist, just lists all sources of all nodes.
const ComplianceCheckResultInconsistentSourceAnnotation = "compliance.openshift.io/inconsistent-source"

// ComplianceCheckResultMostCommonAnnotation stores the most common ComplianceCheckStatus value
// in an inconsistent check. In order for the result to be most common, at least 60% of the nodes
// must report the same result. The nodes that differ from the most common status are listed using
// ComplianceCheckResultInconsistentSourceAnnotation
const ComplianceCheckResultMostCommonAnnotation = "compliance.openshift.io/most-common-status"
const ComplianceCheckResultErrorAnnotation = "compliance.openshift.io/error-msg"

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
	// The check reports different results from different sources, typically cluster nodes
	CheckResultInconsistent ComplianceCheckStatus = "INCONSISTENT"
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

// IDToDNSFriendlyName gets the ID from the scan and returns a DNS
// friendly name
func (ccr *ComplianceCheckResult) IDToDNSFriendlyName() string {
	const rulePrefix = "xccdf_org.ssgproject.content_rule_"
	ruleName := strings.TrimPrefix(ccr.ID, rulePrefix)
	dnsFriendlyFixID := strings.ReplaceAll(ruleName, "_", "-")
	return strings.ToLower(dnsFriendlyFixID)
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
