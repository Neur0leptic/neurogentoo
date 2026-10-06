# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# BEGIN GENERATED DEPENDENCIES
CRATES="
	adler@1.0.2
	aho-corasick@1.1.3
	anstream@0.6.13
	anstyle-parse@0.2.3
	anstyle-query@1.0.2
	anstyle-wincon@3.0.2
	anstyle@1.0.6
	anyhow@1.0.82
	autocfg@1.2.0
	bitflags@2.5.0
	bstr@0.2.17
	bstr@1.9.1
	bumpalo@3.16.0
	bytecount@0.6.7
	byteorder@1.5.0
	bytes@1.6.0
	cc@1.0.92
	cfg-if@1.0.0
	clap@4.5.4
	clap_builder@4.5.2
	clap_derive@4.5.4
	clap_lex@0.7.0
	cmake@0.1.50
	colorchoice@1.0.0
	core_affinity@0.8.1
	crc32fast@1.4.0
	env_filter@0.1.0
	env_logger@0.11.3
	errno@0.3.8
	fastrand@2.0.2
	flate2@1.0.28
	flume@0.10.14
	futures-channel@0.3.30
	futures-core@0.3.30
	futures-executor@0.3.30
	futures-io@0.3.30
	futures-macro@0.3.30
	futures-sink@0.3.30
	futures-task@0.3.30
	futures-timer@3.0.3
	futures-util@0.3.30
	futures@0.3.30
	getrandom@0.2.14
	git-version-macro@0.3.9
	git-version@0.3.9
	glob@0.3.1
	globset@0.4.14
	grep-cli@0.1.10
	gzp@0.11.3
	heck@0.5.0
	hermit-abi@0.3.9
	humantime@2.1.0
	js-sys@0.3.69
	lazy_static@1.4.0
	libc@0.2.153
	libdeflate-sys@0.12.0
	libdeflater@0.12.0
	libz-sys@1.1.16
	linux-raw-sys@0.4.13
	lock_api@0.4.11
	log@0.4.21
	memchr@2.7.2
	memmap2@0.9.4
	miniz_oxide@0.7.2
	nanorand@0.7.0
	num_cpus@1.16.0
	once_cell@1.19.0
	pin-project-internal@1.1.5
	pin-project-lite@0.2.14
	pin-project@1.1.5
	pin-utils@0.1.0
	pkg-config@0.3.30
	proc-macro2@1.0.79
	quote@1.0.36
	regex-automata@0.4.6
	regex-syntax@0.8.3
	regex@1.10.4
	relative-path@1.9.2
	ripline@0.1.0
	rstest@0.19.0
	rstest_macros@0.19.0
	rustc_version@0.4.0
	rustix@0.38.32
	scopeguard@1.2.0
	semver@1.0.22
	serde@1.0.197
	serde_derive@1.0.197
	slab@0.4.9
	spin@0.9.8
	strsim@0.11.1
	syn@2.0.58
	tempfile@3.10.1
	termcolor@1.4.1
	thiserror-impl@1.0.58
	thiserror@1.0.58
	unicode-ident@1.0.12
	utf8parse@0.2.1
	vcpkg@0.2.15
	wasi@0.11.0+wasi-snapshot-preview1
	wasm-bindgen-backend@0.2.92
	wasm-bindgen-macro-support@0.2.92
	wasm-bindgen-macro@0.2.92
	wasm-bindgen-shared@0.2.92
	wasm-bindgen@0.2.92
	winapi-i686-pc-windows-gnu@0.4.0
	winapi-util@0.1.6
	winapi-x86_64-pc-windows-gnu@0.4.0
	winapi@0.3.9
	windows-sys@0.52.0
	windows-targets@0.52.4
	windows_aarch64_gnullvm@0.52.4
	windows_aarch64_msvc@0.52.4
	windows_i686_gnu@0.52.4
	windows_i686_msvc@0.52.4
	windows_x86_64_gnu@0.52.4
	windows_x86_64_gnullvm@0.52.4
	windows_x86_64_msvc@0.52.4
"
# END GENERATED DEPENDENCIES
inherit cargo

DESCRIPTION="A sharp cut(1) clone"
HOMEPAGE="https://github.com/sstadick/hck"
SOURCE_URI="https://github.com/sstadick/hck/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"
SRC_URI="${SOURCE_URI} ${CARGO_CRATE_URIS}"

LICENSE="|| ( MIT Unlicense )"
# Dependent crate licenses
LICENSE+=" Apache-2.0 BSD-2 MIT Unicode-DFS-2016 ZLIB"
SLOT="0"
KEYWORDS="~amd64"

QA_FLAGS_IGNORED="usr/bin/hck"
