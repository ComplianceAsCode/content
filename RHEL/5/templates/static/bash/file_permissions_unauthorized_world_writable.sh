find / /var /home -xdev -follow -type f -perm -002 2>/dev/null | xargs chmod o-w
