# platform = multi_platform_all

{{{
    bash_ensure_ini_config("/etc/systemd/system/tftp.service", "Service", "ExecStart",
    "/usr/sbin/in.tftpd -s /var/lib/tftpboot", "#")
}}}
systemctl daemon-reload
systemctl restart tftp
