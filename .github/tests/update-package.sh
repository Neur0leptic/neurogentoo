#!/usr/bin/env bash
# Behavioral tests using temporary files and mocked package/GitHub operations.
# No system configuration, package builds, commits or pushes are performed.
# Fixtures are evaluated in child shells; mocks are called by the sourced updater.
# shellcheck disable=SC2016,SC2329
set -Eeuo pipefail

test_script="$(realpath -- "${BASH_SOURCE[0]}")"
scripts="$(dirname -- "$test_script")/../scripts"
# shellcheck source=.github/scripts/update-package.sh
source "$scripts/update-package.sh"
fixture="$(mktemp -d "${TMPDIR:-/tmp}/neurogentoo-test.XXXXXX")"
cleanup() {
	# Go makes extracted module directories read-only by default.
	chmod -R u+w -- "$fixture"
	rm -rf -- "$fixture"
}
trap cleanup EXIT
export UPDATER="$scripts/update-package.sh" FIXTURE="$fixture"

assert() { "$@" || die "assertion failed: $*"; }

expect_failure() {
	if bash -c "$1" >"$fixture/failure.log" 2>&1; then
		die "expected command to fail"
	fi
}

make_package() {
	repo_root="$fixture/repo"
	conf="$fixture/packages.conf"
	mkdir -p "$repo_root/gui-apps/ripdrag"
	printf 'gui-apps/ripdrag cargo pr ripdrag --help\n' >"$conf"
	printf 'EAPI=8\n' >"$repo_root/gui-apps/ripdrag/ripdrag-0.4.12.ebuild"
	printf '<remote-id type="github">nik012003/ripdrag</remote-id>\n' \
		>"$repo_root/gui-apps/ripdrag/metadata.xml"
}

test_set_var() {
	printf 'LIBSIGNAL_VERSION_FILE="old/version.go"\n' >"$fixture/recipe"
	set_var "$fixture/recipe" LIBSIGNAL_VERSION_FILE new/signalversion/version.go
	assert grep -qx 'LIBSIGNAL_VERSION_FILE="new/signalversion/version.go"' "$fixture/recipe"
	expect_failure 'source "$UPDATER"; set_var "$FIXTURE/recipe" LIBSIGNAL_VERSION_FILE "../version.go"'
}

test_command_substitution_failure() {
	expect_failure 'source "$UPDATER"; broken() { false; printf hidden; }; value="$(broken)"; touch "$FIXTURE/continued"'
	assert test ! -e "$fixture/continued"
}

test_ego_sum() {
	printf 'EGO_SUM=(\n\t"old v1.0.0"\n)\n' >"$fixture/recipe"
	printf 'example.org/a v1.2.0 h1:abc=\nexample.org/a v1.2.0/go.mod h1:def=\n' >"$fixture/go.sum"
	regenerate_ego_sum "$fixture/recipe" "$fixture"
	assert grep -qx $'\t"example.org/a v1.2.0"' "$fixture/recipe"
	assert grep -qx $'\t"example.org/a v1.2.0/go.mod"' "$fixture/recipe"
	assert test "$(grep -c '^)' "$fixture/recipe")" == 1
	cp "$fixture/recipe" "$fixture/before"
	printf 'evil$(touch_marker) v1.2.0 h1:abc=\n' >"$fixture/go.sum"
	expect_failure 'source "$UPDATER"; regenerate_ego_sum "$FIXTURE/recipe" "$FIXTURE"'
	assert cmp "$fixture/recipe" "$fixture/before"
}

test_cargo_members() {
	printf 'CARGO_UPDATE_DIRS="yazi-fm yazi-cli"\n' >"$fixture/recipe"
	mkdir -p "$fixture/source/"{yazi-fm,yazi-cli}
	touch "$fixture/source/"{yazi-fm,yazi-cli}/Cargo.toml
	pycargoebuild() { printf '%s\n' "$@" >"$fixture/cargo.args"; }
	regenerate_cargo "$fixture/recipe" "$fixture/source"
	assert grep -qxF "$fixture/source/yazi-fm" "$fixture/cargo.args"
	assert grep -qxF "$fixture/source/yazi-cli" "$fixture/cargo.args"
	assert grep -qxF -- -C "$fixture/cargo.args"
}

test_nchat_version_location() {
	repo_root="$fixture/repo"
	mkdir -p "$repo_root/net-libs/libsignal-ffi" "$fixture/source/lib/sgchat/go/ext/signal/pkg/libsignalgo/signalversion"
	touch "$repo_root/net-libs/libsignal-ffi/libsignal-ffi-0.100.0.ebuild"
	printf 'LIBSIGNAL_VERSION="0.100.0"\nLIBSIGNAL_BUILD_REF="old"\nLIBSIGNAL_VERSION_FILE="old/version.go"\n' >"$fixture/recipe"
	printf 'const Version = "v0.102.2"\n' >"$fixture/source/lib/sgchat/go/ext/signal/pkg/libsignalgo/signalversion/version.go"
	printf 'set(LIBSIGNAL_BUILD_REF "0123456789012345678901234567890123456789")\n' >"$fixture/source/lib/sgchat/go/libsignal.cmake"
	update_libsignal() { printf '%s\n' "$1" >"$fixture/libsignal.version"; }
	update_nchat_libsignal "$fixture/recipe" "$fixture/source"
	assert grep -qx 'LIBSIGNAL_VERSION="0.102.2"' "$fixture/recipe"
	assert grep -qx 'LIBSIGNAL_VERSION_FILE="lib/sgchat/go/ext/signal/pkg/libsignalgo/signalversion/version.go"' "$fixture/recipe"
	assert grep -qx '0.102.2' "$fixture/libsignal.version"
	cp "$fixture/source/lib/sgchat/go/ext/signal/pkg/libsignalgo/signalversion/version.go" \
		"$fixture/source/lib/sgchat/go/ext/signal/pkg/libsignalgo/version.go"
	expect_failure 'source "$UPDATER"; repo_root="$FIXTURE/repo"; update_nchat_libsignal "$FIXTURE/recipe" "$FIXTURE/source"'
}

test_gostat_mvs() {
	local tree
	command -v go >/dev/null || die "Go is required for the MVS test"
	repo_root="$fixture/repo"
	mkdir -p "$repo_root/net-im/nchat/files" "$fixture/source/lib/"{wmchat/go/ext/whatsmeow,sgchat/go/ext/signal,gostat}
	printf 'module example.org/wm\n\ngo 1.25.0\n\nrequire (\n example.org/shared v1.2.0\n go.mau.fi/whatsmeow v0.0.0\n)\nreplace go.mau.fi/whatsmeow => ./ext/whatsmeow\n' >"$fixture/source/lib/wmchat/go/go.mod"
	printf 'module example.org/sg\n\ngo 1.25.0\n\nrequire (\n example.org/shared v1.10.0\n go.mau.fi/mautrix-signal v0.0.0\n)\nreplace go.mau.fi/mautrix-signal => ./ext/signal\n' >"$fixture/source/lib/sgchat/go/go.mod"
	printf 'module go.mau.fi/whatsmeow\n\ngo 1.25.0\n' >"$fixture/source/lib/wmchat/go/ext/whatsmeow/go.mod"
	printf 'module go.mau.fi/mautrix-signal\n\ngo 1.25.0\n' >"$fixture/source/lib/sgchat/go/ext/signal/go.mod"
	touch "$fixture/source/lib/"{wmchat,sgchat}/go/go.sum
	mkdir -p "$fixture/proxy/example.org/shared/@v"
	# git archive can produce module zip fixtures from a tree without any commit.
	git -c init.defaultBranch=main init -q "$fixture/archive"
	printf 'module example.org/shared\n\ngo 1.25.0\n' >"$fixture/archive/go.mod"
	git -C "$fixture/archive" add go.mod
	tree="$(git -C "$fixture/archive" write-tree)"
	for version in v1.2.0 v1.10.0; do
		printf 'module example.org/shared\n\ngo 1.25.0\n' >"$fixture/proxy/example.org/shared/@v/$version.mod"
		printf '{"Version":"%s","Time":"2026-01-01T00:00:00Z"}\n' "$version" >"$fixture/proxy/example.org/shared/@v/$version.info"
		git -C "$fixture/archive" archive --format=zip --prefix="example.org/shared@$version/" \
			"$tree" >"$fixture/proxy/example.org/shared/@v/$version.zip"
	done
	export GOPROXY="file://$fixture/proxy" GOSUMDB=off GOMODCACHE="$fixture/modcache" GOCACHE="$fixture/cache"
	regenerate_gostat "$fixture/recipe" "$fixture/source"
	assert grep -q 'example.org/shared v1.10.0' "$repo_root/net-im/nchat/files/gostat-go.mod"
	assert grep -q '@WM_DIR@/ext/whatsmeow' "$repo_root/net-im/nchat/files/gostat-go.mod"
	assert grep -q '@SG_DIR@/ext/signal' "$repo_root/net-im/nchat/files/gostat-go.mod"
	assert grep -q '^example.org/shared v1.10.0 h1:' "$fixture/source/lib/gostat/go.sum"
	assert grep -q '^example.org/shared v1.10.0/go.mod h1:' "$fixture/source/lib/gostat/go.sum"
	cp "$repo_root/net-im/nchat/files/gostat-go.mod" "$fixture/pins.before"
	cp "$fixture/source/lib/gostat/go.sum" "$fixture/sums.before"
	regenerate_gostat "$fixture/recipe" "$fixture/source"
	assert cmp "$repo_root/net-im/nchat/files/gostat-go.mod" "$fixture/pins.before"
	assert cmp "$fixture/source/lib/gostat/go.sum" "$fixture/sums.before"
	printf 'EGO_SUM=(\n)\n' >"$fixture/recipe"
	regenerate_ego_sum "$fixture/recipe" "$fixture/source/lib/gostat"
	assert grep -qx $'\t"example.org/shared v1.10.0"' "$fixture/recipe"
}

