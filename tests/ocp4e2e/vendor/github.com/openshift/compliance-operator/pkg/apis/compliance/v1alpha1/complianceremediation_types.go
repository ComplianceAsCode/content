package v1alpha1

import (
	"fmt"
	"reflect"

	"k8s.io/apimachinery/pkg/apis/meta/v1/unstructured"

	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
)

type RemediationApplicationState string

const (
	RemediationPending             RemediationApplicationState = "Pending"
	RemediationNotApplied          RemediationApplicationState = "NotApplied"
	RemediationApplied             RemediationApplicationState = "Applied"
	RemediationOutdated            RemediationApplicationState = "Outdated"
	RemediationError               RemediationApplicationState = "Error"
	RemediationMissingDependencies RemediationApplicationState = "MissingDependencies"
)

type RemediationType string

const (
	// The key of a ComplianceCheckResult that dependency annotations point to
	ComplianceRemediationDependencyField = "id"
)

const (
	// OutdatedRemediationLabel specifies that the remediation has been superseded by a newer version
	OutdatedRemediationLabel               = "complianceoperator.openshift.io/outdated-remediation"
	RemediationHasUnmetDependenciesLabel   = "compliance.openshift.io/has-unmet-dependencies"
	RemediationCreatedByOperatorAnnotation = "compliance.openshift.io/remediation"
	RemediationDependencyAnnotation        = "compliance.openshift.io/depends-on"
	RemediationDependenciesMetAnnotation   = "compliance.openshift.io/dependencies-met"
)

type ComplianceRemediationSpecMeta struct {
	// Whether the remediation should be picked up and applied by the operator
	Apply bool `json:"apply"`
}

type ComplianceRemediationPayload struct {
	// The remediation payload. This would normally be a full Kubernetes
	// object.
	// +kubebuilder:pruning:PreserveUnknownFields
	// +kubebuilder:validation:EmbeddedResource
	// +kubebuilder:validation:nullable
	Object *unstructured.Unstructured `json:"object,omitempty"`
}

// ComplianceRemediationSpec defines the desired state of ComplianceRemediation
// +k8s:openapi-gen=true
type ComplianceRemediationSpec struct {
	ComplianceRemediationSpecMeta `json:",inline"`
	// Defines the remediation that is proposed by the scan. If there is no "outdated"
	// remediation in this object, the "current" remediation is what will be applied.
	Current ComplianceRemediationPayload `json:"current,omitempty"`
	// In case there was a previous remediation proposed by a previous scan, and that remediation
	// now differs, the old remediation will be kept in this "outdated" key. This requires admin
	// intervention to remove this outdated object and ensure the current is what's applied.
	Outdated ComplianceRemediationPayload `json:"outdated,omitempty"`
}

// ComplianceRemediationStatus defines the observed state of ComplianceRemediation
// +k8s:openapi-gen=true
type ComplianceRemediationStatus struct {
	// Whether the remediation is already applied or not
	// +kubebuilder:default="NotApplied"
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

func (r *ComplianceRemediation) RemediationPayloadDiffers(other *ComplianceRemediation) bool {
	return !reflect.DeepEqual(r.Spec.Current, other.Spec.Current)
}

func (r *ComplianceRemediation) GetSuite() string {
	return r.Labels[SuiteLabel]
}

func (r *ComplianceRemediation) GetScan() string {
	return r.Labels[ComplianceScanLabel]
}

func (r *ComplianceRemediation) GetMcName() string {
	if r.GetScan() == "" {
		return ""
	}

	mcName := fmt.Sprintf("75-%s", r.GetName())

	return mcName
}

// AddOwnershipLabels labels an object to say it was created
// by this operator and is owned by a specific scan and suite
func (r *ComplianceRemediation) AddOwnershipLabels(obj metav1.Object) {
	labels := obj.GetLabels()
	if labels == nil {
		labels = make(map[string]string)
	}
	if r.GetScan() != "" {
		labels[ComplianceScanLabel] = r.GetScan()
	}
	if r.GetSuite() != "" {
		labels[SuiteLabel] = r.GetSuite()
	}
	obj.SetLabels(labels)
}

// IsApplied tells whether the ComplianceRemediation has been applied.
// Note that a Remediation is considered applied if the state of it is
// indeed applied, or if it has been requested to be applied but it has
// become outdated
func (r *ComplianceRemediation) IsApplied() bool {
	applied := r.Status.ApplicationState == RemediationApplied
	outDatedButApplied := r.Spec.Apply && r.Status.ApplicationState == RemediationOutdated
	appliedButUnmet := r.Spec.Apply && r.Status.ApplicationState == RemediationMissingDependencies

	return applied || outDatedButApplied || appliedButUnmet
}

func (r *ComplianceRemediation) HasUnmetDependencies() bool {
	a := r.GetAnnotations()
	if a == nil {
		return false
	}
	_, hasDependencies := a[RemediationDependencyAnnotation]
	_, dependenciesMet := a[RemediationDependenciesMetAnnotation]
	return hasDependencies && !dependenciesMet
}

// +k8s:deepcopy-gen:interfaces=k8s.io/apimachinery/pkg/runtime.Object

// ComplianceRemediationList contains a list of ComplianceRemediation
type ComplianceRemediationList struct {
	metav1.TypeMeta `json:",inline"`
	metav1.ListMeta `json:"metadata,omitempty"`
	Items           []ComplianceRemediation `json:"items"`
}

// AddRemediationAnnotation annotates an object to say it was created
// by this operator
func AddRemediationAnnotation(obj metav1.Object) {
	annotations := obj.GetAnnotations()
	if annotations == nil {
		annotations = make(map[string]string)
	}
	annotations[RemediationCreatedByOperatorAnnotation] = ""
	obj.SetAnnotations(annotations)
}

// AddRemediationAnnotation tells us if an object was created by this
// operator
func RemediationWasCreatedByOperator(obj metav1.Object) bool {
	annotations := obj.GetAnnotations()
	if annotations == nil {
		return false
	}
	_, ok := annotations[RemediationCreatedByOperatorAnnotation]
	return ok
}

func init() {
	SchemeBuilder.Register(&ComplianceRemediation{}, &ComplianceRemediationList{})
}
