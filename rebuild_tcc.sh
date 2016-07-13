#!/bin/bash
set -x
set -e

# https://wiki.gentoo.org/wiki/Clang#Using_clang_with_portage
# https://wiki.gentoo.org/wiki/Binary_package_guide#Creating_binary_packages

# FIXME: flesh out init here:
rm -rf results
mkdir -p results

build_packages()
{
# FIXME: store in a variable not a file (or at least a proper tempfile..):
for x in $(cat $1)
do
    rm -rf /var/portage/packages/*/ /var/tmp/portage/*/
    set +e
    echo "========================================================="
    echo "step: $STEP package: $x"
    echo "========================================================="
    MAKEOPTS="-j1" emerge -Bv $x
    if [ $? -ne 0 ]
    then
        if [ "$STEP" = "false" ]
        then
            echo "step $x failed (and STEP is false), putting in fails_without_cc.list"
            echo "$x" >> fails_without_cc.list
        else
            echo "step $x failed, getting logs"
            echo "$x" >> fail.list
            mkdir -p ~/build_logs/${STEP}/
            rsync -avp /var/tmp/portage/${x}* ~/build_logs/${STEP}/
        fi
    else
        if [ "$STEP" = "false" ]
        then
            echo "step $x succeeded (and STEP is false), putting in builds_without_cc.list"
            echo "$x" >> builds_without_cc.list
        else
            echo "step $x succeeded, putting in good.list"
            echo "$x" >> good.list
        fi
    fi
    set -e
done
}

run_step()
{
    rm -rf good.list fail.list builds_without_cc.list fails_without_cc.list
    export STEP=$1
    if [ "$1" = "false" ]
    then
            build_packages buildlist  2>&1 | tee step_${1}.log
            if [ -f fails_without_cc.list ] ; then
                cp fails_without_cc.list results/step_false_fails_without_cc.list
            fi
            if [ -f builds_without_cc.list ] ; then
                cp builds_without_cc.list results/step_false_builds_without_cc.list
            fi
            cp fails_without_cc.list buildlist
    else
            build_packages buildlist  2>&1 | tee step_${1}.log
            if [ -f fail.list ] ; then 
                cp fail.list results/step_${1}.fail
            fi
            if [ -f good.list ] ; then
                cp good.list results/step_${1}.good
                cp good.list buildlist
            fi
    fi
}

# Initial setup:
qlist --nocolor -I | sort -u > installed
cp installed results/installed

cat installed | sed -e 's/$/ tcc/' -e '/dev-lang\/tcc/d' > /etc/portage/package.env/tcc
mv installed buildlist

# first remove non-C packages:
echo -e "CC=false\nCXX=false" > /etc/portage/env/tcc
run_step false

# sanity check (make sure it builds with just gcc):
echo -e "CC=gcc\nCXX=false" > /etc/portage/env/tcc
run_step gcc

# portability check (if it passes clang and gcc, more likely to be a tcc bug)
# See also: 
echo -e "CC=clang\nCXX=false" > /etc/portage/env/tcc
run_step clang

# tcc check:
echo -e "CC=tcc\nCXX=false" > /etc/portage/env/tcc

# Make sure we're testing against tcc from mob:
ACCEPT_KEYWORDS="**" emerge -v1 =tcc-9999
run_step tcc

good_count=$(wc -l results/step_tcc.good)
bad_count=$(wc -l results/step_tcc.fail)

echo "Done building. good packages: $good_count broken packages: $bad_count"
