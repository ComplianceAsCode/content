#!/bin/bash
{{% if BANNER_MUST_BE_SET == "true" %}}
# platform = Not Applicable
{{% else %}}
rm -rf "{{{ FILEPATH }}}"
{{% endif %}}
