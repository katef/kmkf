
#
# Copyright 2014-2017 Katherine Flavel
#
# See LICENCE for the full copyright terms.
#

AR     ?= ar
RANLIB ?= ar s

ARFLAGS  ?= cr

.for lib in ${LIB}

lib::    ${BUILD}/lib/${lib}.a
CLEAN += ${BUILD}/lib/${lib}.a
CLEAN += ${BUILD}/lib/${lib}.o

${BUILD}/lib/${lib}.a: ${BUILD}/lib/${lib}.o
	${AR} ${ARFLAGS}${ARFLAGS.${lib}} $@ ${.ALLSRC:M*.o}
	${RANLIB} $@

STAGE_BUILD += lib/${lib}.a

.endfor

