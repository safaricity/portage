# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

DESCRIPTION="Package for controlling post emerge --sync operations"
HOMEPAGE="http://www.electron.me.uk/postsync.html"
SRC_URI="http://www.electron.me.uk/files/${P}.tar.bz2"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86"
IUSE=""
S=${WORKDIR}/${PN}

DEPEND=">=virtual/python-2.3"

RDEPEND="${DEPEND}"

src_install() {
	PORTCFG=$(python -c 'import portage; print portage.USER_CONFIG_PATH,') \
		|| die "Cannot get config path"
	PSDIR="/usr/lib/postsync.d"
	PSBIN="${PSDIR}/bin"
	PSETC="${PSDIR}/etc"

	exeinto /usr/sbin
	doexe postsync

	exeinto ${PORTCFG}/bin
	doexe post_sync

	exeinto ${PSBIN}
	doexe bin/*

	dodir ${PSETC}

	dodoc README ChangeLog doc/*
}

pkg_postinst() {
	ebegin "Moving any existing config files ..."
	PORTCFG=$(python -c 'import portage; print portage.USER_CONFIG_PATH,')
	if [ -f ${PORTCFG}/package.warnme ]
	then
		mv ${PORTCFG}/package.warnme /usr/lib/postsync.d/etc
	fi
	eend

	einfo
	einfo "Use postsync -l to see what programs are available then"
	einfo "postsync -e -a <prog> [prog ...] to activate the ones you want."
	einfo
}

pkg_prerm() {
	/usr/sbin/postsync -d
}
