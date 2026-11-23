# Android Studio setup, for a Claude session on a new machine

The Android Studio side of the nvim setup is one file: `new_android_studio/ideavimrc`, installed as `~/.ideavimrc`. It needs the
IdeaVim plugin. The user reads `new_android_studio/KEY_GUIDE.md` for the keys.

## Install

0. Install these Marketplace plugins first, then restart the IDE (the rc rejects `set which-key` / `set easymotion` without them):
   Which-Key (Tobias Völzel, 0.11.2), AceJump (3.8.22), IdeaVim-EasyMotion (1.16) and HarpoonIJ (0.2.0). Check a plugin against the
   installed build before recommending it: `curl 'https://plugins.jetbrains.com/plugins/list?pluginId=<xmlId>&build=<build.txt of the
   install>'` returns the compatible version, or an empty list if there is none (the "LazyGit in Editor Terminal" plugin returned
   nothing for AI-262.9437.185). Then create the two lazygit External Tools (KEY_GUIDE.md, "Lazygit"): group `Vim`, names
   `lazygit` and `lazygit_file`, so the action ids `Tool_Vim_lazygit` / `Tool_Vim_lazygit_file` exist.
1. Check IdeaVim is installed: the folder `~/.local/share/Google/AndroidStudio<version>/IdeaVIM/` exists (Android Studio:
   Settings > Plugins > Marketplace > IdeaVim). Tested with IdeaVim 2.47.3 and Android Studio 2026.2.1.
2. Back up the existing `~/.ideavimrc`, then copy `new_android_studio/ideavimrc` to `~/.ideavimrc`.
3. In the IDE: `SPC h r` reloads it, or `:source ~/.ideavimrc`.
4. Do not edit the IDE's own settings (`~/.config/Google/AndroidStudio*/options/*.xml`) by hand while the IDE is running.

## Rules

- **Check every `<Action>(Id)` against the installed build** before adding it. The ids live in the `plugin.xml` / module XML files inside
  the jars of the install (`<install>/lib`, `<install>/plugins/*/lib`, and `IdeaVIM/lib`):
  `unzip -p <jar> '*.xml' | grep -o '<action id="[^"]*"'`. A wrong id only fails when the key is pressed.
- The install path of Android Studio differs per machine (here `~/Tuan/Android/android-studio`, which is read-only for Claude: read it,
  never change it).
- Keys are mapped on purpose to match `new_vim/nvim/init.lua`. When a key changes in nvim, change it here and in `KEY_GUIDE.md`.
- `sethandler` lines make IdeaVim (not the IDE) own a key. `C-c`, `C-v`, `C-z` stay with the IDE on purpose.
- The first run was not tested in a live IDE. Ask the user to try the keys listed under "First run" in `KEY_GUIDE.md`.

## Known limits

See "Different or missing" in `KEY_GUIDE.md`: flash labels, window resize chords, Oil, Telescope, the UI blocks.
