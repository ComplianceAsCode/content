package ocp4unit

import (
	"testing"
)

func TestUnit(t *testing.T) {
	ctx := newUnitTestContext(t)
	t.Run("Verify kubernetes files are correct", func(t *testing.T) {
		filesTouchedByMCs := make(map[string]fileTracker)
		ctx.assertWithRelevantContentFiles(func(path string) {
			obj := ctx.assertObjectIsValid(path)

			if isMachineConfig(obj) {
				mcfg := ctx.assertMachineConfigIsValid(obj, path)
				if mcfgChangesFile(mcfg, ctx.t) {
					ctx.assertFileDoesntDiffer(mcfg, path, filesTouchedByMCs)
				}
			}
		})
	})

	t.Run("Verify OCP profiles don't contain invalid checks", func(t *testing.T) {
		ctx.asssertWithOCPProfiles(func(path string) {
			obj := ctx.assertProfileIsValid(path)
			ctx.asssertSelectionsNotInOCPProfile(obj.Selections, path,
				[]undesiredSelection{
					{
						Name:   "sysctl_net_ipv4_ip_forward",
						Reason: "Disabling IP forwarding breaks the SDN.",
					},
					{
						Name:   "sysctl_user_max_user_namespaces",
						Reason: "Limiting user namespaces affects the usage of rootless containers and limits general container capabilities.",
					},
				})
		})
	})
}
