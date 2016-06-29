#!/bin/bash
set -e
#set -x

gentoo_src="${HOME}/src/gentoo"

for x in "${gentoo_src}"/*/*/metadata.xml
do
    grep -L maintainer $x > /dev/null 2>&1 && continue
    echo "$(dirname ${x#$gentoo_src} | cut -d/ -f2-)"
done
