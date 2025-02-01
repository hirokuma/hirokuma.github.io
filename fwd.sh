#!/bin/bash

BASE=https://hiro99ma.blogspot.com
YEARS=(2011 2012 2013 2014 2015 2016 2017 2018 2019 2020 2021 2022 2023 2024)

function get_url() {
  local year=$1
  local url=$3
  echo "${BASE}/${year}/"
}

function get_filename() {
  local year=$1
  local url=$3
  echo "./${year}/index.html"
}


for year in ${YEARS[@]}; do
    url=$(get_url $year $month)
    filename=$(get_filename $year $month)
    cat <<EOS > $filename
<!DOCTYPE html>
<html lang="ja">
<head>
  <meta charset="UTF-8">
  <meta http-equiv="refresh" content="0; url=$url">
  <title>Redirecting to old site...</title>
</head>
<body>
  <p>リダイレクト中です。自動的に移動しない場合は、<a href="$url">こちら</a>をクリックしてください。</p>
</body>
</html>
EOS
done

