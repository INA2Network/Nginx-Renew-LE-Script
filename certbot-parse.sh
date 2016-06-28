#!/bin/sh
site=$1
sep=$2
sed -r 's/#.*//;s/ +//g;/^$/ d' "$site" | sed -r -z "s/\n(.)/${sep}\1/g"
