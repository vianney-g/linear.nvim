local conf = require "linear.conf"

local function client()
  if not vim.g.linear_api_key then
    conf.setup()
  end
  return require("linear.client"):new(vim.g.linear_api_key)
end

local function issues(opts)
  opts = opts or {}
  local pickers = require "telescope.pickers"
  local finders = require "telescope.finders"
  local telescope_conf = require("telescope.config").values
  local previewers = require "telescope.previewers"
  local actions = require "telescope.actions"
  local action_state = require "telescope.actions.state"
  local fetched_issues = client():get_issues(opts)

  pickers.new(opts, {
    prompt_title = "Issues",
    finder = finders.new_table {
      results = fetched_issues,
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
    sorter = telescope_conf.generic_sorter(opts),
    attach_mappings = function(prompt_bufnr, map)
      map("i", "<CR>", function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry(prompt_bufnr)
        vim.api.nvim_put({ selection.value["identifier"] }, "", false, true)
      end)
      map("i", "<C-B>", function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry(prompt_bufnr)
        vim.api.nvim_put({ selection.value["branchName"] }, "", false, true)
      end)
      return true
    end,
  }):find()
end

return {
  issues = issues,
  setup = conf.setup,
}
