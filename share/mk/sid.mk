
#
# Copyright 2014-2017 Katherine Flavel
#
# See LICENCE for the full copyright terms.
#

SID ?= sid

SID_CFLAGS += -s no-numeric-terminals -s no-terminals

.for parser in ${PARSER}

SID.${parser} ?= ${parser:R}.sid
ACT.${parser} ?= ${parser:R}.act

${parser:R}.c ${parser:R}.h: ${SID.${parser}} ${ACT.${parser}}
	${SID} -l ansi-c ${SID_CFLAGS} ${SID_CFLAGS.${parser}} \
		${.ALLSRC:M*.sid} ${.ALLSRC:M*.act} ${parser:R}.c ${parser:R}.h \
		|| { rm -f ${parser:R}.c ${parser:R}.h; false; }

${parser:R}.h: ${SID.${parser}} ${ACT.${parser}}
${parser:R}.c: ${SID.${parser}} ${ACT.${parser}}

test::
	${SID} -l test ${SID.${parser}}

gen:: ${parser:R}.c ${parser:R}.h

.endfor

