#!/bin/bash

FAKE_FILE=$(mktemp -p /boot System.map-5.99.0-XXX)
chgrp 5 $FAKE_FILE
