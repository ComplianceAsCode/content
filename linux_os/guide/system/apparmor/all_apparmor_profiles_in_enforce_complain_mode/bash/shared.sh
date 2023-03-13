# platform = multi_platform_sle

{{{ bash_instantiate_variables("var_apparmor_mode") }}}


# Reload all AppArmor profiles 
apparmor_parser -q -r /etc/apparmor.d/

# Set the mode
APPARMOR_MODE="$var_apparmor_mode"

if [ "$APPARMOR_MODE" = "enforce" ]
then
  # Set all profiles to enforce mode
  aa-enforce /etc/apparmor.d/*    
fi

if [ "$APPARMOR_MODE" = "complain" ]
then
  # Set all profiles to complain mode
  aa-complain /etc/apparmor.d/*
fi

UNCONFINED=$(aa-unconfined)
if [ ! -z "$UNCONFINED" ]
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
