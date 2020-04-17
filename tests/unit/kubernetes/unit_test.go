package ocp4unit

import (
	"testing"
)

func TestUnit(t *testing.T) {
	ctx := newUnitTestContext(t)
	t.Run("Verify kubernetes files are correct", func(t *testing.T) {
		ctx.assertWithRelevantFiles(func(path string) {
			obj := ctx.assertObjectIsValid(path)

			if isMachineConfig(obj) {
				ctx.assertMachineConfigIsValid(obj, path)
			}
		})
	})
}
