# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-video/ffmpeg/ffmpeg-0.4.9_p20081014.ebuild,v 1.19 2008/12/21 14:35:23 nixnut Exp $

inherit eutils flag-o-matic multilib toolchain-funcs

FFMPEG_SVN_REV="15615"

DESCRIPTION="Complete solution to record, convert and stream audio and video.
Includes libavcodec. svn revision ${FFMPEG_SVN_REV}"
HOMEPAGE="http://ffmpeg.org/"
MY_P=${P/_/-}
SRC_URI="mirror://gentoo/${MY_P}.tar.bz2"

S=${WORKDIR}/ffmpeg

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="alpha amd64 ~arm hppa ~ia64 ppc ppc64 sparc x86 ~x86-fbsd"
IUSE="aac altivec amr debug dirac doc ieee1394 encode gsm ipv6 mmx mmxext vorbis
	  test theora threads x264 xvid network zlib sdl X mp3 schroedinger
	  hardcoded-tables bindist v4l v4l2 ssse3 vhook"

RDEPEND="vhook? ( >=media-libs/imlib2-1.4.0 >=media-libs/freetype-2 )
	sdl? ( >=media-libs/libsdl-1.2.10 )
	encode? (
		aac? ( media-libs/faac )
		mp3? ( media-sound/lame )
		vorbis? ( media-libs/libvorbis media-libs/libogg )
		theora? ( media-libs/libtheora media-libs/libogg )
		x264? ( >=media-libs/x264-0.0.20081006 )
		xvid? ( >=media-libs/xvid-1.1.0 ) )
	aac? ( >=media-libs/faad2-2.6.1 )
	zlib? ( sys-libs/zlib )
	ieee1394? ( media-libs/libdc1394
				sys-libs/libraw1394 )
	dirac? ( media-video/dirac )
	gsm? ( >=media-sound/gsm-1.0.12-r1 )
	schroedinger? ( media-libs/schroedinger )
	X? ( x11-libs/libX11 x11-libs/libXext )
	amr? ( media-libs/amrnb media-libs/amrwb )"

DEPEND="${RDEPEND}
	mmx? ( dev-lang/yasm )
	doc? ( app-text/texi2html )
	test? ( net-misc/wget )
	v4l? ( sys-kernel/linux-headers )
	v4l2? ( sys-kernel/linux-headers )"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${PN}-shared-gcc4.1.patch
	epatch "${FILESDIR}"/${P}-sparc-gcc43.patch #247653

	# Set version #
	# Any better idea? We can't do much more as we use an exported svn snapshot.
	sed -i s/UNKNOWN/SVN-r${FFMPEG_SVN_REV}/ "${S}/version.sh"
}

src_compile() {
	replace-flags -O0 -O2
	#x86, what a wonderful arch....
	replace-flags -O1 -O2
	local myconf="${EXTRA_ECONF}"

	# enabled by default
	use debug || myconf="${myconf} --disable-debug"
	use zlib || myconf="${myconf} --disable-zlib"
	use sdl || myconf="${myconf} --disable-ffplay"

	if use network; then
		use ipv6 || myconf="${myconf} --disable-ipv6"
	else
		myconf="${myconf} --disable-network"
	fi

	myconf="${myconf} --disable-optimizations"

	# disabled by default
	if use encode
	then
		use aac && myconf="${myconf} --enable-libfaac"
		use mp3 && myconf="${myconf} --enable-libmp3lame"
		use vorbis && myconf="${myconf} --enable-libvorbis"
		use theora && myconf="${myconf} --enable-libtheora"
		use x264 && myconf="${myconf} --enable-libx264"
		use xvid && myconf="${myconf} --enable-libxvid"
	else
		myconf="${myconf} --disable-encoders"
	fi

	# libavdevice options
	use ieee1394 && myconf="${myconf} --enable-libdc1394"
	for i in v4l v4l2 ; do
		use $i || myconf="${myconf} --disable-demuxer=$i"
	done
	use X && myconf="${myconf} --enable-x11grab"

	# Threads; we only support pthread for now but ffmpeg supports more
	use threads && myconf="${myconf} --enable-pthreads"

	# Decoders
	use aac && myconf="${myconf} --enable-libfaad"
	use dirac && myconf="${myconf} --enable-libdirac"
	use schroedinger && myconf="${myconf} --enable-libschroedinger"
	if use gsm; then
		myconf="${myconf} --enable-libgsm"
		# Crappy detection or our installation is weird, pick one (FIXME)
		append-flags -I/usr/include/gsm
	fi
	if use bindist
	then
		use amr && ewarn "libamr is nonfree and cannot be distributed; disabling amr support."
	else
		use amr && myconf="${myconf} --enable-libamr-nb \
									 --enable-libamr-wb \
									 --enable-nonfree"
	fi

	# CPU features
	for i in mmx ssse3 altivec ; do
		use $i ||  myconf="${myconf} --disable-$i"
	done
	use mmxext || myconf="${myconf} --disable-mmx2"
	# disable mmx accelerated code if PIC is required
	# as the provided asm decidedly is not PIC.
	if gcc-specs-pie ; then
		myconf="${myconf} --disable-mmx --disable-mmx2"
	fi

	# Try to get cpu type based on CFLAGS.
	# Bug #172723
	# We need to do this so that features of that CPU will be better used
	# If they contain an unknown CPU it will not hurt since ffmpeg's configure
	# will just ignore it.
	local mymarch=$(get-flag march)
	local mymcpu=$(get-flag mcpu)
	local mymtune=$(get-flag mtune)
	for i in $mymarch $mymcpu $mymtune ; do
		myconf="${myconf} --cpu=$i"
		break
	done

	# video hooking support. replaced by libavfilter, probably needs to be
	# dropped at some point.
	use vhook || myconf="${myconf} --disable-vhook"

	# Mandatory configuration
	myconf="${myconf} --enable-gpl --enable-postproc \
			--enable-avfilter --enable-avfilter-lavf \
			--enable-swscale --disable-stripping"

	# cross compile support
	tc-is-cross-compiler && myconf="${myconf} --enable-cross-compile --arch=$(tc-arch-kernel)"

	# Misc stuff
	use hardcoded-tables && myconf="${myconf} --enable-hardcoded-tables"

	# Specific workarounds for too-few-registers arch...
	if [[ $(tc-arch) == "x86" ]]; then
		filter-flags -fforce-addr -momit-leaf-frame-pointer
		append-flags -fomit-frame-pointer
		is-flag -O? || append-flags -O2
		if (use debug); then
			# no need to warn about debug if not using debug flag
			ewarn ""
			ewarn "Debug information will be almost useless as the frame pointer is omitted."
			ewarn "This makes debugging harder, so crashes that has no fixed behavior are"
			ewarn "difficult to fix. Please have that in mind."
			ewarn ""
		fi
	fi

	cd "${S}"
	./configure \
		--prefix=/usr \
		--libdir=/usr/$(get_libdir) \
		--shlibdir=/usr/$(get_libdir) \
		--mandir=/usr/share/man \
		--enable-static --enable-shared \
		--cc="$(tc-getCC)" \
		${myconf} || die "configure failed"

	emake -j1 depend || die "depend failed"
	emake || die "make failed"
}

src_install() {
	emake -j1 DESTDIR="${D}" install || die "Install Failed"

	use doc && emake -j1 documentation
	dodoc Changelog README INSTALL
	dodoc doc/*
}

# Never die for now...
src_test() {
	for t in codectest libavtest servertest seektest ; do
		emake ${t} || ewarn "Some tests in ${t} failed"
	done
}

pkg_postinst() {
	ewarn "ffmpeg may have had ABI changes, if ffmpeg based programs"
	ewarn "like xine-lib or vlc stop working as expected please"
	ewarn "rebuild them."
}
