package v1alpha1

import (
	"errors"
	"fmt"
	"strconv"

	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
)

// +kubebuilder:validation:Enum=number;bool;string
type VariableType string

const (
	VarTypeNumber = "number"
	VarTypeBool   = "bool"
	VarTypeString = "string"
)

type ValueSelection struct {
	// The string description of the selection
	Description string `json:"description,omitempty"`
	// The value of the variable
	Value string `json:"value,omitempty"`
}

type VariablePayload struct {
	// FIXME: several values are shared with Rule object, maybe create a shared
	// struct? The shared values are documented in table 5 of the XCCDF spec
	// The XCCDF ID

	// the ID of the variable
	ID string `json:"id"`
	// The title of the Variable
	Title string `json:"title"`
	// The description of the Variable
	Description string `json:"description,omitempty"`
	// The type of the variable
	Type VariableType `json:"type"`
	// The value of the variable
	Value string `json:"value,omitempty"`
	// Enumerates what values are allowed for this variable. Can be empty.
	// +optional
	// +nullable
	// +listType=atomic
	Selections []ValueSelection `json:"selections,omitempty"`
}

// +k8s:deepcopy-gen:interfaces=k8s.io/apimachinery/pkg/runtime.Object

// Variable describes a tunable in the XCCDF profile
// +kubebuilder:resource:path=variables,scope=Namespaced
type Variable struct {
	metav1.TypeMeta   `json:",inline"`
	metav1.ObjectMeta `json:"metadata,omitempty"`

	VariablePayload `json:",inline"`
}

func (v *Variable) SetValue(val string) error {
	if err := v.validateType(val); err != nil {
		return err
	}

	if err := v.validateValue(val); err != nil {
		return err
	}

	v.Value = val
	return nil
}

func (v *Variable) validateType(val string) error {
	var err error
	switch v.Type {
	case VarTypeNumber:
		_, err = strconv.Atoi(val)
		return err
	case VarTypeBool:
		_, err = strconv.ParseBool(val)
		return err
	case VarTypeString:
		if len(val) == 0 {
			err = errors.New("value can't be empty")
		}
		break
	}

	return err
}

func (v *Variable) validateValue(val string) error {
	if len(v.Selections) == 0 {
		return nil
	}

	for _, av := range v.Selections {
		if av.Value == val {
			return nil
		}
	}

	return fmt.Errorf("value %s is not allowed, use one of %v", val, v.Selections)
}

// +k8s:deepcopy-gen:interfaces=k8s.io/apimachinery/pkg/runtime.Object

// VariableList contains a list of Variable
type VariableList struct {
	metav1.TypeMeta `json:",inline"`
	metav1.ListMeta `json:"metadata,omitempty"`
	Items           []Variable `json:"items"`
}

func init() {
	SchemeBuilder.Register(&Variable{}, &VariableList{})
}
