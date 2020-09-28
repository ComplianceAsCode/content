package ocp4e2e

import (
	"bufio"
	goctx "context"
	"flag"
	"fmt"
	"io"
	"io/ioutil"
	"os"
	"path"
	"strings"
	"testing"
	"time"

	backoff "github.com/cenkalti/backoff/v3"
	cmpapis "github.com/openshift/compliance-operator/pkg/apis"
	cmpv1alpha1 "github.com/openshift/compliance-operator/pkg/apis/compliance/v1alpha1"
	mcfg "github.com/openshift/machine-config-operator/pkg/apis/machineconfiguration.openshift.io"
	mcfgv1 "github.com/openshift/machine-config-operator/pkg/apis/machineconfiguration.openshift.io/v1"
	mcfgconst "github.com/openshift/machine-config-operator/pkg/daemon/constants"
	"gopkg.in/yaml.v2"
	appsv1 "k8s.io/api/apps/v1"
	corev1 "k8s.io/api/core/v1"
	extscheme "k8s.io/apiextensions-apiserver/pkg/client/clientset/clientset/scheme"
	apierrors "k8s.io/apimachinery/pkg/api/errors"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/apimachinery/pkg/apis/meta/v1/unstructured"
	"k8s.io/apimachinery/pkg/labels"
	"k8s.io/apimachinery/pkg/runtime"
	"k8s.io/apimachinery/pkg/types"
	"k8s.io/apimachinery/pkg/util/wait"
	k8syaml "k8s.io/apimachinery/pkg/util/yaml"
	cached "k8s.io/client-go/discovery/cached"
	"k8s.io/client-go/kubernetes"
	cgoscheme "k8s.io/client-go/kubernetes/scheme"
	"k8s.io/client-go/restmapper"
	"sigs.k8s.io/controller-runtime/pkg/client"
	dynclient "sigs.k8s.io/controller-runtime/pkg/client"
	"sigs.k8s.io/controller-runtime/pkg/client/config"
)

const (
	namespacePath     = "compliance-operator-ns.yaml"
	catalogSourcePath = "compliance-operator-catalog-source.yaml"
	operatorGroupPath = "compliance-operator-operator-group.yaml"
	subscriptionPath  = "compliance-operator-alpha-subscription.yaml"
	apiPollInterval   = 5 * time.Second
)

var product string
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
	product         string
	resourcespath   string
	scanType        cmpv1alpha1.ComplianceScanType
	installOperator bool
	dynclient       dynclient.Client
	restMapper      *restmapper.DeferredDiscoveryRESTMapper
	t               *testing.T
}

