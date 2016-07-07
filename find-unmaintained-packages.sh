#!/bin/bash
set -e
#set -x

gentoo_src="${HOME}/src/gentoo"

for y in "${gentoo_src}"/*/*/
do
    # Eclasses, profiles, licenses, etc.
    if [ ! -d ${y} ] || [ -z "$(ls -1 ${y}/*\.ebuild 2>/dev/null)" ]
    then
        #echo "skipping $y"
        continue
    fi

    x=${y}/metadata.xml

    # There are at least two ways things could be unmaintained:

    # 1) 'maintainer' is missing from metadata.xml: (done):
    grep -L maintainer ${x} > /dev/null 2>&1 && echo "$(dirname ${x#$gentoo_src} | cut -d/ -f2-) (maintainer not in metadata.xml)"

    # 2) 'maintainer-needed' is present in metadata.xml:
    grep -H maintainer-needed ${x} > /dev/null 2>&1 && echo "$(dirname ${x#$gentoo_src} | cut -d/ -f2-) (maintainer-needed in metadata.xml)"

done
