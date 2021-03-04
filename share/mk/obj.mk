
#
# Copyright 2014-2017 Katherine Flavel
#
# See LICENCE for the full copyright terms.
#

UNAME ?= uname
UNAME_SYSTEM != ${UNAME} -s
SYSTEM ?= ${UNAME_SYSTEM}
MACOSX_VERSION_MIN ?= 10.6

CFLAGS_PIC ?= -fPIC

.for dir in ${INCDIR}
CFLAGS += -I ${dir}
.endfor

.for src in ${SRC}
.for dir in ${INCDIR.${src}}
CFLAGS.${src} += -I ${dir}
.endfor
.endfor

# wasm-strip(1) does something totally different
.if ${CC:T:Memcc*}
NOSTRIP = 1
.endif

.if ${CC:T:Memcc*}
.if defined(DEBUG)
# TODO: --emit-symbol-map
CFLAGS += -O1 -g4
CFLAGS += -profiling
CFLAGS += -s ASSERTIONS=1 -s STACK_OVERFLOW_CHECK=1 -s EMULATE_FUNCTION_POINTER_CASTS=1
#CFLAGS += -s SAFE_HEAP=1 # would require a env::segfault definition
.else
CFLAGS += -Oz -g0
.endif
CFLAGS += -s WASM=1 -s STANDALONE_WASM=1
CFLAGS += -s STRICT=1
CFLAGS += -s MALLOC=emmalloc -s ABORTING_MALLOC=0
CFLAGS += -Wno-warn-absolute-paths
.endif

.if ${CC:T:Mgcc*}
.if defined(DEBUG)
CFLAGS += -std=c89 -pedantic
#CFLAGS += -Werror
CFLAGS += -Wall -Wextra -Wno-system-headers
CFLAGS += -ggdb
CFLAGS += -O0 # or -Og if you have it
CFLAGS += -fno-omit-frame-pointer
.else
CFLAGS += -std=c89 -pedantic
CFLAGS += -O3
.endif
.if defined(ASAN)
CFLAGS += -fsanitize=address
.endif
.if defined(UBSAN)
# no unsigned-integer-overflow,implicit-conversion for gcc
CFLAGS += -fsanitize=undefined,float-divide-by-zero,bounds
.endif
.endif

.if ${CC:T:Mclang*}
.if defined(DEBUG)
CFLAGS += -std=c89 -pedantic
#CFLAGS += -Werror
CFLAGS += -Wall -Wextra -Wno-system-headers
CFLAGS += -Wno-padded # padding is not an error
CFLAGS += -O0
CFLAGS += -fno-omit-frame-pointer
.else
CFLAGS += -ansi -pedantic
CFLAGS += -O3
.endif
.if defined(ASAN)
CFLAGS += -fsanitize=address
.endif
.if defined(MSAN)
CFLAGS += -fsanitize=memory -fPIE
.endif
.if defined(UBSAN)
CFLAGS += -fsanitize=undefined,float-divide-by-zero,unsigned-integer-overflow,implicit-conversion,bounds
.endif
.endif

.if defined(DEBUG)
CFLAGS += -g
.else
CFLAGS += -DNDEBUG
.endif

.if ${CC:T:Mgcc*} || ${CC:T:Mclang*}
.if ${SYSTEM} == Darwin
CFLAGS += -mmacosx-version-min=${MACOSX_VERSION_MIN}
.endif
.endif

.for src in ${SRC}

CLEAN += ${BUILD}/${src:R}.o
CLEAN += ${BUILD}/${src:R}.opic

${BUILD}/${src:R}.o: ${src}
	${CC} -o $@ ${CFLAGS} ${CFLAGS.${src}} -c ${.ALLSRC:M*.c}

${BUILD}/${src:R}.opic: ${src}
	${CC} -o $@ ${CFLAGS_PIC} ${CFLAGS} ${CFLAGS.${src}} -c ${.ALLSRC:M*.c}

.endfor

