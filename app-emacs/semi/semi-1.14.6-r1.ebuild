# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-emacs/semi/semi-1.14.6-r1.ebuild,v 1.5 2009/02/19 20:02:58 ulm Exp $

inherit elisp eutils

DESCRIPTION="A library to provide MIME feature for GNU Emacs"
HOMEPAGE="http://www.kanji.zinbun.kyoto-u.ac.jp/~tomo/elisp/SEMI/"
SRC_URI="http://kanji.zinbun.kyoto-u.ac.jp/~tomo/lemi/dist/semi/semi-1.14-for-flim-1.14/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="alpha amd64 ppc sparc x86"
IUSE="linguas_ja"

DEPEND=">=app-emacs/apel-10.6
	virtual/flim"
SITEFILE="65${PN}-gentoo.el"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}/${PN}-info.patch"
}

src_compile() {
	emake PREFIX="${D}"/usr \
		LISPDIR="${D}/${SITELISP}" \
		VERSION_SPECIFIC_LISPDIR="${D}/${SITELISP}" || die "emake failed"

	${EMACS} ${EMACSFLAGS} --visit mime-ui-en.texi -f texi2info \
		|| die "texi2info failed"
	if use linguas_ja; then
		${EMACS} ${EMACSFLAGS} \
			--eval "(set-default-coding-systems 'iso-2022-jp)" \
			--visit mime-ui-ja.texi -f texi2info \
			|| die "texi2info failed"
	fi
}

src_install() {
	emake PREFIX="${D}/usr" \
		LISPDIR="${D}/${SITELISP}" \
		VERSION_SPECIFIC_LISPDIR="${D}/${SITELISP}" install \
		|| die "emake install failed"

	elisp-site-file-install "${FILESDIR}/${SITEFILE}"

	doinfo mime-ui-en.info || die "doinfo failed"
	dodoc README.en ChangeLog VERSION NEWS
	if use linguas_ja; then
		doinfo mime-ui-ja.info || die "doinfo failed"
		dodoc README.ja
	fi
}
