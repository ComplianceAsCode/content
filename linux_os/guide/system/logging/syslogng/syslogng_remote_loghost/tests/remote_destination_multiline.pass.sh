#!/bin/bash
# platform = multi_platform_all
# packages = syslog-ng,linux-base

mkdir -p /etc/syslog-ng/conf.d
cat > /etc/syslog-ng/conf.d/cac-test.conf <<'CONF'
# Forward everything to the central log server.
destination d_cac_remote {
    # UDP is used because the log server does not accept TCP.
    udp(
        "loghost.example.com"
        port(514)
    );
};

log {
    source(s_src);
    filter { level(info..emerg); };
    destination(d_cac_remote);
};
CONF
