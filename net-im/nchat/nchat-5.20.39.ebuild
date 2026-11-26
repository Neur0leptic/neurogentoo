# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

GO_OPTIONAL=1
CMAKE_BUILD_TYPE=Release
inherit go-module cmake multilib toolchain-funcs
# BEGIN GENERATED DEPENDENCIES
EGO_SUM=(
	"cel.dev/expr v0.25.2"
	"cel.dev/expr v0.25.2/go.mod"
	"cloud.google.com/go/auth v0.20.0"
	"cloud.google.com/go/auth v0.20.0/go.mod"
	"cloud.google.com/go/compute/metadata v0.9.0"
	"cloud.google.com/go/compute/metadata v0.9.0/go.mod"
	"filippo.io/edwards25519 v1.2.0"
	"filippo.io/edwards25519 v1.2.0/go.mod"
	"github.com/DATA-DOG/go-sqlmock v1.5.2"
	"github.com/DATA-DOG/go-sqlmock v1.5.2/go.mod"
	"github.com/GoogleCloudPlatform/opentelemetry-operations-go/detectors/gcp v1.34.0"
	"github.com/GoogleCloudPlatform/opentelemetry-operations-go/detectors/gcp v1.34.0/go.mod"
	"github.com/agnivade/levenshtein v1.2.1"
	"github.com/agnivade/levenshtein v1.2.1/go.mod"
	"github.com/andreyvit/diff v0.0.0-20170406064948-c7f18ee00883"
	"github.com/andreyvit/diff v0.0.0-20170406064948-c7f18ee00883/go.mod"
	"github.com/beeper/argo-go v1.1.2"
	"github.com/beeper/argo-go v1.1.2/go.mod"
	"github.com/cespare/xxhash/v2 v2.3.0"
	"github.com/cespare/xxhash/v2 v2.3.0/go.mod"
	"github.com/cncf/xds/go v0.0.0-20260202195803-dba9d589def2"
	"github.com/cncf/xds/go v0.0.0-20260202195803-dba9d589def2/go.mod"
	"github.com/coder/websocket v1.8.15"
	"github.com/coder/websocket v1.8.15/go.mod"
	"github.com/coreos/go-systemd/v22 v22.7.0"
	"github.com/coreos/go-systemd/v22 v22.7.0/go.mod"
	"github.com/creack/pty v1.1.9/go.mod"
	"github.com/davecgh/go-spew v1.1.1"
	"github.com/davecgh/go-spew v1.1.1/go.mod"
	"github.com/elliotchance/orderedmap/v3 v3.1.0"
	"github.com/elliotchance/orderedmap/v3 v3.1.0/go.mod"
	"github.com/emersion/go-vcard v0.0.0-20241024213814-c9703dde27ff"
	"github.com/emersion/go-vcard v0.0.0-20241024213814-c9703dde27ff/go.mod"
	"github.com/envoyproxy/go-control-plane v0.14.0"
	"github.com/envoyproxy/go-control-plane v0.14.0/go.mod"
	"github.com/envoyproxy/go-control-plane/envoy v1.37.0"
	"github.com/envoyproxy/go-control-plane/envoy v1.37.0/go.mod"
	"github.com/envoyproxy/go-control-plane/ratelimit v0.1.0"
	"github.com/envoyproxy/go-control-plane/ratelimit v0.1.0/go.mod"
	"github.com/envoyproxy/protoc-gen-validate v1.3.3"
	"github.com/envoyproxy/protoc-gen-validate v1.3.3/go.mod"
	"github.com/felixge/httpsnoop v1.1.0"
	"github.com/felixge/httpsnoop v1.1.0/go.mod"
	"github.com/go-jose/go-jose/v4 v4.1.4"
	"github.com/go-jose/go-jose/v4 v4.1.4/go.mod"
	"github.com/go-logr/logr v1.4.3"
	"github.com/go-logr/logr v1.4.3/go.mod"
	"github.com/go-logr/stdr v1.2.2"
	"github.com/go-logr/stdr v1.2.2/go.mod"
	"github.com/golang/glog v1.2.5"
	"github.com/golang/glog v1.2.5/go.mod"
	"github.com/golang/protobuf v1.5.4"
	"github.com/golang/protobuf v1.5.4/go.mod"
	"github.com/google/go-cmp v0.7.0"
	"github.com/google/go-cmp v0.7.0/go.mod"
	"github.com/google/s2a-go v0.1.9"
	"github.com/google/s2a-go v0.1.9/go.mod"
	"github.com/google/uuid v1.6.0"
	"github.com/google/uuid v1.6.0/go.mod"
	"github.com/googleapis/enterprise-certificate-proxy v0.3.15"
	"github.com/googleapis/enterprise-certificate-proxy v0.3.15/go.mod"
	"github.com/googleapis/gax-go/v2 v2.22.0"
	"github.com/googleapis/gax-go/v2 v2.22.0/go.mod"
	"github.com/kr/pretty v0.2.1/go.mod"
	"github.com/kr/pretty v0.3.1"
	"github.com/kr/pretty v0.3.1/go.mod"
	"github.com/kr/pty v1.1.1/go.mod"
	"github.com/kr/text v0.1.0/go.mod"
	"github.com/kr/text v0.2.0"
	"github.com/kr/text v0.2.0/go.mod"
	"github.com/lib/pq v1.12.3"
	"github.com/lib/pq v1.12.3/go.mod"
	"github.com/mattn/go-colorable v0.1.14"
	"github.com/mattn/go-colorable v0.1.14/go.mod"
	"github.com/mattn/go-isatty v0.0.20"
	"github.com/mattn/go-isatty v0.0.20/go.mod"
	"github.com/mattn/go-pointer v0.0.1"
	"github.com/mattn/go-pointer v0.0.1/go.mod"
	"github.com/mattn/go-sqlite3 v1.14.52"
	"github.com/mattn/go-sqlite3 v1.14.52/go.mod"
	"github.com/mdp/qrterminal v1.0.1"
	"github.com/mdp/qrterminal v1.0.1/go.mod"
	"github.com/petermattis/goid v0.0.0-20260918085751-abfca077860b"
	"github.com/petermattis/goid v0.0.0-20260918085751-abfca077860b/go.mod"
	"github.com/pkg/diff v0.0.0-20210226163009-20ebb0f2a09e/go.mod"
	"github.com/pkg/errors v0.9.1"
	"github.com/pkg/errors v0.9.1/go.mod"
	"github.com/planetscale/vtprotobuf v0.6.1-0.20240319094008-0393e58bdf10"
	"github.com/planetscale/vtprotobuf v0.6.1-0.20240319094008-0393e58bdf10/go.mod"
	"github.com/pmezard/go-difflib v1.0.0"
	"github.com/pmezard/go-difflib v1.0.0/go.mod"
	"github.com/rogpeppe/go-internal v1.10.0"
	"github.com/rogpeppe/go-internal v1.10.0/go.mod"
	"github.com/rogpeppe/go-internal v1.9.0/go.mod"
	"github.com/rs/xid v1.6.0"
	"github.com/rs/xid v1.6.0/go.mod"
	"github.com/rs/zerolog v1.35.1"
	"github.com/rs/zerolog v1.35.1/go.mod"
	"github.com/sergi/go-diff v1.3.1"
	"github.com/sergi/go-diff v1.3.1/go.mod"
	"github.com/skip2/go-qrcode v0.0.0-20200617195104-da1b6568686e"
	"github.com/skip2/go-qrcode v0.0.0-20200617195104-da1b6568686e/go.mod"
	"github.com/spiffe/go-spiffe/v2 v2.8.1"
	"github.com/spiffe/go-spiffe/v2 v2.8.1/go.mod"
	"github.com/stretchr/testify v1.12.0"
	"github.com/stretchr/testify v1.12.0/go.mod"
	"github.com/tidwall/gjson v1.14.2/go.mod"
	"github.com/tidwall/gjson v1.20.0"
	"github.com/tidwall/gjson v1.20.0/go.mod"
	"github.com/tidwall/match v1.1.1/go.mod"
	"github.com/tidwall/match v1.2.0"
	"github.com/tidwall/match v1.2.0/go.mod"
	"github.com/tidwall/pretty v1.2.0/go.mod"
	"github.com/tidwall/pretty v1.2.1"
	"github.com/tidwall/pretty v1.2.1/go.mod"
	"github.com/tidwall/sjson v1.2.5"
	"github.com/tidwall/sjson v1.2.5/go.mod"
	"github.com/vektah/gqlparser/v2 v2.5.27"
	"github.com/vektah/gqlparser/v2 v2.5.27/go.mod"
	"github.com/yuin/goldmark v1.8.6"
	"github.com/yuin/goldmark v1.8.6/go.mod"
	"go.mau.fi/libsignal v0.2.2"
	"go.mau.fi/libsignal v0.2.2/go.mod"
	"go.mau.fi/util v0.11.0"
	"go.mau.fi/util v0.11.0/go.mod"
	"go.mau.fi/zeroconfig v0.2.0"
	"go.mau.fi/zeroconfig v0.2.0/go.mod"
	"go.opentelemetry.io/auto/sdk v1.2.1"
	"go.opentelemetry.io/auto/sdk v1.2.1/go.mod"
	"go.opentelemetry.io/contrib/detectors/gcp v1.44.0"
	"go.opentelemetry.io/contrib/detectors/gcp v1.44.0/go.mod"
	"go.opentelemetry.io/contrib/instrumentation/net/http/otelhttp v0.69.0"
	"go.opentelemetry.io/contrib/instrumentation/net/http/otelhttp v0.69.0/go.mod"
	"go.opentelemetry.io/otel v1.44.0"
	"go.opentelemetry.io/otel v1.44.0/go.mod"
	"go.opentelemetry.io/otel/metric v1.44.0"
	"go.opentelemetry.io/otel/metric v1.44.0/go.mod"
	"go.opentelemetry.io/otel/sdk v1.44.0"
	"go.opentelemetry.io/otel/sdk v1.44.0/go.mod"
	"go.opentelemetry.io/otel/sdk/metric v1.44.0"
	"go.opentelemetry.io/otel/sdk/metric v1.44.0/go.mod"
	"go.opentelemetry.io/otel/trace v1.44.0"
	"go.opentelemetry.io/otel/trace v1.44.0/go.mod"
	"golang.org/x/crypto v0.58.0"
	"golang.org/x/crypto v0.58.0/go.mod"
	"golang.org/x/exp v0.0.0-20261014143641-f0251eb4aa3e"
	"golang.org/x/exp v0.0.0-20261014143641-f0251eb4aa3e/go.mod"
	"golang.org/x/mod v0.42.0"
	"golang.org/x/mod v0.42.0/go.mod"
	"golang.org/x/net v0.61.0"
	"golang.org/x/net v0.61.0/go.mod"
	"golang.org/x/oauth2 v0.36.0"
	"golang.org/x/oauth2 v0.36.0/go.mod"
	"golang.org/x/sync v0.24.0"
	"golang.org/x/sync v0.24.0/go.mod"
	"golang.org/x/sys v0.49.0"
	"golang.org/x/sys v0.49.0/go.mod"
	"golang.org/x/sys v0.6.0/go.mod"
	"golang.org/x/term v0.47.0"
	"golang.org/x/term v0.47.0/go.mod"
	"golang.org/x/text v0.43.0"
	"golang.org/x/text v0.43.0/go.mod"
	"golang.org/x/tools v0.52.0"
	"golang.org/x/tools v0.52.0/go.mod"
	"golang.org/x/tools/go/expect v0.1.1-deprecated"
	"golang.org/x/tools/go/expect v0.1.1-deprecated/go.mod"
	"golang.org/x/tools/go/packages/packagestest v0.1.1-deprecated"
	"golang.org/x/tools/go/packages/packagestest v0.1.1-deprecated/go.mod"
	"gonum.org/v1/gonum v0.17.0"
	"gonum.org/v1/gonum v0.17.0/go.mod"
	"google.golang.org/api v0.278.0"
	"google.golang.org/api v0.278.0/go.mod"
	"google.golang.org/genproto/googleapis/api v0.0.0-20260706201446-f0a921348800"
	"google.golang.org/genproto/googleapis/api v0.0.0-20260706201446-f0a921348800/go.mod"
	"google.golang.org/genproto/googleapis/rpc v0.0.0-20260706201446-f0a921348800"
	"google.golang.org/genproto/googleapis/rpc v0.0.0-20260706201446-f0a921348800/go.mod"
	"google.golang.org/grpc v1.84.0"
	"google.golang.org/grpc v1.84.0/go.mod"
	"google.golang.org/protobuf v1.36.12"
	"google.golang.org/protobuf v1.36.12/go.mod"
	"gopkg.in/check.v1 v0.0.0-20161208181325-20d25e280405/go.mod"
	"gopkg.in/check.v1 v1.0.0-20201130134442-10cb98267c6c"
	"gopkg.in/check.v1 v1.0.0-20201130134442-10cb98267c6c/go.mod"
	"gopkg.in/natefinch/lumberjack.v2 v2.2.1"
	"gopkg.in/natefinch/lumberjack.v2 v2.2.1/go.mod"
	"gopkg.in/yaml.v3 v3.0.1"
	"gopkg.in/yaml.v3 v3.0.1/go.mod"
	"maunium.net/go/mauflag v1.0.0"
	"maunium.net/go/mauflag v1.0.0/go.mod"
	"maunium.net/go/mautrix v0.32.1-0.20261026145030-920bc073ba8d"
	"maunium.net/go/mautrix v0.32.1-0.20261026145030-920bc073ba8d/go.mod"
	"rsc.io/qr v0.2.0"
	"rsc.io/qr v0.2.0/go.mod"
)
# END GENERATED DEPENDENCIES
go-module_set_globals

