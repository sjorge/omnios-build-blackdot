#!/usr/bin/bash
#
# CDDL HEADER START
#
# The contents of this file are subject to the terms of the
# Common Development and Distribution License, Version 1.0 only
# (the "License").  You may not use this file except in compliance
# with the License.
#
# You can obtain a copy of the license at usr/src/OPENSOLARIS.LICENSE
# or http://www.opensolaris.org/os/licensing.
# See the License for the specific language governing permissions
# and limitations under the License.
#
# When distributing Covered Code, include this CDDL HEADER in each
# file and include the License file at usr/src/OPENSOLARIS.LICENSE.
# If applicable, add the following below this CDDL HEADER, with the
# fields enclosed by brackets "[]" replaced with your own identifying
# information: Portions Copyright [yyyy] [name of copyright owner]
#
# CDDL HEADER END
#
#
# Copyright 2011-2012 OmniTI Computer Consulting, Inc.  All rights reserved.
# Use is subject to license terms.
#
# Load support functions
. ../../lib/functions.sh

PROG=unrar                                  # App name
VER=4.0.7                                   # App version
VERHUMAN=$VER-1                             # Human-readable version
#PVER=                                      # Branch (set in config.sh, override here if needed)
PKG=archiver/unrar                          # Package name (e.g. library/foo)
SUMMARY="RAR archive extractor"
DESC="WinRAR is a powerful archive manager. It can backup your data and reduce the size of email attachments, decompress RAR, ZIP and other files downloaded from Internet and create new archives in RAR and ZIP file format. You can try WinRAR before buy, its trial version is available in downloads"
DEPENDS_IPS=""

BUILDARCH=both

# Nothing to configure or build, just package
prep_build () {
    logmsg "Preparing for build"

    # Get the current date/time for the package timestamp
    DATETIME=`TZ=UTC /usr/bin/date +"%Y%m%dT%H%M%SZ"`

    logmsg "--- Creating temporary install dir"
    # We might need to encode some special chars
    PKGE=$(url_encode $PKG)
    # For DESTDIR the '%' can cause problems for some install scripts
    PKGD=${PKGE//%/_}
    DESTDIR=$DTMPDIR/${PKGD}_pkg
    if [[ -z $DONT_REMOVE_INSTALL_DIR ]]; then
        logcmd chmod -R u+w $DESTDIR > /dev/null 2>&1
        logcmd rm -rf $DESTDIR || \
            logerr "Failed to remove old temporary install dir"
        mkdir -p $DESTDIR || \
            logerr "Failed to create temporary install dir"
    fi

    # cleanup source
    [ -d ${TMPDIR}/src/ ] && rm -rf ${TMPDIR}/src/
    [ -d ${TMPDIR}/staging/ ] && rm -rf ${TMPDIR}/staging/

    # fetch source
    mkdir ${TMPDIR}/src

    # fetch source
    wget -c http://www.rarlab.com/rar/unrarsrc-${VER}.tar.gz -O ${TMPDIR}/src/${PROG}-${VER}.tar.gz

    # expand source and copy patches
    tar xzf ${TMPDIR}/src/${PROG}-${VER}.tar.gz -C ${TMPDIR}/src
    cp patches/* ${TMPDIR}/src/${PROG}/
    cp files/unrar.1 ${TMPDIR}/src/${PROG}/

}

build32 () {
    pushd $TMPDIR > /dev/null

    export PATH=/opt/gcc-4.7.2/bin:$PATH
    cd ${TMPDIR}/src/${PROG}/

    cp makefile.unix makefile.illumos32
    patch < makefile-i386.patch

    /usr/gnu/bin/make -f makefile.illumos32 clean
    /usr/gnu/bin/make -f makefile.illumos32

    cp unrar unrar-i386

    popd > /dev/null
}

build64() {
    pushd $TMPDIR > /dev/null

    export PATH=/opt/gcc-4.7.2/bin:$PATH
    cd ${TMPDIR}/src/${PROG}/

    cp makefile.unix makefile.illumos64
    patch < makefile-amd64.patch

    /usr/gnu/bin/make -f makefile.illumos64 clean
    /usr/gnu/bin/make -f makefile.illumos64
    
    cp unrar unrar-amd64

    popd > /dev/null
}

make_install() {
    logmsg "--- make install"
    logcmd mkdir -p $DESTDIR$PREFIX/bin/{i386,amd64} || \
        logerr "------ Failed to create architecture destination directory."
    logcmd cp ${TMPDIR}/src/${PROG}/unrar-i386 $DESTDIR$PREFIX/bin/i386/unrar || \
        logerr "------ Failed to install i386 binaries."
    logcmd cp ${TMPDIR}/src/${PROG}/unrar-amd64 $DESTDIR$PREFIX/bin/amd64/unrar || \
        logerr "------ Failed to install amd64 binaries."

    logcmd mkdir -p $DESTDIR$PREFIX/share/man/man1 || \
        logerr "------ Failed to create man1."
    logcmd cp ${TMPDIR}/src/${PROG}/unrar.1 $DESTDIR$PREFIX/share/man/man1/ || \
        logerr "------ Failed to install man pages."
}

init
prep_build
build
make_install
make_isa_stub
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et: