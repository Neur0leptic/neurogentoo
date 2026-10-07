#!/usr/bin/env bash
# Prepare one disposable Gentoo runner for the selected application's build.
# This is not an installer or a compiler/world-bootstrap validation.
set -Eeuo pipefail
shopt -s inherit_errexit

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=.github/scripts/update-package.sh
source "$script_dir/update-package.sh"

copy_ci_layer() { # SOURCE_LAYER PORTAGE_DIR
	local relative files
	files="$(find "$1" -type f -printf '%P\n' | LC_ALL=C sort)"
	while IFS= read -r relative; do
		# CI installs one package, not a tier; only that package is unmasked.
		case "$relative" in
			env/*|package.use/*|package.env/*|package.mask/*|package.accept_keywords/*|profile/*)
				install -D -m 0644 -- "$1/$relative" "$2/$relative"
				;;
		esac
	done <<<"$files"
}

render_ci_make_conf() { # TEMPLATE DESTINATION
	local jobs="${CI_BUILD_JOBS:-}" cores memory_jobs
	if [[ -z "$jobs" ]]; then
		cores="$(nproc)"
		memory_jobs="$(awk '/^MemAvailable:/ { n = int($2 / 2097152); print (n > 0 ? n : 1) }' /proc/meminfo)"
		jobs=2
		if ((cores < jobs)); then jobs="$cores"; fi
		if ((memory_jobs < jobs)); then jobs="$memory_jobs"; fi
	fi
	[[ "$jobs" =~ ^[1-9][0-9]*$ && "$jobs" -le 8 ]] || die "invalid CI_BUILD_JOBS"
	# Compile the Intel desktop policy on the runner, without claiming a GPU
	# rendering test. Native CPU flags describe this runner, not an installed PC.
	sed -e "s/@BUILD_JOBS@/$jobs/g" -e "s/@BUILD_LOAD@/$jobs/g" \
		-e 's/@EMERGE_JOBS@/1/g' -e 's/@VIDEO_CARDS@/intel/g' "$1" >"$2"
	if grep -q '@[A-Z_]*@' "$2"; then die "unresolved CI make.conf template"; fi
}

apply_ci_layers() { # PORTAGE_DIR: the same native policy files the installer uses
	local layer
	for layer in bootstrap base clang dwl dwl-apps source-apps binary-apps; do
		copy_ci_layer "$repo_root/config/portage/$layer" "$1"
	done
	copy_ci_layer "$repo_root/config/hardware/templates/intel-legacy/dwl" "$1"
}

prepare_ci() {
	(($# == 1)) || die "usage: prepare-ci.sh PACKAGE"
	conf_field "$1" 2 >/dev/null
	[[ "${GITHUB_ACTIONS:-}" == true && -f /etc/gentoo-release && "$EUID" == 0 ]] ||
		die "prepare-ci is only for a disposable Gentoo Actions container"
	local profile
	profile="$(readlink -f /etc/portage/make.profile)"
	[[ "$profile" == *no-multilib* && "$profile" != *systemd* ]] ||
		die "CI must use an amd64 no-multilib OpenRC profile: $profile"
	[[ "$(uname -m)" == x86_64 ]] || die "CI must run on amd64"
	install -d /etc/portage
	copy_ci_layer "$repo_root/config/portage/bootstrap" /etc/portage
	copy_ci_layer "$repo_root/config/portage/base" /etc/portage
	render_ci_make_conf "$repo_root/config/portage/bootstrap/make.conf" /etc/portage/make.conf
	configure_overlay "$1"
	# Prepare the required toolchain with GCC before enabling the final flags.
	# Dependency binary packages are accepted only when their USE settings match.
	FEATURES="userpriv usersandbox sandbox network-sandbox" \
		emerge --oneshot --getbinpkg --binpkg-respect-use=y --autounmask=n \
			llvm-core/clang:22 llvm-core/lld:22 llvm-core/polly:22 \
			'llvm-runtimes/clang-runtime:22[compiler-rt,polly]' \
			'=llvm-runtimes/libcxx-22*' '=llvm-runtimes/libcxxabi-22*' \
			'=llvm-runtimes/libunwind-22*' dev-lang/rust
	apply_ci_layers /etc/portage
	render_ci_make_conf "$repo_root/config/portage/clang/make.conf" /etc/portage/make.conf
	# Keep CLI tools able to find the requested slot even if no global symlink exists.
	export PATH="/usr/lib/llvm/22/bin:$PATH"
	# The DWL layer keywords Go >=1.27.1, so Go follows the final policy, as on an
	# installed system.
	FEATURES="userpriv usersandbox sandbox network-sandbox" \
		emerge --oneshot --getbinpkg --binpkg-respect-use=y --autounmask=n '>=dev-lang/go-1.27.1'
	for tool in clang clang++ ld.lld llvm-ar rustc cargo go; do
		command -v "$tool" >/dev/null || die "missing CI toolchain command: $tool"
	done
	configure_overlay "$1"
	printf '%s\n' /usr/lib/llvm/22/bin >>"${GITHUB_PATH:?GITHUB_PATH is required}"
	printf '%s\n' "$1" >/run/neurogentoo-ci-ready
	printf 'CI policy: amd64 no-multilib OpenRC, Intel desktop, final Clang flags\n'
	emerge --info
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then prepare_ci "$@"; fi
