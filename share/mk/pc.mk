
#
# Copyright 2014-2017 Katherine Flavel
#
# See LICENCE for the full copyright terms.
#

SED      ?= sed
SEDFLAGS ?=

PCDIR ?= share/pkgconfig

.for pc in ${PC}

all::    ${BUILD}/${pc:R}
CLEAN += ${BUILD}/${pc:R}

DIR_${pc:R} ?= ${PCDIR}

${BUILD}/${pc:R}: ${pc}
	${SED} ${SEDFLAGS} -e 's,@prefix@,${PREFIX},g' ${.ALLSRC:M*.in} > $@

STAGE_BUILD += ${pc:R}

.endfor

