## Dotfiles
These are my dotfiles: a plain Sway session with [Dank Material Shell](https://github.com/AvengeMedia/DankMaterialShell)
(DMS) as bar, launcher, notifications and lock screen, plus KDE apps and zsh. Set up on Arch Linux;
the configs also handle a few Debian/Ubuntu paths. The Sway config is also ready for
[SwayFX](https://github.com/WillPower3309/swayfx), with its effects commented out (see
[SwayFX](#swayfx-optional) below).

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

**SwayFX** (optional)

- `swayfx` (AUR), installed instead of `sway`. See [SwayFX](#swayfx-optional).

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

5. Make DMS start with the Sway session. The Sway config runs
   `scripts/.local/share/scripts/sway-session-start.sh`, which passes the session
   environment to systemd, starts `sway-session.target` and restarts DMS (so a quick
   logout/login doesn't leave DMS crashed or failed). DMS only needs to be attached to
   the target:

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

### Keyboard shortcuts

`$mod` is the Super (Windows) key. `$mod+F1` shows these bindings on screen in DMS.

**Basics and shell**

| Keys                  | Action                                              |
|-----------------------|-----------------------------------------------------|
| `$mod+Return`         | Open a terminal (kitty)                             |
| `$mod+d`              | Launcher (DMS Spotlight)                            |
| `$mod+o`              | Launch mode (see below)                             |
| `$mod+Shift+q`        | Close the focused window                            |
| `$mod+Shift+c`        | Reload the Sway config                              |
| `$mod+Shift+e`        | Power menu (log out, suspend, reboot, shut down)    |
| `$mod+l`              | Lock the screen                                     |
| `$mod+Shift+s`        | Suspend                                             |
| `$mod+c`              | Control center                                      |
| `$mod+Shift+n`        | Notifications                                       |
| `$mod+Shift+v`        | Clipboard history                                   |
| `$mod+comma`          | DMS settings                                        |
| `$mod+F1`             | Show key bindings                                   |
| `Print`               | Region screenshot to the clipboard                  |
| `$mod+Shift+a`        | Switch audio output between speakers and headphones |
| `Alt+Tab`             | Switch to the urgent or last used window (swayr)    |

**Windows and layout**

| Keys                           | Action                                        |
|--------------------------------|-----------------------------------------------|
| `$mod+Arrow`                   | Move focus                                    |
| `$mod+Shift+Arrow` / `h/j/k/l` | Move the focused window                       |
| `$mod+b` / `$mod+v`            | Split horizontally / vertically               |
| `$mod+s` / `$mod+w` / `$mod+e` | Stacking / tabbed / toggle split layout       |
| `$mod+f`                       | Fullscreen                                    |
| `$mod+Shift+space`             | Toggle floating                               |
| `$mod+space`                   | Switch focus between tiling and floating      |
| `$mod+a`                       | Focus the parent container                    |
| `$mod+Shift+minus`             | Move the window to the scratchpad             |
| `$mod+minus`                   | Show or hide scratchpad windows               |
| `$mod+r`                       | Resize mode: arrows or `h/j/k/l`, hold Shift for big steps, `Return`/`Escape` to leave |
| `$mod+drag`                    | Move a window (left button) or resize it (right button) |

**Workspaces and outputs**

| Keys                           | Action                                        |
|--------------------------------|-----------------------------------------------|
| `$mod+1`…`$mod+0`              | Go to workspace 1–10                          |
| `$mod+Shift+1`…`$mod+Shift+0`  | Move the window to workspace 1–10             |
| `$mod+m`                       | Go to the lowest unused workspace             |
| `$mod+n`                       | Next workspace                                |
| `$mod+Ctrl+Shift+Arrow`        | Move the workspace to the next output         |

**Launch mode** (`$mod+o`, then a key; `Return`/`Escape` to cancel)

| Key | App             | Key | App             |
|-----|-----------------|-----|-----------------|
| `f` | Firefox         | `g` | Steam           |
| `c` | VS Code         | `e` | Dolphin         |
| `d` | Discord         | `t` | Terminal        |
| `s` | Signal          | `m` | Cinny (Matrix)  |
| `p` | 1Password       | `,` | System Settings |

Media keys (volume, mic mute, play/pause, next/previous, brightness) go through DMS
and also work on the lock screen.

### SwayFX (optional)

[SwayFX](https://github.com/WillPower3309/swayfx) is a fork of Sway that adds blur,
rounded corners, shadows and similar effects. It reads the same config, so everything
else in this repo works unchanged. It doesn't support HDR, so plain Sway is the default
here and the SwayFX settings are commented out. Plain Sway doesn't know these commands
and shows config errors if they're enabled.

To switch:

1. Install `swayfx` (AUR). It conflicts with `sway` and replaces it.

2. In `sway/.config/sway/config`, uncomment the block under `# SwayFX eye candy`:

   | Option                                | Effect                                    |
   |---------------------------------------|-------------------------------------------|
   | `blur enable`                         | Blur behind transparent windows           |
   | `blur_passes 3`, `blur_radius 4`      | Blur strength                             |
   | `blur_noise 0.15`                     | Noise added to the blur                   |
   | `blur_brightness 0.8`, `blur_saturation 0.8` | Darken and desaturate the blur     |
   | `corner_radius 5`                     | Rounded window corners                    |
   | `shadows enable`                      | Drop shadows under windows                |
   | `animation_duration_ms 100`           | Length of window animations               |

3. Optional extras that go with it:
   - Make the terminal transparent so the blur shows through, by adding this to
     `kitty/.config/kitty/kitty.conf`:

     ```
     background_opacity 0.95
     ```

   - Wider gaps fit better with rounded corners and shadows: change `gaps inner 4`
     to `gaps inner 8` in the Sway config.

4. Reload Sway (`$mod+Shift+c`) or log out and back in.

To go back to plain Sway, comment the block out again **before** reinstalling `sway`.

### Updating

Pull and re-run stow with `--restow` to pick up new or deleted files:

```sh
cd ~/dotfiles && git pull
stow -R sway session scripts dux-plugins swayr kitty zsh mime
```
