#!/bin/bash

# You can safely patch this to a non-existent secret name, it's a no-op, but OK for testing.
oc patch proxies.config cluster --type merge -p '{"spec":{"trustedCA":{"name":"testing"}}}'
