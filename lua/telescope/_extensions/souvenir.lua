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
        seperator = ' ',
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
        path = souvenir._session_path(),
      }
    end,
  })
end

local function open_souvenir_session(prompt_bufnr)
  local selection = action_state.get_selected_entry()
  actions.close(prompt_bufnr)
  souvenir.restore_session(selection.value)
end

local function delete_souvenir_session(prompt_bufnr, selection)
  souvenir.delete_session({ selection.value })
  local current_picker = action_state.get_current_picker(prompt_bufnr)
  current_picker:refresh(gen_new_finder(), { reset_prompt = true })
end

local function souvenir_telescope(opts)
  opts = opts or {}

  pickers.new(opts, {
    prompt_title = 'Session List',
    finder = gen_new_finder(),
    sorter = conf.generic_sorter(opts),
    attach_mappings = function(prompt_bufnr, map)
      actions.select_default:replace(open_souvenir_session)
      local current_picker = action_state.get_current_picker(prompt_bufnr)
      map('i', '<c-d>', function()
        for _, selection in ipairs(current_picker:get_multi_selection()) do
          delete_souvenir_session(prompt_bufnr, selection)
        end
      end)
      map('n', '<c-d>', function()
        for _, selection in ipairs(current_picker:get_multi_selection()) do
          delete_souvenir_session(prompt_bufnr, selection)
        end
      end)
      return true
    end,
  }):find()
end

return t.register_extension({
  exports = {
    souvenir = souvenir_telescope,
  },
})
