#!/bin/bash

oc patch console.config.openshift.io cluster --type merge -p '{"spec":{"authentication":{"logoutRedirect":"https://my.idp.com/logout"}}}'

