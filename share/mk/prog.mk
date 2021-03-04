
#
# Copyright 2014-2017 Katherine Flavel
#
# See LICENCE for the full copyright terms.
#

STRIP ?= strip
WASM_VALIDATE ?= wasm-validate

LFLAGS ?=

.if empty(DIR:M${BUILD}/bin)
DIR += ${BUILD}/bin
.endif

.if ${CC:T:Memcc*}
# emcc seems to apply the same flags for both link and compile time
LFLAGS += ${CFLAGS}
.endif

.if ${CC:T:Mgcc*} && defined(ASAN)
LFLAGS += -fsanitize=address
.endif
.if ${CC:T:Mgcc*} && defined(UBSAN)
# no unsigned-integer-overflow,implicit-conversion for gcc
LFLAGS += -fsanitize=undefined,float-divide-by-zero,bounds
.endif

.if ${CC:T:Mclang*} && defined(ASAN)
LFLAGS += -fsanitize=address
.endif
.if ${CC:T:Mclang*} && defined(MSAN)
LFLAGS += -fsanitize=memory -fPIE -pie
.endif
.if ${CC:T:Mclang*} && defined(UBSAN)
LFLAGS += -fsanitize=undefined,float-divide-by-zero,unsigned-integer-overflow,implicit-conversion,bounds
.endif

.if defined(EFENCE)
LFLAGS += -lefence
.endif

.for prog in ${PROG}

.if ${CC:T:Memcc*}
prog::   ${BUILD}/bin/${prog}.wasm
CLEAN += ${BUILD}/bin/${prog}.wasm
.else
prog::   ${BUILD}/bin/${prog}
CLEAN += ${BUILD}/bin/${prog}
.endif

# .USE so we can pick up dependencies scattered throughout the project Makefiles
.if ${CC:T:Memcc*}
${BUILD}/bin/${prog}: .USE
.endif

.if ${CC:T:Memcc*}
${BUILD}/bin/${prog}.wasm: ${BUILD}/bin/${prog}
.else
${BUILD}/bin/${prog}:
.endif
	${CC} -o $@ ${LFLAGS}${EXT} ${.ALLSRC:M*.o} ${.ALLSRC:M*.a} ${LFLAGS.${prog}}
.if !defined(DEBUG) && !defined(NOSTRIP)
	${STRIP} $@
.endif

.if ${CC:T:Memcc*}
MODE.bin/${prog}.wasm = 655
STAGE_BUILD += bin/${prog}.wasm
.else
MODE.bin/${prog} = 755
STAGE_BUILD += bin/${prog}
.endif

test::
.if ${CC:T:Memcc*}
	${WASM_VALIDATE} ${BUILD}/bin/${prog}.wasm
.endif

.endfor

