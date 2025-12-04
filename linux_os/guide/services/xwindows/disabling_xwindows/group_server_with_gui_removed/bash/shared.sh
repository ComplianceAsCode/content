# platform = multi_platform_rhel

# Note: This is important to update dependencies to allow the removal of the Server
# with GUI group with minimal impact to the system functionality.
dnf groupinstall -y "Minimal Install"

# Remove the Server with GUI group
dnf groupremove -y "Server with GUI"
dnf groupinstall -y "Server"
