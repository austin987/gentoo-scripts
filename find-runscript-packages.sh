#!/bin/bash

#set -x

gentoo_src="$HOME/src/gentoo"

blacklist=( app-emulation/qemu-init-scripts \
    fake/package2 )

cd "$gentoo_src"

for x in */* ; do

for i in "${blacklist[@]}"
do
    if [ "$i" == "$x" ] ; then
        echo "Ignoring ${x}, blacklisted"
        break 1
    fi
done

files=$(grep -rl "#!/sbin/runscript" ${x}/files/* 2>/dev/null)
if [[ -z ${files} ]] ; then
    #echo "Package is clean"
    continue
else
    echo "$runscript usage found in ${x}, ${files}"

    for f in ${files} ; do
       echo "Updating ${f}"
       sed 's%#!/sbin/runscript%#!/sbin/openrc-run%g' -i ${f}
    done
    
    git commit ${x} -m "${x}: use #!/sbin/openrc-run instead of #!/sbin/runscript"
fi
done
