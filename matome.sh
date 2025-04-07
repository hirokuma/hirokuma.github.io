#!/bin/bash -u

if [ ! -f $1/index.md ]; then
    echo \"$1/index.md\" not found
    return
fi

sed -i -e "s|($1/|(/$1/|g" -e "s/\.md/\.html/g" $1/index.md
