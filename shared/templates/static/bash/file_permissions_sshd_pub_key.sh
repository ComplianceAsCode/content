# platform = multi_platform_rhel

#check if files exist before attempting 
#to change them
if ls /etc/ssh/*.pub &> /dev/null
then
    chmod 0644 /etc/ssh/*.pub
fi
