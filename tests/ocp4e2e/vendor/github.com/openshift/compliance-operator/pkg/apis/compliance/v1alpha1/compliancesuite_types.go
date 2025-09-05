package v1alpha1

import (
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
)

// SuiteLabel indicates that an object (normally the ComplianceScan
// or a ComplianceRemediation) belongs to a certain ComplianceSuite.
// This is an easy way to filter them.
const SuiteLabel = "compliance.openshift.io/suite"

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

// ComplianceSuiteSpec defines the desired state of ComplianceSuite
// +k8s:openapi-gen=true
type ComplianceSuiteSpec struct {
	// Defines whether or not the remediations should be applied automatically
	AutoApplyRemediations bool `json:"autoApplyRemediations,omitempty"`
	// Defines a schedule for the scans to run. This is in cronjob format.
	// Note the scan will still be triggered immediately, and the scheduled
	// scans will start running only after the initial results are ready.
	Schedule string `json:"schedule,omitempty"`
	// Contains a list of the scans to execute on the cluster
	// +listType=atomic
	Scans []ComplianceScanSpecWrapper `json:"scans"`
}

// ComplianceSuiteStatus defines the observed state of ComplianceSuite
// +k8s:openapi-gen=true
type ComplianceSuiteStatus struct {
	// +listType=atomic
	ScanStatuses     []ComplianceScanStatusWrapper `json:"scanStatuses"`
	AggregatedPhase  ComplianceScanStatusPhase     `json:"aggregatedPhase,omitempty"`
	AggregatedResult ComplianceScanStatusResult    `json:"aggregatedResult,omitempty"`
	ErrorMessage     string                        `json:"errorMessage,omitempty"`
}

// +k8s:deepcopy-gen:interfaces=k8s.io/apimachinery/pkg/runtime.Object

// ComplianceSuite represents a set of scans that will be applied to the
// cluster. These should help deployers achieve a certain compliance target.
// +k8s:openapi-gen=true
// +kubebuilder:subresource:status
// +kubebuilder:resource:path=compliancesuites,scope=Namespaced
// +kubebuilder:printcolumn:name="Phase",type="string",JSONPath=`.status.aggregatedPhase`
// +kubebuilder:printcolumn:name="Result",type="string",JSONPath=`.status.aggregatedResult`
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
