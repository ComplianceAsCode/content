#!/bin/bash

# we are using an existing default secret name for testing, so it won't cause any subsequent failures on testing routes. 
oc patch proxies.config cluster --type merge -p '{"spec":{"trustedCA":{"name":"trusted-ca-bundle"}}}'
