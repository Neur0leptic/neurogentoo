# neurogentoo

A Gentoo overlay, and the Portage settings that
[install-system](https://github.com/Neur0leptic/install-system) applies to its Gentoo
installations. Forked from [emrakyz/emrakyz](https://github.com/emrakyz/emrakyz).

## Installation

The installer adds the overlay itself. To use its packages on another Gentoo system:

```sh
eselect repository add neurogentoo git https://github.com/Neur0leptic/neurogentoo.git
emaint sync -r neurogentoo
```

Then install packages with `emerge` as usual. Adding the overlay changes no settings.

## Contents

- Package categories at the top level: the ebuilds.
- `config/portage/`: package lists, USE flags, package environments and compiler
  settings for the installer's tiers.
- `config/hardware/`: firmware, microcode and graphics settings for each kind of
  hardware.
- `config/system/`: OpenRC, network and other system configuration.

These are the author's choices, not general Gentoo defaults; only the installer
applies them.

## DWL

`gui-wm/dwl` builds DWL with the desktop patch from the
[dotfiles](https://github.com/Neur0leptic/dotfiles) and takes its `config.h` from
savedconfig. On an installed system, edit `~/.local/src/dwl/config.h` and run
`update_dwl.sh`.

## Package updates

A GitHub Actions workflow checks the packages in `.github/update-packages.conf` every
week. An update that builds and passes a basic test becomes a pull request; a failed
one opens an issue.

## Credits

The original overlay comes from
[emrakyz/emrakyz](https://github.com/emrakyz/emrakyz). Existing copyright notices and
package-specific license declarations are retained.

## Related repositories

- [Installer](https://github.com/Neur0leptic/install-system)
- [Arch package policy](https://github.com/Neur0leptic/neuroarch)
- [Dotfiles](https://github.com/Neur0leptic/dotfiles)
