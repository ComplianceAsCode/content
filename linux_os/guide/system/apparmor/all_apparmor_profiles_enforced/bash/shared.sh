# platform = multi_platform_sle

# Ensure all AppArmor Profiles are enforcing
apparmor_parser -q -r /etc/apparmor.d/
aa-enforce /etc/apparmor.d/*

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
