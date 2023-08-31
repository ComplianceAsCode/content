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

mkdir -p $PAGES_DIR
STATS_DIR=$PAGES_DIR/statistics
mkdir -p $STATS_DIR
touch $STATS_DIR/index.html
echo "<!DOCTYPE html>" > $STATS_DIR/index.html
echo '<html lang="en">' >> $STATS_DIR/index.html
echo "<head>" >> $STATS_DIR/index.html
echo '<meta charset="utf-8" />' >> $STATS_DIR/index.html
echo "<title>Statistics</title>" >> $STATS_DIR/index.html
echo "</head>" >> $STATS_DIR/index.html
echo "<body>" >> $STATS_DIR/index.html
echo "<h1>Statistics</h1>" >> $STATS_DIR/index.html
# get supported products
products=$(echo -e "import ssg.constants\nprint(ssg.constants.product_directories)" | python3 | sed -s "s/'//g; s/,//g; s/\[//g; s/\]//g")
for product in $products
do
    if [ -d build/$product ]; then
    echo "<h4>Product: ${product}</h4>" >> $STATS_DIR/index.html
    echo "<ul>" >> $STATS_DIR/index.html
    mkdir -p $STATS_DIR/$product
    if [ -f build/$product/product-statistics/statistics.html ]; then
        cp -rf build/$product/product-statistics $STATS_DIR/$product/product-statistics
        echo "<li><a href=\"$product/product-statistics/statistics.html\">Product Statistics</a></li>" >> $STATS_DIR/index.html
        fi
    if [ -f build/$product/profile-statistics/statistics.html ]; then
        cp -rf build/$product/profile-statistics $STATS_DIR/$product/profile-statistics
        echo "<li><a href=\"$product/profile-statistics/statistics.html\">Profile statistics</a></li>" >> $STATS_DIR/index.html
        fi
    echo "</ul>" >> $STATS_DIR/index.html
    fi
done
echo "</body>" >> $STATS_DIR/index.html
echo "</html>" >> $STATS_DIR/index.html

# Generate Guides page
mkdir -p $PAGES_DIR/guides
cp -rf build/guides $PAGES_DIR
utils/gen_html_guides_index.py . $PAGES_DIR/guides/index.html
retVal=$?
if [ $retVal -ne 0 ]; then
    echo "Something wrong happened while generating the HTML Guides Index page"
    exit 1
fi

# Generate Mapping Tables page
pushd build/tables
touch index.html
echo "<!DOCTYPE html>" > index.html
echo '<html lang="en">' >> index.html
echo "<head>" >> index.html
echo '<meta charset="utf-8" />' >> index.html
echo "<title>Mapping Tables</title>" >> index.html
echo "</head>" >> index.html
echo "<body>" >> index.html
echo "<h1>Mapping Tables</h1>" >> index.html
echo "<ul>" >> index.html
for table in table-*.html
do
    echo "<li><a href=\"${table}\">${table}</a></li>" >> index.html
done
echo "</ul>" >> index.html
echo "</body>" >> index.html
echo "</html>" >> index.html
popd


# Generate Rendered Policies page
POLICY_DIR="$PAGES_DIR/rendered-policies"
mkdir -p "$POLICY_DIR"
products=$(echo -e "import ssg.constants\nprint(ssg.constants.product_directories)" | python3 | sed -s "s/'//g; s/,//g; s/\[//g; s/\]//g")
for product in $products
do
    if [ -d build/$product ]; then
        mkdir -p "$POLICY_DIR/$product"
        if [ -d "build/$product/rendered-policies/" ]; then
            cp -rf "build/${product}/rendered-policies/"* "$POLICY_DIR/$product/"
        fi
    fi
done
utils/gen_rendered_policies_index.py . "$PAGES_DIR/rendered-policies/index.html"
retVal=$?
if [ $retVal -ne 0 ]; then
    echo "Something wrong happened while generating the HTML Rendered Policy Index page"
    exit 1
fi

# Generate Components page
COMPONENTS_DIR="$PAGES_DIR/components"
mkdir -p "$COMPONENTS_DIR"
utils/render_components.py -r "$(pwd)" "$COMPONENTS_DIR"
retVal=$?
if [ $retVal -ne 0 ]; then
    echo "Something wrong happened while generating components HTML pages."
    exit 1
fi

# Generate Prometheus Stats
PROMETHEUS_STATS_DIR="$PAGES_DIR/prometheus_stats"
mkdir -p "$PROMETHEUS_STATS_DIR"
mv "$PAGES_DIR/policies_metrics" "$PROMETHEUS_STATS_DIR"


pushd $PAGES_DIR
touch index.html
echo "<!DOCTYPE html>" > index.html
echo '<html lang="en">' >> index.html
echo "<head>" >> index.html
echo '<meta charset="utf-8" />' >> index.html
echo "<title>Available Artifacts</title>" >> index.html
echo "</head>" >> index.html
echo "<body>" >> index.html
echo "<h1>Available Artifacts</h1>" >> index.html
echo "<ul>" >> index.html
echo "<li><a href=\"statistics/index.html\">Statistics</a></li>" >> index.html
echo "<li><a href=\"guides/index.html\">Guides</a></li>" >> index.html
echo "<li><a href=\"tables/index.html\">Mapping Tables</a></li>" >> index.html
echo "<li><a href=\"srg_mapping/index.html\">SRG Mapping Tables</a></li>" >> index.html
echo "<li><a href=\"rendered-policies/index.html\">Rendered Policies</a></li>" >> index.html
echo "<li><a href=\"components/index.html\">Components</a></li>" >> index.html
echo "<li><a href=\"prometheus_stats/policies_metrics\">Prometheus Policies Metrics</a></li>" >> index.html
echo "</ul>" >> index.html
echo "</body>" >> index.html
echo "</html>" >> index.html
popd

cp -rf build/tables $PAGES_DIR

exit 0
