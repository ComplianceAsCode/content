package ocp4e2e

import (
	"bufio"
	"context"
	goctx "context"
	"flag"
	"fmt"
	"io"
	"io/ioutil"
	"os"
	"os/exec"
	"path"
	"strings"
	"sync"
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
	"k8s.io/apimachinery/pkg/api/errors"
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
	namespacePath             = "compliance-operator-ns.yaml"
	catalogSourcePath         = "compliance-operator-catalog-source.yaml"
	operatorGroupPath         = "compliance-operator-operator-group.yaml"
	subscriptionPath          = "compliance-operator-alpha-subscription.yaml"
	apiPollInterval           = 5 * time.Second
	testProfilebundleName     = "e2e"
	autoApplySettingsName     = "auto-apply-debug"
	manualRemediationsTimeout = 20 * time.Minute
)

// RuleTest is the definition of the structure rule-specific e2e tests should have
type RuleTest struct {
	DefaultResult          interface{} `yaml:"default_result"`
	ResultAfterRemediation interface{} `yaml:"result_after_remediation,omitempty"`
}

var product string
var profile string
var contentImage string
var installOperator bool

var ruleTestDir string = path.Join("tests", "ocp4")
var ruleTestFilePath string = path.Join(ruleTestDir, "e2e.yml")
var ruleManualRemediationFilePath string = path.Join(ruleTestDir, "e2e-remediation.sh")

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
	benchmarkRoot   string
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
	productpath := path.Join(rootdir, product)
	benchmarkRoot, err := getBenchmarkRootFromProductSpec(productpath)
	if err != nil {
		t.Fatal(err)
	}
	profilepath := path.Join(productpath, "profiles", profilefile)
	resourcespath := path.Join(rootdir, "ocp-resources")

	return &e2econtext{
		Profile:                profile,
		ContentImage:           contentImage,
		OperatorNamespacedName: types.NamespacedName{Name: "compliance-operator"},
		rootdir:                rootdir,
		profilepath:            profilepath,
		resourcespath:          resourcespath,
		benchmarkRoot:          benchmarkRoot,
		product:                product,
		installOperator:        installOperator,
		t:                      t,
	}
}

