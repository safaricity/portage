# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-themes/gnome-themes-extras/gnome-themes-extras-2.22.0-r1.ebuild,v 1.4 2008/11/25 14:30:11 armin76 Exp $

inherit autotools eutils gnome2

DESCRIPTION="Additional themes for GNOME 2.2"
HOMEPAGE="http://librsvg.sourceforge.net/theme.php"

LICENSE="LGPL-2.1 GPL-2 DSL"
SLOT="0"
KEYWORDS="alpha amd64 ~hppa ia64 ppc sparc x86 ~x86-fbsd"
IUSE=""

RDEPEND=">=x11-libs/gtk+-2.6
	>=x11-themes/gtk-engines-2.14
	>=x11-misc/icon-naming-utils-0.8.1
	gnome-base/librsvg"
DEPEND="${RDEPEND}
	dev-util/pkgconfig
	>=dev-util/intltool-0.23"

DOCS="AUTHORS ChangeLog MAINTAINERS README TODO"

src_unpack() {
	gnome2_src_unpack

	# Fix tooltips references, bug #238138
	epatch "${FILESDIR}/${P}-darklooks.patch"

	# Respect LINGUAS, bug #182086
	intltoolize --force || die "intloolize failed"
	eautomake
}
