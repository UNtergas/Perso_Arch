-- SPC o p on an Android layout (res/layout*/x.xml): render it with Paparazzi (layoutlib, the engine behind Android Studio's
-- preview) and show the PNG in a feh window. Nothing is added to the project: preview/preview.init.gradle applies the plugin
-- and a generic test from outside the repo (see new_kotlin_vim/SETUP_FOR_CLAUDE.md). Needs one Gradle build, ~25 s a render.
local M = {}

local CONFIG = vim.fn.stdpath("config") .. "/preview"
local OUT = vim.fn.stdpath("cache") .. "/layout-preview"
local JAVA_HOME = "/usr/lib/jvm/java-21-openjdk-amd64"
local running = false

local function read(path)
  local f = io.open(path, "r")
  if not f then return nil end
  local s = f:read("*a")
  f:close()
  return s
end

local function warn(msg) vim.notify("Layout preview: " .. msg, vim.log.levels.WARN) end

local function show(png)
  if vim.fn.executable("feh") ~= 1 then return warn("feh is not installed, image saved to " .. png) end
  -- one window for every render: feh reloads the file when it changes (inotify)
  vim.fn.system({ "pgrep", "-f", "feh.*--class kvim-preview" })
  if vim.v.shell_error == 0 then return end
  vim.fn.jobstart({ "feh", "-.", "--class", "kvim-preview", "--title", "kvim-preview", png }, { detach = true })
end

local function newest_png(dir, since)
  local best, best_t = nil, since
  for _, p in ipairs(vim.fn.glob(dir .. "/*.png", false, true)) do
    local st = vim.uv.fs_stat(p)
    if st and st.mtime.sec >= best_t then best, best_t = p, st.mtime.sec end
  end
  return best
end

function M.render(buf)
  buf = buf or 0
  local file = vim.api.nvim_buf_get_name(buf)
  local layout = file:match("/res/layout[^/]*/([^/]+)%.xml$")
  if not layout then return warn("not a file under res/layout*/") end
  if running then return warn("a render is already running") end
  local mod = vim.fs.root(file, { "build.gradle", "build.gradle.kts" })
  local root = vim.fs.root(file, { "gradlew" })
  if not (mod and root) then return warn("no module build.gradle / gradlew above this file") end

  local gradle = read(mod .. "/build.gradle") or read(mod .. "/build.gradle.kts") or ""
  local manifest = read(mod .. "/src/main/AndroidManifest.xml") or ""
  local pkg = gradle:match("namespace%s*=?%s*[\"']([^\"']+)[\"']") or manifest:match('package="([^"]+)"')
  if not pkg then return warn("no namespace in the module's build.gradle") end
  local app = manifest:match("<application(.-)>") or ""
  local theme = app:match('android:theme="@style/([^"]+)"') or "android:Theme.Material.Light.NoActionBar"

  local rel = mod:sub(#root + 2)
  local project = ":" .. rel:gsub("/", ":")
  local prefix = rel == "" and ":" or project .. ":"
  vim.cmd("silent! update") -- the build reads the file on disk
  local _, tags = table.concat(vim.api.nvim_buf_get_lines(buf, 0, -1, false), "\n"):gsub("<[%a]", "")
  local empty = tags <= 1 -- only the root element: nothing to draw (an activity that hosts fragments in a bare container)
  vim.fn.mkdir(OUT, "p")
  local started = os.time()
  running = true
  vim.notify("Layout preview: rendering " .. layout .. " (" .. project .. ")...")
  -- no Gradle daemon and no Kotlin daemon: both would stay alive for hours after the render (vim.g.kvim_preview_daemon = true keeps them: faster, ~2 GB)
  local args = {
    "./gradlew", "--init-script", CONFIG .. "/preview.init.gradle",
    prefix .. "cleanTestDebugUnitTest", prefix .. "testDebugUnitTest", "--tests", "kvim.preview.LayoutPreviewTest",
    "--console=plain",
  }
  if not vim.g.kvim_preview_daemon then
    vim.list_extend(args, { "--no-daemon", "-Pkotlin.compiler.execution.strategy=in-process" })
  end
  vim.system(args, {
    cwd = root,
    text = true,
    env = {
      JAVA_HOME = JAVA_HOME,
      PREVIEW_MODULE = project, PREVIEW_TEST_DIR = CONFIG, PREVIEW_PKG = pkg, PREVIEW_LAYOUT = layout, PREVIEW_THEME = theme,
    },
  }, vim.schedule_wrap(function(res)
    running = false
    local log = OUT .. "/last.log"
    local f = io.open(log, "w")
    if f then f:write(res.stdout or "", "\n", res.stderr or ""); f:close() end
    if res.code ~= 0 then
      local tail = vim.list_slice(vim.split((res.stderr or "") .. (res.stdout or ""), "\n"), -12)
      return vim.notify("Layout preview failed (full log: " .. log .. ")\n" .. table.concat(tail, "\n"), vim.log.levels.ERROR)
    end
    local png = newest_png(mod .. "/build/reports/paparazzi/debug/images", started - 1)
    if not png then return warn("the build passed but made no image, see " .. log) end
    local dst = OUT .. "/preview.png"
    vim.uv.fs_copyfile(png, dst) -- overwritten in place, so feh's inotify watch stays valid
    vim.notify("Layout preview: " .. layout .. (empty and " done, but it has no child views, so the picture is blank" or " done"))
    show(dst)
  end))
end

return M
