
#
# Copyright 2018 Katherine Flavel
#
# See LICENCE for the full copyright terms.
#

XSLTPROC ?= xsltproc
XMLLINT ?= xmllint
GZIP ?= gzip -fq

XSLT_FLAGS += --nomkdir --nonet

XMLLINT_FLAGS += --nonet

XML_FLAGS += --xinclude
#XML_FLAGS += --encoding utf8
XML_FLAGS += --path share/dtd

# The approach for producing roff here is a stand-in until I get around to
# writing what I'd really like. My eventual aim is to output mdoc macros
# from mdb. For the moment, so I can have *something*, I'm using the man
# macro output from Docbook XSLT. I don't like it very much.
#
# You can view output by simply man file.1, or render by:
# mandoc -K utf-8 -T utf8 -O indent=4 -c -man file.1

# URI resolved by XML catalog mechanism; no network access is involved.
# If you want to understand how XML catalogs work, please look at this
# helpful diagram: http://xmlsoft.org/catalog.gif
DBXSLT_MAN ?= http://docbook.sourceforge.net/release/xsl/current/manpages/docbook.xsl

# Docbook manpage XSLT parameters:
# http://docbook.sourceforge.net/release/xsl/1.79.1/doc/manpages/index.html
DBXSLT_FLAGS += --param man.hyphenate 1
DBXSLT_FLAGS += --param man.justify 1
DBXSLT_FLAGS += --param man.endnotes.are.numbered 0 # elide glossary links
DBXSLT_FLAGS += --param man.output.subdirs.enabled 0
DBXSLT_FLAGS += --param man.output.in.separate.dir 1
DBXSLT_FLAGS += --param man.output.quietly 1

.if !defined(NODOC)

.if empty(DIR:M${BUILD}/man)
DIR += ${BUILD}/man
.endif

doc::
	# checking for XML catalog entry for Docbook XSLT
	${XSLTPROC} --nonet --nowrite ${DBXSLT_MAN}

.for man in ${MAN}

${BUILD}/${man:H}/${man:T:R}: ${man}
	${XSLTPROC} ${XSLT_FLAGS} ${XML_FLAGS} ${DBXSLT_FLAGS} ${XML_FLAGS.${src}} \
		--stringparam man.output.base.dir ${BUILD}/${man:H}/ \
		${DBXSLT_MAN} ${man}

${BUILD}/${man:H}/${man:T:R}.gz: ${BUILD}/${man:H}/${man:T:R}
	${GZIP} -c ${BUILD}/${man:H}/${man:T:R} > $@

doc:: ${BUILD}/${man:H}/${man:T:R}.gz

CLEAN += ${BUILD}/${man}
CLEAN += ${BUILD}/${man:H}/${man:T:R}
CLEAN += ${BUILD}/${man:H}/${man:T:R}.gz

STAGE_COPY += ${BUILD}/${man:H}/${man:T:R}.gz
DIR.${BUILD}/${man:H}/${man:T:R}.gz = man/man${man:T:R:E}

test::
	${XMLLINT} --noout --dtdattr ${XMLLINT_FLAGS} ${XML_FLAGS} ${XML_FLAGS.${src}} ${man}

.endfor

.endif

