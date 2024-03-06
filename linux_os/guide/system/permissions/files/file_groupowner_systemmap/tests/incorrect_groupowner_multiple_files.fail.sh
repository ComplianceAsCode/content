#!/bin/bash

FAKE_FILE1=$(mktemp -p /boot System.map-5.99.0-XXX)
chgrp root $FAKE_FILE1

FAKE_FILE2=$(mktemp -p /boot System.map-5.99.0-XXX)
chgrp 5 $FAKE_FILE2
