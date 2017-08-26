
#
# Copyright 2014-2017 Katherine Flavel
#
# See LICENCE for the full copyright terms.
#

CFLAGS_PIC ?= -fPIC

.for dir in ${INCDIR}
CFLAGS += -I ${dir}
.endfor

.for src in ${SRC}
.for dir in ${INCDIR.${src}}
CFLAGS.${src} += -I ${dir}
.endfor
.endfor

.if ${CC:T:Mgcc}
.if defined(DEBUG)
CFLAGS += -std=c89 -pedantic
#CFLAGS += -Werror
CFLAGS += -Wall -Wextra -Wno-system-headers
CFLAGS += -ggdb
CFLAGS += -O0 # or -Og if you have it
.else
CFLAGS += -std=c89 -pedantic
CFLAGS += -O3
.endif
.if defined(ASAN)
CFLAGS += -fsanitize=address -fno-omit-frame-pointer
.endif
.endif

.if ${CC:T:Mclang}
.if defined(DEBUG)
CFLAGS += -std=c89 -pedantic
#CFLAGS += -Werror
CFLAGS += -Wall -Wextra -Wno-system-headers
CFLAGS += -Wno-padded # padding is not an error
CFLAGS += -O0
.else
CFLAGS += -ansi -pedantic
CFLAGS += -O3
.endif
.if defined(ASAN)
CFLAGS += -fsanitize=address -fno-omit-frame-pointer
.endif
.endif

.if defined(DEBUG)
CFLAGS += -g
.else
CFLAGS += -DNDEBUG
.endif

.for src in ${SRC}

CLEAN += ${BUILD}/${src:R}.o

${BUILD}/${src:R}.o: ${src}
	${CC} -o $@ ${CFLAGS} ${CFLAGS.${src}} -c ${.ALLSRC:M*.c}

${BUILD}/${src:R}.opic: ${src}
	${CC} -o $@ ${CFLAGS_PIC} ${CFLAGS} ${CFLAGS.${src}} -c ${.ALLSRC:M*.c}

.endfor

