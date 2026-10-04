# Copyright 2026 neurogentoo contributors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Shell formatter (upstream static binary)"
HOMEPAGE="https://github.com/mvdan/sh"
SRC_URI="https://github.com/mvdan/sh/releases/download/v${PV}/shfmt_v${PV}_linux_amd64 -> shfmt-${PV}-linux-amd64"
S="${WORKDIR}"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64"
RESTRICT="strip"
QA_PREBUILT="usr/bin/shfmt"
RDEPEND="!dev-util/sh"

src_unpack() {
	cp "${DISTDIR}/shfmt-${PV}-linux-amd64" shfmt || die
}

src_install() {
	dobin shfmt
}
