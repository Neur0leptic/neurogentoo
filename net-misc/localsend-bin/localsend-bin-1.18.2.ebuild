# Copyright 2026 neurogentoo contributors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop xdg

DESCRIPTION="Share files over the local network (upstream binary)"
HOMEPAGE="https://localsend.org https://github.com/localsend/localsend"
SRC_URI="https://github.com/localsend/localsend/releases/download/v${PV}/LocalSend-${PV}-linux-x86-64.tar.gz -> localsend-${PV}-linux-x86-64.tar.gz"
S="${WORKDIR}"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"
RESTRICT="strip"
QA_PREBUILT="opt/localsend/*"

# GTK and Ayatana supply the Linux runner/plugin DT_NEEDED libraries. In
# particular the bundled tray plugin links libayatana-appindicator3.so.1.
RDEPEND="
	>=sys-libs/glibc-2.34
	sys-devel/gcc[cxx]
	x11-libs/gtk+:3[wayland]
	dev-libs/libayatana-appindicator
	!net-misc/localsend
"
BDEPEND="dev-util/patchelf"

src_prepare() {
	default
	# Upstream plugins retain the CI builder's absolute RUNPATH. Their only
	# non-system dependency, libflutter_linux_gtk.so, is in the same directory.
	local plugin
	for plugin in lib/*_plugin.so; do
		patchelf --set-rpath '$ORIGIN' "${plugin}" || die
	done
}

src_install() {
	insinto /opt/localsend
	doins -r data lib
	exeinto /opt/localsend
	doexe localsend_app
	dosym -r /opt/localsend/localsend_app /usr/bin/localsend
	newicon -s 256 data/flutter_assets/assets/img/logo-256.png localsend.png
	make_desktop_entry localsend LocalSend localsend "Network;FileTransfer;"
}
