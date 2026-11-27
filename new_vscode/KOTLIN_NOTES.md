# Kotlin in VS Code (JetBrains "Kotlin by JetBrains" extension) on snowpack-android

Findings from 2026-11-23. Tested headless (`lsp_probe.py`) on a COPY of `~/Tuan/snowpack-android` (AGP 8.13.2, Gradle 8.13, Kotlin 1.9.24),
never in the project itself.

## What was wrong

1. **The installed extension was 0.0.13, whose bundled server says "This build of kotlin-server has expired" and exits.** Update it:
   `code --install-extension jetbrains.kotlin-server --force` (0.0.86 on 2026-11-23, server `ILS-271.2085.0`, 2027.1 EAP). The server
   needs Java 25; it ships its own runtime. The first launch asks for the EULA inside VS Code (do not pass `--eula` for the user).
2. **Gradle import fails on AGP 8.13.2.** The server's import runs `androidComponents.onVariants` and then reads the BuildConfig
   directory of the androidTest variant before the task has run: `Querying the mapped value of ...
   generateDebugAndroidTestBuildConfig ... before task ':androidapi:generateDebugAndroidTestBuildConfig' has completed is not
   supported` -> `Unable to import a Gradle project`. Nothing is imported, so every file shows 0 diagnostics and no navigation.

## Fix (outside the project)

`gradle-init/kotlin-lsp-androidtest.gradle`, copied to `~/.gradle/init.d/`: it turns the androidTest variants off ONLY when the server
is importing. The server passes the system property `com.jetbrains.ls.imports.gradle` (and init scripts `lsp-gradle-init*.gradle`,
`lsp-gradle-idea-configurator*.gradle`); Android Studio and normal Gradle builds do not, so `connectedAndroidTest` is unaffected.
Remove the file once the server copes with androidTest variants itself.

## Result with the fix (copy of the project, original build.gradle)

- Import finished, indexing to 100% in about 40 s on this machine.
- A planted typo (`AccessState.DENEID`) is reported as `Unresolved reference 'DENEID'` and is the only error.
- `MainFragment.kt` (ViewBinding, `R.string`): 26 diagnostics, 0 errors, only real warnings (deprecated `fromHtml`, unnecessary `!!`...).
- Go to definition: `FragmentMainBinding` -> the generated Java file in `build/generated/data_binding_base_class_source_out/`;
  `R.string.x` -> the generated R class jar. Hover works. (Android Studio would go to the layout XML for a binding field; the server does not.)
- Note: "Couldn't resolve some dependencies: ... androidapi/build/intermediates/full_jar ... android:r" appears when those modules have
  not been built yet (they are missing in the project too). It is not fatal: build once with Gradle and it goes away.

## Re-running the probe

`python3 -I new_vscode/lsp_probe.py <ext>/server <project copy> <empty system dir> <file.kt> [...] [--def FILE:LINE:COL]`
(see its docstring). The server needs about 2 GB of heap plus the Gradle daemon (2 GB from gradle.properties): close big apps first.
The scratch copy used for the tests is `~/.cache/vscode-kotlin-test/` (about 300 MB, safe to delete).

## Not tested

Only the headless protocol was tested, not the VS Code window itself (inlay hints, quick fixes, rename, the Red Hat Java extension
running alongside). Opening the real project in VS Code runs the same import and creates Gradle / server cache files in the project folder.
