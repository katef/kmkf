
#
# Copyright 2014-2017 Katherine Flavel
#
# See LICENCE for the full copyright terms.
#

MKDIR ?= mkdir

mkdir::

# some awkwardness to avoid :O:u for OpenBSD make(1)
DIR != echo ${DIR} | tr ' ' '\n' | sort | uniq

# Double-colon targets are always considered out of date,
# so even though these directories are up to date, they
# would always be recreated. Note there's no need to
# re-create an out of date directory anyway.
#
# So we avoid that situation here by only depending on
# directories which do not currently exist.

.for dir in ${BUILD} ${DIR}
.if !exists(${dir})
mkdir:: ${dir}
.endif
.endfor

# mkdir -p is used for ${BUILD} because that's used-specified
# and we don't know what directories might exist above that.
# Whereas for directories beneath it, we ought to account for
# them all and so purposefully do not use -p.

${BUILD}:
	${MKDIR} -p ${BUILD}

.for dir in ${DIR}
${dir}: ${dir:H}
	${MKDIR} ${dir}
.endfor

