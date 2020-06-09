package ocp4e2e

import (
	"testing"
	"time"
)

func TestE2e(t *testing.T) {
	ctx := newE2EContext(t)
	Setup(t, ctx)
	switch ctx.testtype {
	case "rhcos4":
		RHCOS4Tests(ctx)
	case "ocp4":
		OCP4Tests(ctx)
	}
}

func Setup(t *testing.T, ctx *e2econtext) {
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
			ctx.ensureOperatorGroupExists()
			ctx.ensureSubscriptionExists()
			ctx.waitForOperatorToBeReady()
		} else {
			t.Logf("Skipping operator install as requested")
		}
		ctx.resetClientMappings()
	})
}

func RHCOS4Tests(ctx *e2econtext) {
	// Remediations
	var numberOfRemediationsInit int
	var numberOfRemediationsEnd int

	// Failures
	var numberOfFailuresInit int
	var numberOfFailuresEnd int

	// Check Results
	var numberOfCheckResultsInit int
	var numberOfCheckResultsEnd int

	ctx.t.Run("Run first compliance scan", func(t *testing.T) {
		// Create suite and auto-apply remediations
		suite := ctx.createComplianceSuiteForProfile("1", true)
		ctx.waitForComplianceSuite(suite)
		numberOfRemediationsInit = ctx.getRemediationsForSuite(suite, false)
		numberOfFailuresInit = ctx.getFailuresForSuite(suite, false)
		numberOfCheckResultsInit = ctx.getCheckResultsForSuite(suite)
	})

	ctx.t.Run("Wait for Remediations to apply", func(t *testing.T) {
		// Lets wait for the MachineConfigs to start applying
		time.Sleep(30 * time.Second)
		ctx.waitForNodesToBeReady()
	})

	ctx.t.Run("Run second compliance scan", func(t *testing.T) {
		// Create suite and auto-apply remediations
		suite := ctx.createComplianceSuiteForProfile("2", false)
		ctx.waitForComplianceSuite(suite)
		numberOfRemediationsEnd = ctx.getRemediationsForSuite(suite, true)
		numberOfFailuresEnd = ctx.getFailuresForSuite(suite, true)
		numberOfCheckResultsEnd = ctx.getCheckResultsForSuite(suite)
	})

	ctx.t.Run("We should have the same number of check results in each scan", func(t *testing.T) {
		if numberOfCheckResultsInit != numberOfCheckResultsEnd {
			t.Errorf("The amount of check results are NOT the same: init -> %d  end %d",
				numberOfCheckResultsInit, numberOfCheckResultsEnd)
		} else {
			t.Logf("There amount of check results are the same: init -> %d  end %d",
				numberOfCheckResultsInit, numberOfCheckResultsEnd)
		}
	})

	ctx.t.Run("We should have less remediations to apply", func(t *testing.T) {
		if numberOfRemediationsInit <= numberOfRemediationsEnd {
			t.Errorf("The remediations didn't diminish: init -> %d  end %d",
				numberOfRemediationsInit, numberOfRemediationsEnd)
		} else {
			t.Logf("There are less remediations now: init -> %d  end %d",
				numberOfRemediationsInit, numberOfRemediationsEnd)
		}
		if numberOfFailuresInit <= numberOfFailuresEnd {
			t.Errorf("The failures didn't diminish: init -> %d  end %d",
				numberOfFailuresInit, numberOfFailuresEnd)
		} else {
			t.Logf("There are less failures now: init -> %d  end %d",
				numberOfFailuresInit, numberOfFailuresEnd)
		}
	})
}

func OCP4Tests(ctx *e2econtext) {
	ctx.t.Run("Run platform compliance scan", func(t *testing.T) {
		suite := ctx.createComplianceSuiteForPlatformProfile("1")
		ctx.waitForComplianceSuite(suite)
		if n := ctx.getBadResultsFromSuite(suite, true); n > 0 {
			ctx.t.Errorf("Expected Pass, Fail, Info, or Skip results from platform scans. Got %d Error/None results", n)
		}
	})
}
