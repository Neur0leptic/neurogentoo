#!/usr/bin/env bash
# Keeps the overlay packages listed in .github/update-packages.conf current.
#
#   check                           print a JSON matrix of packages with a newer upstream version
#   update  PACKAGE VERSION         write the new recipe: ebuild, dependency lists, Manifest
#   build   PACKAGE VERSION         build it in this Gentoo container and run its smoke test
#   publish PACKAGE VERSION         commit to a branch and open a pull request (merge if "auto")
#   report-failure PACKAGE VERSION  open or update an issue; the current recipe stays in place
#   report-run-failure              report failed matrix jobs, including container/tool setup
#
# The workflow passes COMMIT for snapshot packages and BASE_BRANCH for pull requests.
# All commands need git, curl and jq; update and build also need Portage, pkgdev,
# pkgcheck and pycargoebuild. check also runs elsewhere with GITHUB_REPOSITORY=owner/name;
# GITHUB_TOKEN is then optional.

set -Eeuo pipefail
shopt -s nullglob inherit_errexit

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)"
conf="$repo_root/.github/update-packages.conf"
api_url="${GITHUB_API_URL:-https://api.github.com}"

die() {
	printf 'update-package: %s\n' "$*" >&2
	exit 1
}

api() { # METHOD PATH [JSON]
	local -a args=(-fsSL -X "$1" -H "Accept: application/vnd.github+json")
	[[ -z "${GITHUB_TOKEN:-}" ]] || args+=(-H "Authorization: Bearer $GITHUB_TOKEN")
	(($# < 3)) || args+=(-H "Content-Type: application/json" --data "$3")
	curl "${args[@]}" "$api_url$2"
}

conf_packages() {
	awk '!/^#/ && NF { print $1 }' "$conf"
}

conf_field() { # PACKAGE FIELD: 2 type, 3 merge policy, 4 smoke test
	awk -v package="$1" -v field="$2" '
		!/^#/ && $1 == package {
			if (field < 4) {
				print $field
			} else {
				$1 = $2 = $3 = ""
				sub(/^ +/, "")
				print
			}
			found = 1
		}
		END { exit !found }' "$conf" || die "not listed in update-packages.conf: $1"
}

upstream_repo() { # PACKAGE -> owner/name from metadata.xml
	local repo
	repo="$(sed -n 's|.*<remote-id type="github">\([^<]*\)</remote-id>.*|\1|p' \
		"$repo_root/$1/metadata.xml" | head -n 1)"
	[[ "$repo" =~ ^[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+$ ]] || die "no GitHub remote-id in $1/metadata.xml"
	printf '%s' "$repo"
}

current_ebuild() { # PACKAGE -> path of its newest ebuild
	local -a ebuilds=("$repo_root/$1/${1#*/}"-*.ebuild)
	((${#ebuilds[@]})) || die "no ebuild for $1"
	printf '%s\n' "${ebuilds[@]}" | sort -V | tail -n 1
}

ebuild_version() { # EBUILD PACKAGE
	local name="${1##*/}"
	name="${name%.ebuild}"
	printf '%s' "${name#"${2#*/}"-}"
}

version_gt() { # A B: is A newer than B?
	[[ "$1" != "$2" && "$(printf '%s\n%s\n' "$1" "$2" | sort -V | tail -n 1)" == "$1" ]]
}

latest_release() { # owner/name -> newest stable release tag (vX.Y.Z or X.Y.Z) without "v"
	git ls-remote --tags --refs "https://github.com/$1.git" |
		sed -n 's|^[0-9a-f]*\trefs/tags/v\{0,1\}\([0-9][0-9.]*\)$|\1|p' |
		awk '/^[0-9]+(\.[0-9]+)*$/' | sort -V | tail -n 1
}

tag_commit() { # owner/name VERSION -> commit of the release tag
	git ls-remote "https://github.com/$1.git" \
		"refs/tags/v$2" "refs/tags/v$2^{}" "refs/tags/$2" "refs/tags/$2^{}" |
		awk '$2 ~ /\^\{\}$/ { peeled = $1 } { any = $1 } END { print (peeled != "" ? peeled : any) }'
}

snapshot_version() { # owner/name COMMIT -> 0_pYYYYMMDD of the commit
	local date
	date="$(api GET "/repos/$1/commits/$2" | jq -r '.commit.committer.date')"
	[[ "$date" =~ ^([0-9]{4})-([0-9]{2})-([0-9]{2})T ]] || die "cannot date commit $2 of $1"
	printf '0_p%s%s%s' "${BASH_REMATCH[1]}" "${BASH_REMATCH[2]}" "${BASH_REMATCH[3]}"
}

branch_name() { # PACKAGE VERSION
	printf 'update/%s-%s' "${1//\//-}" "$2"
}

pull_request_for() { # BRANCH -> number of a pull request from it, if any; a closed one was declined
	api GET "/repos/$GITHUB_REPOSITORY/pulls?state=all&head=${GITHUB_REPOSITORY%%/*}:$1" |
		jq -r '.[0].number // empty'
}

set_var() { # FILE NAME VALUE: replace exactly one NAME="..." line
	[[ "$(grep -c "^$2=\"" "$1" || true)" == 1 && "$3" =~ ^[A-Za-z0-9._+/-]+$ && "$3" != *..* ]] ||
		die "cannot set $2 in ${1##*/}"
	sed -i "s|^$2=\"[^\"]*\"\$|$2=\"$3\"|" "$1"
}

bump_ebuild() { # PACKAGE VERSION -> path of the new ebuild; older ebuilds are removed
	local package="$1" version="$2" old new path
	old="$(current_ebuild "$package")"
	new="$repo_root/$package/${package#*/}-$version.ebuild"
	git -C "$repo_root" mv -- "$old" "$new"
	for path in "$repo_root/$package/${package#*/}"-*.ebuild; do
		[[ "$path" == "$new" ]] || git -C "$repo_root" rm -q -- "$path"
	done
	# Sources pinned to a commit follow the commit of the release tag.
	if grep -q '^SOURCE_COMMIT=' "$new"; then
		set_var "$new" SOURCE_COMMIT "$(tag_commit "$(upstream_repo "$package")" "$version")"
	fi
	printf '%s' "$new"
}

# Literal ebuild variables are intentionally substituted without sourcing code.
# shellcheck disable=SC2016
fetch_source() { # EBUILD PACKAGE VERSION -> unpacked upstream source directory
	local uri commit work
	local -a dirs
	uri="$(sed -n 's/^SOURCE_URI="\(.*\)"$/\1/p' "$1")"
	commit="$(sed -n 's/^SOURCE_COMMIT="\([0-9a-f]*\)"$/\1/p' "$1")"
	uri="${uri%% -> *}"
	uri="${uri//'${PV}'/$3}"
	uri="${uri//'${PN}'/${2#*/}}"
	uri="${uri//'${P}'/${2#*/}-$3}"
	uri="${uri//'${SOURCE_COMMIT}'/$commit}"
	[[ "$uri" == https://* && "$uri" != *'$'* ]] || die "cannot resolve SOURCE_URI of ${1##*/}"
	work="$(mktemp -d)"
	curl -fsSL -- "$uri" | tar -xz -C "$work"
	dirs=("$work"/*/)
	((${#dirs[@]} == 1)) || die "unexpected source archive layout: $uri"
	printf '%s' "${dirs[0]%/}"
}

regenerate_ego_sum() { # EBUILD SOURCE_DIR: EGO_SUM from upstream's go.sum files
	local files file list
	local -a sums=()
	grep -qx 'EGO_SUM=(' "$1" || die "no EGO_SUM block in ${1##*/}"
	files="$(sed -n 's/^DEPS_FILES="\(.*\)"$/\1/p' "$1")"
	for file in ${files:-go.sum}; do sums+=("$2/$file"); done
	(($# < 3)) || sums+=("$3")
	list="$(mktemp)"
	# DEPS_FILES is a space-separated list; most packages have a single go.sum.
	for file in "${sums[@]}"; do
		[[ -f "$file" ]] || die "upstream source has no $file"
		# Entries become bash strings that Portage sources as root: plain module paths only.
		awk '
			NF != 3 || $3 !~ /^h1:[A-Za-z0-9+\/=]+$/ { exit 1 }
			$1 !~ /^[A-Za-z0-9._~+\/-]+$/ || $2 !~ /^v[A-Za-z0-9._+-]+(\/go\.mod)?$/ { exit 1 }
			{ printf "\t\"%s %s\"\n", $1, $2 }' "$file" || die "unexpected entry in upstream $file"
	done | LC_ALL=C sort -u >"$list"
	awk -v list="$list" '
		$0 == "EGO_SUM=(" { print; while ((getline line < list) > 0) print line; skip = 1; next }
		skip && $0 == ")" { skip = 0 }
		!skip { print }' "$1" >"$1.new"
	mv -- "$1.new" "$1"
	rm -f -- "$list"
}

regenerate_cargo() { # EBUILD SOURCE_DIR: use package members, not a workspace root
	local dirs dir
	local -a sources=()
	dirs="$(sed -n 's/^CARGO_UPDATE_DIRS="\(.*\)"$/\1/p' "$1")"
	for dir in ${dirs:-.}; do
		[[ "$dir" =~ ^[A-Za-z0-9_./-]+$ && "$dir" != *..* && "$dir" != /* ]] ||
			die "invalid Cargo member: $dir"
		[[ -f "$2/$dir/Cargo.toml" ]] || die "missing Cargo member: $dir"
		sources+=("$2/$dir")
	done
	pycargoebuild -C -F wget -M --no-config -i "$1" "${sources[@]}" >&2
}

regenerate_gostat() { # EBUILD SOURCE_DIR: combine pinned requirements with Go MVS
	local work version module selected path
	local -a modules=("$2/lib/wmchat/go" "$2/lib/sgchat/go") args=() sums=() downloads=()
	work="$(mktemp -d)"
	# These commands read module metadata, not upstream build scripts. Never let
	# a toolchain directive download or execute a different Go installation.
	export GOTOOLCHAIN=local GOWORK=off GOFLAGS='' GOENV=off
	for path in "${modules[@]}"; do
		(cd "$path" && go mod edit -json) >>"$work/modules.json"
	done
	# The assembly patch supports these two vendored replacements only.
	jq -es 'all(.[]; all(.Replace[]?;
		(.Old.Path == "go.mau.fi/whatsmeow" and .New.Path == "./ext/whatsmeow") or
		(.Old.Path == "go.mau.fi/mautrix-signal" and .New.Path == "./ext/signal")))' \
		"$work/modules.json" >/dev/null || die "nchat's module replacements changed"
	version="$(jq -sr '.[].Go' "$work/modules.json" | sort -V | tail -n 1)"
	[[ "$version" =~ ^[0-9]+\.[0-9]+(\.[0-9]+)?$ ]] || die "invalid nchat Go version"
	(cd "$work" && go work init "${modules[@]}")
	(cd "$work" && GOWORK="$work/go.work" go list -m -json all) >"$work/graph.json"
	selected="$(jq -rs --slurpfile modules "$work/modules.json" '
		map(select(.Version != null)) | INDEX(.Path) as $graph |
		[$modules[].Require[].Path] | unique[] |
		if $graph[.] == null then error("missing module in Go graph: " + .)
		else [$graph[.].Path, $graph[.].Version] | @tsv end' "$work/graph.json")"
	while IFS=$'\t' read -r module version; do
		[[ "$module" =~ ^[A-Za-z0-9._~+/-]+$ && "$version" =~ ^v[A-Za-z0-9._+-]+$ ]] ||
			die "unexpected selected Go requirement: $module $version"
		args+=("-require=$module@$version")
	done <<<"$selected"
	# Only the original two modules' requirements are seeded. Go itself resolves
	# their shared versions; no latest queries or hand-written semver comparison.
	version="$(jq -sr '.[].Go' "$work/modules.json" | sort -V | tail -n 1)"
	: >"$work/go.mod"
	(cd "$work" && go mod edit -module=github.com/d99kris/nchat/lib/gostat \
		-go="$version" "${args[@]}" \
		"-replace=go.mau.fi/whatsmeow=${modules[0]}/ext/whatsmeow" \
		"-replace=go.mau.fi/mautrix-signal=${modules[1]}/ext/signal")
	sums=("${modules[0]}/go.sum" "${modules[1]}/go.sum")
	for path in "${modules[0]}/ext/whatsmeow/go.sum" "${modules[1]}/ext/signal/go.sum" "$work/go.work.sum"; do
		[[ ! -f "$path" ]] || sums+=("$path")
	done
	cat "${sums[@]}" | sort -u >"$work/go.sum"
	# Metadata resolution alone only records .mod hashes. Download every selected
	# module archive now so new transitive versions also become offline distfiles.
	# Go verifies the upstream checksums; this does not compile or run source code.
	(cd "$work" && go mod download all)
	# Go's pruned graph can leave unused test dependencies with only .mod hashes.
	# Explicit downloads cover every version selected by the protocol workspace.
	selected="$(jq -sr '.[] | select(.Version != null and .Replace == null) |
		.Path + "@" + .Version' "$work/graph.json")"
	while IFS= read -r module; do
		[[ "$module" =~ ^[A-Za-z0-9._~+/-]+@v[A-Za-z0-9._+-]+$ ]] ||
			die "unexpected Go download: $module"
		downloads+=("$module")
	done <<<"$selected"
	(cd "$work" && go mod download -json "${downloads[@]}") >"$work/downloads.json"
	jq -sr '.[] |
		if .Sum == null or .GoModSum == null then error("missing module checksums")
		else [.Path, .Version, .Sum], [.Path, (.Version + "/go.mod"), .GoModSum] end |
		join(" ")' "$work/downloads.json" >"$work/extra.sum"
	{
		printf '// Generated from the pinned nchat protocol module requirements.\n'
		sed -e "s|${modules[0]}|@WM_DIR@|g" -e "s|${modules[1]}|@SG_DIR@|g" "$work/go.mod"
	} >"$repo_root/net-im/nchat/files/gostat-go.mod"
	cat "$work/go.sum" "$work/extra.sum" | LC_ALL=C sort -u >"$2/lib/gostat/go.sum"
	rm -rf -- "$work"
}

lock_git_commit() { # CARGO_LOCK CRATE -> commit of the crate's git source
	awk -v crate="$2" '
		$0 == "[[package]]" { name = ""; next }
		/^name = / { name = $3; gsub(/"/, "", name) }
		/^source = "git\+/ && name == crate { sub(/.*#/, ""); sub(/".*/, ""); print; exit }' "$1"
}

configure_overlay() { # PACKAGE: register this checkout like the installer does
	local -a packages=("$1")
	[[ "$(conf_field "$1" 2)" != nchat ]] || packages+=(net-libs/libsignal-ffi)
	install -d /etc/portage/repos.conf /etc/portage/package.mask \
		/etc/portage/package.unmask /etc/portage/package.accept_keywords
	printf '[neurogentoo]\nlocation = %s\n' "$repo_root" >/etc/portage/repos.conf/neurogentoo.conf
	# Only the packages under test may come from this overlay.
	printf '*/*::neurogentoo\n' >/etc/portage/package.mask/neurogentoo
	printf '%s::neurogentoo\n' "${packages[@]}" >/etc/portage/package.unmask/neurogentoo
	printf '%s::neurogentoo ~amd64\n' "${packages[@]}" >/etc/portage/package.accept_keywords/neurogentoo
}

check_package() { # PACKAGE
	(cd "$repo_root" && pkgcheck scan --exit=error "$1")
}

refresh_manifest() { # PACKAGE
	(cd "$repo_root/$1" && pkgdev manifest)
}

update_libsignal() { # VERSION: the libsignal-ffi release that nchat requires
	local ebuild source boring
	ebuild="$(bump_ebuild net-libs/libsignal-ffi "$1")"
	source="$(fetch_source "$ebuild" net-libs/libsignal-ffi "$1")"
	regenerate_cargo "$ebuild" "$source"
	boring="$(lock_git_commit "$source/Cargo.lock" boring)"
	set_var "$ebuild" BORING_COMMIT "$boring"
	set_var "$ebuild" SPQR_COMMIT "$(lock_git_commit "$source/Cargo.lock" spqr)"
	# boring-sys builds the BoringSSL revision recorded as its git submodule.
	set_var "$ebuild" BORINGSSL_COMMIT "$(api GET \
		"/repos/signalapp/boring/contents/boring-sys/deps/boringssl?ref=$boring" | jq -r '.sha')"
	refresh_manifest net-libs/libsignal-ffi
	check_package net-libs/libsignal-ffi
}

update_nchat_libsignal() { # NCHAT_EBUILD SOURCE_DIR
	local version ref file
	local -a files=()
	# version.go has moved between nchat releases; find it below libsignalgo.
	while IFS= read -r file; do
		if grep -q '^const Version = "v' "$file"; then files+=("$file"); fi
	done < <(find "$2/lib/sgchat/go/ext/signal/pkg/libsignalgo" -name version.go -type f)
	((${#files[@]} == 1)) || die "expected one libsignal version.go, found ${#files[@]}"
	version="$(sed -n 's/^const Version = "v\([0-9][0-9.]*\)"$/\1/p' "${files[0]}")"
	ref="$(sed -n 's/^set(LIBSIGNAL_BUILD_REF "\([0-9a-f]*\)")$/\1/p' "$2/lib/sgchat/go/libsignal.cmake")"
	[[ "$version" =~ ^[0-9]+(\.[0-9]+)+$ && "$ref" =~ ^[0-9a-f]{40}$ ]] ||
		die "cannot read the libsignal version nchat requires"
	set_var "$1" LIBSIGNAL_VERSION "$version"
	set_var "$1" LIBSIGNAL_BUILD_REF "$ref"
	set_var "$1" LIBSIGNAL_VERSION_FILE "${files[0]#"$2/"}"
	[[ "$version" == "$(ebuild_version "$(current_ebuild net-libs/libsignal-ffi)" net-libs/libsignal-ffi)" ]] ||
		update_libsignal "$version"
}

cmd_check() {
	local package type repo ebuild current latest commit number
	local -a entries=()
	[[ -z "${ONLY_PACKAGE:-}" ]] || conf_field "$ONLY_PACKAGE" 2 >/dev/null
	while read -r package; do
		[[ -z "${ONLY_PACKAGE:-}" || "$package" == "$ONLY_PACKAGE" ]] || continue
		type="$(conf_field "$package" 2)"
		repo="$(upstream_repo "$package")"
		ebuild="$(current_ebuild "$package")"
		current="$(ebuild_version "$ebuild" "$package")"
		commit=""
		if [[ "$type" == snapshot ]]; then
			commit="$(git ls-remote "https://github.com/$repo.git" HEAD | cut -f1)"
			if grep -qx "MY_COMMIT=\"$commit\"" "$ebuild"; then
				latest="$current"
			else
				latest="$(snapshot_version "$repo" "$commit")"
			fi
		else
			latest="$(latest_release "$repo")"
		fi
		if [[ -z "$latest" ]] || ! version_gt "$latest" "$current"; then
			printf '%s: %s is current\n' "$package" "$current" >&2
			continue
		fi
		number="$(pull_request_for "$(branch_name "$package" "$latest")")"
		if [[ -n "$number" ]]; then
			printf '%s: %s already has a pull request\n' "$package" "$latest" >&2
			continue
		fi
		printf '%s: %s -> %s\n' "$package" "$current" "$latest" >&2
		entries+=("$(jq -cn --arg package "$package" --arg version "$latest" --arg commit "$commit" '$ARGS.named')")
	done < <(conf_packages)
	printf 'matrix=%s\n' "$(printf '%s\n' "${entries[@]}" | jq -cs '.')"
}

cmd_update() { # PACKAGE VERSION
	local type ebuild source
	require_ci "$1"
	type="$(conf_field "$1" 2)"
	configure_overlay "$1"
	ebuild="$(bump_ebuild "$1" "$2")"
	case "$type" in
		bin) ;;
		snapshot)
			set_var "$ebuild" MY_COMMIT "${COMMIT:?COMMIT is required for snapshot packages}"
			;;
		cargo)
			source="$(fetch_source "$ebuild" "$1" "$2")"
			regenerate_cargo "$ebuild" "$source"
			;;
		go | nchat)
			source="$(fetch_source "$ebuild" "$1" "$2")"
			if [[ "$type" == nchat ]]; then
				patch --dry-run --fuzz=0 -p1 -d "$source" \
					<"$repo_root/net-im/nchat/files/nchat-gostat-pins.patch" >&2
				regenerate_gostat "$ebuild" "$source"
				regenerate_ego_sum "$ebuild" "$source" "$source/lib/gostat/go.sum"
				update_nchat_libsignal "$ebuild" "$source"
			else
				regenerate_ego_sum "$ebuild" "$source"
			fi
			;;
		*) die "unknown package type: $type" ;;
	esac
	refresh_manifest "$1"
	check_package "$1"
}

cmd_build() { # PACKAGE VERSION
	require_ci "$1"
	configure_overlay "$1"
	local -a packages=("=$1-$2::neurogentoo")
	local excluded="$1::neurogentoo"
	if [[ "$(conf_field "$1" 2)" == nchat ]]; then
		packages+=("=net-libs/libsignal-ffi-$(ebuild_version \
			"$(current_ebuild net-libs/libsignal-ffi)" net-libs/libsignal-ffi)::neurogentoo")
		excluded+=" net-libs/libsignal-ffi::neurogentoo"
	fi
	# Gentoo's stock profile lacks some USE flags that dependencies of the overlay's
	# packages need (such as gtk[wayland]); installed systems get them from the
	# installer's policy. Portage may enable USE flags here, but never keywords,
	# masks or licenses. Binary packages are still used only when their USE flags
	# match: that is emerge's default, and passing --binpkg-respect-use explicitly
	# would disable --autounmask-use.
	FEATURES="userpriv usersandbox sandbox network-sandbox" \
		emerge --oneshot --getbinpkg --autounmask=y --autounmask-use=y \
		--autounmask-license=n --autounmask-keep-keywords=y --autounmask-keep-masks=y \
		--autounmask-continue=y --usepkg-exclude="$excluded" "${packages[@]}"
	# Upstream code runs unprivileged, as in Portage's build (FEATURES=userpriv).
	runuser -u portage -- env TERM=dumb bash -c "$(conf_field "$1" 4)"
}

require_ci() { # PACKAGE: refuse accidental use on an installed system
	[[ -f /etc/gentoo-release && -f /run/neurogentoo-ci-ready &&
		"$(cat /run/neurogentoo-ci-ready)" == "$1" && "${GITHUB_ACTIONS:-}" == true ]] ||
		die "first run prepare-ci.sh in a disposable Gentoo Actions container"
}

cmd_publish() { # PACKAGE VERSION
	local branch title source body number file path allowed changes
	local -a paths=("$1")
	[[ "$(conf_field "$1" 2)" != nchat ]] || paths+=(net-libs/libsignal-ffi)
	changes="$(git -C "$repo_root" diff --name-only; git -C "$repo_root" diff --cached --name-only;
		git -C "$repo_root" ls-files --others --exclude-standard)"
	while IFS= read -r file; do
		[[ -n "$file" ]] || continue
		allowed=false
		for path in "${paths[@]}"; do
			[[ "$file" != "$path/"* ]] || allowed=true
		done
		[[ "$allowed" == true ]] || die "refusing to publish unrelated changed file: $file"
	done <<<"$changes"
	branch="$(branch_name "$1" "$2")"
	title="$1: update to $2"
	if [[ "$(conf_field "$1" 2)" == snapshot ]]; then
		source="https://github.com/$(upstream_repo "$1")/commit/${COMMIT:?COMMIT is required}"
	else
		source="https://github.com/$(upstream_repo "$1")/releases/tag/v$2"
	fi
	body="Upstream: $source
Checked: pkgcheck, a Portage build and the smoke test \`$(conf_field "$1" 4)\`.
Workflow run: $GITHUB_SERVER_URL/$GITHUB_REPOSITORY/actions/runs/$GITHUB_RUN_ID"
	git -C "$repo_root" switch -q -c "$branch"
	git -C "$repo_root" add -A -- "${paths[@]}"
	git -C "$repo_root" -c user.name="github-actions[bot]" \
		-c user.email="41898282+github-actions[bot]@users.noreply.github.com" commit -q -m "$title"
	# The checkout stores no credentials, so earlier steps never saw the token. The branch
	# belongs to the bot; forcing replaces what an earlier failed run left behind.
	GIT_CONFIG_COUNT=1 GIT_CONFIG_KEY_0="http.https://github.com/.extraheader" \
		GIT_CONFIG_VALUE_0="Authorization: Basic $(printf 'x-access-token:%s' \
		"${GITHUB_TOKEN:?GITHUB_TOKEN is required}" | base64 -w0)" \
		git -C "$repo_root" push -q --force origin "$branch"
	number="$(api POST "/repos/$GITHUB_REPOSITORY/pulls" "$(jq -n --arg title "$title" \
		--arg head "$branch" --arg base "${BASE_BRANCH:-main}" --arg body "$body" '$ARGS.named')" |
		jq -r '.number')"
	printf 'Opened pull request #%s\n' "$number"
	if [[ "$(conf_field "$1" 3)" == auto ]]; then
		api PUT "/repos/$GITHUB_REPOSITORY/pulls/$number/merge" '{"merge_method":"squash"}' >/dev/null
		printf 'Merged pull request #%s\n' "$number"
	fi
}

cmd_report_failure() { # PACKAGE VERSION
	local title body number
	title="Automatic update failed: $1 $2"
	body="The update workflow could not prepare, build or test $1 $2, so the current recipe stays in place.
Log: $GITHUB_SERVER_URL/$GITHUB_REPOSITORY/actions/runs/$GITHUB_RUN_ID"
	if [[ -n "${UPDATE_LOG:-}" && -f "$UPDATE_LOG" && -r "$UPDATE_LOG" ]]; then
		# This log contains only the disposable runner's update/build output. Keep
		# the issue small; the full transcript remains in the linked workflow run.
		body+=$'\n\nRecent output:\n```\n'
		body+="$(tail -c 10000 -- "$UPDATE_LOG")"
		body+=$'\n```'
	fi
	number="$(api GET "/repos/$GITHUB_REPOSITORY/issues?state=open&per_page=100" |
		jq -r --arg title "$title" 'map(select(.title == $title and (.pull_request | not))) | .[0].number // empty')"
	if [[ -n "$number" ]]; then
		api POST "/repos/$GITHUB_REPOSITORY/issues/$number/comments" \
			"$(jq -n --arg body "$body" '$ARGS.named')" >/dev/null
	else
		api POST "/repos/$GITHUB_REPOSITORY/issues" \
			"$(jq -n --arg title "$title" --arg body "$body" '$ARGS.named')" >/dev/null
	fi
}

cmd_report_run_failure() {
	local jobs entries entry package version id work
	jobs="$(api GET "/repos/$GITHUB_REPOSITORY/actions/runs/$GITHUB_RUN_ID/jobs?per_page=100")"
	entries="$(jq -c '.[]' <<<"${UPDATE_MATRIX:?UPDATE_MATRIX is required}")"
	work="$(mktemp -d)"
	while IFS= read -r entry; do
		[[ -n "$entry" ]] || continue
		package="$(jq -r '.package' <<<"$entry")"
		version="$(jq -r '.version' <<<"$entry")"
		conf_field "$package" 2 >/dev/null
		id="$(jq -r --arg name "Update $package $version" '
			[.jobs[] | select(.name == $name and
				(.conclusion == "failure" or .conclusion == "timed_out" or
				 .conclusion == "cancelled"))] |
			.[0].id // empty' <<<"$jobs")"
		[[ -n "$id" ]] || continue
		[[ "$id" =~ ^[0-9]+$ ]] || die "invalid failed Actions job ID"
		# A separate trusted runner can report even when the Gentoo container never
		# reached checkout. GitHub's downloaded job logs already mask workflow secrets.
		if ! api GET "/repos/$GITHUB_REPOSITORY/actions/jobs/$id/logs" >"$work/job.log"; then
			printf 'Job log download failed; use the linked Actions run.\n' >"$work/job.log"
		fi
		UPDATE_LOG="$work/job.log" cmd_report_failure "$package" "$version"
	done <<<"$entries"
	rm -rf -- "$work"
}

main() {
	local command="${1:-}"
	case "$command" in
		check | report-run-failure)
			"cmd_${command//-/_}"
			;;
		update | build | publish | report-failure)
			(($# == 3)) || die "usage: ${0##*/} $command PACKAGE VERSION"
			[[ "$2" =~ ^[a-z0-9+_-]+/[A-Za-z0-9+_-]+$ && "$3" =~ ^[0-9][A-Za-z0-9._+-]*$ ]] ||
				die "invalid package or version: $2 $3"
			"cmd_${command//-/_}" "$2" "$3"
			;;
		*)
			die "usage: ${0##*/} {check|report-run-failure} | {update|build|publish|report-failure} PACKAGE VERSION"
			;;
	esac
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then main "$@"; fi
