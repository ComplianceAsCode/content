package ocp4e2e

import (
	"testing"
)

func TestE2e(t *testing.T) {
	ctx := newE2EContext(t)
	t.Run("Parameter setup and validation", func(t *testing.T) {
		ctx.assertRootdir()
		ctx.assertProfile()
		ctx.assertContentImage()
		ctx.assertKubeClient()
	})

	t.Run("Operator setup", func(t *testing.T) {
		ctx.ensureNamespaceExistsAndSet()
		ctx.ensureOperatorSourceExists()
		ctx.ensureCatalogSourceConfigExists()
		ctx.ensureOperatorGroupExists()
		ctx.ensureSubscriptionExists()
		ctx.waitForOperatorToBeReady()
		ctx.resetClientMappings()
	})

	t.Run("Run compliance scan", func(t *testing.T) {
		suite := ctx.createComplianceSuiteForProfile("1")
		ctx.waitForComplianceSuite(suite)
	})
}
