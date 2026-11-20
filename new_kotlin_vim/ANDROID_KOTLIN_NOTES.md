# Android / Kotlin problems in kvim: working notes for a Claude session

Read `SETUP_FOR_CLAUDE.md` first for install and the general rules. This file is the state of the
Android-specific work: what was wrong, what fixes exist, where they live, how they were tested and what
not to retry. All of it was tested on `~/Tuan/snowpack-android` (AGP 8.13.2, Gradle 8.13, Kotlin 1.9.24,
modules `app`, `androidapi`, `demo_access`, `demo_services`, ...) through **copies**, never in place.

## Status

| # | Problem | State | Where |
|---|---|---|---|
| 1 | `import ....databinding.ActivityMainBinding` shows "Unresolved reference: databinding" (Android Studio shows none) | **fixed**, user confirmed | `kvim/init.lua`, `before_init` of `kotlin_language_server` |
| 2 | `gd` on a binding class or field opened the generated `.java`, Android Studio opens the layout XML | **fixed**, headless-tested, user to confirm in real use | `kvim/lua/kotlin_definition.lua` (`generated_to_layout`) |
| 3 | No preview of an Android layout (Android Studio has one) | **works**: `SPC o p` on `res/layout*/x.xml`, render with Paparazzi, shown in a `feh` window | `kvim/lua/layout_preview.lua`, `kvim/preview/`, mapping in `kvim/init.lua` |

## 1. Generated binding classes are "unresolved"

- **Cause.** `ActivityMainBinding` is generated Java under
  `<module>/build/generated/data_binding_base_class_source_out/<variant>/out/`. `kotlin_language_server`
  (fwcd, 1.3.13) reads Java sources only from its **workspace folders given at initialize**. `build/` is
  not one, so the class is invisible. The generated file exists after one Gradle build.
- **Fix.** `before_init` appends the `debug` folder of every module (`<root>/*/build/generated/...`) to
  `params.workspaceFolders`. Only `debug`: adding `release` too gives two copies of every class.
- **Measured** on a copy: baseline 33 diagnostics ("Unresolved reference: databinding" plus two
  `ActivityMainBinding`), with the folder at startup 1 diagnostic and `textDocument/definition` returns the generated file.
- **Dead end: `vim.lsp.buf.add_workspace_folder` after startup has no effect** (still 33). It has to be at initialize.
- **Limits.** Needs a Gradle build first; after a layout change rebuild and restart the server. Flavour-only
  variants (`devDebug`) are not matched. `R` and `BuildConfig` are not handled.

## 2. `gd` on a binding goes to the layout

`kotlin_definition.lua` wraps the Kotlin client's `textDocument/definition` (see the "Definition adapter"
bullet in `SETUP_FOR_CLAUDE.md`). `deliver()` now runs every result through `generated_to_layout`:

- A location in a `.../data_binding_base_class_source_out/.../*Binding.java`.
- The line is the class (`ActivityMainBinding`) -> `src/*/res/layout/activity_main.xml`, line 1
  (CamelCase to snake_case, falls back to `layout*` qualifier folders).
- The line is a field (`public final Button btnStartStop;`) -> the `android:id="@+id/btn_start_stop"` line of that layout.
- Anything unmatched (for example an id like `btn_1` whose field is `btn1`) keeps the Java location.
- Tests: `nvim --headless -u NONE -l new_kotlin_vim/tests/definition_fallbacks.lua` still passes. The mapping itself was
  checked against the real generated files of `demo_services` with a small script.

## 3. Layout preview (`SPC o p`)

Why Paparazzi: Android Studio renders with **layoutlib**; Paparazzi runs layoutlib in a Gradle unit test and
writes a PNG, so the picture matches Studio's. Nothing is added to the project.

