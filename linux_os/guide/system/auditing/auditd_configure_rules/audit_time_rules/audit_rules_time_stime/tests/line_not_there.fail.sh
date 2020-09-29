#!/bin/bash


sed -i "/^[\s]*-a[\s]+always,exit[\s]+-F[\s]+arch=b32.*(-S[\s]+stime[\s]+|([\s]+|[,])stime([\s]+|[,])).*(-k[\s]+|-F[\s]+key=)[\S]+[\s]*$/d" /etc/audit/rules.d/*.rules
