package v1alpha1

import (
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
)

type NamedObjectReference struct {
	Name     string `json:"name,omitempty"`
	Kind     string `json:"kind,omitempty"`
	APIGroup string `json:"apiGroup,omitempty"`
}

// +k8s:deepcopy-gen:interfaces=k8s.io/apimachinery/pkg/runtime.Object

// ScanSettingBinding is the Schema for the scansettingbindings API
// +kubebuilder:resource:path=scansettingbindings,scope=Namespaced
type ScanSettingBinding struct {
	metav1.TypeMeta   `json:",inline"`
	metav1.ObjectMeta `json:"metadata,omitempty"`

	Profiles    []NamedObjectReference `json:"profiles,omitempty"`
	SettingsRef *NamedObjectReference  `json:"settingsRef,omitempty"`
}

// +k8s:deepcopy-gen:interfaces=k8s.io/apimachinery/pkg/runtime.Object

// ScanSettingBindingList contains a list of ScanSettingBinding
type ScanSettingBindingList struct {
	metav1.TypeMeta `json:",inline"`
	metav1.ListMeta `json:"metadata,omitempty"`
	Items           []ScanSettingBinding `json:"items"`
}

func init() {
	SchemeBuilder.Register(&ScanSettingBinding{}, &ScanSettingBindingList{})
}
