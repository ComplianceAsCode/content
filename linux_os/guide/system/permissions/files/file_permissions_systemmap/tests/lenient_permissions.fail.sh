#!/bin/bash

FAKE_FILE=$(mktemp -p /boot System.map-5.99.0-XXX)
chmod 0644 $FAKE_FILE
