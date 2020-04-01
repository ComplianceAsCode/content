package ocp4e2e

import (
	"bufio"
	goctx "context"
	"flag"
	"fmt"
	"io"
	"os"
	"path"
	"testing"
	"time"

	backoff "github.com/cenkalti/backoff/v3"
	cmpapis "github.com/openshift/compliance-operator/pkg/apis"
	cmpv1alpha1 "github.com/openshift/compliance-operator/pkg/apis/compliance/v1alpha1"
	mcfg "github.com/openshift/machine-config-operator/pkg/apis/machineconfiguration.openshift.io"
	appsv1 "k8s.io/api/apps/v1"
	extscheme "k8s.io/apiextensions-apiserver/pkg/client/clientset/clientset/scheme"
	apierrors "k8s.io/apimachinery/pkg/api/errors"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/apimachinery/pkg/apis/meta/v1/unstructured"
	"k8s.io/apimachinery/pkg/runtime"
	"k8s.io/apimachinery/pkg/types"
	k8syaml "k8s.io/apimachinery/pkg/util/yaml"
	cached "k8s.io/client-go/discovery/cached"
	"k8s.io/client-go/kubernetes"
	cgoscheme "k8s.io/client-go/kubernetes/scheme"
	"k8s.io/client-go/restmapper"
	dynclient "sigs.k8s.io/controller-runtime/pkg/client"
	"sigs.k8s.io/controller-runtime/pkg/client/config"
)

const (
	namespacePath           = "compliance-operator-ns.yaml"
	operatorSourcePath      = "compliance-operator-source.yaml"
	catalogSourceConfigPath = "compliance-operator-csc.yaml"
	operatorGroupPath       = "compliance-operator-operator-group.yaml"
	subscriptionPath        = "compliance-operator-alpha-subscription.yaml"
	apiPollInterval         = 5 * time.Second
)

var profile string
var contentImage string
var installOperator bool

type e2econtext struct {
	// These are public because they're needed in the template
	Profile                string
	ContentImage           string
	OperatorNamespacedName types.NamespacedName
	// These are only needed for the test and will only be used in this package
	rootdir         string
	profilepath     string
	resourcespath   string
	installOperator bool
	dynclient       dynclient.Client
	restMapper      *restmapper.DeferredDiscoveryRESTMapper
	t               *testing.T
}

func init() {
	flag.StringVar(&profile, "profile", "", "The profile to check")
	flag.StringVar(&contentImage, "content-image", "", "The path to the image with the content to test")
	flag.BoolVar(&installOperator, "install-operator", true, "Should the test-code install the operator or not? "+
		"This is useful if you need to test with your own deployment of the operator")
}

func newE2EContext(t *testing.T) *e2econtext {
	rootdir := os.Getenv("ROOT_DIR")
	if rootdir == "" {
		rootdir = "../../"
	}

	profilefile := fmt.Sprintf("%s.profile", profile)
	profilepath := path.Join(rootdir, "ocp4", "profiles", profilefile)
	resourcespath := path.Join(rootdir, "ocp-resources")

	return &e2econtext{
		Profile:                profile,
		ContentImage:           contentImage,
		OperatorNamespacedName: types.NamespacedName{Name: "compliance-operator"},
		rootdir:                rootdir,
		profilepath:            profilepath,
		resourcespath:          resourcespath,
		installOperator:        installOperator,
		t:                      t,
	}
}

func (ctx *e2econtext) assertRootdir() {
	dirinfo, err := os.Stat(ctx.rootdir)
	if os.IsNotExist(err) {
		ctx.t.Fatal("$ROOT_DIR points to an unexistent directory")
	}
	if err != nil {
		ctx.t.Fatal(err)
	}
	if !dirinfo.IsDir() {
		ctx.t.Fatal("$ROOT_DIR must be a directory")
	}
}

func (ctx *e2econtext) assertProfile() {
	if ctx.Profile == "" {
		ctx.t.Fatal("a profile must be given with the `-profile` flag")
	}
	_, err := os.Stat(ctx.profilepath)
	if os.IsNotExist(err) {
		ctx.t.Fatalf("The profile path %s points to an unexistent file", ctx.profilepath)
	}
	if err != nil {
		ctx.t.Fatal(err)
	}
}

func (ctx *e2econtext) assertContentImage() {
	if ctx.ContentImage == "" {
		ctx.t.Fatal("A content image must be provided with the `-content-image` flag")
	}
}

