package library

import (
	"fmt"
	"testing"

	"github.com/stretchr/testify/require"
	"k8s.io/client-go/rest"
	"k8s.io/client-go/tools/clientcmd"
	"k8s.io/client-go/tools/clientcmd/api"
)

// NewClientConfigForTest returns a config configured to connect to the api server
func NewClientConfigForTest(t *testing.T) *rest.Config {
	loader := clientcmd.NewDefaultClientConfigLoadingRules()
	clientConfig := clientcmd.NewNonInteractiveDeferredLoadingClientConfig(loader, &clientcmd.ConfigOverrides{ClusterInfo: api.Cluster{InsecureSkipTLSVerify: true}})
	config, err := clientConfig.ClientConfig()
	if err == nil {
		fmt.Printf("Found configuration for host %v.\n", config.Host)
	}

	require.NoError(t, err)
	return config
}
