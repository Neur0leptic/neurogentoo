# neurogentoo

A Gentoo overlay and installer-policy repository forked from
[emrakyz/emrakyz](https://github.com/emrakyz/emrakyz).

It contains package recipes, Wayland desktop configuration and native policy inputs for
[install-system](https://github.com/Neur0leptic/install-system).

## Contents

- Package categories at the repository root contain inherited and additional ebuilds.
- `config/portage/` contains package sets, USE settings, package environments
  and compiler-policy layers.
- `config/hardware/` contains firmware, microcode and graphics-policy templates.
- `config/system/` contains OpenRC, networking and system-configuration inputs.

## Usage and scope

`neurogentoo` is a normal Portage repository using Gentoo as its master.
Package installation and dependency resolution remain Portage's responsibility.
Installer policy provides minimal, DWL and full tiers, with optional torrent tools.

The `config/` layers are consumed by the installer. Adding the overlay alone
does not activate its compiler settings or deploy system configuration.
These templates are opinionated, not universal Gentoo defaults.

The DWL recipe uses the shared desktop patch and IPC protocol from
[dotfiles](https://github.com/Neur0leptic/dotfiles). Chezmoi manages the runtime
desktop settings separately.

## Package updates

The **Update packages** GitHub Actions workflow checks the packages listed in
`.github/update-packages.conf` weekly. It can also be run manually for one package.
Successful updates open a pull request after recipe checks, compilation and a
basic command-line test. Pull requests are merged manually; failed updates leave
the current recipes unchanged and open an issue with the workflow log.

The workflow compiles with Gentoo's standard profile and binary packages. The
installer's compiler settings apply when an installed system updates.

Enable **Allow GitHub Actions to create and approve pull requests** under
**Settings → Actions → General** before the first run.

## Credits

The original overlay comes from
[emrakyz/emrakyz](https://github.com/emrakyz/emrakyz).
Existing copyright notices and package-specific license declarations are retained.

## Related repositories

- [Installer](https://github.com/Neur0leptic/install-system)
- [Arch package policy](https://github.com/Neur0leptic/neuroarch)
- [Dotfiles](https://github.com/Neur0leptic/dotfiles)
