
#
# Copyright 2014-2017 Katherine Flavel
#
# See LICENCE for the full copyright terms.
#

.if ${CC:T:Memcc*}
LD ?= ${CC}
.else
LD ?= ld
.endif

UNAME ?= uname
UNAME_SYSTEM != ${UNAME} -s
SYSTEM ?= ${UNAME_SYSTEM}
MACOSX_VERSION_MIN ?= 10.6

.if ${SYSTEM} == Darwin
LIBEXT ?= dylib
.else
LIBEXT ?= so
.endif

.if ${SYSTEM} == Darwin
LDSFLAGS ?= -dylib -flat_namespace -undefined dynamic_lookup
.else
LDSFLAGS ?= -shared
.endif

.if ${CC:T:Mgcc*} || ${CC:T:Mclang*}
.if ${SYSTEM} == Darwin
LDSFLAGS += -macosx_version_min ${MACOSX_VERSION_MIN}
.endif
.endif

.if empty(DIR:M${BUILD}/lib)
DIR += ${BUILD}/lib
.endif

.for lib in ${LIB}

lib::    ${BUILD}/lib/${lib}.${LIBEXT}
CLEAN += ${BUILD}/lib/${lib}.${LIBEXT}

${BUILD}/lib/${lib}.${LIBEXT}: ${BUILD}/lib/${lib}.opic
	${LD} -o $@ ${LDSFLAGS} ${LDSFLAGS.${lib}} ${.ALLSRC:M*.opic}

STAGE_BUILD += lib/${lib}.${LIBEXT}

.endfor

