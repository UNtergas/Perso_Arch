return {
  -- Volt plugin (lazy-loaded)
  { "nvzone/volt", lazy = true },

  -- Minty plugin (only loads when using "Shades" or "Huefy" commands)
  {
    "nvzone/minty",
    cmd = { "Shades", "Huefy" },
  },
}

