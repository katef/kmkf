
#
# Copyright 2014-2017 Katherine Flavel
#
# See LICENCE for the full copyright terms.
#

LD ?= ld
UNAME ?= uname
UNAME_SYSTEM != ${UNAME} -s
SYSTEM ?= ${UNAME_SYSTEM}
OBJCOPY ?= objcopy

LDRFLAGS ?=

.if empty(DIR:M${BUILD}/lib)
DIR += ${BUILD}/lib
.endif

# objects are collated for libraries to avoid passing
# possibly conflicting filenames to ar(1)
.for lib in ${LIB}
PART += ${lib}
.endfor

.for part in ${PART}

CLEAN += ${BUILD}/lib/${part}.o
CLEAN += ${BUILD}/lib/${part}.opic

${BUILD}/lib/${part}.o:
	${LD} -r -o $@ ${.ALLSRC:M*.o} ${LDRFLAGS} ${LDRFLAGS.${part}}
.if ${SYSTEM} != Darwin
.if !empty(SYMS.${part})
	${OBJCOPY} --keep-global-symbols=${SYMS.${part}} $@ $@
.endif
.endif

${BUILD}/lib/${part}.opic:
	${LD} -r -o $@ ${.ALLSRC:M*.opic} ${LDRFLAGS} ${LDRFLAGS.${part}}
.if ${SYSTEM} != Darwin
.if !empty(SYMS.${part})
	${OBJCOPY} --keep-global-symbols=${SYMS.${part}} $@ $@
.endif
.endif

.endfor

