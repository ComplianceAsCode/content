#!/bin/bash

touch /dev/foo
restorecon -F /dev/foo
