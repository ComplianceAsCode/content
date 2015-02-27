find /root /home/* -perm -1 -o -perm -2 -o -perm -4 -o -perm -20 2>/dev/null | xargs -I entry chmod o-rwx,g-w "entry"
