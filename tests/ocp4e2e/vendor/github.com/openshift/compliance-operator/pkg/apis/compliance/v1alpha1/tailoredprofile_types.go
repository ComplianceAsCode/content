package v1alpha1

import (
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
)

// FIXME: move name/rationale to a common struct with an interface?

type TailoredProfileOutputType string

const (
	// PolicyOutput specifies that the TailoredProfile should
	// generate a Policy object.
	PolicyOutput TailoredProfileOutputType = "Policy"
	// ConfigMapOutput specifies that the TailoredProfile should
	// generate a ConfigMap object (default).
	ConfigMapOutput TailoredProfileOutputType = "ConfigMap"
)

// RuleReferenceSpec specifies a rule to be selected/deselected, as well as the reason why
type RuleReferenceSpec struct {
	// Name of the rule that's being referenced
	Name string `json:"name"`
	// Rationale of why this rule is being selected/deselected
	Rationale string `json:"rationale"`
}

// ValueReferenceSpec specifies a value to be set for a variable with a reason why
type VariableValueSpec struct {
	// Name of the variable that's being referenced
	Name string `json:"name"`
	// Rationale of why this value is being tailored
	Rationale string `json:"rationale"`
	// Rationale of why this value is being tailored
	Value string `json:"value"`
}

// TailoredProfileSpec defines the desired state of TailoredProfile
type TailoredProfileSpec struct {
	// Points to the name of the profile to extend
	Extends string `json:"extends"`
	// Overwrites the title of the extended profile (optional)
	Title string `json:"title,omitempty"`
	// Overwrites the description of the extended profile (optional)
	Description string `json:"description,omitempty"`
	// Defines the type of output that the tailored profile will do.
	// +kubebuilder:validation:Enum=ConfigMap;Policy
	OutputType TailoredProfileOutputType `json:"outputType,omitempty"`
	// Enables the referenced rules
	// +optional
	// +nullable
	EnableRules []RuleReferenceSpec `json:"enableRules,omitempty"`
	// Disables the referenced rules
	// +optional
	// +nullable
	DisableRules []RuleReferenceSpec `json:"disableRules,omitempty"`
	// Sets the referenced variables to selected values
	// +optional
	// +nullable
	SetValues []VariableValueSpec `json:"setValues,omitempty"`
}

// TailoredProfileState defines the state fo the tailored profile
type TailoredProfileState string

const (
	// TailoredProfileStatePending is a state where a tailored profile is still pending to be processed
	TailoredProfileStatePending TailoredProfileState = "PENDING"
	// TailoredProfileStateReady is a state where a tailored profile is ready to be used
	TailoredProfileStateReady TailoredProfileState = "READY"
	// TailoredProfileStateError is a state where a tailored profile had an error while processing
	TailoredProfileStateError TailoredProfileState = "ERROR"
)

// TailoredProfileStatus defines the observed state of TailoredProfile
type TailoredProfileStatus struct {
	// The XCCDF ID of the tailored profile
	ID string `json:"id,omitempty"`
	// Points to the generated resource of the type specified in "outputType"
	OutputRef OutputRef `json:"outputRef,omitempty"`
	// The current state of the tailored profile
	State        TailoredProfileState `json:"state,omitempty"`
	ErrorMessage string               `json:"errorMessagae,omitempty"`
}

// OutputRef is a reference to the object created from the tailored profile
type OutputRef struct {
	Name      string `json:"name"`
	Namespace string `json:"namespace"`
}

// +k8s:deepcopy-gen:interfaces=k8s.io/apimachinery/pkg/runtime.Object

// TailoredProfile is the Schema for the tailoredprofiles API
// +kubebuilder:subresource:status
// +kubebuilder:resource:path=tailoredprofiles,scope=Namespaced
// +kubebuilder:printcolumn:name="State",type="string",JSONPath=`.status.state`,description="State of the tailored profile"
type TailoredProfile struct {
	metav1.TypeMeta   `json:",inline"`
	metav1.ObjectMeta `json:"metadata,omitempty"`

	Spec   TailoredProfileSpec   `json:"spec,omitempty"`
	Status TailoredProfileStatus `json:"status,omitempty"`
}

// +k8s:deepcopy-gen:interfaces=k8s.io/apimachinery/pkg/runtime.Object

// TailoredProfileList contains a list of TailoredProfile
type TailoredProfileList struct {
	metav1.TypeMeta `json:",inline"`
	metav1.ListMeta `json:"metadata,omitempty"`
	Items           []TailoredProfile `json:"items"`
}

func init() {
	SchemeBuilder.Register(&TailoredProfile{}, &TailoredProfileList{})
}
