# platform = Red Hat Enterprise Linux 7
grep -q "^ExecStart=\-.*/sbin/sulogin" /usr/lib/systemd/system/rescue.service
if ! [ $? -eq 0 ]; then
    sed -i "s/ExecStart=-.*-c \"/&\/sbin\/sulogin; /g" /usr/lib/systemd/system/rescue.service
fi
