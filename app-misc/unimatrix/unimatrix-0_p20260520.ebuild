# Copyright 2026 neurogentoo contributors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{11..14} )
# unimatrix imports curses for its terminal animation.
PYTHON_REQ_USE="ncurses"
inherit python-single-r1

MY_COMMIT="dff519f972103f91384f360f270614184de8aa92"
DESCRIPTION="Terminal simulation of the Matrix digital rain"
HOMEPAGE="https://github.com/will8211/unimatrix"
SRC_URI="https://github.com/will8211/unimatrix/archive/${MY_COMMIT}.tar.gz -> ${PN}-${MY_COMMIT}.tar.gz"
S="${WORKDIR}/${PN}-${MY_COMMIT}"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="~amd64"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"
RDEPEND="${PYTHON_DEPS}"
BDEPEND="${PYTHON_DEPS}"

src_install() {
	python_newscript unimatrix.py unimatrix
	dodoc README.md
}