func (ctx *e2econtext) assertKubeClient() {
	// Get a config to talk to the apiserver
	cfg, err := config.GetConfig()
	if err != nil {
		ctx.t.Fatal(err)
	}

	// create the kubeclient (temporarily)
	kubeclient, err := kubernetes.NewForConfig(cfg)
	if err != nil {
		ctx.t.Fatal(err.Error())
	}

	// create dynamic client
	scheme := runtime.NewScheme()
	if err := cgoscheme.AddToScheme(scheme); err != nil {
		ctx.t.Fatalf("failed to add cgo scheme to runtime scheme: %s", err)
	}
	if err := extscheme.AddToScheme(scheme); err != nil {
		ctx.t.Fatalf("failed to add api extensions scheme to runtime scheme: %s", err)
	}
	if err := cmpapis.AddToScheme(scheme); err != nil {
		ctx.t.Fatalf("failed to add cmpliance scheme to runtime scheme: %s", err)
	}
	if err := mcfg.Install(scheme); err != nil {
		ctx.t.Fatalf("failed to add cmpliance scheme to runtime scheme: %s", err)
	}

	cachedDiscoveryClient := cached.NewMemCacheClient(kubeclient.Discovery())
	ctx.restMapper = restmapper.NewDeferredDiscoveryRESTMapper(cachedDiscoveryClient)
	ctx.restMapper.Reset()

	ctx.dynclient, err = dynclient.New(cfg, dynclient.Options{Scheme: scheme, Mapper: ctx.restMapper})
	if err != nil {
		ctx.t.Fatalf("failed to build the dynamic client: %s", err)
	}
}

func (ctx *e2econtext) resetClientMappings() {
	ctx.restMapper.Reset()
}

// Makes sure that the namespace where the test will run exists. Doesn't fail
// if it already does.
func (ctx *e2econtext) ensureNamespaceExistsAndSet() {
	path := path.Join(ctx.resourcespath, namespacePath)
	obj := ctx.ensureObjectExists(path)
	// Ensures that we don't depend on a specific namespace in the code,
	// but we can instead change the namespace depending on the resource
	// file
	ctx.OperatorNamespacedName.Namespace = obj.GetName()
}

func (ctx *e2econtext) ensureOperatorSourceExists() {
	path := path.Join(ctx.resourcespath, operatorSourcePath)
	ctx.ensureObjectExists(path)
}

func (ctx *e2econtext) ensureCatalogSourceConfigExists() {
	path := path.Join(ctx.resourcespath, catalogSourceConfigPath)
	ctx.ensureObjectExists(path)
}

func (ctx *e2econtext) ensureOperatorGroupExists() {
	path := path.Join(ctx.resourcespath, operatorGroupPath)
	ctx.ensureObjectExists(path)
}

func (ctx *e2econtext) ensureSubscriptionExists() {
	path := path.Join(ctx.resourcespath, subscriptionPath)
	ctx.ensureObjectExists(path)
}

// Makes sure that an object from the given file path exists in the cluster.
// If this already exists, this is not an issue.
// Note that this assumes that the object's manifest already contains
// the Namespace reference.
// If all went well, this will return the reference to the object that was created.
func (ctx *e2econtext) ensureObjectExists(path string) *unstructured.Unstructured {
	obj, err := readObjFromYAMLFilePath(path)

	if err != nil {
		ctx.t.Fatalf("failed to decode object from '%s' spec: %s", path, err)
	}

	err = ctx.dynclient.Create(goctx.TODO(), obj)
	if err != nil && !apierrors.IsAlreadyExists(err) {
		ctx.t.Fatalf("failed to create object from '%s': %s", path, err)
	}

	return obj
}

func (ctx *e2econtext) waitForOperatorToBeReady() {
	bo := backoff.WithMaxRetries(backoff.NewConstantBackOff(apiPollInterval), 30)

	retryFunc := func() error {
		od := &appsv1.Deployment{}
		err := ctx.dynclient.Get(goctx.TODO(), ctx.OperatorNamespacedName, od)
		if err != nil {
			return err
		}
		if len(od.Status.Conditions) == 0 {
			return fmt.Errorf("No conditions for deployment yet")
		}
		if od.Status.Conditions[0].Type != appsv1.DeploymentAvailable {
			return fmt.Errorf("The deployment is not ready yet")
		}
		return nil
	}

	notifyFunc := func(err error, d time.Duration) {
		// TODO(jaosorior): Change this for a log call
		fmt.Printf("Operator deployment not ready after %s: %s\n", d.String(), err)
	}

	err := backoff.RetryNotify(retryFunc, bo, notifyFunc)
	if err != nil {
		ctx.t.Fatalf("Operator deployment was never created: %s", err)
	}
}

