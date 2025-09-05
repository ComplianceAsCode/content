#!/bin/bash

groupdel 888888 || true
echo "testuser:x:8000:888888:testuser:/home/testuser:/bin/bash" >> /etc/passwd
