
#
# Copyright 2014-2017 Katherine Flavel
#
# See LICENCE for the full copyright terms.
#

LD ?= ld
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

.if ${SYSTEM} == Darwin
.if !empty(SYMS.${part})

${BUILD}/lib/${part}.o:    ${BUILD}/${SYMS.${part}}-macho
${BUILD}/lib/${part}.opic: ${BUILD}/${SYMS.${part}}-macho

${BUILD}/${SYMS.${part}}-macho: ${SYMS.${part}}
	${SED} ${SEDFLAGS} -e '/^[^#]/ s,^,_,' ${SYMS.${part}} > $@

LDRFLAGS.${part} += -exported_symbols_list ${BUILD}/${SYMS.${part}}-macho

CLEAN += ${BUILD}/${SYMS.${part}}-macho

.endif
.endif

${BUILD}/lib/${part}.o:
	${LD} -r -o $@ ${.ALLSRC:M*.o} ${LDRFLAGS} ${LDRFLAGS.${part}}
.if ${SYSTEM} != Darwin
.if !empty(SYMS.${part})
	${OBJCOPY} --keep-global-symbols=${SYMS.${part}} $@ $@
.endif
.endif
.if !defined(DEBUG) && !defined(NOSTRIP)
	${STRIP} -x $@
.endif

${BUILD}/lib/${part}.opic:
	${LD} -r -o $@ ${.ALLSRC:M*.opic} ${LDRFLAGS} ${LDRFLAGS.${part}}
.if ${SYSTEM} != Darwin
.if !empty(SYMS.${part})
	${OBJCOPY} --keep-global-symbols=${SYMS.${part}} $@ $@
.endif
.endif
.if !defined(DEBUG) && !defined(NOSTRIP)
	${STRIP} -x $@
.endif

.endfor

