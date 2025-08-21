#!/bin/bash

# url configuration
URL="https://blog.hirokuma.work/"

# begin new sitemap
exec 1> my-sitemap.xml

# print head
echo '<?xml version="1.0" encoding="UTF-8"?>'
echo '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">'

# print urls
# find . \( -type d -and -name "201*" -and -prune \) -or -type f \( -name "*.md" -o -name "*.html" \) -printf "%TY-%Tm-%Td%p\n" | \
for f in $(find ./ -name "*.md"); do
    HTML=`echo $f | sed -e "s|\./||g" -e "s/\.md$/\.html/g"`
    DTS=8
    DTE=17
    DT=`grep -e "^date: \"" -m1 -h $f`
    if [ $? -ne 0 ]; then
        DTS=7
        DTE=16
        DT=`grep -e "^date: " -m1 -h $f`
    fi
    if [ $? -eq 0 ]; then
        DATE=`echo $DT | cut -c${DTS}-${DTE} | sed -e 's|/|-|g' -e 's/$/T00:00:00+00:00/'`
    fi
    echo "<url>"
    echo "  <loc>${URL}${HTML}</loc>"
    if [ -n "${DATE}" ]; then
        echo "  <lastmod>${DATE}</lastmod>"
    fi
    echo "</url>"
done

# print foot
echo "</urlset>"

cp my-sitemap.xml sitemap.xml
