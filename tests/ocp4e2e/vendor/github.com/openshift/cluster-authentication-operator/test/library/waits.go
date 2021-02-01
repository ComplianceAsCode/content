package library

import (
	"context"
	"fmt"
	"net/http"
	"strings"
	"testing"
	"time"

	"k8s.io/apimachinery/pkg/api/errors"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/apimachinery/pkg/util/wait"

	configv1 "github.com/openshift/api/config/v1"
	configv1client "github.com/openshift/client-go/config/clientset/versioned/typed/config/v1"
	routev1client "github.com/openshift/client-go/route/clientset/versioned/typed/route/v1"
	"github.com/openshift/library-go/pkg/config/clusteroperator/v1helpers"
	"github.com/openshift/library-go/pkg/operator/resource/retry"
	"github.com/openshift/library-go/pkg/route/routeapihelpers"
)

func WaitForClusterOperatorAvailableNotProgressingNotDegraded(t *testing.T, client configv1client.ConfigV1Interface, name string) error {
	return WaitForClusterOperatorStatus(t, client, name, configv1.ConditionTrue, configv1.ConditionFalse, configv1.ConditionFalse, "")
}

func WaitForClusterOperatorDegraded(t *testing.T, client configv1client.ConfigV1Interface, name string) error {
	return WaitForClusterOperatorStatus(t, client, name, "", "", configv1.ConditionTrue, "")
}

func WaitForClusterOperatorProgressing(t *testing.T, client configv1client.ConfigV1Interface, name string) error {
	return WaitForClusterOperatorStatus(t, client, name, "", configv1.ConditionTrue, "", "")
}

func WaitForClusterOperatorStatus(t *testing.T, client configv1client.ConfigV1Interface, name string, available, progressing, degraded, upgradable configv1.ConditionStatus) error {
	return wait.PollImmediate(time.Second, 10*time.Minute, func() (bool, error) {
		clusterOperator, err := client.ClusterOperators().Get(context.TODO(), name, metav1.GetOptions{})
		if errors.IsNotFound(err) {
			t.Logf("clusteroperators.config.openshift.io/%v: %v", name, err)
			return false, nil
		}
		if retry.IsHTTPClientError(err) {
			t.Logf("clusteroperators.config.openshift.io/%v: %v", name, err)
			return false, nil
		}
		conditions := clusterOperator.Status.Conditions
		t.Logf("clusteroperators.config.openshift.io/%v: %v", name, conditionsStatusString(conditions))
		availableStatusIsMatch, progressingStatusIsMatch, degradedStatusIsMatch, upgradableStatusIsMatch := true, true, true, true
		if available != "" {
			availableStatusIsMatch = v1helpers.IsStatusConditionPresentAndEqual(conditions, configv1.OperatorAvailable, available)
		}
		if progressing != "" {
			progressingStatusIsMatch = v1helpers.IsStatusConditionPresentAndEqual(conditions, configv1.OperatorProgressing, progressing)
		}
		if degraded != "" {
			degradedStatusIsMatch = v1helpers.IsStatusConditionPresentAndEqual(conditions, configv1.OperatorDegraded, degraded)
		}
		if upgradable != "" {
			upgradableStatusIsMatch = v1helpers.IsStatusConditionPresentAndEqual(conditions, configv1.OperatorDegraded, upgradable)
		}
		done := availableStatusIsMatch && progressingStatusIsMatch && degradedStatusIsMatch && upgradableStatusIsMatch
		return done, nil
	})
}

func conditionsStatusString(conditions []configv1.ClusterOperatorStatusCondition) string {
	var result strings.Builder
	orderedConditionTypes := []configv1.ClusterStatusConditionType{configv1.OperatorAvailable, configv1.OperatorProgressing, configv1.OperatorDegraded, configv1.OperatorUpgradeable}
	for i, conditionType := range orderedConditionTypes {
		condition := v1helpers.FindStatusCondition(conditions, conditionType)
		if condition == nil {
			continue
		}
		if i > 0 {
			result.WriteString(", ")
		}
		result.WriteString(fmt.Sprintf("%v: %v", condition.Type, condition.Status))
	}
	return result.String()
}

func WaitForRouteAdmitted(t *testing.T, client routev1client.RouteV1Interface, name, ns string) (string, error) {
	var admittedURL string

	t.Logf("waiting for route %s/%s to be admitted", ns, name)
	err := wait.PollImmediate(time.Second, 2*time.Minute, func() (bool, error) {
		route, err := client.Routes(ns).Get(context.TODO(), name, metav1.GetOptions{})
		if err != nil {
			t.Logf("route.Get(%s/%s) error: %v", ns, name, err)
			return false, nil
		}
		if _, ingress, err := routeapihelpers.IngressURI(route, ""); err != nil {
			t.Log(err)
			return false, nil
		} else {
			admittedURL = ingress.Host
		}
		return true, nil
	})

	return admittedURL, err
}

func WaitForHTTPStatus(t *testing.T, waitDuration time.Duration, client *http.Client, targetURL string, expectedStatus int) error {
	t.Logf("waiting for HEAD at %q to report %d", targetURL, expectedStatus)

	var lastObservedStatus int
	return wait.PollImmediate(time.Second, waitDuration, func() (bool, error) {
		resp, err := client.Head(targetURL)
		if err != nil {
			t.Logf("failed to HEAD %q: %v", targetURL, err)
			return false, nil
		}
		if resp.StatusCode == expectedStatus {
			return true, nil
		}

		if resp.StatusCode != lastObservedStatus { // only log failure once in 10 seconds
			lastObservedStatus = resp.StatusCode
			t.Logf("HEAD %s: %s", targetURL, resp.Status)
		}
		return false, nil
	})
}
