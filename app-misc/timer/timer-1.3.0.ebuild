# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit go-module
# BEGIN GENERATED DEPENDENCIES
EGO_SUM=(
	"github.com/atotto/clipboard v0.1.4/go.mod"
	"github.com/aymanbagabas/go-osc52 v1.0.3/go.mod"
	"github.com/aymanbagabas/go-osc52 v1.2.1/go.mod"
	"github.com/aymanbagabas/go-osc52/v2 v2.0.1"
	"github.com/aymanbagabas/go-osc52/v2 v2.0.1/go.mod"
	"github.com/charmbracelet/bubbles v0.15.0"
	"github.com/charmbracelet/bubbles v0.15.0/go.mod"
	"github.com/charmbracelet/bubbletea v0.23.1/go.mod"
	"github.com/charmbracelet/bubbletea v0.23.2"
	"github.com/charmbracelet/bubbletea v0.23.2/go.mod"
	"github.com/charmbracelet/harmonica v0.2.0"
	"github.com/charmbracelet/harmonica v0.2.0/go.mod"
	"github.com/charmbracelet/lipgloss v0.6.0/go.mod"
	"github.com/charmbracelet/lipgloss v0.7.1"
	"github.com/charmbracelet/lipgloss v0.7.1/go.mod"
	"github.com/containerd/console v1.0.3"
	"github.com/containerd/console v1.0.3/go.mod"
	"github.com/cpuguy83/go-md2man/v2 v2.0.2/go.mod"
	"github.com/inconshreveable/mousetrap v1.1.0"
	"github.com/inconshreveable/mousetrap v1.1.0/go.mod"
	"github.com/kylelemons/godebug v1.1.0/go.mod"
	"github.com/lucasb-eyer/go-colorful v1.2.0"
	"github.com/lucasb-eyer/go-colorful v1.2.0/go.mod"
	"github.com/mattn/go-isatty v0.0.14/go.mod"
	"github.com/mattn/go-isatty v0.0.16/go.mod"
	"github.com/mattn/go-isatty v0.0.17"
	"github.com/mattn/go-isatty v0.0.17/go.mod"
	"github.com/mattn/go-localereader v0.0.1"
	"github.com/mattn/go-localereader v0.0.1/go.mod"
	"github.com/mattn/go-runewidth v0.0.10/go.mod"
	"github.com/mattn/go-runewidth v0.0.12/go.mod"
	"github.com/mattn/go-runewidth v0.0.13/go.mod"
	"github.com/mattn/go-runewidth v0.0.14"
	"github.com/mattn/go-runewidth v0.0.14/go.mod"
	"github.com/muesli/ansi v0.0.0-20211018074035-2e021307bc4b/go.mod"
	"github.com/muesli/ansi v0.0.0-20211031195517-c9f0611b6c70"
	"github.com/muesli/ansi v0.0.0-20211031195517-c9f0611b6c70/go.mod"
	"github.com/muesli/cancelreader v0.2.2"
	"github.com/muesli/cancelreader v0.2.2/go.mod"
	"github.com/muesli/mango v0.1.0"
	"github.com/muesli/mango v0.1.0/go.mod"
	"github.com/muesli/mango-cobra v1.2.0"
	"github.com/muesli/mango-cobra v1.2.0/go.mod"
	"github.com/muesli/mango-pflag v0.1.0"
	"github.com/muesli/mango-pflag v0.1.0/go.mod"
	"github.com/muesli/reflow v0.2.1-0.20210115123740-9e1d0d53df68/go.mod"
	"github.com/muesli/reflow v0.3.0"
	"github.com/muesli/reflow v0.3.0/go.mod"
	"github.com/muesli/roff v0.1.0"
	"github.com/muesli/roff v0.1.0/go.mod"
	"github.com/muesli/termenv v0.11.1-0.20220204035834-5ac8409525e0/go.mod"
	"github.com/muesli/termenv v0.13.0/go.mod"
	"github.com/muesli/termenv v0.14.0/go.mod"
	"github.com/muesli/termenv v0.15.1"
	"github.com/muesli/termenv v0.15.1/go.mod"
	"github.com/rivo/uniseg v0.1.0/go.mod"
	"github.com/rivo/uniseg v0.2.0"
	"github.com/rivo/uniseg v0.2.0/go.mod"
	"github.com/russross/blackfriday/v2 v2.1.0/go.mod"
	"github.com/sahilm/fuzzy v0.1.0/go.mod"
	"github.com/spf13/cobra v1.7.0"
	"github.com/spf13/cobra v1.7.0/go.mod"
	"github.com/spf13/pflag v1.0.5"
	"github.com/spf13/pflag v1.0.5/go.mod"
	"golang.org/x/sync v0.1.0"
	"golang.org/x/sync v0.1.0/go.mod"
	"golang.org/x/sys v0.0.0-20210124154548-22da62e12c0c/go.mod"
	"golang.org/x/sys v0.0.0-20210615035016-665e8c7367d1/go.mod"
	"golang.org/x/sys v0.0.0-20210630005230-0f9fa26af87c/go.mod"
	"golang.org/x/sys v0.0.0-20220204135822-1c1b9b1eba6a/go.mod"
	"golang.org/x/sys v0.0.0-20220811171246-fbc7d0a398ab/go.mod"
	"golang.org/x/sys v0.6.0"
	"golang.org/x/sys v0.6.0/go.mod"
	"golang.org/x/term v0.0.0-20210927222741-03fcf44c2211"
	"golang.org/x/term v0.0.0-20210927222741-03fcf44c2211/go.mod"
	"golang.org/x/text v0.3.7/go.mod"
	"golang.org/x/text v0.3.8"
	"golang.org/x/text v0.3.8/go.mod"
	"golang.org/x/tools v0.0.0-20180917221912-90fa682c2a6e/go.mod"
	"gopkg.in/check.v1 v0.0.0-20161208181325-20d25e280405/go.mod"
	"gopkg.in/yaml.v3 v3.0.1/go.mod"
)
# END GENERATED DEPENDENCIES
go-module_set_globals

DESCRIPTION="Terminal countdown timer"
HOMEPAGE="https://github.com/caarlos0/timer"
SOURCE_COMMIT="50561bc33b32d1a07cddf8264e3cbb134f425463"
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
