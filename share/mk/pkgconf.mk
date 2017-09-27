
#
# Copyright 2014-2017 Katherine Flavel
#
# See LICENCE for the full copyright terms.
#

PKGCONF ?= pkgconf # or pkg-config
PCFLAGS ?=

.for pkg in ${PKG}

.BEGIN::
	${PKGCONF} ${PCFLAGS} ${PCFLAGS.${pkg}} --exists ${pkg}

CFLAGS.${pkg} != ${PKGCONF} ${PCFLAGS} ${PCFLAGS.${pkg}} ${pkg} --cflags
LIBS.${pkg}   != ${PKGCONF} ${PCFLAGS} ${PCFLAGS.${pkg}} ${pkg} --libs

.endfor