test_ci_keywords() {
	# shellcheck source=.github/scripts/prepare-ci.sh
	source "$scripts/prepare-ci.sh"
	assert test "$(ci_keywords | wc -l)" == 1
	assert grep -qx '>=dev-lang/go-[0-9.]* ~amd64' <(ci_keywords)
}

test_update_detection() {
	make_package
	latest_release() { printf '0.4.13\n'; }
	pull_request_for() { :; }
	assert test "$(cmd_check | sed 's/^matrix=//' | jq -r '.[0].version')" == 0.4.13
	pull_request_for() { printf '42\n'; }
	assert test "$(cmd_check)" == 'matrix=[]'
	latest_release() { printf '0.4.12\n'; }
	assert test "$(cmd_check)" == 'matrix=[]'
}

test_check_api_failure() {
	make_package
	expect_failure 'source "$UPDATER"; repo_root="$FIXTURE/repo"; conf="$FIXTURE/packages.conf"; latest_release() { printf "0.4.13\n"; }; pull_request_for() { return 22; }; cmd_check; touch "$FIXTURE/continued"'
	assert test ! -e "$fixture/continued"
}

test_build_arguments() {
	make_package
	require_ci() { :; }
	configure_overlay() { :; }
	emerge() { printf '%s\n' "$@" >>"$fixture/emerge.args"; printf 'FEATURES=%s\n' "$FEATURES" >>"$fixture/emerge.args"; }
	runuser() { printf '%s\n' "$@" >"$fixture/smoke.args"; }
	cmd_build gui-apps/ripdrag 0.4.13
	assert grep -qxF -- --pretend "$fixture/emerge.args"
	assert test "$(grep -cFx -- --autounmask=n "$fixture/emerge.args")" == 2
	assert grep -qxF -- --usepkg-exclude=gui-apps/ripdrag::neurogentoo "$fixture/emerge.args"
	assert grep -q '^FEATURES=.*network-sandbox' "$fixture/emerge.args"
	assert grep -qxF 'ripdrag --help' "$fixture/smoke.args"
}

test_build_and_smoke_failures() {
	make_package
	expect_failure 'source "$UPDATER"; conf="$FIXTURE/packages.conf"; require_ci() { :; }; configure_overlay() { :; }; emerge() { if [[ "$1" == --pretend ]]; then return 0; else return 47; fi; }; runuser() { touch "$FIXTURE/smoke"; }; cmd_publish() { touch "$FIXTURE/published"; }; cmd_build gui-apps/ripdrag 0.4.13; cmd_publish gui-apps/ripdrag 0.4.13'
	assert test ! -e "$fixture/smoke"
	assert test ! -e "$fixture/published"
	expect_failure 'source "$UPDATER"; conf="$FIXTURE/packages.conf"; require_ci() { :; }; configure_overlay() { :; }; emerge() { :; }; runuser() { return 33; }; cmd_publish() { touch "$FIXTURE/published"; }; cmd_build gui-apps/ripdrag 0.4.13; cmd_publish gui-apps/ripdrag 0.4.13'
	assert test ! -e "$fixture/published"
}

test_nchat_build_arguments() {
	make_package
	mkdir -p "$repo_root/net-libs/libsignal-ffi"
	touch "$repo_root/net-libs/libsignal-ffi/libsignal-ffi-0.102.2.ebuild"
	printf 'net-im/nchat nchat pr nchat --help\n' >"$conf"
	require_ci() { :; }
	configure_overlay() { :; }
	emerge() { printf '%s\n' "$@" >>"$fixture/emerge.args"; }
	runuser() { :; }
	cmd_build net-im/nchat 5.19.18
	assert grep -qxF -- '--usepkg-exclude=net-im/nchat::neurogentoo net-libs/libsignal-ffi::neurogentoo' "$fixture/emerge.args"
	assert test "$(grep -cFx -- '=net-libs/libsignal-ffi-0.102.2::neurogentoo' "$fixture/emerge.args")" == 2
}

