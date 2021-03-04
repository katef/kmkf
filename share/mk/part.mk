
#
# Copyright 2014-2017 Katherine Flavel
#
# See LICENCE for the full copyright terms.
#

.if ${CC:T:Memcc*}
LD ?= ${CC}
# emcc seems to apply the same flags for both link and compile time
LDRFLAGS += ${CFLAGS}
.else
LD ?= ld
.endif

STRIP ?= strip
UNAME ?= uname
UNAME_SYSTEM != ${UNAME} -s
SYSTEM ?= ${UNAME_SYSTEM}
OBJCOPY ?= objcopy

SED      ?= sed
SEDFLAGS ?=

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

.if !empty(SYMS.${part})

${BUILD}/lib/${part}.o:    ${BUILD}/${SYMS.${part}}
${BUILD}/lib/${part}.opic: ${BUILD}/${SYMS.${part}}

# not all symbol-stripping mechanisms support comments
SEDFLAGS.${SYMS.${part}} += -e 's,\#.*,,; /^$$/ d'

.if ${SYSTEM} == Darwin
SEDFLAGS.${SYMS.${part}} += -e 's,^,_,'
.endif

${BUILD}/${SYMS.${part}}: ${SYMS.${part}}
	${SED} ${SEDFLAGS} ${SEDFLAGS.${SYMS.${part}}} ${SYMS.${part}} > $@

CLEAN += ${BUILD}/${SYMS.${part}}

.endif

.if !empty(SYMS.${part})
.if ${SYSTEM} == Darwin
LDRFLAGS.${part} += -exported_symbols_list ${BUILD}/${SYMS.${part}}
.endif
.endif

${BUILD}/lib/${part}.o:
	${LD} -r -o $@ ${.ALLSRC:M*.o} ${LDRFLAGS} ${LDRFLAGS.${part}}
.if !${CC:T:Memcc*}
.if ${SYSTEM} != Darwin
.if !empty(SYMS.${part})
	${OBJCOPY} --keep-global-symbols=${BUILD}/${SYMS.${part}} $@ $@
.endif
.endif
.if !defined(DEBUG) && !defined(NOSTRIP)
	${STRIP} -x $@
.endif
.endif

${BUILD}/lib/${part}.opic:
	${LD} -r -o $@ ${.ALLSRC:M*.opic} ${LDRFLAGS} ${LDRFLAGS.${part}}
.if !${CC:T:Memcc*}
.if ${SYSTEM} != Darwin
.if !empty(SYMS.${part})
	${OBJCOPY} --keep-global-symbols=${BUILD}/${SYMS.${part}} $@ $@
.endif
.endif
.if !defined(DEBUG) && !defined(NOSTRIP)
	${STRIP} -x $@
.endif
.endif

.endfor

