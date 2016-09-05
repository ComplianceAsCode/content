#!/bin/bash

# This horrible abomination will go away before the PR is final
# for now this is a workaround before remediation generation is
# part of the cmake build.

pushd ..

pushd Fedora/templates
make
mkdir -p output/ansible
mkdir -p ../input/oval/oval_5.11
popd

pushd RHEL/5/templates
make
mkdir -p output/ansible
mkdir -p ../input/oval/oval_5.11
popd

pushd RHEL/6/templates
make
mkdir -p output/ansible
mkdir -p ../input/oval/oval_5.11
popd

pushd RHEL/7/templates
make
mkdir -p output/ansible
mkdir -p ../input/oval/oval_5.11
popd

popd