DESCRIPTION="Terminal chat client with Signal, Telegram and WhatsApp support"
HOMEPAGE="https://github.com/d99kris/nchat"
SOURCE_URI="https://github.com/d99kris/nchat/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"
DEPS_FILES="lib/sgchat/go/go.sum lib/sgchat/go/ext/signal/go.sum lib/wmchat/go/go.sum lib/wmchat/go/ext/whatsmeow/go.sum"
LIBSIGNAL_VERSION="0.106.1"
LIBSIGNAL_BUILD_REF="5a918ba1c85828b06637f1cf424601f9a5b3e10c"
LIBSIGNAL_VERSION_FILE="lib/sgchat/go/ext/signal/pkg/libsignalgo/signalversion/version.go"
SRC_URI="${SOURCE_URI} ${EGO_SUM_SRC_URI}"

LICENSE="GPL-3 AGPL-3 Apache-2.0 BSD BSD-2 Boost-1.0 ISC MIT MPL-2.0"
SLOT="0"
KEYWORDS="~amd64"
RDEPEND="dev-db/sqlite:3
	dev-libs/openssl:=
	media-libs/libpng:=
	sys-apps/file
	sys-libs/ncurses:=
	virtual/zlib
	gui-apps/wl-clipboard"
DEPEND="${RDEPEND}
	=net-libs/libsignal-ffi-${LIBSIGNAL_VERSION}"
