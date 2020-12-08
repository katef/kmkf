
#
# Copyright 2014-2017 Katherine Flavel
#
# See LICENCE for the full copyright terms.
#

STRIP ?= strip

LFLAGS ?=

.if empty(DIR:M${BUILD}/bin)
DIR += ${BUILD}/bin
.endif

.if ${CC:T:Mgcc} && defined(ASAN)
LFLAGS += -fsanitize=address
.endif
.if ${CC:T:Mgcc} && defined(UBSAN)
LFLAGS += -fsanitize=undefined,float-divide-by-zero,unsigned-integer-overflow,implicit-conversion,bounds
.endif

.if ${CC:T:Mclang} && defined(ASAN)
LFLAGS += -fsanitize=address
.endif
.if ${CC:T:Mclang} && defined(MSAN)
LFLAGS += -fsanitize=memory -fPIE -pie
.endif
.if ${CC:T:Mclang} && defined(UBSAN)
LFLAGS += -fsanitize=undefined,float-divide-by-zero,unsigned-integer-overflow,implicit-conversion,bounds
.endif

.if defined(EFENCE)
LFLAGS += -lefence
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

