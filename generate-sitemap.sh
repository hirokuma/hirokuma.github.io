#!/bin/bash

# url configuration
URL="https://blog.hirokuma.work/"

# begin new sitemap
exec 1> my-sitemap.xml

# print head
echo '<?xml version="1.0" encoding="UTF-8"?>'
echo '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">'

# print urls
find . -type f \( -name "*.md" -o -name "*.html" \) -printf "%TY-%Tm-%Td%p\n" | \
sed -e "s/\.md$/\.html/g" | \
while read -r line; do
  DATE=${line:0:10}
  FILE=${line:12}
  if [ ${FILE:0:1} == "_" ]; then
    continue
  fi
  if [[ $FILE =~ ^201 ]]; then
    continue
  fi
  if [[ $FILE =~ ^202[0-3] ]]; then
    continue
  fi
  if [[ $FILE =~ ^2024/0[1-3] ]]; then
    continue
  fi
  echo "<url>"
  echo "<loc>${URL}${FILE}</loc>"
  echo "<lastmod>${DATE}T00:00:00+09:00</lastmod>"
  echo "</url>"
done

# print foot
echo "</urlset>"

cp my-sitemap.xml sitemap.xml
