package v1alpha1

import (
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
)

// +genclient

// ComplianceScanRescanAnnotation indicates that a ComplianceScan
// should be re-run
const ComplianceScanRescanAnnotation = "compliance.openshift.io/rescan"

// ComplianceScanIndicatorLabel serves as an indicator for which ComplianceScan
// owns the referenced object
const ComplianceScanIndicatorLabel = "compliance-scan"

// Represents the status of the compliance scan run.
type ComplianceScanStatusPhase string

const (
	// PhasePending represents the scan pending to be scheduled
	PhasePending ComplianceScanStatusPhase = "PENDING"
	// PhaseLaunching represents being scheduled and launching pods to run the scans
	PhaseLaunching ComplianceScanStatusPhase = "LAUNCHING"
	// PhaseRunning represents the scan being ran by the pods and waiting for the results
	PhaseRunning ComplianceScanStatusPhase = "RUNNING"
	// PhaseAggregating represents the scan aggregating the results
	PhaseAggregating ComplianceScanStatusPhase = "AGGREGATING"
	// PhaseDone represents the scan pods being done and the results being available
	PhaseDone ComplianceScanStatusPhase = "DONE"
)

func stateCompare(lowPhase ComplianceScanStatusPhase, scanPhase ComplianceScanStatusPhase) ComplianceScanStatusPhase {
	orderedStates := make(map[ComplianceScanStatusPhase]int)
	orderedStates[PhasePending] = 0
	orderedStates[PhaseLaunching] = 1
	orderedStates[PhaseRunning] = 2
	orderedStates[PhaseAggregating] = 3
	orderedStates[PhaseDone] = 4

	if orderedStates[lowPhase] > orderedStates[scanPhase] {
		return scanPhase
	}
	return lowPhase
}

// Represents the result of the compliance scan
type ComplianceScanStatusResult string

const (
	// ResultCompliant represents the compliance scan having succeeded
	ResultNotAvailable ComplianceScanStatusResult = "NOT-AVAILABLE"
	// ResultCompliant represents the compliance scan having succeeded
	ResultCompliant ComplianceScanStatusResult = "COMPLIANT"
	// ResultError represents a compliance scan pod having failed to run the scan or encountered an error
	ResultError ComplianceScanStatusResult = "ERROR"
	// ResultNonCompliant represents the compliance scan having found a gap
	ResultNonCompliant ComplianceScanStatusResult = "NON-COMPLIANT"
	ScanTypeNode       ComplianceScanType         = "Node"
	ScanTypePlatform   ComplianceScanType         = "Platform"
)

func resultCompare(lowResult ComplianceScanStatusResult, scanResult ComplianceScanStatusResult) ComplianceScanStatusResult {
	orderedResults := make(map[ComplianceScanStatusResult]int)
	orderedResults[ResultNotAvailable] = 0
	orderedResults[ResultError] = 1
	orderedResults[ResultNonCompliant] = 2
	orderedResults[ResultCompliant] = 3

	if orderedResults[lowResult] > orderedResults[scanResult] {
		return scanResult
	}
	return lowResult
}

// TailoringConfigMapRef is a reference to a ConfigMap that contains the
// tailoring file. It assumes a key called `tailoring.xml` which will
// have the tailoring contents.
type TailoringConfigMapRef struct {
	// Name of the ConfigMap being referenced
	Name string `json:"name"`
}

// ComplianceScanType
// +k8s:openapi-gen=true
type ComplianceScanType string

