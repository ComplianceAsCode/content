#!/bin/bash


dnf -y install dnf-automatic
systemctl enable --now dnf-automatic.timer
