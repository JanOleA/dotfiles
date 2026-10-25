## Dotfiles
These are my dotfiles: a plain Sway session with [Dank Material Shell](https://github.com/AvengeMedia/DankMaterialShell)
(DMS) as bar, launcher, notifications and lock screen, plus KDE apps and zsh. Set up on Arch Linux;
the configs also handle a few Debian/Ubuntu paths.

Each top-level directory is a [GNU Stow](https://www.gnu.org/software/stow/) package that mirrors `~`:

| Package       | Contents                                                        |
|---------------|-----------------------------------------------------------------|
| `sway`        | Sway config                                                     |
| `session`     | `sway-session.target` for systemd and session environment vars  |
| `scripts`     | Helper scripts in `~/.local/share/scripts`                      |
| `dux-plugins` | DMS "Sway Mode" bar widget                                      |
| `swayr`       | swayr window switcher config (uses wofi)                        |
| `kitty`       | Kitty terminal config, Catppuccin Mocha theme                   |
| `zsh`         | `.zshrc`, `.profile`, Powerlevel10k config                      |
| `mime`        | Default applications                                            |

### Required packages

Arch package names. Packages marked (AUR) come from the AUR.

**Core**

- `stow`, `git`
- `sway` (includes `swaymsg`)
- `dms-shell`
- `swayr` (AUR), `wofi`
- `autotiling`
- `kitty`
- `jq`

**Session / KDE integration**

- `polkit-kde-agent`
- `kwallet-pam`
- `plasma-workspace` (application menu, used with `XDG_MENU_PREFIX=plasma-`)
- `plasma-integration` (Qt theme, used with `QT_QPA_PLATFORMTHEME=kde`)
- `kdeconnect` (optional)

**Scripts**

- `grim`, `slurp`, `wl-clipboard` for screenshots
- `ffmpeg` for HDR screenshot conversion (needs the zscale filter, which Arch's build has)
- `libpulse` (`pactl`) for the audio port toggle
- `swayidle` for running `after-resume.sh` after suspend (optional, depends on the machine)

**Shell**

- `zsh`, `bat`
- [Oh My Zsh](https://ohmyz.sh/) and [Powerlevel10k](https://github.com/romkatv/powerlevel10k)
  (both installed with git, see below)
- MesloLGS NF font ([download](https://github.com/romkatv/powerlevel10k#meslo-nerd-font-patched-for-powerlevel10k))

**Apps used by key bindings and default applications** (optional)

- `firefox`, `dolphin`, `kate`, `gwenview`, `systemsettings`
- `visual-studio-code-bin` (AUR), `discord`, `signal-desktop`, `1password` (AUR), `steam`
- Cinny via Flatpak: `flatpak install flathub in.cinny.Cinny`

Install everything in one go (needs an AUR helper such as `paru`):

```sh
paru -S --needed stow git sway dms-shell swayr wofi autotiling kitty jq \
    polkit-kde-agent kwallet-pam plasma-workspace plasma-integration kdeconnect \
    grim slurp wl-clipboard ffmpeg libpulse zsh bat
```

### Deploying

1. Clone the repo into your home directory. `.stowrc` sets the target to `~`, so run
   stow from inside the repo:

   ```sh
   git clone git@github.com:JanOleA/dotfiles.git ~/dotfiles
   cd ~/dotfiles
   ```

2. Install Oh My Zsh and Powerlevel10k **before** stowing. The Oh My Zsh installer
   replaces `~/.zshrc`, and `--keep-zshrc` stops it from doing that:

   ```sh
   sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended --keep-zshrc
   git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
       "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
   chsh -s /usr/bin/zsh
   ```

3. Remove or back up any existing files that would conflict (for example a default
   `~/.zshrc`, `~/.profile` or `~/.config/sway/config`). Do a dry run to see conflicts:

   ```sh
   stow -n -v sway session scripts dux-plugins swayr kitty zsh mime
   ```

4. Stow the packages:

   ```sh
   stow sway session scripts dux-plugins swayr kitty zsh mime
   ```

   `.stowrc` uses `--no-folding`, so stow links individual files and never turns a
   whole directory such as `~/.config` into a symlink.

5. Make DMS start with the Sway session. The Sway config starts `sway-session.target`,
   so DMS only needs to be attached to it:

   ```sh
   systemctl --user daemon-reload
   systemctl --user add-wants sway-session.target dms
   ```

6. Add machine-specific Sway settings (outputs, workspace assignments) in
   `~/.config/sway/config.d/`. That directory is included by the Sway config but not
   stored in this repo. Get output names with `swaymsg -t get_outputs`.

7. Log out and choose **Sway** in your display manager, or run `sway` from a TTY.
   In DMS, enable the **Sway Mode** widget under Settings → Plugins.

### Machine-specific settings to check

- `zsh/.profile` exports `HDR_OUTPUTS`, `SDR_NITS` and `HDR_TONEMAP` for an HDR
  monitor. On a machine without HDR, remove `HDR_OUTPUTS`, otherwise screenshots are
  converted from HDR and come out wrong.
- `mime/.config/mimeapps.list` points to `userapp-Firefox-1EQTU3.desktop`, a file
  that Firefox creates when it is set as the default browser. On a new machine, set
  the default browser again (`xdg-settings set default-web-browser firefox.desktop`)
  or edit the file.
- `scripts/.local/share/scripts/after-resume.sh` fixes monitors that come back wrong
  after suspend. It depends on the machine, so it's started from `config.d` and not
  from the main Sway config. To use it, add this with your own output names (needs
  `swayidle`):

  ```
  exec swayidle -w after-resume '$HOME/.local/share/scripts/after-resume.sh DP-3'
  ```

### Updating

Pull and re-run stow with `--restow` to pick up new or deleted files:

```sh
cd ~/dotfiles && git pull
stow -R sway session scripts dux-plugins swayr kitty zsh mime
```
