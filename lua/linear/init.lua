local pathlib = require("plenary.path")
local with = require("plenary.context_manager").with
local open = require("plenary.context_manager").open

M = {}

local function get_conf_file()
  local config_root = pathlib.new(vim.fn.expand("$XDG_CONFIG_HOME"))

  if not config_root:is_dir() then
    if vim.fn.has("win32") > 0 then
      config_root = pathlib.new(vim.fn.expand("~/AppData/Local"))
    else
      config_root = pathlib.new(vim.fn.expand("~/.config"))
    end
  end

  if not config_root:is_dir() then
    print("Error: could not find config path")
    return
  end

  local config_dir = config_root / "linear_nvim"

  if not config_dir:exists() then
    config_dir:mkdir()
  end

  return config_dir / "credentials.json"
end

local function read_api_key()
  local conf_file = get_conf_file()
  if conf_file == nil or not conf_file:exists() then
    return nil
  end
  return with(open(conf_file, "r"), function(f)
    local content = f:read()
    return vim.fn.json_decode(content)["api_key"]
  end)
end

local function set_api_key(api_key)
  vim.g.linear_api_key = api_key
end

local function ask_api_key()
  -- Ask for api key and save it to credentials.json
  local api_key = vim.fn.input("Enter your Linear API key: ")
  local conf = { api_key = api_key }
  local conf_file = get_conf_file()
  if not conf_file then
    return
  end

  with(open(conf_file, "w"), function(f)
    f:write(vim.fn.json_encode(conf))
  end)
  return api_key
end

function M.reset()
  set_api_key(ask_api_key())
end

function M.setup(api_key)
  if api_key == nil then
    api_key = read_api_key()
  end

  if api_key == nil then
    api_key = ask_api_key()
  end

  set_api_key(api_key)
end

local function client()
  if not vim.g.linear_api_key then
    M.setup()
  end
  return require("linear.client"):new(vim.g.linear_api_key)
end

function M.issues(opts)
  opts = opts or {}
  local pickers = require "telescope.pickers"
  local finders = require "telescope.finders"
  local conf = require("telescope.config").values
  local previewers = require "telescope.previewers"
  local actions = require "telescope.actions"
  local action_state = require "telescope.actions.state"
  local issues = client():get_issues(opts)

  pickers.new(opts, {
    prompt_title = "Issues",
    finder = finders.new_table {
      results = issues,
      entry_maker = function(issue)
        return {
          value = issue,
          display = issue["identifier"] .. "  " .. issue["title"],
          ordinal = issue["identifier"] .. "  " .. issue["title"],
        }
      end,
    },
    previewer = previewers.new_buffer_previewer {
      title = "Description",
      define_preview = function(self, entry, status)
        if vim.api.nvim_buf_is_valid(self.state.bufnr) then
          local description = entry.value["description"]
          if description == vim.NIL then
            description = "No description"
          end
          local description_lines = {}
          for line in description:gmatch("[^\r\n]+") do
            table.insert(description_lines, line)
          end
          vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, description_lines)
          vim.api.nvim_buf_set_option(self.state.bufnr, "filetype", "markdown")
          -- set buffer line breaks to wrap long lines
          vim.api.nvim_win_set_option(self.state.winid, "wrap", true)
        end
      end,
    },
    sorter = conf.generic_sorter(opts),
    attach_mappings = function(prompt_bufnr, map)
      map("i", "<CR>", function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry(prompt_bufnr)
        vim.api.nvim_put({ selection.value["branchName"] }, "", false, true)
      end)
      return true
    end,
  }):find()
end

return M
