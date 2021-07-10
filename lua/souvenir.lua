--[[
  souvenir.nvim   Nvim plugin that manages Neovim sessions
  Copyright (C) 2021  Little Clover 
  This program is free software: you can redistribute it and/or modify 
  it under the terms of the GNU General Public License as published by 
  the Free Software Foundation, either version 3 of the License, or 
  (at your option) any later version. 
  This program is distributed in the hope that it will be useful, 
  but WITHOUT ANY WARRANTY; without even the implied warranty of 
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the 
  GNU General Public License for more details. 
  You should have received a copy of the GNU General Public License 
  along with this program.  If not, see <https://www.gnu.org/licenses/>
--]]
local scan = require('plenary').scandir

if vim.version().minor < 5 then
  vim.api.nvim_err_writeln('fatal: souvenir: require Neovim version 0.5+')
  return
end

local SHADA_PATH = (function()
  if os.getenv('XDG_DATA_HOME') ~= nil then
    return os.getenv('XDG_DATA_HOME')..'/nvim/shada/'
  else
    return os.getenv('HOME')..'.local/share/nvim/shada/'
  --[[
    TODO:
        add window path support
          - littleclover 2021-07-03 11:59:47 PM +0800
  --]]
  end
end)()
local session_path = nil
local override_opt = false
local shada        = true

local function set_session_path(path)
  session_path = vim.fn.expand(path)
end

local function is_dir_exist(dir)
  if vim.fn.isdirectory(dir) == 1 then
    return true
  end
  return false
end

local function is_file_exist(file)
  if vim.fn.empty(vim.fn.glob(file)) ~= 1 and vim.fn.filereadable(vim.fn.glob(file)) == 1 then
    return true
  end
  return false
end

local function create_dir_recur(path)
  if os.execute('mkdir -p '..path) > 0 then
    vim.api.nvim_err_writeln('fatal: cannot create directory '..path)
  else
    vim.api.nvim_echo({{'souvenir: directory '..path..' successfully created', 'Normal'}}, true, {})
  end
end

local function session_path_init()
  if session_path == '' or session_path == nil then
    if os.getenv('XDG_DATA_HOME') ~= nil then
      session_path = os.getenv('XDG_DATA_HOME')..'/nvim/souvenirs/'
      if is_dir_exist(session_path) == false then
        create_dir_recur(session_path)
      end
    else
      session_path = os.getenv('HOME')..'/.local/share/nvim/souvenirs/'
      if is_dir_exist(session_path) == false then
        create_dir_recur(session_path)
      end
    end
    --[[
    TODO:
    add window path support
    - littleclover 2021-07-03 11:59:47 PM +0800
    --]]
  else
    if is_dir_exist(session_path) == false then
      create_dir_recur(session_path)
    end
  end

  return session_path
end

local function save_session(args)
  setmetatable(args, { __index = { override = false } })
  local session_file = args[1]..'.vim' or args.session..'.vim'
  local session_shada = args[1]..'.shada' or args.session..'.shada'
  local override = args[2] or args.override or override_opt

  session_path = session_path_init()

  if override == false and is_file_exist(session_path..session_file) == false then
    vim.api.nvim_exec('mksession '..session_path..session_file, false)
    if shada ~= false then
      vim.api.nvim_exec('wshada! '..SHADA_PATH..session_shada, false)
    end
  elseif override == true then
    vim.api.nvim_exec('mksession! '..session_path..session_file, false)
    if shada ~= false then
      vim.api.nvim_exec('wshada! '..SHADA_PATH..session_shada, false)
    end
  else
    vim.api.nvim_err_writeln('fatal: '..session_file..' exists! pass second arg as `true` to `save_session` to override the file')
  end
end

local function restore_session(session)
  local session_file = session..'.vim'
  local session_shada = session..'.shada'

  session_path = session_path_init()

  if is_file_exist(session_path..session_file) == true then
    vim.api.nvim_exec('source '..session_path..session_file, false)
    if shada ~= false then
      vim.api.nvim_exec('rshada! '..SHADA_PATH..session_shada, false)
    end
  else
    vim.api.nvim_err_writeln('fatal: '..session_file..' does not exist')
  end
end

local function list_session()
  session_path = session_path_init()

  if is_dir_exist(session_path) == true then
    local file_list_tbl = scan.scan_dir(session_path, { depth = 1 })
    print('Session List:')
    print(' ')
    for i, file in ipairs(file_list_tbl) do
      local base_file = vim.fn.substitute(file, '.*/\\ze', '', '')
      print('    '..i..'. '..vim.fn.substitute(base_file, '\\.vim', '', ''))
    end
  else
    vim.api.nvim_echo({{'souvenir: no session has been stored', 'Normal'}}, true, {})
  end
end

local function delete_session(session)
  local session_file = session..'.vim'
  local session_shada = session..'.shada'

  session_path = session_path_init()

  if is_file_exist(session_path..session_file) == true then
    if os.execute('rm '..session_path..session_file) > 0 then
      vim.api.nvim_err_writeln('fatal: cannot delete'..session_file..', check your permission!')
    end
    if shada ~= false then
      if os.execute('rm '..SHADA_PATH..session_shada) >0 then
        vim.api.nvim_err_writeln('fatal: cannot delete'..session_shada..', check your permission!')
      end
    end
    vim.api.nvim_echo({{'souvenir: session `'..session..'` deleted', 'Normal'}}, true, {})
  else
    vim.api.nvim_err_writeln('fatal: '..session_file..' does not exist')
  end
end

local function setup(cfg_tbl)
  local sp = cfg_tbl['session_path']

  if sp ~= nil and sp ~= '' then
    set_session_path(sp)
  end

  if cfg_tbl['override'] ~= nil then
    override_opt = cfg_tbl['override']
  end

  if cfg_tbl['shada'] ~= nil then
    shada = cfg_tbl['shada']
  end
end

return {
  save_session    = save_session,
  restore_session = restore_session,
  delete_session  = delete_session,
  list_session    = list_session,
  setup           = setup,
}
