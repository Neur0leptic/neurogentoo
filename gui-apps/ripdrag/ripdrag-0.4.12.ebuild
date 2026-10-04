# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

RUST_MIN_VER="1.95.0"
# BEGIN GENERATED DEPENDENCIES
CRATES="
	anstream@0.6.13
	anstyle@1.0.13
	anstyle-parse@0.2.3
	anstyle-query@1.0.2
	anstyle-wincon@3.0.2
	async-channel@2.5.0
	autocfg@1.2.0
	bitflags@2.10.0
	bstr@1.9.1
	cairo-rs@0.21.2
	cairo-sys-rs@0.21.2
	cfg-expr@0.20.3
	clap@4.5.51
	clap_builder@4.5.51
	clap_derive@4.5.49
	clap_lex@0.7.6
	colorchoice@1.0.0
	concurrent-queue@2.5.0
	crossbeam-utils@0.8.21
	equivalent@1.0.1
	event-listener@5.4.1
	event-listener-strategy@0.5.4
	field-offset@0.3.6
	futures-channel@0.3.30
	futures-core@0.3.30
	futures-executor@0.3.30
	futures-io@0.3.30
	futures-macro@0.3.30
	futures-task@0.3.30
	futures-util@0.3.30
	gdk-pixbuf@0.21.2
	gdk-pixbuf-sys@0.21.2
	gdk4@0.10.1
	gdk4-sys@0.10.1
	gio@0.21.2
	gio-sys@0.21.2
	glib@0.21.3
	glib-macros@0.21.2
	glib-sys@0.21.2
	gobject-sys@0.21.2
	graphene-rs@0.21.2
	graphene-sys@0.21.2
	gsk4@0.10.1
	gsk4-sys@0.10.1
	gtk4@0.10.1
	gtk4-macros@0.10.1
	gtk4-sys@0.10.1
	hashbrown@0.16.0
	heck@0.5.0
	indexmap@2.12.0
	libc@0.2.153
	memchr@2.7.6
	memoffset@0.9.1
	normpath@1.2.0
	opener@0.8.3
	pango@0.21.3
	pango-sys@0.21.2
	parking@2.2.1
	pin-project-lite@0.2.14
	pin-utils@0.1.0
	pkg-config@0.3.32
	proc-macro-crate@3.4.0
	proc-macro2@1.0.103
	quote@1.0.35
	regex-automata@0.4.6
	rustc_version@0.4.0
	semver@1.0.22
	serde@1.0.228
	serde_core@1.0.228
	serde_derive@1.0.228
	serde_spanned@1.0.3
	slab@0.4.9
	smallvec@1.15.1
	strsim@0.11.1
	syn@2.0.108
	system-deps@7.0.6
	target-lexicon@0.13.2
	toml@0.9.8
	toml_datetime@0.7.3
	toml_edit@0.23.7
	toml_parser@1.0.4
	toml_writer@1.0.4
	unicode-ident@1.0.12
	utf8parse@0.2.1
	version-compare@0.2.0
	windows-link@0.2.1
	windows-sys@0.52.0
	windows-sys@0.60.2
	windows-targets@0.52.4
	windows-targets@0.53.5
	windows_aarch64_gnullvm@0.52.4
	windows_aarch64_gnullvm@0.53.1
	windows_aarch64_msvc@0.52.4
	windows_aarch64_msvc@0.53.1
	windows_i686_gnu@0.52.4
	windows_i686_gnu@0.53.1
	windows_i686_gnullvm@0.53.1
	windows_i686_msvc@0.52.4
	windows_i686_msvc@0.53.1
	windows_x86_64_gnu@0.52.4
	windows_x86_64_gnu@0.53.1
	windows_x86_64_gnullvm@0.52.4
	windows_x86_64_gnullvm@0.53.1
	windows_x86_64_msvc@0.52.4
	windows_x86_64_msvc@0.53.1
	winnow@0.7.13
"
# END GENERATED DEPENDENCIES
inherit cargo

DESCRIPTION="Drag and drop files to and from the terminal"
HOMEPAGE="https://github.com/nik012003/ripdrag"
SOURCE_URI="https://github.com/nik012003/ripdrag/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"
SOURCE_SHA256="ffa685c42e84558cc47d8bd5713f8a68f8cd8e313be55a111a0bc43bf1e220de"
SRC_URI="${SOURCE_URI} ${CARGO_CRATE_URIS}"

LICENSE="GPL-3 Apache-2.0 Apache-2.0-with-LLVM-exceptions MIT Unicode-DFS-2016"
SLOT="0"
KEYWORDS="~amd64"
RDEPEND=">=gui-libs/gtk-4.8:4[wayland]
	x11-misc/xdg-utils"
DEPEND=">=gui-libs/gtk-4.8:4[wayland]"
BDEPEND="virtual/pkgconfig"

src_configure() {
	cargo_src_configure --locked
}
