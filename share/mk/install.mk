
#
# Copyright 2014-2017 Katherine Flavel
#
# See LICENCE for the full copyright terms.
#

INSTALL ?= install

REMOVE ?= rm -f
RMDIR  ?= rmdir

.for stage in ${STAGE_BUILD} ${STAGE_COPY}

DIR.${stage}  ?= ${stage:H}
MODE.${stage} ?= 644

.for dir in ${DIR.${stage}}
STAGE_DIR += ${dir}
MODE.${dir} ?= 755
.endfor

.endfor

# some awkwardness to avoid :O:u for OpenBSD make(1)
STAGE_DIR != echo ${STAGE_DIR} | tr ' ' '\n' | sort | uniq

install::
.for dir in ${STAGE_DIR}
	${INSTALL} -m ${MODE.${dir}} -d ${PREFIX}/${dir}
.endfor
.for stage in ${STAGE_BUILD}
	${INSTALL} -m ${MODE.${stage}} ${BUILD}/${stage} ${PREFIX}/${DIR.${stage}}/${stage:T}
.endfor
.for stage in ${STAGE_COPY}
	${INSTALL} -m ${MODE.${stage}} ${stage} ${PREFIX}/${DIR.${stage}}/${stage:T}
.endfor

.for stage in ${STAGE_BUILD}
install:: ${BUILD}/${stage}
.endfor
.for stage in ${STAGE_COPY}
install:: ${stage}
.endfor

# For "proper" package installation, I would expect a package manager to
# install to a staging area, take just what it needs, and provided its
# own uninstallation.
#
# An uninstall target is provided largely as convenience. It's tricky,
# because we can't keep track of exactly what may have been created
# during install (I would expect this to still work after `make clean`),
# and we don't know if the user-specified ${PREFIX} is unique to this
# package (e.g. PREFIX=/opt/pkgname) or might overlap with other things
# (as is typical, e.g. PREFIX=/usr/local).
#
# By convention, we do expect several common subdirectories directly
# under ${PREFIX} (i.e. /bin, /lib, etc), and so avoid removing those
# and instead remove only their children which we can account for.
# This does mean that the uninstall target will leave bin, lib etc behind
# for the case where ${PREFIX} is a directory just for this package.

uninstall::
.for stage in ${STAGE_BUILD}
	${REMOVE} ${PREFIX}/${DIR.${stage}}/${stage:T}
.endfor
.for stage in ${STAGE_COPY}
	${REMOVE} ${PREFIX}/${DIR.${stage}}/${stage:T}
.endfor
.for dir in ${STAGE_DIR:M*/*}
.if exists(${PREFIX}/${dir})
	${RMDIR} ${PREFIX}/${dir}
.endif
.endfor
.for dir in ${STAGE_DIR:N*/*}
	@echo \# not removing ${PREFIX}/${dir}
.endfor
	@echo \# not removing ${PREFIX}

