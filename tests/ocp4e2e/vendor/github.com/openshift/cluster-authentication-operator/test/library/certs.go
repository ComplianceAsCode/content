package library

import (
	"context"
	"crypto/rand"
	"crypto/rsa"
	"crypto/x509"
	"crypto/x509/pkix"
	"fmt"
	"math"
	"math/big"
	"testing"
	"time"

	"github.com/stretchr/testify/require"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	corev1client "k8s.io/client-go/kubernetes/typed/core/v1"
)

type CryptoMaterials struct {
	PrivateKey  *rsa.PrivateKey
	Certificate *x509.Certificate
}

// NewServerCertificate returns crypto materials suitable for use by a server. The hosts specified will be added as
// subject alternate names.
func NewServerCertificate(t *testing.T, signer *CryptoMaterials, hosts ...string) *CryptoMaterials {
	var err error
	server := &CryptoMaterials{}
	if server.PrivateKey, err = rsa.GenerateKey(rand.Reader, 2048); err != nil {
		panic(err)
	}
	var serialNumber *big.Int
	if serialNumber, err = rand.Int(rand.Reader, big.NewInt(math.MaxInt64)); err != nil {
		panic(err)
	}
	template := &x509.Certificate{
		Subject:               pkix.Name{CommonName: fmt.Sprintf("%vServer_%v", t.Name(), serialNumber)},
		NotBefore:             time.Now().AddDate(-1, 0, 0),
		NotAfter:              time.Now().AddDate(1, 0, 0),
		SignatureAlgorithm:    x509.SHA256WithRSA,
		SerialNumber:          serialNumber,
		KeyUsage:              x509.KeyUsageKeyEncipherment | x509.KeyUsageDigitalSignature,
		ExtKeyUsage:           []x509.ExtKeyUsage{x509.ExtKeyUsageServerAuth},
		BasicConstraintsValid: true,
		DNSNames:              hosts,
	}
	var certs []byte
	if certs, err = x509.CreateCertificate(rand.Reader, template, signer.Certificate, server.PrivateKey.Public(), signer.PrivateKey); err != nil {
		panic(err)
	}
	if server.Certificate, err = x509.ParseCertificate(certs); err != nil {
		panic(err)
	}
	return server
}

// NewCertificateAuthorityCertificate returns crypto materials for a certificate authority. If no parent certificate
// is specified, the generated certificate will be self-signed.
func NewCertificateAuthorityCertificate(t *testing.T, parent *CryptoMaterials) *CryptoMaterials {
	result := &CryptoMaterials{}
	var err error
	if result.PrivateKey, err = rsa.GenerateKey(rand.Reader, 2048); err != nil {
		panic(err)
	}
	var serialNumber *big.Int
	if serialNumber, err = rand.Int(rand.Reader, big.NewInt(math.MaxInt64)); err != nil {
		panic(err)
	}
	var subject string
	if parent == nil {
		subject = fmt.Sprintf("%vRootCA_%v", t.Name(), serialNumber)
	} else {
		subject = fmt.Sprintf("%vIntermediateCA_%v", t.Name(), serialNumber)
	}
	template := &x509.Certificate{
		Subject:               pkix.Name{CommonName: subject},
		NotBefore:             time.Now().AddDate(-1, 0, 0),
		NotAfter:              time.Now().AddDate(1, 0, 0),
		SignatureAlgorithm:    x509.SHA256WithRSA,
		SerialNumber:          serialNumber,
		KeyUsage:              x509.KeyUsageKeyEncipherment | x509.KeyUsageDigitalSignature | x509.KeyUsageCertSign,
		BasicConstraintsValid: true,
		IsCA:                  true,
	}
	signerCertificate := template
	signerPrivateKey := result.PrivateKey
	if parent != nil {
		signerCertificate = parent.Certificate
		signerPrivateKey = parent.PrivateKey
	}
	var der []byte
	if der, err = x509.CreateCertificate(rand.Reader, template, signerCertificate, result.PrivateKey.Public(), signerPrivateKey); err != nil {
		panic(err)
	}
	if result.Certificate, err = x509.ParseCertificate(der); err != nil {
		panic(err)
	}
	return result
}

// SyncDefaultIngressCAToConfig synchronizes the openshift-config-managed/default-ingress-cert
// to the openshift-config NS as a CA suited for an IdP configuration.
// Useful when deploying an IDP behind a reencrypt/edge-termination route.
// Returns a cleanup function for the CM.
func SyncDefaultIngressCAToConfig(t *testing.T, cmClient corev1client.ConfigMapsGetter, name string) func() {
	ca, err := cmClient.ConfigMaps("openshift-config-managed").Get(context.TODO(), "default-ingress-cert", metav1.GetOptions{})
	require.NoError(t, err)

	ca.ObjectMeta = metav1.ObjectMeta{Name: name, Labels: CAOE2ETestLabels()}
	ca.Data["ca.crt"] = ca.Data["ca-bundle.crt"] // IdP config requires "ca.crt" key for CA bundles
	_, err = cmClient.ConfigMaps("openshift-config").Create(context.TODO(), ca, metav1.CreateOptions{})
	require.NoError(t, err)

	return func() {
		if err := cmClient.ConfigMaps("openshift-config").Delete(context.TODO(), name, metav1.DeleteOptions{}); err != nil {
			t.Logf("cleanup failed for config map 'openshift-config/%s'", name)
		}
	}
}