func (ctx *e2econtext) createComplianceSuiteForProfile(suffix string) *cmpv1alpha1.ComplianceSuite {
	suite := &cmpv1alpha1.ComplianceSuite{
		ObjectMeta: metav1.ObjectMeta{
			Name:      ctx.Profile + "-suite-" + suffix,
			Namespace: ctx.OperatorNamespacedName.Namespace,
		},
		Spec: cmpv1alpha1.ComplianceSuiteSpec{
			AutoApplyRemediations: false,
			Scans: []cmpv1alpha1.ComplianceScanSpecWrapper{
				{
					Name: ctx.Profile + "-master-scan-" + suffix,
					ComplianceScanSpec: cmpv1alpha1.ComplianceScanSpec{
						ContentImage: ctx.ContentImage,
						Profile:      "xccdf_org.ssgproject.content_profile_" + ctx.Profile,
						Content:      "ssg-ocp4-ds.xml",
						NodeSelector: map[string]string{
							"node-role.kubernetes.io/master": "",
						},
					},
				},
				{
					Name: ctx.Profile + "-worker-scan-" + suffix,
					ComplianceScanSpec: cmpv1alpha1.ComplianceScanSpec{
						ContentImage: ctx.ContentImage,
						Profile:      "xccdf_org.ssgproject.content_profile_" + ctx.Profile,
						Content:      "ssg-ocp4-ds.xml",
						NodeSelector: map[string]string{
							"node-role.kubernetes.io/worker": "",
						},
					},
				},
			},
		},
	}

	bo := backoff.WithMaxRetries(backoff.NewConstantBackOff(apiPollInterval), 180)
	err := backoff.RetryNotify(func() error {
		return ctx.dynclient.Create(goctx.TODO(), suite)
	}, bo, func(err error, d time.Duration) {
		fmt.Printf("Couldn't create compliance suite after %s: %s\n", d.String(), err)
	})
	if err != nil {
		ctx.t.Fatalf("failed to create compliance-suite: %s", err)
	}
	return suite
}

func (ctx *e2econtext) waitForComplianceSuite(suite *cmpv1alpha1.ComplianceSuite) {
	key := types.NamespacedName{Name: suite.Name, Namespace: suite.Namespace}
	// aprox. 15 min
	bo := backoff.WithMaxRetries(backoff.NewConstantBackOff(apiPollInterval), 180)

	err := backoff.Retry(func() error {
		err := ctx.dynclient.Get(goctx.TODO(), key, suite)
		if err != nil {
			// Returning an error merely makes this retry after the interval
			return err
		}
		if len(suite.Status.ScanStatuses) == 0 {
			return fmt.Errorf("No statuses available yet")
		}
		for _, scanstatus := range suite.Status.ScanStatuses {
			if scanstatus.Phase != cmpv1alpha1.PhaseDone {
				// Returning an error merely makes this retry after the interval
				return fmt.Errorf("Still waiting for the scans to be done")
			}
			if scanstatus.Result == cmpv1alpha1.ResultError {
				// If there was an error, we can stop already.
				ctx.t.Fatalf("There was an unexpected error in the scan '%s': %s",
					scanstatus.Name, scanstatus.ErrorMessage)
			}
		}
		return nil
	}, bo)
	if err != nil {
		ctx.t.Fatalf("The Compliance Suite '%s' didn't get to DONE phase: %s", key.Name, err)
	}
}

// Reads a YAML file and returns an unstructured object from it. This object
// can be taken into use by the dynamic client
func readObjFromYAMLFilePath(path string) (*unstructured.Unstructured, error) {
	nsyamlfile, err := os.Open(path)
	if err != nil {
		return nil, err
	}
	defer nsyamlfile.Close()

	return readObjFromYAML(bufio.NewReader(nsyamlfile))
}

// Reads a YAML file and returns an unstructured object from it. This object
// can be taken into use by the dynamic client
func readObjFromYAML(r io.Reader) (*unstructured.Unstructured, error) {
	obj := &unstructured.Unstructured{}
	dec := k8syaml.NewYAMLToJSONDecoder(r)
	err := dec.Decode(obj)
	return obj, err
}
