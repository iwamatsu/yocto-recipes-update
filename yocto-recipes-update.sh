#!/bin/bash

POKY_REPO_BASE="${HOME}/dev/yocto/poky"
POKY_WORK_BASE="${HOME}/dev/yocto/yocto-recipe-lists/"
MACHINES="qemuarm"
TARGET_CODENAME="morty pyro rocko sumo master"

# basedir
if [ ! -d ${POKY_WORK_BASE} ] ; then
    mkdir -p ${POKY_WORK_BASE}
fi

# work dir
if [ ! -d ${POKY_WORK_BASE}/w ] ; then
    mkdir -p ${POKY_WORK_BASE}/w
fi

# log dir
if [ ! -d ${POKY_WORK_BASE}/log ] ; then
    mkdir -p ${POKY_WORK_BASE}/log
fi

if [ ! -d ${POKY_REPO_BASE} ] ; then
    git clone git://git.yoctoproject.org/poky ${POKY_REPO_BASE}
fi

cd $POKY_REPO_BASE

git remote update

for codename in ${TARGET_CODENAME}; do
    echo "${codename} ...."

    git archive --format=tar --prefix=poky-${codename}/ origin/${codename} | gzip > $POKY_WORK_BASE/w/poky-${codename}.tar.gz

    cd ${POKY_WORK_BASE}/w
    tar -xzf poky-${codename}.tar.gz

    for machine in ${MACHINES} ; do
        cd poky-${codename}
        rm -rf ../build-${codename}-${machine}/conf/*
        source ./oe-init-build-env ../build-${codename}-${machine} > /dev/null 2>&1
        # other

	cat <<-EOF >> conf/local.conf
DL_DIR = "\${TOPDIR}/../downloads"
SSTATE_DIR ?= "\${TOPDIR}/../sstate-cache"
TMPDIR = "\${TOPDIR}/tmp"
MACHINE = "${machine}"
	EOF

        bitbake-layers show-recipes > ${POKY_WORK_BASE}/log/poky-${codename}.${machine}.show-recipes.lists
    done # target

    cd ${POKY_REPO_BASE}
done # codename