- **Flow** (`layout_preview.lua`, `M.render`): from the buffer path find the module (`build.gradle` above it)
  and the root (`gradlew`); read `namespace` from the module's `build.gradle(.kts)` (fallback: manifest
  `package=`) and the application theme from the manifest (`@style/X` -> `X`, fallback
  `android:Theme.Material.Light.NoActionBar`). Run, from the root, `./gradlew --init-script preview/preview.init.gradle
  :<module>:cleanTestDebugUnitTest :<module>:testDebugUnitTest --tests kvim.preview.LayoutPreviewTest --no-daemon
  -Pkotlin.compiler.execution.strategy=in-process`, with env `PREVIEW_MODULE`, `PREVIEW_TEST_DIR`, `PREVIEW_PKG`,
  `PREVIEW_LAYOUT`, `PREVIEW_THEME` and `JAVA_HOME` = JDK 21. Then take the newest PNG under
  `<module>/build/reports/paparazzi/debug/images/`, copy it over `~/.cache/kvim/layout-preview/preview.png` (in place, so
  feh's inotify watch survives) and open or refresh `feh -. --class kvim-preview`. Failure: log in
  `~/.cache/kvim/layout-preview/last.log` and the last lines in a notification.
- **`preview/preview.init.gradle`.** Adds `app.cash.paparazzi:paparazzi-gradle-plugin:1.3.5` (env
  `PREVIEW_PLUGIN_VERSION` overrides) to the **root project's buildscript classpath** in `gradle.projectsLoaded`, so
  it shares a classloader with AGP (putting it in the init script's own `initscript {}` classpath cannot see AGP).
  It applies `app.cash.paparazzi` to the module when the Android application plugin is applied and adds
  `preview/` as an extra test source folder.
- **`preview/LayoutPreviewTest.kt`.** One generic test: reads `PREVIEW_PKG` / `PREVIEW_LAYOUT` from the
  environment, gets the layout id by **reflection on `<pkg>.R$layout`** (not `getIdentifier`), inflates it and
  calls `paparazzi.snapshot`. Pixel 5 (`DeviceConfig.PIXEL_5`).
- **Verified** (copy, headless, then by the user): `demo_services/activity_main.xml` and `app/fragment_main.xml` (themed
  text fields, bottom navigation, nested layouts) render like Studio. First run about 2 minutes (compiles `androidapi`
  and the module, downloads layoutlib), then about 25 s with `--no-daemon`.
- **A blank picture can be right.** `app/.../activity_main.xml` is an empty `FrameLayout` (the real UI is in fragments).
  The plugin now says "no child views, so the picture is blank" when the file has only its root element.
- **No daemon left behind.** The first version used the normal Gradle daemon; it (and the Kotlin daemon) stayed alive for
  hours after the window closed. Now `--no-daemon` plus the in-process Kotlin compiler; `vim.g.kvim_preview_daemon = true`
  opts back into the daemon (faster, but about 2 GB stays resident).
- **Environment facts.** The terminal is Alacritty inside tmux, which has **no image protocol** (no kitty, sixel or
  iTerm), so inline images (`snacks.image`) cannot work and the preview is an external `feh` window (Wayland, niri;
  a niri window rule for app-id `kvim-preview` can make it floating, not set up). `feh` and `chafa` are installed;
  `chafa` could draw a rough in-terminal version, not built. `SPC o p` is buffer-local to `xml` buffers, next to
  `SPC o m` (markdown) and `SPC o t` (terminal).
- **Limits.** Debug variant only; fixed Pixel 5 size; no runtime data (adapters, network); custom views render if
  their classes compile; needs `compileSdk` platform installed and the module buildable.
- **Not tried.** Paparazzi 2.0 alpha (1.3.5 already works with AGP 8.13.2); JetBrains `kotlin-lsp` (its Gradle import fails
  on AGP 8.13.2, see `SETUP_FOR_CLAUDE.md`).

## How to test without hurting the machine

These rules come from a real incident (test copies and servers once overflowed memory and rebooted the machine):

- Never run kvim, a server or Gradle inside `~/Tuan/...`. Copy first: `git ls-files -z` plus `local.properties` through
  `rsync -a --from0 --files-from=-` into `~/.cache/<name>/`, add generated folders with a plain `rsync -a` when needed,
  delete the copy afterwards with a literal path.
- Check `grep -E 'MemAvailable|SwapFree' /proc/meminfo` first. Android Studio, kvim's own Kotlin server (2.5 to 3.3 GB)
  and jdtls were running when it got tight. Ask the user to close Studio if available memory is under about 3 GB.
  Wrap Gradle in a watchdog that kills its process group when `MemAvailable` drops under about 600 MB.
- One server at a time with `JAVA_OPTS=-Xmx1g`; a headless test server can outlive nvim, so check
  `ps -eo pid,rss,etime,args | grep '[j]ava.*kotlinLanguageServer'` and kill only the test one.
- Do not `pkill -f` a pattern that also appears in your own command line: it kills the shell running it.
- Headless Kotlin check: open the copy's `MainActivity.kt` with `NVIM_APPNAME=kvim nvim --headless -n`, `vim.wait` until
  the `kotlin_language_server` client exists and diagnostics arrive, then count `vim.diagnostic.get(0)` and send
  `textDocument/definition` with `vim.lsp.buf_request_sync`.
- Preview check: from a copy, run `require("layout_preview").render(0)` in `nvim --headless -u NONE` (load the module
  with `dofile`, override `vim.notify`, `vim.wait` for "done" or "failed"), then look at the PNG.
- Workflow reminders: edit `~/.config/kvim` first, test, then copy to `new_kotlin_vim/kvim/`; the user tests for a day
  before anything is pushed unless they say to commit and push.
