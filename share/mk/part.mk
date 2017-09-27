
#
# Copyright 2014-2017 Katherine Flavel
#
# See LICENCE for the full copyright terms.
#

LD ?= ld

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

${BUILD}/lib/${part}.opic:
	${LD} -r -o $@ ${.ALLSRC:M*.opic} ${LDRFLAGS} ${LDRFLAGS.${part}}

.endfor

