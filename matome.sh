#!/bin/bash -u

sed -i -e "s|2025/|/2025/|g" -e "s/\.md/\.html/g" $1

