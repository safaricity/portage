# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

ESVN_REPO_URI="https://svn.musicpd.org/gmpc/trunk/"
ESVN_STORE_DIR="${DISTDIR}/svn-src"
ESVN_BOOTSTRAP="autogen.sh"
inherit subversion

DESCRIPTION="A Gnome client for the Music Player Daemon."
HOMEPAGE="http://cms.qballcow.nl/"

KEYWORDS="~amd64 ~ppc ~sparc ~x86"
SLOT="0"
LICENSE="GPL-2"

DEPEND=">=x11-libs/gtk+-2.4
	>=gnome-base/libglade-2.3
	dev-perl/XML-Parser
	>=media-libs/libmpd-live-0.1
	>dev-util/gob-2
	!media-sound/gmpc
	net-misc/curl"

## Ugly but covers up missing portage feature, we don't want
## gmpc installing over gmpc-live
PROVIDE="media-sound/gmpc"

## This is needed to extract the svn revision for the about window. The
## subversion.eclass doen't copy the .svn directories, so after the copy
## to the working directory, this information is unavilable.
pkg_setup() {
	local repo_uri=${ESVN_REPO_URI%/}
	local repo="${ESVN_STORE_DIR}/${ESVN_PROJECT}/${repo_uri##*/}/src"
	REV=`svn info ${repo} | grep "Last Changed Rev" | awk -F ': ' '{ print $2}'`
}

src_compile() {
       	sed -ie "s%REVISION=.*%REVISION=$REV%" ${WORKDIR}/${PF}/src/Makefile.am

	econf || die "Configure failed!"
	emake || die "Make failed!"
}
src_install() {
	make DESTDIR=${D} install || die "make install failed"
}

DOCS="AUTHORS ChangeLog NEWS README"

