package ocp4e2e

import (
	"testing"
	"time"
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
		if ctx.installOperator {
			ctx.ensureOperatorSourceExists()
			ctx.ensureCatalogSourceConfigExists()
			ctx.ensureOperatorGroupExists()
			ctx.ensureSubscriptionExists()
			ctx.waitForOperatorToBeReady()
		} else {
			t.Logf("Skipping operator install as requested")
		}
		ctx.resetClientMappings()
	})

	var numberOfRemediationsInit int
	var numberOfRemediationsEnd int

	t.Run("Run first compliance scan", func(t *testing.T) {
		// Create suite and auto-apply remediations
		suite := ctx.createComplianceSuiteForProfile("1", true)
		ctx.waitForComplianceSuite(suite)
		numberOfRemediationsInit = ctx.getRemediationsForSuite(suite, false)
	})

	t.Run("Wait for Remediations to apply", func(t *testing.T) {
		// Lets wait for the MachineConfigs to start applying
		time.Sleep(30 * time.Second)
		ctx.waitForNodesToBeReady()
	})

	t.Run("Run second compliance scan", func(t *testing.T) {
		// Create suite and auto-apply remediations
		suite := ctx.createComplianceSuiteForProfile("2", false)
		ctx.waitForComplianceSuite(suite)
		numberOfRemediationsEnd = ctx.getRemediationsForSuite(suite, true)
	})

	t.Run("We should have less remediations to apply", func(t *testing.T) {
		if numberOfRemediationsInit <= numberOfRemediationsEnd {
			t.Errorf("The remediations didn't diminish: init -> %d  end %d",
				numberOfRemediationsInit, numberOfRemediationsEnd)
		} else {
			t.Logf("There are less remediations now: init -> %d  end %d",
				numberOfRemediationsInit, numberOfRemediationsEnd)
		}
	})
}
