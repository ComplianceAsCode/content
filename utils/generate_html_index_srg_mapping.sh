#!/usr/bin/env bash
# suppress stdout from pushd and popd commands
pushd () {
    command pushd "$@" > /dev/null
}

popd () {
    command popd "$@" > /dev/null
}

if [ -z "$1" ]; then
    echo "You must inform a directory to store built files."
    exit 1
fi
PAGES_DIR=$1

if [ -z "$2" ]; then
    echo "You must inform a list of products in double quotes."
    exit 1
fi
srg_products=$2 # space separated list of products

mkdir -p $PAGES_DIR

# Generate SRG Mapping Tables
pushd $PAGES_DIR
touch index.html
echo "<!DOCTYPE html>" > index.html
echo '<html lang="en">' >> index.html
echo "<head>" >> index.html
echo '<meta charset="utf-8" />' >> index.html
echo "<title>SRG Mapping Tables</title>" >> index.html
echo "</head>" >> index.html
echo "<body>" >> index.html
echo "<h1>SRG Mapping Tables</h1>" >> index.html
for product in $srg_products
do
echo "<h4>Product: ${product}</h4>" >> index.html
echo "<ul>" >> index.html
echo "<li><a href=\"srg-mapping-${product}.html\">srg-mapping-${product}.html</a></li>" >> index.html
echo "<li><a href=\"srg-mapping-${product}.xlsx\">srg-mapping-${product}.xlsx</a></li>" >> index.html
echo "</ul>" >> index.html
done
echo "</body>" >> index.html
echo "</html>" >> index.html
popd

exit 0
