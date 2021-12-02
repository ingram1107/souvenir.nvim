local has_t, t = pcall(require, 'telescope')

if not has_t then
  error("Using souvenir.nvim's telescope utility require nvim-telescope/telescope.nvim")
end

local actions = require('telescope.actions')
local action_state = require('telescope.actions.state')
local finders = require('telescope.finders')
local pickers = require('telescope.pickers')
local previewers = require('telescope.previewers')
local entry_display = require('telescope.pickers.entry_display')
local conf = require('telescope.config').values
local souvenir = require('souvenir')
local fs_table = require('souvenir.fs_table')

local function gen_new_finder()
  return finders.new_table({
    results = fs_table:scandir(souvenir._session_path()),
    entry_maker = function(entry)
      local displayer = entry_display.create({
        seperator = " ",
        items = {
          { width = 50 },
        },
      })

      local function make_display(entry)
          return displayer({
            entry.value,
          })
      end

      return {
        value = entry,
        display = make_display,
        ordinal = entry,
        path = souvenir._session_path()
      }
    end
  })
end

-- TODO: need to have a way to somewhat execute source command on the target window
-- local function open_souvenir_session(prompt_bufnr)
--   local selection = action_state.get_selected_entry()
--   souvenir.restore_session(selection.value)
--   local current_picker = action_state.get_current_picker(prompt_bufnr)
--   current_picker:refresh(gen_new_finder(), { reset_prompt = true })
-- end

local function delete_souvenir_session(prompt_bufnr)
  local selection = action_state.get_selected_entry()
  souvenir.delete_session(selection.value)
  local current_picker = action_state.get_current_picker(prompt_bufnr)
  current_picker:refresh(gen_new_finder(), { reset_prompt = true })
end

local function souvenir_telescope(opts)
  opts = opts or {}

  pickers.new(opts, {
    prompt_title = "Session List",
    finder = gen_new_finder(),
    sorter = conf.generic_sorter(opts),
    attach_mappings = function(_, map)
      -- map("i", "<cr>", open_souvenir_session)
      -- map("n", "<cr>", open_souvenir_session)
      map("i", "<c-d>", delete_souvenir_session)
      map("n", "<c-d>", delete_souvenir_session)
      return true
    end,
  }):find()
end

return t.register_extension({
  exports = {
    souvenir = souvenir_telescope,
  },
})
