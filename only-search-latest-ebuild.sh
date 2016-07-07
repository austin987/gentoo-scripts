#!/bin/bash
set -e
#set -x

# Iterate through the tree, find the latest ebuild (by version number,
# not date), and run given command. Useful for mass cleanups where older
# ebuilds aren't going to be fixed.

gentoo_src="${HOME}/src/gentoo"

command_to_run="grep -H inherit.*games"

for x in ${gentoo_src}/*/*
do
    # Eclasses, profiles, licenses, etc.
    if [ ! -d $x ] || [ -z "$(ls -1 ${x}/*\.ebuild 2>/dev/null)" ] ;
    then
        #echo "skipping $x"
        continue
    fi

    y="$(ls -1 ${x}/*\.ebuild | tail -n1)"
    #echo "$x's latest ebuild is $y"
    ${command_to_run} ${y} 2>/dev/null || continue
done
