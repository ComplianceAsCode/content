#!/bin/bash
{{% if BANNER_MUST_BE_SET != "true" %}}
# platform = Not Applicable
{{% else %}}
echo > "{{{ FILEPATH }}}"
{{% endif %}}
