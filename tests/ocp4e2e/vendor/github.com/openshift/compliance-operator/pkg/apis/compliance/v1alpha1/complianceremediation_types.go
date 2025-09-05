package v1alpha1

import (
	"fmt"

	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/apimachinery/pkg/apis/meta/v1/unstructured"
)

type RemediationApplicationState string

const (
	RemediationNotApplied RemediationApplicationState = "NotApplied"
	RemediationApplied    RemediationApplicationState = "Applied"
	RemediationError      RemediationApplicationState = "Error"
)

type RemediationType string

const (
	// The remediation wraps a MachineConfig payload
	McRemediation RemediationType = "MachineConfig"
)

const (
	// ScanLabel defines the label that associates the Remediation with the scan
	ScanLabel = "complianceoperator.openshift.io/scan"
)

type ComplianceRemediationSpecMeta struct {
	// Remediation type specifies the artifact the remediation is based on. For now, only MachineConfig is supported
	Type RemediationType `json:"type,omitempty"`
	// Whether the remediation should be picked up and applied by the operator
	Apply bool `json:"apply"`
}

// ComplianceRemediationSpec defines the desired state of ComplianceRemediation
// +k8s:openapi-gen=true
type ComplianceRemediationSpec struct {
	ComplianceRemediationSpecMeta `json:",inline"`
	// The actual MachineConfig remediation payload
	MachineConfigContents *unstructured.Unstructured `json:"machineConfigContents,omitempty"`
	// The remediation payload. This would normally be a full Kubernetes
	// object.
	Object *unstructured.Unstructured `json:"object,omitempty"`
}

// ComplianceRemediationStatus defines the observed state of ComplianceRemediation
// +k8s:openapi-gen=true
type ComplianceRemediationStatus struct {
	// Whether the remediation is already applied or not
	ApplicationState RemediationApplicationState `json:"applicationState,omitempty"`
	ErrorMessage     string                      `json:"errorMessage,omitempty"`
}

// +k8s:deepcopy-gen:interfaces=k8s.io/apimachinery/pkg/runtime.Object

// ComplianceRemediation represents a remediation that can be applied to the
// cluster to fix the found issues.
// +k8s:openapi-gen=true
// +kubebuilder:subresource:status
// +kubebuilder:resource:path=complianceremediations,scope=Namespaced
// +kubebuilder:printcolumn:name="State",type="string",JSONPath=`.status.applicationState`
type ComplianceRemediation struct {
	metav1.TypeMeta   `json:",inline"`
	metav1.ObjectMeta `json:"metadata,omitempty"`

	// Contains the definition of what the remediation should be
	Spec ComplianceRemediationSpec `json:"spec,omitempty"`
	// Contains information on the remediation (whether it's applied or not)
	Status ComplianceRemediationStatus `json:"status,omitempty"`
}

func (r *ComplianceRemediation) GetSuite() string {
	return r.Labels[SuiteLabel]
}

func (r *ComplianceRemediation) GetScan() string {
	return r.Labels[ScanLabel]
}

func (r *ComplianceRemediation) GetMcName() string {
	if r.GetScan() == "" || r.GetSuite() == "" {
		return ""
	}
	return fmt.Sprintf("75-%s-%s", r.GetScan(), r.GetSuite())
}

// +k8s:deepcopy-gen:interfaces=k8s.io/apimachinery/pkg/runtime.Object

// ComplianceRemediationList contains a list of ComplianceRemediation
type ComplianceRemediationList struct {
	metav1.TypeMeta `json:",inline"`
	metav1.ListMeta `json:"metadata,omitempty"`
	Items           []ComplianceRemediation `json:"items"`
}

func init() {
	SchemeBuilder.Register(&ComplianceRemediation{}, &ComplianceRemediationList{})
}
