# Copyright 2022-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit git-r3 savedconfig toolchain-funcs

DESCRIPTION="dwl with the canonical Neuroleptic desktop patch and IPC protocol"
HOMEPAGE="https://codeberg.org/dwl/dwl"
DWL_COMMIT="d41ecb745cc94fbb48e93af01f5fd5d0b2488945"
SOURCE_URI="https://codeberg.org/dwl/dwl/archive/${DWL_COMMIT}.tar.gz -> dwl-${DWL_COMMIT}.tar.gz"
SRC_URI="${SOURCE_URI}"
EGIT_REPO_URI="https://github.com/Neur0leptic/dotfiles.git"
EGIT_BRANCH="main"
EGIT_CHECKOUT_DIR="${WORKDIR}/dotfiles"
EGIT_SUBMODULES=()
S="${WORKDIR}/dwl"

LICENSE="CC0-1.0 GPL-3+ MIT"
SLOT="0"
KEYWORDS=""
RDEPEND="gui-libs/wlroots:0.20=[drm,libinput,session,-X]
	dev-libs/libinput:=
	dev-libs/wayland
	x11-libs/libxkbcommon
	x11-libs/pixman"
DEPEND="${RDEPEND}
	sys-kernel/linux-headers"
BDEPEND=">=dev-libs/wayland-protocols-1.41
	>=dev-util/wayland-scanner-1.23
	llvm-core/clang
	llvm-core/lld
	virtual/pkgconfig"

src_unpack() {
	# Git inputs are fetched by the eclass, never during prepare/compile/install.
	git-r3_src_unpack
	unpack "dwl-${DWL_COMMIT}.tar.gz"
}

src_prepare() {
	eapply "${EGIT_CHECKOUT_DIR}/dot_config/dwl/patches/0001-neuroleptic.patch"
	cp "${EGIT_CHECKOUT_DIR}/dot_config/dwl/protocols/dwl-ipc-unstable-v2.xml" \
		protocols/dwl-ipc-unstable-v2.xml || die
	default
	restore_config config.h
}

src_compile() {
	emake CC="$(tc-getCC)" PKG_CONFIG="$(tc-getPKG_CONFIG)" \
		XWAYLAND= XLIBS= CFLAGS="${CFLAGS}" LDFLAGS="${LDFLAGS}" dwl
}

src_install() {
	emake DESTDIR="${D}" PREFIX="${EPREFIX}/usr" install
	dodoc CHANGELOG.md README.md
	save_config config.h
	# Installed provenance lets resume detect a different config/patch build.
	insinto /usr/share/dwl/neurogentoo
	doins config.h
	newins "${EGIT_CHECKOUT_DIR}/dot_config/dwl/patches/0001-neuroleptic.patch" desktop.patch
	newins "${EGIT_CHECKOUT_DIR}/dot_config/dwl/protocols/dwl-ipc-unstable-v2.xml" dwl-ipc-unstable-v2.xml
	printf '%s\n' "${EGIT_VERSION}" > "${T}/dotfiles-revision" || die
	doins "${T}/dotfiles-revision"
}
