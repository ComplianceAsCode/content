# platform = multi_platform_sle

if ! [ -x /etc/gdm/Xsession ] ; then
    echo "can only remediate if /etc/gdm/Xsession is an executable shell script" >&2
    exit 1
fi

if ! awk 'NR==1 && $0 == "#!/bin/sh" { exit 0 } ; { exit 1 }' /etc/gdm/Xsession ; then
    echo "can only remediate if /etc/gdm/Xsession is a shell script" >&2
    exit 1
fi

f=$(mktemp)

echo '#!/bin/sh

if ! zenity --text-info \
 --title "Consent" \
 --filename=/etc/gdm/banner \
 --no-markup \
 --checkbox="Accept." 10 10; then
  sleep 1;
  exit 1;
fi
' > "$f"

# copy original contents of /etc/gdm/Xsession - but skip the shebang
tail -n +2 /etc/gdm/Xsession >> "$f"

chown --reference=/etc/gdm/Xsession "$f"
chmod --reference=/etc/gdm/Xsession "$f"
mv "$f" /etc/gdm/Xsession
