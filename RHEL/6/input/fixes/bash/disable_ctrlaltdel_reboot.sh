
sed -i 's,^exec.*,exec /usr/bin/logger -p authpriv.notice -t init "Ctrl-Alt-Del was pressed and ignored",'  FILE