BDEPEND="app-arch/unzip
	>=dev-lang/go-1.27.1
	dev-util/gperf
	llvm-core/clang
	virtual/pkgconfig"

src_unpack() {
	unpack "${P}.tar.gz"
	local S="${S}/lib/sgchat/go"
	export GOTOOLCHAIN=local GOSUMDB=off
	go-module_setup_proxy
}

src_prepare() {
	cmake_src_prepare
	eapply "${FILESDIR}/nchat-explicit-cstdlib.patch"
	# nchat 5.20 releases contain both Signal fixes: one fixed-array file for
	# Clang and GCC, and the status-returning logger callbacks.
	if ver_test -lt 5.20; then
		eapply "${FILESDIR}/nchat-libsignal-clang.patch"
		eapply "${FILESDIR}/nchat-signal-logger.patch"
	fi
	# Both Go protocols share one runtime in the internal-static build. Seed the
	# generated module with the pinned union, rather than discovering versions.
	cp "${FILESDIR}/gostat-go.mod" lib/gostat/go.mod || die
	eapply "${FILESDIR}/nchat-gostat-pins.patch"
	grep -qxF "const Version = \"v${LIBSIGNAL_VERSION}\"" \
		"${LIBSIGNAL_VERSION_FILE}" || die "libsignal ABI changed"
	local acquisition=lib/sgchat/go/libsignal.cmake
	grep -qxF "set(LIBSIGNAL_BUILD_REF \"${LIBSIGNAL_BUILD_REF}\")" \
		"${acquisition}" || die "libsignal build revision changed"
	grep -qx 'if(DOWNLOAD_LIBSIGNAL)' "${acquisition}" || die
	grep -q '^# BoringSSL/OpenSSL symbol isolation' "${acquisition}" || die
	# Keep upstream symbol isolation, but remove both network acquisition paths.
	{
		sed '/^if(DOWNLOAD_LIBSIGNAL)$/,$d' "${acquisition}"
		cat "${FILESDIR}/libsignal-offline.cmake"
		sed -n '/^# BoringSSL\/OpenSSL symbol isolation/,$p' "${acquisition}"
	} > "${T}/libsignal.cmake" || die
	cp "${T}/libsignal.cmake" "${acquisition}" || die
}

