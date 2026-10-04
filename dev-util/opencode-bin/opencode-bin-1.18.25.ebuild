# Copyright 2026 neurogentoo contributors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Open source coding agent (x86-64 baseline binary)"
HOMEPAGE="https://opencode.ai https://github.com/anomalyco/opencode"
SRC_URI="https://github.com/anomalyco/opencode/releases/download/v${PV}/opencode-linux-x64-baseline.tar.gz -> opencode-${PV}-linux-x64-baseline.tar.gz"
S="${WORKDIR}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
RESTRICT="strip"
QA_PREBUILT="usr/bin/opencode"

# The selected baseline executable needs GLIBC_2.17, without an AVX2 requirement.
RDEPEND="
	>=sys-libs/glibc-2.17
	!dev-util/opencode
"

src_install() {
	dobin opencode
}
