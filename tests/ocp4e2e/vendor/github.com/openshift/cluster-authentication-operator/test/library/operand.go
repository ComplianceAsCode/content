package library

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"

	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	corev1client "k8s.io/client-go/kubernetes/typed/core/v1"

	osinv1 "github.com/openshift/api/osin/v1"
)

// GrabOAuthServerConfig grabs the oauth-server configuration from the
// openshift-authenticat/v4-0-config-system-cliconfig configmap
func GrabOAuthServerConfig(cmClient corev1client.ConfigMapsGetter) (*osinv1.OsinServerConfig, error) {
	config, err := cmClient.ConfigMaps("openshift-authentication").Get(context.TODO(), "v4-0-config-system-cliconfig", metav1.GetOptions{})
	if err != nil {
		return nil, err
	}

	rawConfig := config.Data["v4-0-config-system-cliconfig"]

	configObj := &osinv1.OsinServerConfig{}
	if err := json.NewDecoder(bytes.NewBuffer([]byte(rawConfig))).Decode(configObj); err != nil {
		return nil, fmt.Errorf("failed to decode object: %v; raw object dump:\n%s", err, rawConfig)
	}

	return configObj, nil
}

// GetIDPByName returns a pointer to a copy of the identity provider of a name
// from the config.
func GetIDPByName(config *osinv1.OsinServerConfig, name string) *osinv1.IdentityProvider {
	for _, idp := range config.OAuthConfig.IdentityProviders {
		if idp.Name == name {
			return idp.DeepCopy()
		}
	}
	return nil
}
