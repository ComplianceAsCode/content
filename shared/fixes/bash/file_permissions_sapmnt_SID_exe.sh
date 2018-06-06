# platform = multi_platform_ol
# reboot = false
# strategy = restrict
# complexity = low
# disruption = low
# Get /sapmnt/SID/exe from /sapmnt. Works for multiple SIDs.
find /sapmnt -regex '^/sapmnt/[A-Z][A-Z0-9][A-Z0-9]/exe$' -exec chomd 755 {} \; 
