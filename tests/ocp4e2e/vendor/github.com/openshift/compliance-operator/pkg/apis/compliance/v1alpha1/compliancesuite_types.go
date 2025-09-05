package v1alpha1

import (
	"reflect"

	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
)

// SuiteLabel indicates that an object (normally the ComplianceScan
// or a ComplianceRemediation) belongs to a certain ComplianceSuite.
// This is an easy way to filter them.
const SuiteLabel = "compliance.openshift.io/suite"

// SuiteScriptLabel indicates that the object is a script belonging to the
// compliance suite controller
const SuiteScriptLabel = "compliance.openshift.io/suite-script"

// SuiteFinalizer is a finalizer for ComplianceSuites. It gets automatically
// added by the ComplianceSuite controller in order to delete resources.
const SuiteFinalizer = "suite.finalizers.compliance.openshift.io"

// ApplyRemediationsAnnotation is an annotation that, when set on a ComplianceSuite
// will apply all the remediations that were generated. It will be removed once
// they've been applied.
const ApplyRemediationsAnnotation = "compliance.openshift.io/apply-remediations"

// RemoveOutdatedAnnotation is an annotation that, when set on a ComplianceSuite
// will automatically remove outdated remediations so the operator will apply
// only the up-to-date ones. It'll be removed once the outdated remediations have
// been removed.
const RemoveOutdatedAnnotation = "compliance.openshift.io/remove-outdated"

// ComplianceScanSpecWrapper provides a ComplianceScanSpec and a Name
// +k8s:openapi-gen=true
type ComplianceScanSpecWrapper struct {
	ComplianceScanSpec `json:",inline"`

	// Contains a human readable name for the scan. This is to identify the
	// objects that it creates.
	Name string `json:"name,omitempty"`
}

func (sw *ComplianceScanSpecWrapper) ScanSpecDiffers(other *ComplianceScan) bool {
	if sw.Name != other.Name {
		return true
	}

	// Avoid returning that the two differ if the other (typically retrieved through
	// an API call) has the defaults set
	swCopy := sw.DeepCopy()
	if swCopy.RawResultStorage.Size == "" {
		swCopy.RawResultStorage.Size = DefaultRawStorageSize
	}
	if swCopy.RawResultStorage.Rotation == 0 && other.Spec.RawResultStorage.Rotation == DefaultStorageRotation {
		swCopy.RawResultStorage.Rotation = DefaultStorageRotation
	}

	// In case this ever gets slow, switch to comparing the fields one by
	// one and fall back by deep equality on the complex types only
	return !reflect.DeepEqual(swCopy.ComplianceScanSpec, other.Spec)
}

// ComplianceScanStatusWrapper provides a ComplianceScanStatus and a Name
// +k8s:openapi-gen=true
type ComplianceScanStatusWrapper struct {
	ComplianceScanStatus `json:",inline"`

	// Contains a human readable name for the scan. This is to identify the
	// objects that it creates.
	Name string `json:"name,omitempty"`
}

// ComplianceSuiteSettings groups together settings of a ComplianceSuite
// +k8s:openapi-gen=true
type ComplianceSuiteSettings struct {
	// Defines whether or not the remediations should be applied automatically
	AutoApplyRemediations bool `json:"autoApplyRemediations,omitempty"`
	// Defines a schedule for the scans to run. This is in cronjob format.
	// Note the scan will still be triggered immediately, and the scheduled
	// scans will start running only after the initial results are ready.
	Schedule string `json:"schedule,omitempty"`
}

// ComplianceSuiteSpec defines the desired state of ComplianceSuite
// +k8s:openapi-gen=true
type ComplianceSuiteSpec struct {
	ComplianceSuiteSettings `json:",inline"`
	// Contains a list of the scans to execute on the cluster
	// +listType=atomic
	Scans []ComplianceScanSpecWrapper `json:"scans"`
}

// ComplianceSuiteStatus defines the observed state of ComplianceSuite
// +k8s:openapi-gen=true
type ComplianceSuiteStatus struct {
	// +listType=atomic
	ScanStatuses []ComplianceScanStatusWrapper `json:"scanStatuses"`
	Phase        ComplianceScanStatusPhase     `json:"phase,omitempty"`
	Result       ComplianceScanStatusResult    `json:"result,omitempty"`
	ErrorMessage string                        `json:"errorMessage,omitempty"`
}

// +k8s:deepcopy-gen:interfaces=k8s.io/apimachinery/pkg/runtime.Object

// ComplianceSuite represents a set of scans that will be applied to the
// cluster. These should help deployers achieve a certain compliance target.
// +k8s:openapi-gen=true
// +kubebuilder:subresource:status
// +kubebuilder:resource:path=compliancesuites,scope=Namespaced
// +kubebuilder:printcolumn:name="Phase",type="string",JSONPath=`.status.phase`
// +kubebuilder:printcolumn:name="Result",type="string",JSONPath=`.status.result`
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

// ScanStatusWrapperFromScan returns a ComplianceScanStatusWrapper object
// (used by the ComplianceSuite object) in order to display the status of
// a scan
func ScanStatusWrapperFromScan(s *ComplianceScan) ComplianceScanStatusWrapper {
	return ComplianceScanStatusWrapper{
		Name:                 s.Name,
		ComplianceScanStatus: s.Status,
	}
}

// ComplianceScanFromWrapper returns a ComplianceScan from the wrapper that's given
// to a ComplianceSuite. This will return all the values that are derivable from the
// wrapper in order to build a scan. Anything missing must be added separately.
func ComplianceScanFromWrapper(sw *ComplianceScanSpecWrapper) *ComplianceScan {
	return &ComplianceScan{
		ObjectMeta: metav1.ObjectMeta{
			Name: sw.Name,
		},
		Spec: sw.ComplianceScanSpec,
	}
}

func (s *ComplianceSuite) LowestCommonState() ComplianceScanStatusPhase {
	if len(s.Status.ScanStatuses) == 0 {
		return PhasePending
	}

	lowestCommonState := PhaseDone

	for _, scanStatusWrap := range s.Status.ScanStatuses {
		lowestCommonState = stateCompare(lowestCommonState, scanStatusWrap.Phase)
	}

	return lowestCommonState
}

func (s *ComplianceSuite) LowestCommonResult() ComplianceScanStatusResult {
	if len(s.Status.ScanStatuses) == 0 {
		return ResultNotAvailable
	}

	lowestCommonResult := ResultCompliant

	for _, scanStatusWrap := range s.Status.ScanStatuses {
		lowestCommonResult = resultCompare(lowestCommonResult, scanStatusWrap.Result)
	}

	return lowestCommonResult
}

func (s *ComplianceSuite) IsResultAvailable() bool {
	result := s.LowestCommonResult()
	return result != "" && result != ResultNotAvailable
}

// ShouldApplyRemediations returns whether the ComplianceSuite requires
// that the CoplianceRemediations that were generated from it be
// applied.
func (s *ComplianceSuite) ShouldApplyRemediations() bool {
	// autoApplyRemediations from the spec takes precedence
	if s.Spec.AutoApplyRemediations {
		return true
	}
	return s.ApplyRemediationsAnnotationSet()
}

func (s *ComplianceSuite) ApplyRemediationsAnnotationSet() bool {
	annotations := s.GetAnnotations()
	if annotations == nil {
		return false
	}
	_, ok := annotations[ApplyRemediationsAnnotation]
	return ok
}

func (s *ComplianceSuite) RemoveOutdated() bool {
	annotations := s.GetAnnotations()
	if annotations == nil {
		return false
	}
	_, ok := annotations[RemoveOutdatedAnnotation]
	return ok
}
