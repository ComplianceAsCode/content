#!/bin/bash


dnf -y install dnf-automatic
systemctl disable --now dnf-automatic.timer
