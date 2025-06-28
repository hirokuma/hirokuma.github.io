#!/bin/bash

SITEMAP="my-sitemap.xml"

rm -f $SITEMAP
curl --silent -o $SITEMAP https://blog.hirokuma.work/sitemap.xml
