#!/usr/bin/env bash
# Prepare one disposable Gentoo container for the selected application's build.
# Builds use Gentoo's stock profile, toolchain and binary packages; only the
# packages under test are compiled from source. The installer's compiler policy
# is not reproduced: GitHub's runners cannot build that toolchain within a job,
# and installed systems compile merged updates with it anyway.
set -Eeuo pipefail
shopt -s inherit_errexit

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=.github/scripts/update-package.sh
source "$script_dir/update-package.sh"

ci_keywords() { # The overlay's Go recipes need the Go release the DWL layer keywords.
	grep -h '^>=dev-lang/go-[0-9.]* ~amd64$' "$repo_root/config/portage/dwl/package.accept_keywords/"* ||
		die "no Go keyword in the DWL policy"
}

prepare_ci() {
	(($# == 1)) || die "usage: prepare-ci.sh PACKAGE"
	conf_field "$1" 2 >/dev/null
	[[ "${GITHUB_ACTIONS:-}" == true && -f /etc/gentoo-release && "$EUID" == 0 ]] ||
		die "prepare-ci is only for a disposable Gentoo Actions container"
	[[ "$(uname -m)" == x86_64 ]] || die "CI must run on amd64"
	# actions/checkout records safe.directory under a temporary HOME, and these
	# steps run as root on a checkout owned by the runner user.
	git config --global --add safe.directory "$repo_root"
	install -d /etc/portage/package.accept_keywords
	ci_keywords >/etc/portage/package.accept_keywords/ci-go
	printf 'MAKEOPTS="-j%s"\n' "$(nproc)" >>/etc/portage/make.conf
	configure_overlay "$1"
	# The updater regenerates Go dependency lists, and its tests need Go too.
	FEATURES="userpriv usersandbox sandbox network-sandbox" \
		emerge --oneshot --getbinpkg --noreplace --autounmask=n "$(ci_keywords | cut -d' ' -f1)"
	printf '%s\n' "$1" >/run/neurogentoo-ci-ready
	emerge --info
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then prepare_ci "$@"; fi
