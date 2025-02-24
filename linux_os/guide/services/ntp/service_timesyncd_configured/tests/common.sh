#!/bin/bash

{{% if "ubuntu" in product %}}
mkdir -p /etc/systemd/timesyncd.conf.d/
echo "" > /etc/systemd/timesyncd.conf.d/oscap-remedy.conf
{{% else %}}
mkdir -p /etc/systemd/timesyncd.d/
echo "" > /etc/systemd/timesyncd.d/oscap-remedy.conf
{{% endif %}}
echo "" > /etc/systemd/timesyncd.conf
