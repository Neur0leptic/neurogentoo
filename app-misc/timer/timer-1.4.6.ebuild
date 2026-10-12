# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit go-module
# BEGIN GENERATED DEPENDENCIES
EGO_SUM=(
	"github.com/aymanbagabas/go-osc52/v2 v2.0.1"
	"github.com/aymanbagabas/go-osc52/v2 v2.0.1/go.mod"
	"github.com/charmbracelet/bubbles v0.20.0"
	"github.com/charmbracelet/bubbles v0.20.0/go.mod"
	"github.com/charmbracelet/bubbletea v1.3.4"
	"github.com/charmbracelet/bubbletea v1.3.4/go.mod"
	"github.com/charmbracelet/harmonica v0.2.0"
	"github.com/charmbracelet/harmonica v0.2.0/go.mod"
	"github.com/charmbracelet/lipgloss v1.0.0"
	"github.com/charmbracelet/lipgloss v1.0.0/go.mod"
	"github.com/charmbracelet/x/ansi v0.8.0"
	"github.com/charmbracelet/x/ansi v0.8.0/go.mod"
	"github.com/charmbracelet/x/term v0.2.1"
	"github.com/charmbracelet/x/term v0.2.1/go.mod"
	"github.com/cpuguy83/go-md2man/v2 v2.0.6/go.mod"
	"github.com/erikgeiser/coninput v0.0.0-20211004153227-1c3628e74d0f"
	"github.com/erikgeiser/coninput v0.0.0-20211004153227-1c3628e74d0f/go.mod"
	"github.com/inconshreveable/mousetrap v1.1.0"
	"github.com/inconshreveable/mousetrap v1.1.0/go.mod"
	"github.com/lucasb-eyer/go-colorful v1.2.0"
	"github.com/lucasb-eyer/go-colorful v1.2.0/go.mod"
	"github.com/mattn/go-isatty v0.0.20"
	"github.com/mattn/go-isatty v0.0.20/go.mod"
	"github.com/mattn/go-localereader v0.0.1"
	"github.com/mattn/go-localereader v0.0.1/go.mod"
	"github.com/mattn/go-runewidth v0.0.16"
	"github.com/mattn/go-runewidth v0.0.16/go.mod"
	"github.com/muesli/ansi v0.0.0-20230316100256-276c6243b2f6"
	"github.com/muesli/ansi v0.0.0-20230316100256-276c6243b2f6/go.mod"
	"github.com/muesli/cancelreader v0.2.2"
	"github.com/muesli/cancelreader v0.2.2/go.mod"
	"github.com/muesli/mango v0.2.0"
	"github.com/muesli/mango v0.2.0/go.mod"
	"github.com/muesli/mango-cobra v1.2.0"
	"github.com/muesli/mango-cobra v1.2.0/go.mod"
	"github.com/muesli/mango-pflag v0.1.0"
	"github.com/muesli/mango-pflag v0.1.0/go.mod"
	"github.com/muesli/roff v0.1.0"
	"github.com/muesli/roff v0.1.0/go.mod"
	"github.com/muesli/termenv v0.15.2"
	"github.com/muesli/termenv v0.15.2/go.mod"
	"github.com/rivo/uniseg v0.2.0/go.mod"
	"github.com/rivo/uniseg v0.4.7"
	"github.com/rivo/uniseg v0.4.7/go.mod"
	"github.com/russross/blackfriday/v2 v2.1.0/go.mod"
	"github.com/spf13/cobra v1.9.1"
	"github.com/spf13/cobra v1.9.1/go.mod"
	"github.com/spf13/pflag v1.0.6"
	"github.com/spf13/pflag v1.0.6/go.mod"
	"golang.org/x/sync v0.11.0"
	"golang.org/x/sync v0.11.0/go.mod"
	"golang.org/x/sys v0.0.0-20210809222454-d867a43fc93e/go.mod"
	"golang.org/x/sys v0.30.0"
	"golang.org/x/sys v0.30.0/go.mod"
	"golang.org/x/sys v0.6.0/go.mod"
	"golang.org/x/text v0.13.0"
	"golang.org/x/text v0.13.0/go.mod"
	"gopkg.in/check.v1 v0.0.0-20161208181325-20d25e280405/go.mod"
	"gopkg.in/yaml.v3 v3.0.1/go.mod"
)
# END GENERATED DEPENDENCIES
go-module_set_globals

DESCRIPTION="Terminal countdown timer"
HOMEPAGE="https://github.com/caarlos0/timer"
SOURCE_COMMIT="f7723f23883efd0391ce928183b40459cfa4f1f7"
SOURCE_URI="https://github.com/caarlos0/timer/archive/${SOURCE_COMMIT}.tar.gz -> timer-${SOURCE_COMMIT}.tar.gz"
SRC_URI="${SOURCE_URI} ${EGO_SUM_SRC_URI}"
S="${WORKDIR}/timer-${SOURCE_COMMIT}"

LICENSE="MIT Apache-2.0 BSD BSD-2"
SLOT="0"
KEYWORDS="~amd64"
BDEPEND=">=dev-lang/go-1.27.1"

src_unpack() {
	export GOTOOLCHAIN=local GOSUMDB=off
	go-module_src_unpack
}

src_compile() {
	GOTOOLCHAIN=local CGO_ENABLED=0 ego build -buildvcs=false -mod=readonly -trimpath \
		-ldflags="-s -w -buildid= -X main.version=${PV}" -o timer .
}

src_install() {
	dobin timer
	einstalldocs
}
