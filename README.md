# neurogentoo

A Gentoo overlay and installer-policy repository forked from
[emrakyz/emrakyz](https://github.com/emrakyz/emrakyz).

This fork retains inherited ebuilds while adding desktop and CLI packages,
Wayland-focused configuration and native policy inputs for
[install-system](https://github.com/Neur0leptic/install-system).

## Contents

- Package categories at the repository root contain inherited and additional ebuilds.
- `config/portage/` contains package sets, USE settings, package environments
  and compiler-policy layers.
- `config/hardware/` contains firmware, microcode and graphics-policy templates.
- `config/system/` contains OpenRC, networking and system-configuration inputs.

## Additions and changes

- Repository identity changed from `emrakyz` to `neurogentoo`.
- Added minimal, DWL and full package sets, with optional torrent tools.
- Added staged GCC/Clang, Polly and Rust compiler-policy inputs.
- Added hardware-dependent configuration templates.
- Added a live DWL ebuild using the canonical patch and IPC protocol from
  `dotfiles/main`, applied to an ABI-compatible Codeberg DWL source.
- Added recipes for applications including nchat, libsignal-ffi, cliamp,
  impala, wiki-tui, croc, clipse and ripdrag.
- Added binary packages for OpenCode, shfmt, LocalSend and Helium.
- Added a newer Yazi ebuild.
- Added declared Go and Cargo dependency inputs for the new build recipes.

## Usage and scope

`neurogentoo` is a normal Portage repository using Gentoo as its master.
Package installation and dependency resolution remain Portage's responsibility.

The `config/` layers are consumed by the installer. Adding the overlay alone
does not activate its compiler settings or deploy system configuration.
These templates are opinionated, not universal Gentoo defaults.

## Credits

The original overlay comes from
[emrakyz/emrakyz](https://github.com/emrakyz/emrakyz).
Existing copyright notices and package-specific license declarations are retained.

## Related repositories

- [Installer](https://github.com/Neur0leptic/install-system)
- [Arch package policy](https://github.com/Neur0leptic/neuroarch)
- [Dotfiles](https://github.com/Neur0leptic/dotfiles)
