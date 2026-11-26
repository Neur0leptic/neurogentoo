# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# BEGIN GENERATED DEPENDENCIES
CRATES="
	adler2@2.0.1
	aho-corasick@1.1.4
	anstream@1.0.0
	anstyle-parse@1.0.0
	anstyle-query@1.1.5
	anstyle-wincon@3.0.11
	anstyle@1.0.14
	anyhow@1.0.102
	bitflags@2.11.1
	bstr@0.2.17
	bstr@1.12.1
	bumpalo@3.20.2
	bytecount@0.6.9
	byteorder@1.5.0
	bytes@1.11.1
	cc@1.2.62
	cfg-if@1.0.4
	clap@4.6.1
	clap_builder@4.6.0
	clap_derive@4.6.1
	clap_lex@1.1.0
	cmake@0.1.58
	colorchoice@1.0.5
	core_affinity@0.8.3
	crc32fast@1.5.0
	env_filter@1.0.1
	env_logger@0.11.10
	equivalent@1.0.2
	errno@0.3.14
	fastrand@2.4.1
	find-msvc-tools@0.1.9
	flate2@1.1.9
	flume@0.11.1
	foldhash@0.1.5
	futures-core@0.3.32
	futures-macro@0.3.32
	futures-sink@0.3.32
	futures-task@0.3.32
	futures-timer@3.0.4
	futures-util@0.3.32
	getrandom@0.2.17
	getrandom@0.4.2
	git-version-macro@0.3.9
	git-version@0.3.9
	glob@0.3.3
	globset@0.4.18
	grep-cli@0.1.12
	gzp@2.0.2
	hashbrown@0.15.5
	hashbrown@0.17.1
	heck@0.5.0
	hermit-abi@0.5.2
	id-arena@2.3.0
	indexmap@2.14.0
	is_terminal_polyfill@1.70.2
	itoa@1.0.18
	jiff-static@0.2.24
	jiff@0.2.24
	js-sys@0.3.98
	lazy_static@1.5.0
	leb128fmt@0.1.0
	libc@0.2.186
	libdeflate-sys@1.25.2
	libdeflater@1.25.2
	libz-ng-sys@1.1.28
	libz-sys@1.1.28
	linux-raw-sys@0.12.1
	lock_api@0.4.14
	log@0.4.29
	memchr@2.8.0
	memmap2@0.9.10
	miniz_oxide@0.8.9
	nanorand@0.7.0
	num_cpus@1.17.0
	once_cell@1.21.4
	once_cell_polyfill@1.70.2
	pin-project-lite@0.2.17
	pkg-config@0.3.33
	portable-atomic-util@0.2.7
	portable-atomic@1.13.1
	prettyplease@0.2.37
	proc-macro-crate@3.5.0
	proc-macro2@1.0.106
	quote@1.0.45
	r-efi@6.0.0
	regex-automata@0.4.14
	regex-syntax@0.8.10
	regex@1.12.3
	relative-path@1.9.3
	ripline@0.1.0
	rstest@0.26.1
	rstest_macros@0.26.1
	rustc_version@0.4.1
	rustix@1.1.4
	rustversion@1.0.22
	scopeguard@1.2.0
	semver@1.0.28
	serde@1.0.228
	serde_core@1.0.228
	serde_derive@1.0.228
	serde_json@1.0.150
	shlex@1.3.0
	simd-adler32@0.3.9
	slab@0.4.12
	spin@0.9.8
	strsim@0.11.1
	syn@2.0.117
	tempfile@3.27.0
	termcolor@1.4.1
	thiserror-impl@2.0.18
	thiserror@2.0.18
	toml_datetime@1.1.1+spec-1.1.0
	toml_edit@0.25.11+spec-1.1.0
	toml_parser@1.1.2+spec-1.1.0
	unicode-ident@1.0.24
	unicode-xid@0.2.6
	utf8parse@0.2.2
	vcpkg@0.2.15
	wasi@0.11.1+wasi-snapshot-preview1
	wasip2@1.0.3+wasi-0.2.9
	wasip3@0.4.0+wasi-0.3.0-rc-2026-01-06
	wasm-bindgen-macro-support@0.2.121
	wasm-bindgen-macro@0.2.121
	wasm-bindgen-shared@0.2.121
	wasm-bindgen@0.2.121
	wasm-encoder@0.244.0
	wasm-metadata@0.244.0
	wasmparser@0.244.0
	winapi-i686-pc-windows-gnu@0.4.0
	winapi-util@0.1.11
	winapi-x86_64-pc-windows-gnu@0.4.0
	winapi@0.3.9
	windows-link@0.2.1
	windows-sys@0.61.2
	winnow@1.0.3
	wit-bindgen-core@0.51.0
	wit-bindgen-rust-macro@0.51.0
	wit-bindgen-rust@0.51.0
	wit-bindgen@0.51.0
	wit-bindgen@0.57.1
	wit-component@0.244.0
	wit-parser@0.244.0
	zmij@1.0.21
"
# END GENERATED DEPENDENCIES
inherit cargo

DESCRIPTION="A sharp cut(1) clone"
HOMEPAGE="https://github.com/sstadick/hck"
SOURCE_URI="https://github.com/sstadick/hck/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"
SRC_URI="${SOURCE_URI} ${CARGO_CRATE_URIS}"

LICENSE="|| ( MIT Unlicense )"
# Dependent crate licenses
LICENSE+=" Apache-2.0 BSD-2 MIT Unicode-3.0 ZLIB"
SLOT="0"
KEYWORDS="~amd64"

QA_FLAGS_IGNORED="usr/bin/hck"
