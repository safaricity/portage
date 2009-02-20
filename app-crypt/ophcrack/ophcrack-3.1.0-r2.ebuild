# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-crypt/ophcrack/ophcrack-3.1.0-r2.ebuild,v 1.1 2009/02/20 11:20:12 ikelos Exp $

inherit eutils

DESCRIPTION="A time-memory-trade-off-cracker"
HOMEPAGE="http://ophcrack.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~x86"
IUSE="qt4 debug"

CDEPEND="dev-libs/openssl
		 net-libs/netwib
		 qt4? ( >=x11-libs/qt-gui-4 )"
DEPEND="app-arch/unzip
		>=dev-util/pkgconfig-0.22
		${CDEPEND}"
RDEPEND="app-crypt/ophcrack-tables
		 ${CDEPEND}"

src_compile() {
	local myconf

	myconf="$(use_enable qt4 gui)"
	myconf="${myconf} $(use_enable debug)"

	econf ${myconf} || die "Failed to compile"
	emake || die "Failed to make"
}

src_install() {
	emake install DESTDIR="${D}" || "Installation failed."

	cd "${S}"
	newicon src/gui/pixmaps/os.xpm ophcrack.xpm
	make_desktop_entry "${PN}" OphCrack ophcrack
}
