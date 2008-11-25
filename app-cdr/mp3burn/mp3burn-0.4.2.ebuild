# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-cdr/mp3burn/mp3burn-0.4.2.ebuild,v 1.1 2008/11/25 09:58:46 ssuominen Exp $

DESCRIPTION="Burn mp3s without filling up your disk with .wav files"
HOMEPAGE="http://sourceforge.net/projects/mp3burn"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~sparc ~x86"
IUSE=""

DEPEND="dev-lang/perl"
RDEPEND="${DEPEND}
	 virtual/mpg123
	 media-libs/flac
	 media-sound/vorbis-tools
	 virtual/cdrtools
	 dev-perl/MP3-Info
	 dev-perl/ogg-vorbis-header
	 dev-perl/String-ShellQuote"

S=${WORKDIR}/${PN}

src_compile() {
	emake || die "emake failed."
}

src_install() {
	dobin ${PN} || die "dobin failed."
	doman ${PN}.1
	dodoc Changelog README
}
