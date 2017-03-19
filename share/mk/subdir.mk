
#
# Copyright 2014-2017 Katherine Flavel
#
# See LICENCE for the full copyright terms.
#

.for dir in ${SUBDIR}

.include "${dir}/Makefile"

DIR += ${BUILD}/${dir}

.endfor

