// Package routeapihelpers contains utilities for handling OpenShift route objects.
package routeapihelpers

import (
	"fmt"
	"net/url"

	routev1 "github.com/openshift/api/route/v1"
	corev1 "k8s.io/api/core/v1"
	kvalidation "k8s.io/apimachinery/pkg/util/validation"
	field "k8s.io/apimachinery/pkg/util/validation/field"
)

// IngressURI calculates an admitted ingress URI.
// If 'host' is nonempty, only the ingress for that host is considered.
// If 'host' is empty, the first admitted ingress is used.
func IngressURI(route *routev1.Route, host string) (*url.URL, *routev1.RouteIngress, error) {
	scheme := "http"
	if route.Spec.TLS != nil {
		scheme = "https"
	}

	for _, ingress := range route.Status.Ingress {
		if host == "" || host == ingress.Host {
			uri := &url.URL{
				Scheme: scheme,
				Host:   ingress.Host,
			}

			for _, condition := range ingress.Conditions {
				if condition.Type == routev1.RouteAdmitted && condition.Status == corev1.ConditionTrue {
					return uri, &ingress, nil
				}
			}

			if host == ingress.Host {
				return uri, &ingress, fmt.Errorf("ingress for host %s in route %s in namespace %s is not admitted", host, route.ObjectMeta.Name, route.ObjectMeta.Namespace)
			}
		}
	}

	if host == "" {
		return nil, nil, fmt.Errorf("no admitted ingress for route %s in namespace %s", route.ObjectMeta.Name, route.ObjectMeta.Namespace)
	}
	return nil, nil, fmt.Errorf("no ingress for host %s in route %s in namespace %s", host, route.ObjectMeta.Name, route.ObjectMeta.Namespace)
}

// ValidateHost checks that a route's host name satisfies DNS requirements, with
// the assumption that the caller has already checked for an empty host name.
// Unless the allowNonCompliant annotation is set to true, host name must have
// at least two labels, with each label no more than 63 characters from the set of
// alphanumeric characters, '-' or '.', and must start and end with an alphanumeric
// character. A trailing dot is allowed. The total host name length must be no more
// than 253 characters.
// If allowNonCompliant is set to true, it uses a smaller set of conditions from
// IsDNS1123Subdomain, e.g. character set as described above, and total host name
// length must be no more than 253 characters.
func ValidateHost(host string, allowNonCompliant string, hostPath *field.Path) field.ErrorList {
	result := field.ErrorList{}

	if allowNonCompliant == "true" {
		errs := kvalidation.IsDNS1123Subdomain(host)
		if len(errs) != 0 {
			result = append(result, field.Invalid(hostPath, host, fmt.Sprintf("host must conform to DNS naming conventions: %v", errs)))
		}
	} else {
		errs := kvalidation.IsFullyQualifiedDomainName(hostPath, host)
		if len(errs) != 0 {
			result = append(result, field.Invalid(hostPath, host, fmt.Sprintf("host must conform to DNS 1123 naming conventions: %v", errs)))
		}
	}
	return result
}
