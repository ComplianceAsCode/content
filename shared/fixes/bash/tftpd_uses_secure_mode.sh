if [ -e /etc/xinetd.d/tftp ]; then
        ISS=$(grep server_args /etc/xinetd.d/tftp | egrep '(-s)' | wc -l )
        #Start-Lockdown
        if [ $ISS -lt 1 ]; then
                sed  -i "/server_args/ c\        server_args             = -s /tftpboot" /etc/xinetd.d/tftp
        fi
fi
