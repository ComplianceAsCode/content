find / /var /home -follow -xdev -type f -perm -002 2>/dev/null | xargs chmod o-w