func init() {
	flag.StringVar(&profile, "profile", "", "The profile to check")
	flag.StringVar(&product, "product", "", "The product this profile is for - e.g. 'rhcos4', 'ocp4'")
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
	profilepath := path.Join(rootdir, product, "profiles", profilefile)
	resourcespath := path.Join(rootdir, "ocp-resources")

	return &e2econtext{
		Profile:                profile,
		ContentImage:           contentImage,
		OperatorNamespacedName: types.NamespacedName{Name: "compliance-operator"},
		rootdir:                rootdir,
		profilepath:            profilepath,
		resourcespath:          resourcespath,
		product:                product,
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
		ctx.t.Fatalf("failed to add MachineConfig scheme to runtime scheme: %s", err)
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

func (ctx *e2econtext) assertScanType() {
	scanType, err := ctx.getScanType()
	if err != nil {
		ctx.t.Fatalf("Couldn't get scan type: %s", err)
	}
	ctx.scanType = scanType
}

func (ctx *e2econtext) getScanType() (cmpv1alpha1.ComplianceScanType, error) {
	profileInfo := &struct {
		BenchmarkRoot string `yaml:"benchmark_root"`
	}{}

	file, err := ioutil.ReadFile(path.Join(ctx.rootdir, ctx.product, "product.yml"))

	if err != nil {
		return "", fmt.Errorf("Can't open product definition: %s", err)
	}

	err = yaml.Unmarshal(file, profileInfo)

	if err != nil {
		return "", fmt.Errorf("Can't read product definition: %s", err)
	}

	if strings.HasSuffix(profileInfo.BenchmarkRoot, "applications") {
		return cmpv1alpha1.ScanTypePlatform, nil
	}

	if strings.HasSuffix(profileInfo.BenchmarkRoot, "linux_os/guide") {
		return cmpv1alpha1.ScanTypeNode, nil
	}

	return "", fmt.Errorf("Unkown platform type. It has to be either `linux_os/type` or `application`")
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

func (ctx *e2econtext) ensureCatalogSourceExists() {
	path := path.Join(ctx.resourcespath, catalogSourcePath)
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

func (ctx *e2econtext) createComplianceSuiteForProfile(suffix string, autoApply bool) *cmpv1alpha1.ComplianceSuite {
	suite := &cmpv1alpha1.ComplianceSuite{
		ObjectMeta: metav1.ObjectMeta{
			Name:      ctx.Profile + "-suite-" + suffix,
			Namespace: ctx.OperatorNamespacedName.Namespace,
		},
		Spec: cmpv1alpha1.ComplianceSuiteSpec{
			ComplianceSuiteSettings: cmpv1alpha1.ComplianceSuiteSettings{
				AutoApplyRemediations: autoApply,
			},
			Scans: ctx.getScansForSuite(suffix),
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

func (ctx *e2econtext) getScansForSuite(suffix string) []cmpv1alpha1.ComplianceScanSpecWrapper {
	switch ctx.scanType {
	case cmpv1alpha1.ScanTypePlatform:
		return []cmpv1alpha1.ComplianceScanSpecWrapper{
			{
				Name: ctx.Profile + "-platform-scan-" + suffix,
				ComplianceScanSpec: cmpv1alpha1.ComplianceScanSpec{
					ScanType:     cmpv1alpha1.ScanTypePlatform,
					ContentImage: ctx.ContentImage,
					Profile:      "xccdf_org.ssgproject.content_profile_" + ctx.Profile,
					Content:      fmt.Sprintf("ssg-%s-ds.xml", ctx.product),
					ComplianceScanSettings: cmpv1alpha1.ComplianceScanSettings{
						Debug: true,
					},
				},
			},
		}
	case cmpv1alpha1.ScanTypeNode:
		return []cmpv1alpha1.ComplianceScanSpecWrapper{
			{
				Name: ctx.Profile + "-master-scan-" + suffix,
				ComplianceScanSpec: cmpv1alpha1.ComplianceScanSpec{
					ContentImage: ctx.ContentImage,
					Profile:      "xccdf_org.ssgproject.content_profile_" + ctx.Profile,
					Content:      fmt.Sprintf("ssg-%s-ds.xml", ctx.product),
					NodeSelector: map[string]string{
						"node-role.kubernetes.io/master": "",
					},
					ComplianceScanSettings: cmpv1alpha1.ComplianceScanSettings{
						Debug: true,
					},
				},
			},
			{
				Name: ctx.Profile + "-worker-scan-" + suffix,
				ComplianceScanSpec: cmpv1alpha1.ComplianceScanSpec{
					ContentImage: ctx.ContentImage,
					Profile:      "xccdf_org.ssgproject.content_profile_" + ctx.Profile,
					Content:      fmt.Sprintf("ssg-%s-ds.xml", ctx.product),
					NodeSelector: map[string]string{
						"node-role.kubernetes.io/worker": "",
					},
					ComplianceScanSettings: cmpv1alpha1.ComplianceScanSettings{
						Debug: true,
					},
				},
			},
		}
	}

	// We shouldn't get here.
	return nil
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

func (ctx *e2econtext) waitForMachinePoolUpdate(name string) error {
	mcKey := types.NamespacedName{Name: name}

	var lastErr error
	err := wait.PollImmediate(10*time.Second, 20*time.Minute, func() (bool, error) {
		pool := &mcfgv1.MachineConfigPool{}
		lastErr = ctx.dynclient.Get(goctx.TODO(), mcKey, pool)
		if lastErr != nil {
			ctx.t.Errorf("Could not get the pool %s post update", name)
			return false, nil
		}

		// Check if the pool has finished updating yet.
		if (pool.Status.UpdatedMachineCount == pool.Status.MachineCount) &&
			(pool.Status.UnavailableMachineCount == 0) {
			ctx.t.Logf("The pool %s has updated", name)
			return true, nil
		}

		ctx.t.Logf("The pool %s has not updated yet. updated %d/%d unavailable %d",
			name,
			pool.Status.UpdatedMachineCount, pool.Status.MachineCount,
			pool.Status.UnavailableMachineCount)
		return false, nil
	})

	// timeout error
	if err != nil {
		return err
	}

	// An actual error at the end of the run
	if lastErr != nil {
		return lastErr
	}

	return nil
}

func (ctx *e2econtext) getRemediationsForSuite(s *cmpv1alpha1.ComplianceSuite, display bool) int {
	remList := &cmpv1alpha1.ComplianceRemediationList{}
	labelSelector, _ := labels.Parse(cmpv1alpha1.SuiteLabel + "=" + s.Name)
	opts := &client.ListOptions{
		LabelSelector: labelSelector,
	}
	err := ctx.dynclient.List(goctx.TODO(), remList, opts)
	if err != nil {
		ctx.t.Fatalf("Couldn't get remediation list")
	}
	if display {
		if len(remList.Items) > 0 {
			ctx.t.Logf("Remediations from ComplianceSuite: %s", s.Name)
		}
		for _, rem := range remList.Items {
			ctx.t.Logf("- %s", rem.Name)
		}
	}
	return len(remList.Items)
}

func (ctx *e2econtext) getFailuresForSuite(s *cmpv1alpha1.ComplianceSuite, display bool) int {
	failList := &cmpv1alpha1.ComplianceCheckResultList{}
	matchLabels := dynclient.MatchingLabels{
		cmpv1alpha1.SuiteLabel:                               s.Name,
		string(cmpv1alpha1.ComplianceCheckResultStatusLabel): string(cmpv1alpha1.CheckResultFail),
	}
	err := ctx.dynclient.List(goctx.TODO(), failList, matchLabels)
	if err != nil {
		ctx.t.Fatalf("Couldn't get check result list")
	}
	if display {
		if len(failList.Items) > 0 {
			ctx.t.Logf("Failures from ComplianceSuite: %s", s.Name)
		}
		for _, rem := range failList.Items {
			ctx.t.Logf("- %s", rem.Name)
		}
	}
	return len(failList.Items)
}

// This returns the number of results that are either CheckResultError or CheckResultNoResult
func (ctx *e2econtext) getInvalidResultsFromSuite(s *cmpv1alpha1.ComplianceSuite, display bool) int {
	ret := 0
	errList := &cmpv1alpha1.ComplianceCheckResultList{}
	matchLabels := dynclient.MatchingLabels{
		cmpv1alpha1.SuiteLabel:                               s.Name,
		string(cmpv1alpha1.ComplianceCheckResultStatusLabel): string(cmpv1alpha1.CheckResultError),
	}
	err := ctx.dynclient.List(goctx.TODO(), errList, matchLabels)
	if err != nil {
		ctx.t.Fatalf("Couldn't get result list")
	}
	if display {
		if len(errList.Items) > 0 {
			ctx.t.Logf("Errors from ComplianceSuite: %s", s.Name)
		}
		for _, check := range errList.Items {
			ctx.t.Logf("unexpected Error result - %s", check.Name)
		}
	}
	ret = len(errList.Items)

	noneList := &cmpv1alpha1.ComplianceCheckResultList{}
	matchLabels = dynclient.MatchingLabels{
		cmpv1alpha1.SuiteLabel:                               s.Name,
		string(cmpv1alpha1.ComplianceCheckResultStatusLabel): string(cmpv1alpha1.CheckResultNoResult),
	}
	err = ctx.dynclient.List(goctx.TODO(), noneList, matchLabels)
	if err != nil {
		ctx.t.Fatalf("Couldn't get result list")
	}
	if display {
		if len(noneList.Items) > 0 {
			ctx.t.Logf("None result from ComplianceSuite: %s", s.Name)
		}
		for _, check := range noneList.Items {
			ctx.t.Logf("unexpected None result - %s", check.Name)
		}
	}

	return ret + len(noneList.Items)
}

func (ctx *e2econtext) getCheckResultsForSuite(s *cmpv1alpha1.ComplianceSuite) int {
	failList := &cmpv1alpha1.ComplianceCheckResultList{}
	matchLabels := dynclient.MatchingLabels{
		cmpv1alpha1.SuiteLabel: s.Name,
	}
	err := ctx.dynclient.List(goctx.TODO(), failList, matchLabels)
	if err != nil {
		ctx.t.Fatalf("Couldn't get remediation list")
	}
	return len(failList.Items)
}

func isNodeReady(node corev1.Node) bool {
	if node.Spec.Unschedulable {
		return false
	}
	for _, condition := range node.Status.Conditions {
		if condition.Type == corev1.NodeReady &&
			condition.Status == corev1.ConditionTrue &&
			node.Annotations[mcfgconst.MachineConfigDaemonStateAnnotationKey] == mcfgconst.MachineConfigDaemonStateDone {
			return true
		}
	}
	return false
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
