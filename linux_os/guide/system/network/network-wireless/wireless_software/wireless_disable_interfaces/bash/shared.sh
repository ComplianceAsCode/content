# platform = multi_platform_all

if 
    rpm -qa | grep NetworkManager
then
    nmcli radio all off
else
    echo "NetworkManager package not installed" >&2     
fi
