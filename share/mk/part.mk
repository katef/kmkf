
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

# Workaround for a bug in FreeBSD's objcopy, where --keep-global-symbols=file
# does not make *other* symbols local, as giving --keep-global-symbol=name
# (that's singular) for each symbol does.
# I reported this here: https://sourceforge.net/p/elftoolchain/tickets/610/
#
# My workaround is to override ${OBJCOPY} with a wrapper that converts the
# --keep-global-symbols=file argument to expand out the file's list to
# --keep-global-symbol=name (-G for short) for each symbol,
# and then call the original ${OBJCOPY}.
#
# This is illegible, but it does keep the workaround in one place (we don't need
# an external script), and it keeps the conditional logic out of the callers.
objcopy_ver != ${OBJCOPY} --version
.if ${objcopy_ver:M*elftoolchain*}
OBJCOPY := f() { $$$$1 $$$$(${SED} s,^,-G, $$$${2\#\#--keep-global-symbols=}) $$$$3 $$$$4; }; f ${OBJCOPY}
.endif

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

