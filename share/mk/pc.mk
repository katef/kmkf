
#
# Copyright 2014-2017 Katherine Flavel
#
# See LICENCE for the full copyright terms.
#

SED      ?= sed
SEDFLAGS ?=

PCDIR ?= share/pkgconfig

.for pc in ${PC}

install:: ${BUILD}/${pc:R}
CLEAN +=  ${BUILD}/${pc:R}

DIR.${pc:R} ?= ${PCDIR}

# built as a dependency from the install target,
# so that other targets do not require ${PREFIX}.
${BUILD}/${pc:R}: ${pc}
	${SED} ${SEDFLAGS} ${SEDFLAGS.${pc}} \
		-e 's,@prefix@,${PREFIX},g' ${.ALLSRC:M*.in} > $@

STAGE_BUILD += ${pc:R}

.endfor

