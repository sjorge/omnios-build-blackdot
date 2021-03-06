#!/usr/bin/bash
#
# CDDL HEADER START
#
# The contents of this file are subject to the terms of the
# Common Development and Distribution License, Version 1.0 only
# (the "License"). You may not use this file except in compliance
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
# Copyright 2011-2012 OmniTI Computer Consulting, Inc. All rights reserved.
# Copyright 2013 Jorge Schrauwen.  All rights reserved.
# Use is subject to license terms.
#
# Load support functions
. ../../lib/functions.sh
. ../myfunc.sh

PROG=pynagios
VER=0.1.1
PKG=library/python-2/pynagios
SUMMARY="Python library to write Nagios plugins."
DESC="PyNagios is a simple Python library meant to make writing Nagios plugins much easier. Nagios plugins have quite a few guidelines to adhere to, and PyNagios provides helpers to make this easy."

RUN_DEPENDS_IPS="runtime/python-26"
BUILD_DEPENDS_IPS="runtime/python-26"

download_source() {
    logmsg "Downloading Source"

    cd ${TMPDIR}
    wget -c https://pypi.python.org/packages/source/${PROG:0:1}/${PROG}/${PROG}-${VER}.tar.gz

    tar xvpf ${PROG}-${VER}.tar.gz
}


init
download_source $PROG $PROG $VER
patch_source
prep_build
python_build
make_package
auto_publish
clean_up
