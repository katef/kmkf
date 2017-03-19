
#
# Copyright 2014-2017 Katherine Flavel
#
# See LICENCE for the full copyright terms.
#

CD  ?= cd
TOP ?= ..

.ifndef BUILD
all .DEFAULT:
	${CD} ${TOP} && ${MAKE} ${.TARGETS}
.endif

