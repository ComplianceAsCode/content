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

mkdir $PAGES_DIR
STATS_DIR=$PAGES_DIR/statistics
mkdir $STATS_DIR
touch $STATS_DIR/index.html
echo "<html>" > $STATS_DIR/index.html
echo "<header>" >> index.html
echo "<h1>Statistics</h1>" >> index.html
echo "</header>" >> index.html
echo "<body>" >> $STATS_DIR/index.html
echo "<ul>" >> $STATS_DIR/index.html
# get supported products
products=$(echo -e "import ssg.constants\nprint(ssg.constants.product_directories)" | python3 | sed -s "s/'//g; s/,//g; s/\[//g; s/\]//g")
for product in $products
do
    if [ -d build/$product ]; then
    mkdir -p $STATS_DIR/$product
    if [ -f build/$product/product-statistics/statistics.html ]; then
        cp -rf build/$product/product-statistics $STATS_DIR/$product/product-statistics
        echo "<li><a href=\"$product/product-statistics/statistics.html\">Statistics for product: ${product}</a></li>" >> $STATS_DIR/index.html
        fi
    if [ -f build/$product/profile-statistics/statistics.html ]; then
        cp -rf build/$product/profile-statistics $STATS_DIR/$product/profile-statistics
        echo "<li><a href=\"$product/profile-statistics/statistics.html\">Profile statistics for product: ${product}</a></li>" >> $STATS_DIR/index.html
        fi
    fi
done
echo "</ul>" >> $STATS_DIR/index.html
echo "</body>" >> $STATS_DIR/index.html
echo "</html>" >> $STATS_DIR/index.html

# Generate Guides page
mkdir -p $PAGES_DIR/guides
cp -rf build/guides $PAGES_DIR
utils/gen_html_guides_index.py . $PAGES_DIR/guides/index.html


# Generate Mapping Tables page
pushd build/tables
touch index.html
echo "<html>" > index.html
echo "<header>" >> index.html
echo "<h1>Mapping Tables</h1>" >> index.html
echo "</header>" >> index.html
echo "<body>" >> index.html
echo "<ul>" >> index.html
for table in table-*.html
do
    echo "<li><a href=\"${table}\">${table}</a></li>" >> index.html
done
echo "</ul>" >> index.html
echo "</body>" >> index.html
echo "</html>" >> index.html
popd

pushd $PAGES_DIR
touch index.html
echo "<html>" > index.html
echo "<header>" >> index.html
echo "<h1>Available Artifacts</h1>" >> index.html
echo "</header>" >> index.html
echo "<body>" >> index.html
echo "<ul>" >> index.html
echo "<li><a href=\"statistics/index.html\">Statistics</a></li>" >> index.html
echo "<li><a href=\"guides/index.html\">Guides</a></li>" >> index.html
echo "<li><a href=\"tables/index.html\">Mapping Tables</a></li>" >> index.html
echo "</ul>" >> index.html
echo "</body>" >> index.html
echo "</html>" >> index.html
popd

cp -rf build/tables $PAGES_DIR

exit 0