// ComplianceScanSpec defines the desired state of ComplianceScan
// +k8s:openapi-gen=true
type ComplianceScanSpec struct {
	// The type of Compliance scan.
	ScanType ComplianceScanType `json:"scanType,omitempty"`
	// Is the image with the content (Data Stream), that will be used to run
	// OpenSCAP.
	ContentImage string `json:"contentImage,omitempty"`
	// Is the profile in the data stream to be used. This is the collection of
	// rules that will be checked for.
	Profile string `json:"profile,omitempty"`
	// A Rule can be specified if the scan should check only for a specific
	// rule. Note that when leaving this empty, the scan will check for all the
	// rules for a specific profile.
	Rule string `json:"rule,omitempty"`
	// Is the path to the file that contains the content (the data stream).
	// Note that the path needs to be relative to the `/` (root) directory, as
	// it is in the ContentImage
	Content string `json:"content,omitempty"`
	// By setting this, it's possible to only run the scan on certain nodes in
	// the cluster. Note that when applying remediations generated from the
	// scan, this should match the selector of the MachineConfigPool you want
	// to apply the remediations to.
	NodeSelector map[string]string `json:"nodeSelector,omitempty"`
	// Is a reference to a ConfigMap that contains the
	// tailoring file. It assumes a key called `tailoring.xml` which will
	// have the tailoring contents.
	TailoringConfigMap *TailoringConfigMapRef `json:"tailoringConfigMap,omitempty"`
	// Disables cleaning up resources in the DONE phase, this might be useful for debugging.
	Debug bool `json:"debug,omitempty"`
}

// ComplianceScanStatus defines the observed state of ComplianceScan
// +k8s:openapi-gen=true
type ComplianceScanStatus struct {
	// Is the phase where the scan is at. Normally, one must wait for the scan
	// to reach the phase DONE.
	Phase ComplianceScanStatusPhase `json:"phase,omitempty"`
	// Once the scan reaches the phase DONE, this will contain the result of
	// the scan. Where COMPLIANT means that the scan succeeded; NON-COMPLIANT
	// means that there were rule violations; and ERROR means that the scan
	// couldn't complete due to an issue.
	Result ComplianceScanStatusResult `json:"result,omitempty"`
	// If there are issues on the scan, this will be filled up with an error
	// message.
	ErrorMessage string `json:"errormsg,omitempty"`
	// Specifies the current index of the scan. Given multiple scans, this marks the
	// amount that have been executed.
	CurrentIndex int64 `json:"currentIndex,omitempty"`
}

// +k8s:deepcopy-gen:interfaces=k8s.io/apimachinery/pkg/runtime.Object

// ComplianceScan represents a scan with a certain configuration that will be
// applied to objects of a certain entity in the host. These could be nodes
// that apply to a certain nodeSelector, or the cluster itself.
// +k8s:openapi-gen=true
// +kubebuilder:subresource:status
// +kubebuilder:printcolumn:name="Phase",type="string",JSONPath=`.status.phase`
// +kubebuilder:printcolumn:name="Result",type="string",JSONPath=`.status.result`
type ComplianceScan struct {
	metav1.TypeMeta   `json:",inline"`
	metav1.ObjectMeta `json:"metadata,omitempty"`

	// The spec is the configuration for the compliance scan.
	Spec ComplianceScanSpec `json:"spec,omitempty"`
	// The status will give valuable information on what's going on with the
	// scan; and, more importantly, if the scan is successful (compliant) or
	// not (non-compliant)
	Status ComplianceScanStatus `json:"status,omitempty"`
}

// NeedsRescan indicates whether a ComplianceScan needs to
// rescan or not
func (cs *ComplianceScan) NeedsRescan() bool {
	annotations := cs.GetAnnotations()
	if annotations == nil {
		return false
	}
	_, needsRescan := annotations[ComplianceScanRescanAnnotation]
	return needsRescan
}

// +k8s:deepcopy-gen:interfaces=k8s.io/apimachinery/pkg/runtime.Object

// ComplianceScanList contains a list of ComplianceScan
type ComplianceScanList struct {
	metav1.TypeMeta `json:",inline"`
	metav1.ListMeta `json:"metadata,omitempty"`
	Items           []ComplianceScan `json:"items"`
}

func init() {
	SchemeBuilder.Register(&ComplianceScan{}, &ComplianceScanList{})
}
