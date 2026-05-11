-- Patch to make nvim 0.12 work with treesitter
local function patch_treesitter_ft_to_lang()
  local ok, parsers = pcall(require, "nvim-treesitter.parsers")
  if not ok or parsers.ft_to_lang then
    return
  end

  local language = vim.treesitter.language
  if not language or type(language.get_lang) ~= "function" then
    return
  end

  parsers.ft_to_lang = function(filetype)
    return language.get_lang(filetype) or filetype
  end
end

local function patch_treesitter_configs_module()
  local ok = pcall(require, "nvim-treesitter.configs")
  if ok then
    return
  end

  package.preload["nvim-treesitter.configs"] = function()
    local M = {}

    function M.get_module(name)
      if name == "highlight" then
        return {
          additional_vim_regex_highlighting = false,
        }
      end

      return {}
    end

    function M.is_enabled(name, lang, _bufnr)
      if name ~= "highlight" then
        return false
      end

      local get_query = vim.treesitter.query.get or vim.treesitter.get_query
      if type(get_query) ~= "function" then
        return false
      end

      return pcall(get_query, lang, "highlights")
    end

    return M
  end
end

patch_treesitter_ft_to_lang()
patch_treesitter_configs_module()
