package v1alpha1

import (
	"fmt"
	"strings"

	corev1 "k8s.io/api/core/v1"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
)

// +genclient

// ComplianceScanRescanAnnotation indicates that a ComplianceScan
// should be re-run
const ComplianceScanRescanAnnotation = "compliance.openshift.io/rescan"

// ComplianceScanLabel serves as an indicator for which ComplianceScan
// owns the referenced object
const ComplianceScanLabel = "compliance.openshift.io/scan-name"

// ScriptLabel defines that the object is a script for a scan object
const ScriptLabel = "complianceoperator.openshift.io/scan-script"

// ResultLabel defines that the object is a result of a scan
const ResultLabel = "complianceoperator.openshift.io/scan-result"

// ScanFinalizer is a finalizer for ComplianceScans. It gets automatically
// added by the ComplianceScan controller in order to delete resources.
const ScanFinalizer = "scan.finalizers.compliance.openshift.io"

// DefaultRawStorageSize specifies the default storage size where the raw
// results will be stored at
const DefaultRawStorageSize = "1Gi"
const DefaultStorageRotation = 3

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

// CmScanResultAnnotation holds the processed scanner result
const CmScanResultAnnotation = "compliance.openshift.io/scan-result"

// CmScanResultErrMsg holds the processed scanner error message
const CmScanResultErrMsg = "compliance.openshift.io/scan-error-msg"

const (
	// ResultNot available represents the compliance scan not having finished yet
	ResultNotAvailable ComplianceScanStatusResult = "NOT-AVAILABLE"
	// ResultCompliant represents the compliance scan having succeeded
	ResultCompliant ComplianceScanStatusResult = "COMPLIANT"
	// ResultNotApplicable represents the compliance scan having no useful results after finished
	ResultNotApplicable ComplianceScanStatusResult = "NOT-APPLICABLE"
	// ResultError represents a compliance scan pod having failed to run the scan or encountered an error
	ResultError ComplianceScanStatusResult = "ERROR"
	// ResultNonCompliant represents the compliance scan having found a gap
	ResultNonCompliant ComplianceScanStatusResult = "NON-COMPLIANT"
	// ResultInconsistent represents checks differing across the machines
	ResultInconsistent ComplianceScanStatusResult = "INCONSISTENT"
	ScanTypeNode       ComplianceScanType         = "Node"
	ScanTypePlatform   ComplianceScanType         = "Platform"
)

func resultCompare(lowResult ComplianceScanStatusResult, scanResult ComplianceScanStatusResult) ComplianceScanStatusResult {
	orderedResults := make(map[ComplianceScanStatusResult]int)
	orderedResults[ResultNotAvailable] = 0
	orderedResults[ResultError] = 1
	orderedResults[ResultInconsistent] = 2
	orderedResults[ResultNonCompliant] = 3
	orderedResults[ResultNotApplicable] = 4
	orderedResults[ResultCompliant] = 5

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

// When changing the defaults, remember to change also the DefaultRawStorageSize and
// DefaultStorageRotation constants
type RawResultStorageSettings struct {
	// Specifies the amount of storage to ask for storing the raw results. Note that
	// if re-scans happen, the new results will also need to be stored. Defaults to 1Gi.
	// +kubebuilder:validation:Default=1Gi
	// +kubebuilder:default="1Gi"
	Size string `json:"size,omitempty"`
	// Specifies the amount of scans for which the raw results will be stored.
	// Older results will get rotated, and it's the responsibility of administrators
	// to store these results elsewhere before rotation happens. Note that a rotation
	// policy of '0' disables rotation entirely. Defaults to 3.
	// +kubebuilder:default=3
	Rotation uint16 `json:"rotation,omitempty"`
	// Specifies the StorageClassName to use when creating the PersistentVolumeClaim
	// to hold the raw results. By default this is null, which will attempt to use the
	// default storage class configured in the cluster. If there is no default class specified
	// then this needs to be set.
	// +nullable
	StorageClassName *string `json:"storageClassName,omitempty"`
	// Specifies the access modes that the PersistentVolume will be created with.
	// The persistent volume will hold the raw results of the scan.
	// +kubebuilder:default={"ReadWriteOnce"}
	PVAccessModes []corev1.PersistentVolumeAccessMode `json:"pvAccessModes,omitempty"`
}

// ComplianceScanSettings groups together settings of a ComplianceScan
// +k8s:openapi-gen=true
type ComplianceScanSettings struct {
	// Enable debug logging of workloads and OpenSCAP
	Debug bool `json:"debug,omitempty"`
	// Specifies settings that pertain to raw result storage.
	RawResultStorage RawResultStorageSettings `json:"rawResultStorage,omitempty"`
	// Defines that no external resources in the Data Stream should be used. External
	// resources could be, for instance, CVE feeds. This is useful for disconnected
	// installations without access to a proxy.
	NoExternalResources bool `json:"noExternalResources,omitempty"`
	// Defines a proxy for the scan to get external resources from. This is useful for
	// disconnected installations with access to a proxy.
	HTTPSProxy string `json:"httpsProxy,omitempty"`
	// Specifies tolerations needed for the scan to run on the nodes. This is useful
	// in case the target set of nodes have custom taints that don't allow certain
	// workloads to run. Defaults to allowing scheduling on the master nodes.
	// +kubebuilder:default={{key: "node-role.kubernetes.io/master", operator: "Exists", effect: "NoSchedule"}}
	ScanTolerations []corev1.Toleration `json:"scanTolerations,omitempty"`
}

// ComplianceScanSpec defines the desired state of ComplianceScan
// +k8s:openapi-gen=true
type ComplianceScanSpec struct {
	// The type of Compliance scan.
	// +kubebuilder:default=Node
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

	ComplianceScanSettings `json:",inline"`
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
	// Specifies the object that's storing the raw results for the scan.
	ResultsStorage StorageReference `json:"resultsStorage,omitempty"`
}

// StorageReference stores a reference to where certain objects are being stored
type StorageReference struct {
	// Kind of the referent.
	// More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#types-kinds
	// +optional
	Kind string `json:"kind,omitempty"`
	// Namespace of the referent.
	// More info: https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/
	// +optional
	Namespace string `json:"namespace,omitempty"`
	// Name of the referent.
	// More info: https://kubernetes.io/docs/concepts/overview/working-with-objects/names/#names
	// +optional
	Name string `json:"name,omitempty"`
	// API version of the referent.
	// +optional
	APIVersion string `json:"apiVersion,omitempty"`
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

// GetScanTypeIfValid returns scan type if the scan has a valid one, else it returns
// an error
func (cs *ComplianceScan) GetScanTypeIfValid() (ComplianceScanType, error) {
	if strings.ToLower(string(cs.Spec.ScanType)) == strings.ToLower(string(ScanTypePlatform)) {
		return ScanTypePlatform, nil
	}

	if strings.ToLower(string(cs.Spec.ScanType)) == strings.ToLower(string(ScanTypeNode)) {
		return ScanTypeNode, nil
	}
	return "", fmt.Errorf("Unknown scan type")
}

// GetScanType get's the scan type for a scan
func (cs *ComplianceScan) GetScanType() ComplianceScanType {
	scantype, err := cs.GetScanTypeIfValid()
	if err != nil {
		// This shouldn't happen
		panic(err)
	}
	return scantype
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
