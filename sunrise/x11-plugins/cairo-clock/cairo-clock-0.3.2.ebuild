# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils

DESCRIPTION="Clock for desktop with ARGB visuals."
HOMEPAGE="http://macslow.thepimp.net/?page_id=23"
SRC_URI="http://macslow.thepimp.net/projects/cairo-clock/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~x86"
IUSE=""

DEPEND=">=x11-libs/cairo-1.0.2
	>=x11-libs/gtk+-2.8.8
	>=gnome-base/libglade-2.5.1
	>=gnome-base/librsvg-2.14"
RDEPEND="${DEPEND}"

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
	dodoc README NEWS AUTHORS TODO
}

pkg_postinst() {
	echo
	elog "Note, that you need running composite manager for visuals."
	epause 5
	echo
}
