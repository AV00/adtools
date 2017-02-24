#!/bin/bash -x
#
# Simple shell script that is called in context of travis and that
# will build the current native adtools package.
#

make -C native-build -j4 CROSS_IS_PRESENT=1 native-install &>/tmp/build.out