src_configure() {
	go-module_src_configure
	export GOTOOLCHAIN=local GOFLAGS='-buildvcs=false -mod=readonly'
	# Before 5.20, Linux otherwise selects GCC cgo aliases even when CC is Clang.
	if tc-is-clang && ver_test -lt 5.20; then
		GOFLAGS+=' -tags=libsignal_clang'
	fi
	local mycmakeargs=(
		-DBUILD_TESTING=OFF
		# Keep bundled clip internal; external system libraries stay shared.
		-DBUILD_SHARED_LIBS=OFF
		# dobin does not perform CMake's install-time RPATH rewrite.
		-DCMAKE_SKIP_RPATH=ON
		-DDOWNLOAD_LIBSIGNAL=OFF
		-DNEUROGENTOO_LIBSIGNAL_FFI="${ESYSROOT}/usr/$(get_libdir)/libsignal-ffi/${LIBSIGNAL_VERSION}/libsignal_ffi.a"
		-DHAS_DUMMY=OFF
		-DHAS_DYNAMICLOAD=OFF
		-DHAS_SHARED_LIBS=OFF
		-DHAS_STATIC_EXTLIBS=OFF
		-DHAS_STATICGOLIB=ON
		-DHAS_SIGNAL=ON
		-DHAS_TELEGRAM=ON
		-DHAS_WHATSAPP=ON
		-DHAVE_XCB_XLIB_H=OFF
		-DCLIP_X11_WITH_PNG=OFF
		-DCMAKE_REQUIRE_FIND_PACKAGE_PNG=ON
	)
	cmake_src_configure
	# Upstream otherwise silently falls back to text-only clipboard support.
	grep -qx 'FOUND_PNG_H:INTERNAL=1' "${BUILD_DIR}/CMakeCache.txt" ||
		die "PNG image clipboard support is required"
}

src_install() {
	# Upstream also installs internal static libraries; only the application and
	# its documentation are runtime outputs of this recipe.
	dobin "${BUILD_DIR}/bin/nchat"
	doman src/nchat.1
	dodoc LICENSE LICENSE.AGPL-3.0 "${BUILD_DIR}/THIRD_PARTY_LICENSES"
}
