
#
# Copyright 2014-2017 Katherine Flavel
#
# See LICENCE for the full copyright terms.
#

INSTALL ?= install

.for stage in ${STAGE_BUILD} ${STAGE_COPY}

DIR.${stage}  ?= ${stage:H}
MODE.${stage} ?= 644

.for dir in ${DIR.${stage}}
STAGE_DIR += ${dir}
MODE.${dir} ?= 755
.endfor

.endfor

# some awkwardness to avoid :O:u for OpenBSD make(1)
STAGE_DIR != echo ${STAGE_DIR} | tr ' ' '\n' | sort | uniq

install::
.for dir in ${STAGE_DIR}
	${INSTALL} -m ${MODE.${dir}} -d ${PREFIX}/${dir}
.endfor
.for stage in ${STAGE_BUILD}
	${INSTALL} -m ${MODE.${stage}} ${BUILD}/${stage} ${PREFIX}/${DIR.${stage}}/${stage:T}
.endfor
.for stage in ${STAGE_COPY}
	${INSTALL} -m ${MODE.${stage}} ${stage} ${PREFIX}/${DIR.${stage}}/${stage:T}
.endfor

.for stage in ${STAGE_BUILD}
install:: ${BUILD}/${stage}
.endfor
.for stage in ${STAGE_COPY}
install:: ${stage}
.endfor

