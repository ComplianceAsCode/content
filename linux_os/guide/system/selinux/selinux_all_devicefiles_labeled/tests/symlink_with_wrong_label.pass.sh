#!/bin/bash

ln -s /dev/cpu /dev/foo
restorecon -F /dev/foo