test_pr_only() {
	make_package
	export GITHUB_TOKEN=fixture-token GITHUB_REPOSITORY=example/repo \
		GITHUB_SERVER_URL=https://github.com GITHUB_RUN_ID=123
	git() { printf '%s\n' "$*" >>"$fixture/git.calls"; }
	api() {
		printf '%s %s\n' "$1" "$2" >>"$fixture/api.calls"
		[[ "$1" == POST && "$2" == /repos/example/repo/pulls ]] || die "unexpected API write"
		printf '{"number":42}\n'
	}
	cmd_publish gui-apps/ripdrag 0.4.13
	assert test "$(wc -l <"$fixture/api.calls")" == 1
	assert grep -q 'add -A -- gui-apps/ripdrag$' "$fixture/git.calls"
	assert grep -q 'push -q --force origin update/gui-apps-ripdrag-0.4.13$' "$fixture/git.calls"
}

test_failure_report() {
	export GITHUB_REPOSITORY=example/repo GITHUB_SERVER_URL=https://github.com GITHUB_RUN_ID=123
	printf 'controlled updater failure\n' >"$fixture/update.log"
	export UPDATE_LOG="$fixture/update.log"
	api() {
		printf '%s %s\n' "$1" "$2" >>"$fixture/api.calls"
		if [[ "$1" == GET ]]; then
			printf '[]\n'
		else
			jq -r '.body' <<<"$3" >"$fixture/issue.body"
			printf '{"number":1}\n'
		fi
	}
	cmd_report_failure gui-apps/ripdrag 0.4.13
	assert grep -qx 'POST /repos/example/repo/issues' "$fixture/api.calls"
	assert grep -qx 'controlled updater failure' "$fixture/issue.body"
	assert grep -qF 'https://github.com/example/repo/actions/runs/123' "$fixture/issue.body"
}

test_early_failure_report() {
	make_package
	printf 'app-misc/yazi cargo pr yazi --version\n' >>"$conf"
	export GITHUB_REPOSITORY=example/repo GITHUB_RUN_ID=123
	export UPDATE_MATRIX='[{"package":"gui-apps/ripdrag","version":"0.4.13"},{"package":"app-misc/yazi","version":"26.8.15"}]'
	api() {
		case "$2" in
			*/jobs\?*) printf '{"jobs":[{"id":7,"name":"Update gui-apps/ripdrag 0.4.13","conclusion":"failure"},{"id":8,"name":"Update app-misc/yazi 26.8.15","conclusion":"success"}]}\n' ;;
			*/jobs/7/logs) printf 'controlled tool setup failure\n' ;;
			*) die "unexpected reporter request: $2" ;;
		esac
	}
	cmd_report_failure() {
		printf '%s %s\n' "$1" "$2" >>"$fixture/reports"
		assert grep -qx 'controlled tool setup failure' "$UPDATE_LOG"
	}
	cmd_report_run_failure
	assert grep -qx 'gui-apps/ripdrag 0.4.13' "$fixture/reports"
	assert test "$(wc -l <"$fixture/reports")" == 1
}

test_system_guard() {
	expect_failure 'GITHUB_ACTIONS=false bash "$UPDATER" update gui-apps/ripdrag 0.4.13'
	assert grep -q 'disposable Gentoo Actions container' "$fixture/failure.log"
}

test_unrelated_changes() {
	make_package
	expect_failure 'source "$UPDATER"; conf="$FIXTURE/packages.conf"; git() { printf "README.md\n"; }; cmd_publish gui-apps/ripdrag 0.4.13'
	assert grep -q 'refusing to publish unrelated changed file: README.md' "$fixture/failure.log"
}

if [[ "${1:-}" == --case ]]; then
	"$2"
	exit
fi

tests=(test_set_var test_command_substitution_failure test_ego_sum test_cargo_members
	test_nchat_version_location test_gostat_mvs test_ci_keywords test_update_detection
	test_check_api_failure test_build_arguments test_build_and_smoke_failures test_nchat_build_arguments test_pr_only
	test_failure_report test_early_failure_report test_system_guard test_unrelated_changes)
for test in "${tests[@]}"; do
	bash "$test_script" --case "$test"
	printf 'PASS %s\n' "$test"
done
printf '%s behavioral tests passed (package builds and GitHub writes were mocked).\n' "${#tests[@]}"
