-- mkdnflow is just for ensuring hitting 'Enter' when in a list in insert mode creates a new list item below.
-- All other markdown functionality is handled by obsidian.nvim below.
local function createNoteWithDefaultTemplate()
  local TEMPLATE_FILENAME = "meeting"
  local obsidian = require("obsidian").get_client()
  local utils = require("obsidian.util")

  -- prevent Obsidian.nvim from injecting it's own frontmatter table
  obsidian.opts.disable_frontmatter = true

  -- prompt for note title
  -- @see: borrowed from obsidian.command.new
  local title = utils.input("Enter title or path (optional): ")
  if not title then
    return
  elseif title == "" then
    title = nil
  end

  local note = obsidian:create_note({ title = title, no_write = false, template = TEMPLATE_FILENAME })

  if not note then
    return
  end
  -- open new note in a buffer
  obsidian:open_note(note, { sync = true })
  -- -- NOTE: make sure the template folder is configured in Obsidian.nvim opts
  -- obsidian:write_note_to_buffer(note, { template = TEMPLATE_FILENAME })
  -- -- hack: delete empty lines before frontmatter; template seems to be injected at line 2
  -- vim.api.nvim_buf_set_lines(0, 0, 1, false, {})
end

local function createJiraTicketNote()
  local obsidian = require("obsidian").get_client()
  local utils = require("obsidian.util")
  local jira_domain = os.getenv("JIRA_DOMAIN")

  local base_url = "https://" .. jira_domain .. "/browse/PPO-"
  local ppo_num = utils.input("Ticket number: ")

  local full_url = base_url .. ppo_num

  local ticket_name = fetch_field_from_jira(ppo_num, "summary")
  local time_code = fetch_field_from_jira(ppo_num, "customfield_23252")[1]
  local time_code = string.sub(time_code, 1, 6)


  -- Create note from template
  local TEMPLATE_FILENAME = "jira-ticket"

  local full_title = "PPO-" .. ppo_num .. " - " .. ticket_name

  -- prevent Obsidian.nvim from injecting it's own frontmatter table
  obsidian.opts.disable_frontmatter = true

  note = obsidian:create_note({ title = full_title, no_write = false, template = TEMPLATE_FILENAME })
  note.add_field(note, "url", full_url)
  note.add_field(note, "time_code", time_code)
  note.add_alias(note, full_title)
  note.add_tag(note, "jira-ticket")
  note.save(note, {
    update_content = function()
      return { "", "# " .. full_title }
    end
  })

  obsidian:open_note(note, { sync = true })
end

local function addMyTimeFields()
  --- add project, etc. based on inputted JIRA ticket
  local utils = require("obsidian.util")
  local jira_domain = os.getenv("JIRA_DOMAIN")

  local base_url = "https://" .. jira_domain .. "/browse/PPO-"

  -- local full_title = "PPO-" .. ppo_num .. " - " .. ticket_name

  local current_line = vim.api.nvim_get_current_line()
  -- Search for "PPO-" followed by 5 digits
  local ppo_match = current_line:match("PPO%-(%d%d%d%d%d)")
  if ppo_match then
    -- print("Found PPO number: ", ppo_match)
    PPO_num = ppo_match
    New_entry = false
  else
    PPO_num = utils.input("Ticket number: ")
    New_entry = true
  end

  local ticket_name = fetch_field_from_jira(PPO_num, "summary")
  local time_code = fetch_field_from_jira(PPO_num, "customfield_23252")[1]
  local time_code = string.sub(time_code, 1, 6)

  local lines = {
    "project: " .. time_code,
    "project name: ",
    "task number: ",
    "hours: 1"
  }

  if New_entry then
    local heading = "## PPO-" .. PPO_num .. " - " .. ticket_name
    table.insert(lines, 1, heading)
  end

  local buf = vim.api.nvim_get_current_buf()
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  vim.api.nvim_buf_set_lines(buf, row, row, false, lines)
end


function fetch_field_from_jira(ppo_num, field)
  local jiraPAT = os.getenv("JIRA_PAT")
  local auth_string = "Bearer " .. jiraPAT

  local curl = require('plenary.curl')

  local jira_domain = os.getenv("JIRA_DOMAIN")
  local base_url = "https://" .. jira_domain .. "/rest/api/2/issue/PPO-"
  local full_url = base_url .. ppo_num

  local response = curl.get(full_url, {
    headers = {
      Authorization = auth_string
    }
  })

  local data = vim.json.decode(response.body)

  local result = data.fields[field]

  return result
