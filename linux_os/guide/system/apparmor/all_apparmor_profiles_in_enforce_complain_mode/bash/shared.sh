# platform = multi_platform_sle,multi_platform_ubuntu

{{{ bash_instantiate_variables("var_apparmor_mode") }}}

# make sure apparmor-utils is installed for aa-complain and aa-enforce
{{{ bash_package_install("apparmor-utils") }}}

# Reload all AppArmor profiles
apparmor_parser -q -r /etc/apparmor.d/

# Set the mode
APPARMOR_MODE="$var_apparmor_mode"

if [ "$APPARMOR_MODE" = "enforce" ]
then
  {{% if 'ubuntu' in product %}}
  # Set all profiles to enforce mode except disabled profiles
  find /etc/apparmor.d -maxdepth 1 ! -type d -exec bash -c '[[ -e "/etc/apparmor.d/disable/$(basename "$1")" ]] || aa-enforce "$1"' _ {} \;
  {{% else %}}
  # Set all profiles to enforce mode
  aa-enforce /etc/apparmor.d/*
  {{% endif %}}
fi

if [ "$APPARMOR_MODE" = "complain" ]
then
  {{% if 'ubuntu' in product %}}
  # Load all not-loaded profiles into complain mode
  apparmor_parser -a --Complain /etc/apparmor.d/
  echo "***WARNING***: This remediation will not downgrade any existing AppArmor profiles."
  {{% else %}}
  # Set all profiles to complain mode
  aa-complain /etc/apparmor.d/*
  {{% endif %}}
fi

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
