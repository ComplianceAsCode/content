package constants

const (
	// XXX
	//
	// Add a constant here, if and only if: it's exported (of course) and it's reused across the entire project.
	// Otherwise, prefer an unexported const in a specific package.
	//
	// XXX

	// CurrentMachineConfigAnnotationKey is used to fetch current MachineConfig for a machine
	CurrentMachineConfigAnnotationKey = "machineconfiguration.openshift.io/currentConfig"
	// DesiredMachineConfigAnnotationKey is used to specify the desired MachineConfig for a machine
	DesiredMachineConfigAnnotationKey = "machineconfiguration.openshift.io/desiredConfig"
	// MachineConfigDaemonStateAnnotationKey is used to fetch the state of the daemon on the machine.
	MachineConfigDaemonStateAnnotationKey = "machineconfiguration.openshift.io/state"
	// OpenShiftOperatorManagedLabel is used to filter out kube objects that don't need to be synced by the MCO
	OpenShiftOperatorManagedLabel = "openshift.io/operator-managed"
	// MachineConfigDaemonStateWorking is set by daemon when it is applying an update.
	MachineConfigDaemonStateWorking = "Working"
	// MachineConfigDaemonStateDone is set by daemon when it is done applying an update.
	MachineConfigDaemonStateDone = "Done"
	// MachineConfigDaemonStateDegraded is set by daemon when an error not caused by a bad MachineConfig
	// is thrown during an update.
	MachineConfigDaemonStateDegraded = "Degraded"
	// MachineConfigDaemonStateUnreconcilable is set by the daemon when a MachineConfig cannot be applied.
	MachineConfigDaemonStateUnreconcilable = "Unreconcilable"
	// MachineConfigDaemonReasonAnnotationKey is set by the daemon when it needs to report a human readable reason for its state. E.g. when state flips to degraded/unreconcilable.
	MachineConfigDaemonReasonAnnotationKey = "machineconfiguration.openshift.io/reason"
	// InitialNodeAnnotationsFilePath defines the path at which it will find the node annotations it needs to set on the node once it comes up for the first time.
	// The Machine Config Server writes the node annotations to this path.
	InitialNodeAnnotationsFilePath = "/etc/machine-config-daemon/node-annotations.json"
	// InitialNodeAnnotationsBakPath defines the path of InitialNodeAnnotationsFilePath when the initial bootstrap is done. We leave it around for debugging and reconciling.
	InitialNodeAnnotationsBakPath = "/etc/machine-config-daemon/node-annotation.json.bak"

	// EtcPivotFile is used by the `pivot` command
	// For more information, see https://github.com/openshift/pivot/pull/25/commits/c77788a35d7ee4058d1410e89e6c7937bca89f6c#diff-04c6e90faac2675aa89e2176d2eec7d8R44
	EtcPivotFile = "/etc/pivot/image-pullspec"

	// HostSelfBinary is the path where we copy our own binary to the host
	HostSelfBinary = "/run/bin/machine-config-daemon"

	// MachineConfigEncapsulatedPath contains all of the data from a MachineConfig object
	// except the Spec/Config object; this supports inverting+encapsulating a MachineConfig
	// object so that Ignition can process it on first boot, and then the MCD can act on
	// non-Ignition fields such as the osImageURL and kernelArguments.
	MachineConfigEncapsulatedPath = "/etc/ignition-machine-config-encapsulated.json"

	// MachineConfigEncapsulatedBakPath defines the path where the machineconfigdaemom-firstboot.service
	// will leave a copy of the encapsulated MachineConfig in MachineConfigEncapsulatedPath after
	// processing for debugging and auditing purposes.
	MachineConfigEncapsulatedBakPath = "/etc/ignition-machine-config-encapsulated.json.bak"

	// MachineConfigDaemonForceFile if present causes the MCD to skip checking the validity of the
	// "currentConfig" state.  Create this file (empty contents is fine) if you wish the MCD
	// to proceed and attempt to "reconcile" to the new "desiredConfig" state regardless.
	MachineConfigDaemonForceFile = "/run/machine-config-daemon-force"
)
