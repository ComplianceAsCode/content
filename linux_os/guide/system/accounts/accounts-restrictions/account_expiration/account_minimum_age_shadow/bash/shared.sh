# platform = multi_platform_sle

for user in $( awk -F':' '$4==0 { print $1 }' < /etc/shadow ) ; do
    passwd -n 1 "$user"
done