end

return {
  {
    'jakewvincent/mkdnflow.nvim',
    config = function()
      require('mkdnflow').setup({
        -- mappings = {
        --   MkdnEnter = { { 'i', 'n', 'v' }, '<CR>' },
        --   --   MkdnToggleToDo = { { 'n', 'v' }, '<C-k>' },
        -- },
        modules = {
          bib = false,
          buffers = false,
          conceal = false,
          cursor = true, -- for increasing / decreasing headers
          folds = false,
          links = true,
          lists = true, -- lists and maps seem to enable continuing a checklist when pressing Enter.
          maps = true,
          paths = true,
          tables = false,
          yaml = false,
          cmp = false
        },
        mappings = {
          -- MkdnEnter = { { 'n', 'v' }, '<CR>' }, -- This monolithic command has the aforementioned
          -- insert-mode-specific behavior and also will trigger row jumping in tables. Outside
          -- of lists and tables, it behaves as <CR> normally does.
          -- Using Enter for MkdnNewListItem doesn't work with with espanso on wayland. When expanding multi-line snippets,
          -- it creates a new line at the wrong point.
          -- MkdnNewListItem = { 'i', '<CR>' }, -- Use this command instead if you only want <CR> in
          -- insert mode to add a new list item (and behave as usual outside of lists).
          MkdnEnter = false, -- Let obsidian.nvim handle smart enter in normal mode: toggle checkboxes, follow links.
          MkdnNewListItem = { 'i', '<CR>' },
          MkdnIncreaseHeading = { 'n', '+' },
          MkdnDecreaseHeading = { 'n', '-' },
          MkdnTab = { 'n', '<Tab>' },
          MkdnSTab = { 'n', '<S-Tab>' },
        }
      })
      vim.api.nvim_create_autocmd("BufLeave", { pattern = "*.md", command = "silent! w" })
    end
  },

  {
    "epwalsh/obsidian.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim"
    },
    lazy = false, -- load on markdown files
    ft = "markdown",
    opts = {
    },
    config = function()
      require('obsidian').setup({
        -- A list of workspace names, paths, and configuration overrides.
        -- If you use the Obsidian app, the 'path' of a workspace should generally be
        -- your vault root (where the `.obsidian` folder is located).
        -- When obsidian.nvim is loaded by your plugin manager, it will automatically set
        -- the workspace to the first workspace in the list whose `path` is a parent of the
        -- current markdown file being edited.
        workspaces = {
          {
            name = "notes",
            path = "~/notes",
          },
        },

        -- Alternatively - and for backwards compatibility - you can set 'dir' to a single path instead of
        -- 'workspaces'. For example:
        -- dir = "~/vaults/work",

        -- Optional, if you keep notes in a specific subdirectory of your vault.
        -- notes_subdir = "notes",

        -- Optional, set the log level for obsidian.nvim. This is an integer corresponding to one of the log
        -- levels defined by "vim.log.levels.*".
        log_level = vim.log.levels.INFO,

        daily_notes = {
          -- Optional, if you keep daily notes in a separate directory.
          folder = "daily",
          -- Optional, if you want to change the date format for the ID of daily notes.
          date_format = "%Y-%m-%d",
          -- Optional, if you want to change the date format of the default alias of daily notes.
          alias_format = "%A %-d %B %Y",
          -- Optional, if you want to automatically insert a template from your template directory like 'daily.md'
          template = "daily.md"
        },

        -- Optional, completion of wiki links, local markdown links, and tags using nvim-cmp.
        completion = {
          -- Set to false to disable completion.
          nvim_cmp = true,
          -- Trigger completion at 2 chars.
          min_chars = 2,
        },

        -- Optional, configure key mappings. These are the defaults. If you don't want to set any keymappings this
        -- way then set 'mappings = {}'.
        mappings = {
          -- Overrides the 'gf' mapping to work on markdown/wiki links within your vault.
          ["gf"] = {
            action = function()
              return require("obsidian").util.gf_passthrough()
            end,
            opts = { noremap = false, expr = true, buffer = true },
          },
          -- Toggle check-boxes.
          ["<leader>oh"] = {
            action = function()
              return require("obsidian").util.toggle_checkbox()
            end,
            opts = { buffer = true },
          },
          -- Smart action depending on context, either follow link or toggle checkbox.
          ["<cr>"] = {
            action = function()
              return require("obsidian").util.smart_action()
            end,
            opts = { buffer = true, expr = true, desc = "obsidian.nvim - Smart Action - Create checkbox, toggle checkbox, or follow link." },
          }
        },

        -- Where to put new notes. Valid options are
        --  * "current_dir" - put new notes in same directory as the current buffer.
        --  * "notes_subdir" - put new notes in the default notes subdirectory.
        new_notes_location = "notes_subdir",

        -- Optional, customize how note IDs are generated given an optional title.
        ---@param title string|?
        ---@return string
        note_id_func = function(title)
          -- Create file name
          local suffix = ""
          if title ~= nil then
            -- If title is given, transform it into valid file name.
            suffix = title:gsub(" ", "-"):gsub("[^A-Za-z0-9-]", ""):lower()
          else
            -- If title is nil, just add 4 random uppercase letters to the suffix.
            for _ = 1, 4 do
              suffix = suffix .. string.char(math.random(65, 90))
            end
          end
          -- return tostring(os.time()) .. "-" .. suffix
          return suffix
        end,

        -- Optional, customize how note file names are generated given the ID, target directory, and title.
        ---@param spec { id: string, dir: obsidian.Path, title: string|? }
        ---@return string|obsidian.Path The full path to the new note.
        note_path_func = function(spec)
          -- This is equivalent to the default behavior.
          local path = spec.dir / tostring(spec.id)
          return path:with_suffix(".md")
        end,

        -- Optional, customize how wiki links are formatted. You can set this to one of:
        --  * "use_alias_only", e.g. '[[Foo Bar]]'
        --  * "prepend_note_id", e.g. '[[foo-bar|Foo Bar]]'
        --  * "prepend_note_path", e.g. '[[foo-bar.md|Foo Bar]]'
        --  * "use_path_only", e.g. '[[foo-bar.md]]'
        -- Or you can set it to a function that takes a table of options and returns a string, like this:
        wiki_link_func = function(opts)
          return require("obsidian.util").wiki_link_id_prefix(opts)
        end,

        -- Optional, customize how markdown links are formatted.
        markdown_link_func = function(opts)
          return require("obsidian.util").markdown_link(opts)
        end,

        -- Either 'wiki' or 'markdown'.
        preferred_link_style = "wiki",

        -- Optional, customize the default name or prefix when pasting images via `:ObsidianPasteImg`.
        ---@return string
        image_name_func = function()
          -- Prefix image names with timestamp.
          return string.format("%s-", os.time())
        end,

        -- Optional, boolean or a function that takes a filename and returns a boolean.
        -- `true` indicates that you don't want obsidian.nvim to manage frontmatter.
        disable_frontmatter = false,

        -- Optional, alternatively you can customize the frontmatter data.
        ---@return table
        note_frontmatter_func = function(note)
          -- Add the title of the note as an alias.
          if note.title then
            note:add_alias(note.title)
          end

          local out = { id = note.id, aliases = note.aliases, tags = note.tags }

          -- `note.metadata` contains any manually added fields in the frontmatter.
          -- So here we just make sure those fields are kept in the frontmatter.
          if note.metadata ~= nil and not vim.tbl_isempty(note.metadata) then
            for k, v in pairs(note.metadata) do
              out[k] = v
            end
          end

          return out
        end,

        -- Optional, for templates (see below).
        templates = {
          folder = "templates",
          date_format = "%Y-%m-%d",
          time_format = "%H:%M",
          -- A map for custom variables, the key should be the variable and the value a function
          substitutions = {},
        },

        -- Optional, by default when you use `:ObsidianFollowLink` on a link to an external
        -- URL it will be ignored but you can customize this behavior here.
        ---@param url string
        follow_url_func = function(url)
          -- Open the URL in the default web browser.
          local os_name = vim.loop.os_uname().sysname
          if os_name == "Linux" then
            print("linux")
            vim.fn.jobstart({ "xdg-open", url }) -- linux
          else
            print("macOS")
            vim.fn.jobstart({ "open", url }) -- Mac OS
          end
        end,

        ---@param img string
        follow_img_func = function(img)
          -- vim.fn.jobstart { "qlmanage", "-p", img }  -- Mac OS quick look preview
          vim.fn.jobstart({ "xdg-open", img }) -- linux
          -- vim.cmd(':silent exec "!start ' .. url .. '"') -- Windows
        end,

        -- Optional, set to true if you use the Obsidian Advanced URI plugin.
        -- https://github.com/Vinzent03/obsidian-advanced-uri
        use_advanced_uri = false,

        -- Optional, set to true to force ':ObsidianOpen' to bring the app to the foreground.
        open_app_foreground = false,

        picker = {
          -- Set your preferred picker. Can be one of 'telescope.nvim', 'fzf-lua', or 'mini.pick'.
          name = "telescope.nvim",
          -- Optional, configure key mappings for the picker. These are the defaults.
          -- Not all pickers support all mappings.
          mappings = {
            -- Create a new note from your query.
            new = "<C-x>",
            -- Insert a link to the selected note.
            insert_link = "<C-l>",
          },
        },

        -- Optional, sort search results by "path", "modified", "accessed", or "created".
        -- The recommend value is "modified" and `true` for `sort_reversed`, which means, for example,
        -- that `:ObsidianQuickSwitch` will show the notes sorted by latest modified time
        sort_by = "modified",
        sort_reversed = true,

        -- Optional, determines how certain commands open notes. The valid options are:
        -- 1. "current" (the default) - to always open in the current window
        -- 2. "vsplit" - to open in a vertical split if there's not already a vertical split
        -- 3. "hsplit" - to open in a horizontal split if there's not already a horizontal split
        open_notes_in = "current",

        -- Optional, define your own callbacks to further customize behavior.
        callbacks = {
          -- Runs at the end of `require("obsidian").setup()`.
          ---@param client obsidian.Client
          post_setup = function(client) end,

          -- Runs anytime you enter the buffer for a note.
          ---@param client obsidian.Client
          ---@param note obsidian.Note
          enter_note = function(client, note) end,

          -- Runs anytime you leave the buffer for a note.
          ---@param client obsidian.Client
          ---@param note obsidian.Note
          leave_note = function(client, note) end,

          -- Runs right before writing the buffer for a note.
          ---@param client obsidian.Client
          ---@param note obsidian.Note
          pre_write_note = function(client, note) end,

          -- Runs anytime the workspace is set/changed.
          ---@param client obsidian.Client
          ---@param workspace obsidian.Workspace
          post_set_workspace = function(client, workspace) end,
        },

        -- Optional, configure additional syntax highlighting / extmarks.
        -- This requires you have `conceallevel` set to 1 or 2. See `:help conceallevel` for more details.
        ui = {
          enable = true,          -- set to false to disable all additional syntax features
          update_debounce = 200,  -- update delay after a text change (in milliseconds)
          max_file_length = 5000, -- disable UI features for files with more than this many lines
          -- Define how various check-boxes are displayed
          checkboxes = {
            -- NOTE: the 'char' value has to be a single character, and the highlight groups are defined below.
            [" "] = { char = "󰄱", hl_group = "ObsidianTodo" },
            ["x"] = { char = "", hl_group = "ObsidianDone" },
            [">"] = { char = "", hl_group = "ObsidianRightArrow" },
            ["~"] = { char = "󰰱", hl_group = "ObsidianTilde" },
            ["!"] = { char = "", hl_group = "ObsidianImportant" },
            -- Replace the above with this if you don't have a patched font:
            -- [" "] = { char = "☐", hl_group = "ObsidianTodo" },
            -- ["x"] = { char = "✔", hl_group = "ObsidianDone" },

            -- You can also add more custom ones...
          },
          -- Use bullet marks for non-checkbox lists.
          bullets = { char = "•", hl_group = "ObsidianBullet" },
          external_link_icon = { char = "", hl_group = "ObsidianExtLinkIcon" },
          -- Replace the above with this if you don't have a patched font:
          -- external_link_icon = { char = "", hl_group = "ObsidianExtLinkIcon" },
          reference_text = { hl_group = "ObsidianRefText" },
          highlight_text = { hl_group = "ObsidianHighlightText" },
          tags = { hl_group = "ObsidianTag" },
          block_ids = { hl_group = "ObsidianBlockID" },
          hl_groups = {
            -- The options are passed directly to `vim.api.nvim_set_hl()`. See `:help nvim_set_hl`.
            ObsidianTodo = { bold = true, fg = "#f78c6c" },
            ObsidianDone = { bold = true, fg = "#89ddff" },
            ObsidianRightArrow = { bold = true, fg = "#f78c6c" },
            ObsidianTilde = { bold = true, fg = "#ff5370" },
            ObsidianImportant = { bold = true, fg = "#d73128" },
            ObsidianBullet = { bold = true, fg = "#89ddff" },
            ObsidianRefText = { underline = true, fg = "#c792ea" },
            ObsidianExtLinkIcon = { fg = "#c792ea" },
            ObsidianTag = { italic = true, fg = "#89ddff" },
            ObsidianBlockID = { italic = true, fg = "#89ddff" },
            ObsidianHighlightText = { bg = "#75662e" },
          },
        },

        -- Specify how to handle attachments.
        attachments = {
          -- The default folder to place images in via `:ObsidianPasteImg`.
          -- If this is a relative path it will be interpreted as relative to the vault root.
          -- You can always override this per image by passing a full path to the command instead of just a filename.
          img_folder = "assets/imgs", -- This is the default
          -- A function that determines the text to insert in the note when pasting an image.
          -- It takes two arguments, the `obsidian.Client` and an `obsidian.Path` to the image file.
          -- This is the default implementation.
          ---@param client obsidian.Client
          ---@param path obsidian.Path the absolute path to the image file
          ---@return string
          img_text_func = function(client, path)
            path = client:vault_relative_path(path) or path
            return string.format("![%s](%s)", path.name, path)
          end,
        },
      }
      )
      vim.keymap.set("n", "<leader>or", ':ObsidianYesterday<CR>',
        { silent = true, noremap = true, desc = "[O]bsidian Yesterday" })

      vim.keymap.set("n", "<leader>ot", ':ObsidianToday<CR>',
        { silent = true, noremap = true, desc = "[O]bsidian [T]oday" })

      vim.keymap.set("n", "<leader>oy", ':ObsidianTomorrow<CR>',
        { silent = true, noremap = true, desc = "[O]bsidian Tomorrow" })

      vim.keymap.set("v", "<leader>ole", ':ObsidianLink<CR>',
        { silent = true, noremap = true, desc = "[O]bsidian [L]ink visual selection to an [E]xisting note / path" })

      vim.keymap.set("v", "<leader>oln", ':ObsidianLinkNew<CR>',
        { silent = true, noremap = true, desc = "[O]bsidian [L]ink [N]ew" })

      vim.keymap.set("v", "<leader>oe", ':ObsidianExtractNote<CR>',
        { silent = true, noremap = true, desc = "[O]bsidian [E]xtract to new note" })

      vim.keymap.set("n", "<leader>nn", createNoteWithDefaultTemplate, { desc = "[N]ew Obsidian [N]ote from template" })

      vim.keymap.set("n", "<leader>nj", createJiraTicketNote, { desc = "[N]ew Obsidian [J]ira Ticket Note" })

      vim.keymap.set("n", "<leader>nk", addMyTimeFields, { desc = "Insert MyTime fields for a PPO ticket." })

      vim.keymap.set("n", "<leader>oo", ':ObsidianQuickSwitch<CR>', { desc = "[O]bsidian [O]pen (Quick Switcher)" })

      vim.keymap.set("n", "<leader>op", function()
          require("nvim-tree.api").tree.close()
          vim.cmd("ObsidianFollowLink vsplit")
          vim.wait(500)
          vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<C-w>', true, true, true), 'n', true)
          vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<C-r>', true, true, true), 'n', true)
        end,
        { desc = "Obsidian - Open Link in vsplit" })

      vim.keymap.set("n", "<leader>od", ":ObsidianDailies<CR>",
        { desc = "[O]bsidian - [D]ailies" })

      vim.keymap.set("n", "<leader>ob", ":ObsidianBacklinks<CR>",
        { desc = "[O]bsidian - [B]acklinks" })

      vim.o.conceallevel = 2 -- Hide links in normal mode, show links in insert mode.
    end
  }
}
