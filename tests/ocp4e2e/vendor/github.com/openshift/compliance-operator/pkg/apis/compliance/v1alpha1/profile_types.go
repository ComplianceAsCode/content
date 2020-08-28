package v1alpha1

import (
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
)

// ProductTypeAnnotation specifies what kind of platform (node,platform)
// this Profile or a TailoredProfile targets
const ProductTypeAnnotation = "compliance.openshift.io/product-type"

// ProductAnnotation specifies the name of the platform this Profile
// or TailoredProfile is targetting. Example: ocp4, rhcos4, ...
const ProductAnnotation = "compliance.openshift.io/product"

// ProfileRule defines the name of a specific rule in the profile
type ProfileRule string

// NewProfileRule returns a new ProfileRule from the given rule string
func NewProfileRule(rule string) ProfileRule {
	return ProfileRule(rule)
}

// ProfileValue defines a value for a setting in the profile
type ProfileValue string

type ProfilePayload struct {
	Title       string `json:"title"`
	Description string `json:"description"`
	ID          string `json:"id"`
	// +nullable
	// +optional
	// +listType=atomic
	Rules []ProfileRule `json:"rules,omitempty"`
	// +nullable
	// +optional
	// +listType=atomic
	Values []ProfileValue `json:"values,omitempty"`
}

// +k8s:deepcopy-gen:interfaces=k8s.io/apimachinery/pkg/runtime.Object

// Profile is the Schema for the profiles API
// +kubebuilder:resource:path=profiles,scope=Namespaced
type Profile struct {
	metav1.TypeMeta   `json:",inline"`
	metav1.ObjectMeta `json:"metadata,omitempty"`

	ProfilePayload `json:",inline"`
}

// +k8s:deepcopy-gen:interfaces=k8s.io/apimachinery/pkg/runtime.Object

// ProfileList contains a list of Profile
type ProfileList struct {
	metav1.TypeMeta `json:",inline"`
	metav1.ListMeta `json:"metadata,omitempty"`
	Items           []Profile `json:"items"`
}

func init() {
	SchemeBuilder.Register(&Profile{}, &ProfileList{})
}
