
#
# Copyright 2014-2017 Katherine Flavel
#
# See LICENCE for the full copyright terms.
#

MKDIR ?= mkdir

mkdir::

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

${BUILD}:
	${MKDIR} -p ${BUILD}

.for dir in ${DIR}
${dir}: ${dir:H}
	${MKDIR} ${dir}
.endfor

