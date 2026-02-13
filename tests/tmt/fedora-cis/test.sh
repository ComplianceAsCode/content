#!/bin/bash
#
# THIS TEST IS DESTRUCTIVE AND RE-BOOTS THE SYSTEM MULTIPLE TIMES,
#
# To be run via TMT, a test execution tool, see
# https://tmt.readthedocs.io/en/stable/
#

persistent_store=/var/tmp/test-fedora-cis

orig_ds=/usr/share/xml/scap/ssg/content/ssg-fedora-ds.xml
ds="$persistent_store/ds.xml"

rules_to_unselect=(
	#
	# CONTENT ISSUES
	#

	# TODO: add issues here

	#
	# TESTING FARM ENVIRONMENT ISSUES
	#

	# this is a mandatory prerequisite for TMT
	package_rsync_removed

	# we can't really remediate partitioning layout on Testing Farm
	'partition_for_[a-zA-Z0-9_]*'

	# likely caused by Testing Farm specific 'test' user
	accounts_password_last_change_is_in_past
	ensure_pam_wheel_group_empty
	use_pam_wheel_group_for_su

	# /mnt/scratchspace on Testing Farm
	dir_perms_world_writable_sticky_bits

	#
	# CONTEST (TEST SUITE) ISSUES
	#

	# avoid this globally, so we don't have to change passwords
	# or call 'chage' in every type of remediation
	accounts_password_set_max_life_existing
	accounts_password_set_max_life_root

	# also just allow root without -oPermitRootLogin=yes hacks
	sshd_disable_root_login
	sshd_disable_root_password_login

	#
	# RULES WITHOUT AUTOMATED REMEDIATION
	#
	grub2_password
	sshd_limit_user_access
)

function fatal {
	printf 'error: %s\n' "$*" >&2
	exit 1
}

function + {
	local rc
	{ set -x; } 2>/dev/null
	"$@"
	{ rc=$?; set +x; } 2>/dev/null
	return $rc
}

function unselect {
	local ds="$1" rules=("${@:2}")
	local rule e_args=()
	for rule in "${rules[@]}"; do
		e_args+=(-e "/<xccdf-1.2:select idref=\"xccdf_org.ssgproject.content_rule_${rule}\" /s/selected=\"true\"/selected=\"false\"/")
	done
	+ sed "${e_args[@]}" "$ds" || fatal "unselect sed failed"
}

case "$TMT_REBOOT_COUNT" in
	0)
		echo "Creating $persistent_store"
		+ rm -rf "$persistent_store"
		+ mkdir -p "$persistent_store"

		echo "Unselecting problematic rules"
		+ unselect "$orig_ds" "${rules_to_unselect[@]}" > "$ds"

		echo "First remediation before reboot"
		+ oscap xccdf eval --profile cis --remediate --progress \
			--results-arf "$persistent_store/remediation-arf.xml" \
			"$ds"
		[[ $? -eq 0 || $? -eq 2 ]] || fatal "oscap failed to remediate"
		+ tmt-reboot
		;;
	1)
		echo "Second remediation"
		+ oscap xccdf eval --profile cis --remediate --progress \
			--results-arf "$persistent_store/remediation2-arf.xml" \
			"$ds"
		[[ $? -eq 0 || $? -eq 2 ]] || fatal "oscap failed to remediate"
		+ tmt-reboot
		;;
	2)
		echo "Final scan"
		+ oscap xccdf eval --profile cis --progress \
			--results-arf "$persistent_store/scan-arf.xml" \
			--report "$persistent_store/report.html" \
			"$ds"
		oscap_rc=$?

		echo "Rendering first remediation via oscap-report"
		+ oscap-report \
			"$persistent_store/remediation-arf.xml" \
			> "$persistent_store/remediation.html"

		echo "Packing results"
		+ gzip -9 "$persistent_store"/*.xml
		+ mv -v "$persistent_store"/* "$TMT_TEST_DATA/."
		+ rm -rf "$persistent_store"

		case "$oscap_rc" in
			0) ;;
			2)
				# TODO: swap these after all issues are fixed/unselected
				echo "some checks failed, see report.html"
				#fatal "some checks failed, see report.html"
				;;
			*)
				fatal "oscap failed to scan"
				;;
		esac
		;;
	*)
		fatal "TMT_REBOOT_COUNT undefined, not running under TMT?"
		;;
esac

exit 0
