#!/bin/bash

FAKE_FILE1=$(mktemp -p /boot System.map-5.99.0-XXX)
chmod 0600 $FAKE_FILE1

FAKE_FILE2=$(mktemp -p /boot System.map-5.99.0-XXX)
chmod 0644 $FAKE_FILE2
