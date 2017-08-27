
#
# Copyright 2014-2017 Katherine Flavel
#
# See LICENCE for the full copyright terms.
#

MKDIR ?= mkdir

mkdir:: ${DIR}

.for dir in ${DIR}
${dir}: ${dir:H}
	${MKDIR} -p ${dir}
.endfor

