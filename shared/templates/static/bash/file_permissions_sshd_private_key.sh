# platform = multi_platform_rhel

#check if files exist before attempting 
#to change them
if ls /etc/ssh/*_key &> /dev/null
then
    chmod 0640 /etc/ssh/*_key
fi
