#!/bin/bash
set -e
#set -x

# Iterate through the tree, find the latest ebuild (by version number,
# not date), and run given command. Useful for mass cleanups where older
# ebuilds aren't going to be fixed.

gentoo_src="${HOME}/src/gentoo"

# Deprecated games eclass:
# As of 2016/06/07: 777
#command_to_run="grep -H inherit.*games"

# EAPI 1:
# As of 2016/06/07: 1386
#command_to_run="grep -L EAPI="

# EAPI 2-4:
# As of 2016/06/07: 2276
#command_to_run="grep -H EAPI=.*[2..4]"


command_to_run=""


for x in ${gentoo_src}/*/*
do
    # Eclasses, profiles, licenses, etc.
    if [ ! -d $x ] || [ -z "$(ls -1 ${x}/*\.ebuild 2>/dev/null)" ] ;
    then
        #echo "skipping $x"
        continue
    fi

    y="$(ls -1 ${x}/*\.ebuild | sort -V | tail -n1)"
    #echo "$x's latest ebuild is $y"
    ${command_to_run} ${y} 2>/dev/null || continue
done