func getBenchmarkRootFromProductSpec(productpath string) (string, error) {
	prodyamlpath := path.Join(productpath, "product.yml")
	benchmarkRelative := struct {
		Path string `yaml:"benchmark_root"`
	}{}
	buf, err := ioutil.ReadFile(prodyamlpath)
	if err != nil {
		return "", err
	}

	err = yaml.Unmarshal(buf, &benchmarkRelative)
	if err != nil {
		return "", fmt.Errorf("Couldn't parse file %q: %v", prodyamlpath, err)
	}
	return path.Join(productpath, benchmarkRelative.Path), nil
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

func (ctx *e2econtext) ensureTestProfileBundle() {
	key := types.NamespacedName{
		Name:      testProfilebundleName,
		Namespace: ctx.OperatorNamespacedName.Namespace,
	}
	pb := &cmpv1alpha1.ProfileBundle{
		ObjectMeta: metav1.ObjectMeta{
			Name:      testProfilebundleName,
			Namespace: ctx.OperatorNamespacedName.Namespace,
		},
		Spec: cmpv1alpha1.ProfileBundleSpec{
			ContentImage: ctx.ContentImage,
			ContentFile:  fmt.Sprintf("ssg-%s-ds.xml", ctx.product),
		},
	}

	bo := backoff.WithMaxRetries(backoff.NewConstantBackOff(apiPollInterval), 180)
	err := backoff.RetryNotify(func() error {
		found := &cmpv1alpha1.ProfileBundle{}
		if err := ctx.dynclient.Get(goctx.TODO(), key, found); err != nil {
			if errors.IsNotFound(err) {
				return ctx.dynclient.Create(goctx.TODO(), pb)
			}
			return err
		}
		// Update the spec in case it differs
		found.Spec = pb.Spec
		return ctx.dynclient.Update(goctx.TODO(), found)
	}, bo, func(err error, d time.Duration) {
		fmt.Printf("Couldn't ensure test PB exists after %s: %s\n", d.String(), err)
	})
	if err != nil {
		ctx.t.Fatalf("failed to ensure test PB: %s", err)
	}
}

func (ctx *e2econtext) ensureTestSettings() {
	defaultkey := types.NamespacedName{
		Name:      "default",
		Namespace: ctx.OperatorNamespacedName.Namespace,
	}
	defaultSettings := &cmpv1alpha1.ScanSetting{}

	bo := backoff.WithMaxRetries(backoff.NewConstantBackOff(apiPollInterval), 180)

	err := backoff.RetryNotify(func() error {
		return ctx.dynclient.Get(goctx.TODO(), defaultkey, defaultSettings)
	}, bo, func(err error, d time.Duration) {
		fmt.Printf("Couldn't get default scanSettings after %s: %s\n", d.String(), err)
	})
	if err != nil {
		ctx.t.Fatalf("failed to get default scanSettings: %s", err)
	}

	// Ensure auto-apply
	key := types.NamespacedName{
		Name:      autoApplySettingsName,
		Namespace: ctx.OperatorNamespacedName.Namespace,
	}
	autoApplySettings := defaultSettings.DeepCopy()
	// Delete Object Meta so we reset unwanted references
	autoApplySettings.ObjectMeta = metav1.ObjectMeta{
		Name:      autoApplySettingsName,
		Namespace: ctx.OperatorNamespacedName.Namespace,
	}
	autoApplySettings.AutoApplyRemediations = true
	autoApplySettings.Debug = true
	err = backoff.RetryNotify(func() error {
		found := &cmpv1alpha1.ScanSetting{}
		if err := ctx.dynclient.Get(goctx.TODO(), key, found); err != nil {
			if errors.IsNotFound(err) {
				return ctx.dynclient.Create(goctx.TODO(), autoApplySettings)
			}
			return err
		}
		// Copy references to enable updating object
		found.ObjectMeta.DeepCopyInto(&autoApplySettings.ObjectMeta)
		return ctx.dynclient.Update(goctx.TODO(), autoApplySettings)
	}, bo, func(err error, d time.Duration) {
		fmt.Printf("Couldn't ensure auto-apply scansettings after %s: %s\n", d.String(), err)
	})
	if err != nil {
		ctx.t.Fatalf("failed to ensure auto-apply scanSettings: %s", err)
	}
}

func (ctx *e2econtext) getPrefixedProfileName() string {
	return testProfilebundleName + "-" + ctx.Profile
}

func (ctx *e2econtext) createBindingForProfile() string {
	binding := &cmpv1alpha1.ScanSettingBinding{
		ObjectMeta: metav1.ObjectMeta{
			Name:      ctx.getPrefixedProfileName(),
			Namespace: ctx.OperatorNamespacedName.Namespace,
		},
		Profiles: []cmpv1alpha1.NamedObjectReference{
			{
				APIGroup: "compliance.openshift.io/v1alpha1",
				Kind:     "Profile",
				Name:     ctx.getPrefixedProfileName(),
			},
		},
		SettingsRef: &cmpv1alpha1.NamedObjectReference{
			APIGroup: "compliance.openshift.io/v1alpha1",
			Kind:     "ScanSetting",
			Name:     autoApplySettingsName,
		},
	}

	bo := backoff.WithMaxRetries(backoff.NewConstantBackOff(apiPollInterval), 180)
	err := backoff.RetryNotify(func() error {
		return ctx.dynclient.Create(goctx.TODO(), binding)
	}, bo, func(err error, d time.Duration) {
		fmt.Printf("Couldn't create binding after %s: %s\n", d.String(), err)
	})
	if err != nil {
		ctx.t.Fatalf("failed to create binding: %s", err)
	}
	return binding.Name
}

func (ctx *e2econtext) waitForComplianceSuite(suiteName string) {
	key := types.NamespacedName{Name: suiteName, Namespace: ctx.OperatorNamespacedName.Namespace}
	// aprox. 15 min
	bo := backoff.WithMaxRetries(backoff.NewConstantBackOff(apiPollInterval), 180)

	err := backoff.Retry(func() error {
		suite := &cmpv1alpha1.ComplianceSuite{}
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
			ctx.t.Logf("Could not get the pool %s post update. Retrying.", name)
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

func (ctx *e2econtext) doRescan(s string) {
	scanList := &cmpv1alpha1.ComplianceScanList{}
	labelSelector, _ := labels.Parse(cmpv1alpha1.SuiteLabel + "=" + s)
	opts := &client.ListOptions{
		LabelSelector: labelSelector,
	}
	err := ctx.dynclient.List(goctx.TODO(), scanList, opts)
	if err != nil {
		ctx.t.Fatalf("Couldn't get scan list")
	}
	if len(scanList.Items) == 0 {
		ctx.t.Fatal("This suite didn't contain scans")
	}
	for _, scan := range scanList.Items {
		updatedScan := scan.DeepCopy()
		annotations := updatedScan.GetAnnotations()
		if annotations == nil {
			annotations = map[string]string{}
		}
		annotations[cmpv1alpha1.ComplianceScanRescanAnnotation] = ""
		updatedScan.SetAnnotations(annotations)

		bo := backoff.WithMaxRetries(backoff.NewConstantBackOff(apiPollInterval), 180)
		err := backoff.RetryNotify(func() error {
			return ctx.dynclient.Update(goctx.TODO(), updatedScan)
		}, bo, func(err error, d time.Duration) {
			fmt.Printf("Couldn't rescan after %s: %s\n", d.String(), err)
		})
		if err != nil {
			ctx.t.Fatalf("failed rescan: %s", err)
		}
	}
	var lastErr error
	err = wait.PollImmediate(2*time.Second, 5*time.Minute, func() (bool, error) {
		suite := &cmpv1alpha1.ComplianceSuite{}
		key := types.NamespacedName{Name: s, Namespace: ctx.OperatorNamespacedName.Namespace}
		lastErr = ctx.dynclient.Get(goctx.TODO(), key, suite)
		if lastErr != nil {
			return false, nil
		}
		if suite.Status.Phase == cmpv1alpha1.PhaseDone {
			return false, nil
		}
		// The scan has been reset, we're good to go
		return true, nil
	})

	// timeout error
	if err != nil {
		ctx.t.Fatalf("Timed out waiting for scan to be reset: %s", err)
	}

	// An actual error at the end of the run
	if lastErr != nil {
		ctx.t.Fatalf("Error occured while waiting for scan to be reset: %s", lastErr)
	}
}

func (ctx *e2econtext) getRemediationsForSuite(s string) int {
	remList := &cmpv1alpha1.ComplianceRemediationList{}
	labelSelector, _ := labels.Parse(cmpv1alpha1.SuiteLabel + "=" + s)
	opts := &client.ListOptions{
		LabelSelector: labelSelector,
	}
	err := ctx.dynclient.List(goctx.TODO(), remList, opts)
	if err != nil {
		ctx.t.Fatalf("Couldn't get remediation list")
	}
	if len(remList.Items) > 0 {
		ctx.t.Logf("Remediations from ComplianceSuite: %s", s)
	} else {
		ctx.t.Log("This suite didn't generate remediations")
	}
	for _, rem := range remList.Items {
		ctx.t.Logf("- %s", rem.Name)
	}
	return len(remList.Items)
}

func (ctx *e2econtext) getFailuresForSuite(s string) int {
	failList := &cmpv1alpha1.ComplianceCheckResultList{}
	matchLabels := dynclient.MatchingLabels{
		cmpv1alpha1.SuiteLabel:                               s,
		string(cmpv1alpha1.ComplianceCheckResultStatusLabel): string(cmpv1alpha1.CheckResultFail),
	}
	err := ctx.dynclient.List(goctx.TODO(), failList, matchLabels)
	if err != nil {
		ctx.t.Fatalf("Couldn't get check result list")
	}
	if len(failList.Items) > 0 {
		ctx.t.Logf("Failures from ComplianceSuite: %s", s)
	}
	for _, rem := range failList.Items {
		ctx.t.Logf("- %s", rem.Name)
	}
	return len(failList.Items)
}

// This returns the number of results that are either CheckResultError or CheckResultNoResult
func (ctx *e2econtext) getInvalidResultsFromSuite(s string) int {
	ret := 0
	errList := &cmpv1alpha1.ComplianceCheckResultList{}
	matchLabels := dynclient.MatchingLabels{
		cmpv1alpha1.SuiteLabel:                               s,
		string(cmpv1alpha1.ComplianceCheckResultStatusLabel): string(cmpv1alpha1.CheckResultError),
	}
	err := ctx.dynclient.List(goctx.TODO(), errList, matchLabels)
	if err != nil {
		ctx.t.Fatalf("Couldn't get result list")
	}
	if len(errList.Items) > 0 {
		ctx.t.Logf("Errors from ComplianceSuite: %s", s)
	}
	for _, check := range errList.Items {
		ctx.t.Logf("unexpected Error result - %s", check.Name)
	}
	ret = len(errList.Items)

	noneList := &cmpv1alpha1.ComplianceCheckResultList{}
	matchLabels = dynclient.MatchingLabels{
		cmpv1alpha1.SuiteLabel:                               s,
		string(cmpv1alpha1.ComplianceCheckResultStatusLabel): string(cmpv1alpha1.CheckResultNoResult),
	}
	err = ctx.dynclient.List(goctx.TODO(), noneList, matchLabels)
	if err != nil {
		ctx.t.Fatalf("Couldn't get result list")
	}
	if len(noneList.Items) > 0 {
		ctx.t.Logf("None result from ComplianceSuite: %s", s)
	}
	for _, check := range noneList.Items {
		ctx.t.Logf("unexpected None result - %s", check.Name)
	}

	return ret + len(noneList.Items)
}

func (ctx *e2econtext) verifyCheckResultsForSuite(s string, afterRemediations bool) (int, []string) {
	manualRemediationSet := map[string]bool{}
	resList := &cmpv1alpha1.ComplianceCheckResultList{}
	matchLabels := dynclient.MatchingLabels{
		cmpv1alpha1.SuiteLabel: s,
	}
	err := ctx.dynclient.List(goctx.TODO(), resList, matchLabels)
	if err != nil {
		ctx.t.Fatalf("Couldn't get result list")
	}
	if len(resList.Items) > 0 {
		ctx.t.Logf("Results from ComplianceSuite: %s", s)
	} else {
		ctx.t.Logf("There were no results for the ComplianceSuite: %s", s)
	}
	for _, check := range resList.Items {
		ctx.t.Logf("Result - Name: %s - Status: %s - Severity: %s", check.Name, check.Status, check.Severity)
		manualRem, err := ctx.verifyRule(check, afterRemediations)
		if err != nil {
			ctx.t.Error(err)
		}
		if manualRem != "" {
			manualRemediationSet[manualRem] = true
		}
	}

	manualRemediations := []string{}
	for key := range manualRemediationSet {
		manualRemediations = append(manualRemediations, key)
	}

	return len(resList.Items), manualRemediations
}

func (ctx *e2econtext) verifyRule(result cmpv1alpha1.ComplianceCheckResult, afterRemediations bool) (string, error) {
	ruleName, err := ctx.getRuleFolderNameFromResult(result)
	if err != nil {
		return "", err
	}
	rulePathBytes, err := exec.Command("find", ctx.benchmarkRoot, "-name", ruleName).Output()
	if err != nil {
		return "", err
	}
	rulePath := strings.Trim(string(rulePathBytes), "\n")
	testFilePath := path.Join(rulePath, ruleTestFilePath)

	buf, err := ioutil.ReadFile(testFilePath)
	if err != nil {
		if os.IsNotExist(err) {
			// There's no test file, so no need to verify
			return "", nil
		}
		return "", err
	}

	test := RuleTest{}
	if err := yaml.Unmarshal(buf, &test); err != nil {
		return "", err
	}

	remPath := path.Join(rulePath, ruleManualRemediationFilePath)
	_, err = os.Stat(remPath)
	if os.IsNotExist(err) {
		// We reset the path to return in case there isn't a remediation
		remPath = ""
	}

	// Initial run
	if !afterRemediations {
		if err := verifyRuleResult(result, test.DefaultResult, test, ruleName); err != nil {
			return remPath, err
		}
	} else {
		// after remediations
		// If we expect a change after remediation is applied, let's test for it
		if test.ResultAfterRemediation != nil {
			if err := verifyRuleResult(result, test.ResultAfterRemediation, test, ruleName); err != nil {
				return remPath, err
			}
		} else {
			// Check that the default didn't change
			if err := verifyRuleResult(result, test.DefaultResult, test, ruleName); err != nil {
				return remPath, err
			}
		}
	}

	ctx.t.Logf("Rule %s matched expected result", ruleName)
	return remPath, nil
}

func verifyRuleResult(foundResult cmpv1alpha1.ComplianceCheckResult, expectedResult interface{}, testDef RuleTest, ruleName string) error {
	if matches, err := matchFoundResultToExpectation(foundResult, expectedResult); !matches || err != nil {
		if err != nil {
			return fmt.Errorf("E2E-ERROR: The e2e YAML for rule '%s' is malformed: %v . Got error: %v", ruleName, testDef, err)
		}
		return fmt.Errorf("E2E-FAILURE: The expected result for the %s rule didn't match. Expected '%s', Got '%s'",
			ruleName, expectedResult, foundResult.Status)
	}
	return nil
}

func matchFoundResultToExpectation(foundResult cmpv1alpha1.ComplianceCheckResult, expectedResult interface{}) (bool, error) {
	// Handle expected result for all roles
	if resultStr, ok := expectedResult.(string); ok {
		return strings.ToLower(string(foundResult.Status)) == strings.ToLower(resultStr), nil
	}
	// Handle role-specific result
	if resultMap, ok := expectedResult.(map[interface{}]interface{}); ok {
		for rawRole, rawRoleResult := range resultMap {
			role, ok := rawRole.(string)
			if !ok {
				return false, fmt.Errorf("Couldn't parse the result as string or map of strings")
			}
			roleResult, ok := rawRoleResult.(string)
			if !ok {
				return false, fmt.Errorf("Couldn't parse the result as string or map of strings")
			}
			// NOTE(jaosorior): Normally, the results will have a reference
			// to the role they apply to in the name. This is hacky...
			if strings.Contains(foundResult.GetLabels()[cmpv1alpha1.ComplianceScanLabel], role) {
				return strings.ToLower(string(foundResult.Status)) == strings.ToLower(roleResult), nil
			}
		}
		return false, fmt.Errorf("The role specified in the test doesn't match an existing role")
	}
	return false, fmt.Errorf("Couldn't parse the result as string or map")
}

func (ctx *e2econtext) getRuleFolderNameFromResult(result cmpv1alpha1.ComplianceCheckResult) (string, error) {
	labels := result.GetLabels()
	resultName := result.Name
	if labels == nil {
		return "", fmt.Errorf("ERROR: Can't derive name from rule %s since it contains no label", resultName)
	}
	prefix, ok := labels[cmpv1alpha1.ComplianceScanLabel]
	if !ok {
		return "", fmt.Errorf("ERROR: Result %s doesn't have label with scan name", resultName)
	}
	if !strings.HasPrefix(resultName, prefix) {
		return "", fmt.Errorf("ERROR: Result %s doesn't have expected prefix %s", resultName, prefix)
	}
	// Removes prefix plus the "-" delimiter
	prefixRemoved := resultName[len(prefix)+1:]
	return strings.ReplaceAll(prefixRemoved, "-", "_"), nil
}

func (ctx *e2econtext) applyManualRemediations(rems []string) {
	var wg sync.WaitGroup
	cmdctx, cancel := context.WithTimeout(context.Background(), manualRemediationsTimeout)
	defer cancel()

	for _, rem := range rems {
		wg.Add(1)
		go ctx.runManualRemediation(cmdctx, &wg, rem)
	}

	wg.Wait()
}

func (ctx *e2econtext) runManualRemediation(cmdctx goctx.Context, wg *sync.WaitGroup, rem string) {
	defer wg.Done()

	ctx.t.Logf("Running manual remediation '%s'", rem)
	cmd := exec.CommandContext(cmdctx, rem)
	cmd.Env = os.Environ()
	out, err := cmd.CombinedOutput()

	if cmdctx.Err() == context.DeadlineExceeded {
		ctx.t.Errorf("Command '%s' timed out", rem)
		return
	}

	if err != nil {
		ctx.t.Errorf("Failed applying remediation '%s': %s\n%s", rem, err, out)
	}
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
