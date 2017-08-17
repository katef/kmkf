
#
# Copyright 2014-2017 Katherine Flavel
#
# See LICENCE for the full copyright terms.
#

STRIP ?= strip

LFLAGS ?=

DIR += ${BUILD}/bin

.if ${CC:T:Mgcc} && defined(ASAN)
LFLAGS += -fsanitize=address
.endif

.if ${CC:T:Mclang} && defined(ASAN)
LFLAGS += -fsanitize=address
.endif

.for prog in ${PROG}

prog::   ${BUILD}/bin/${prog}
CLEAN += ${BUILD}/bin/${prog}

${BUILD}/bin/${prog}:
	${CC} -o $@ ${LFLAGS} ${.ALLSRC:M*.o} ${.ALLSRC:M*.a} ${LFLAGS.${prog}}
.if !defined(DEBUG) && !defined(NOSTRIP)
	${STRIP} $@
.endif

MODE.bin/${prog} = 755
STAGE_BUILD += bin/${prog}

.endfor

