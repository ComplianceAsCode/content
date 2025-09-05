package ocp4unit

import (
	"testing"
)

var ruleExceptions = []string{
	"sshd_disable_compression",
	"sshd_set_idle_timeout",
	"sshd_set_keepalive",
	"audit_delete_success",  // The remediation uses a macro, so it looks like as an invalid YAML
}

func TestUnit(t *testing.T) {
	ctx := newUnitTestContext(t)
	t.Run("Verify kubernetes files are correct", func(t *testing.T) {
		filesTouchedByMCs := make(map[string]fileTracker)
		ctx.assertWithRelevantContentFiles(func(path string) {
			if isRuleException(path) {
				return
			}
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
