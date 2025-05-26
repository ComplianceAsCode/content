# platform = multi_platform_sle,multi_platform_ubuntu,multi_platform_debian

# make sure apparmor-utils is installed for aa-complain and aa-enforce
{{{ bash_package_install("apparmor-utils") }}}

# Ensure all AppArmor Profiles are enforcing
apparmor_parser -q -r /etc/apparmor.d/
{{% if 'ubuntu' in product %}}
# Current version of apparmor-utils has issue https://gitlab.com/apparmor/apparmor/-/issues/411 and we're waiting for https://gitlab.com/apparmor/apparmor/-/merge_requests/1218 to be landed on noble
find /etc/apparmor.d -maxdepth 1 ! -type d -exec aa-enforce "{}" \;
{{% else %}}
aa-enforce /etc/apparmor.d/*
{{% endif %}}

{{% if 'ubuntu' in product %}}
UNCONFINED=$(aa-status | grep "processes are unconfined" | awk '{print $1;}')
if [ $UNCONFINED -ne 0 ];
{{% else %}}
UNCONFINED=$(aa-unconfined)
if [ ! -z "$UNCONFINED" ]
{{% endif %}}
then
  echo -e "***WARNING***: There are some unconfined processes:"
  echo -e "----------------------------"
  echo "The may need to have a profile created or activated for them and then be restarted."
  for PROCESS in "${UNCONFINED[@]}"
  do
      echo "$PROCESS"
  done
  echo -e "----------------------------"
  echo "The may need to have a profile created or activated for them and then be restarted."
fi
