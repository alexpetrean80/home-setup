local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

local function get_hostname()
  local handle = io.popen("hostname")
  if handle == nil then
    return ""
  end
  local hostname = handle:read("*a") or ""
  handle:close()
  hostname = string.gsub(hostname, "\n$", "")
  return hostname
end

local spec = {
  { "LazyVim/LazyVim", import = "lazyvim.plugins" },
  { import = "extras" },
  { import = "plugins" },
  { import = "extend" },
}

if get_hostname() ~= "F59V2P7FXY" then
  -- plugins not allowed for work use, e.g. copilot
  table.insert(spec, { import = "lazyvim.plugins.extras.ai.copilot" })
else
  -- work related config, e.g. snyk-ls
  table.insert(spec, { import = "work" })
end

require("lazy").setup({
  spec = spec,
  defaults = {
    lazy = false,
    -- It's recommended to leave version=false for now, since a lot the plugin that support versioning,
    -- have outdated releases, which may break your Neovim install.
    version = false, -- always use the latest git commit
  },
  install = { colorscheme = { "tokyonight", "habamax" } },
  checker = {
    enabled = true, -- check for plugin updates periodically
    notify = false, -- notify on update
  }, -- automatically check for plugin updates
  rocks = {
    hererocks = false,
  },
  performance = {
    rtp = {
      -- disable some rtp plugins
      disabled_plugins = {
        "gzip",
        -- "matchit",
        -- "matchparen",
        "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})
