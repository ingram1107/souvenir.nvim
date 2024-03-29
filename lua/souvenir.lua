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
local fs_table = require('souvenir.fs_table')
local utils = require('souvenir.utils')

if vim.version().minor < 7 then
  vim.api.nvim_err_writeln('fatal: souvenir: require Neovim version 0.7+')
  return
end

local SHADA_PATH = (function()
  if vim.loop.os_uname().version:match('Windows') then
    return vim.fn.stdpath('data') .. '\\shada\\'
  else
    return vim.fn.stdpath('data') .. '/shada/'
  end
end)()
local session_path = nil
local override_opt = false
local shada = true

local function session_path_init(path)
  if path == '' or path == nil then
    if vim.loop.os_uname().version:match('Windows') then
      path = vim.fn.stdpath('data') .. '\\souvenirs\\'
    else
      path = vim.fn.stdpath('data') .. '/souvenirs/'
    end

    if utils.is_dir_exist(path) == false then
      utils.create_dir_recur(path)
    end
  else
    path = vim.fn.expand(path)
    if utils.is_dir_exist(path) == false then
      utils.create_dir_recur(path)
    end
  end

  return path
end

local M = {}

function M._session_path()
  return session_path
end

function M.save_session(args)
  setmetatable(args, { __index = { override = false } })
  local session_file = args[1] .. '.vim' or args.session .. '.vim'
  local session_shada = args[1] .. '.shada' or args.session .. '.shada'
  local override = args[2] or args.override or override_opt

  if override == false and utils.is_file_exist(session_path .. session_file) == false then
    vim.cmd('mksession ' .. session_path .. session_file)
    if shada ~= false then
      vim.cmd('wshada! ' .. SHADA_PATH .. session_shada)
    end
  elseif override == true then
    vim.cmd('mksession! ' .. session_path .. session_file)
    if shada ~= false then
      vim.cmd('wshada! ' .. SHADA_PATH .. session_shada)
    end
  else
    vim.api.nvim_err_writeln(
      'fatal: ' .. session_file .. ' exists! Add `!` or pass second arg as `true` to `save_session` to override'
    )
  end
end

function M.restore_session(session)
  local session_file = session .. '.vim'
  local session_shada = session .. '.shada'

  if utils.is_file_exist(session_path .. session_file) == true then
    vim.cmd('source ' .. session_path .. session_file)
    if shada ~= false then
      vim.cmd('rshada! ' .. SHADA_PATH .. session_shada)
    end
  else
    vim.api.nvim_err_writeln('fatal: ' .. session_file .. ' does not exist')
  end
end

function M.list_session()
  if utils.is_dir_exist(session_path) == true then
    fs_table:scandir(session_path)
    if not fs_table:is_empty() then
      print('Session List:')
      print(' ')
      fs_table:print()
    else
      vim.api.nvim_echo({ { 'souvenir: no session has been stored', 'Normal' } }, true, {})
    end
  else
    vim.api.nvim_echo({ { 'souvenir: session directory does not exist', 'Normal' } }, true, {})
  end
end

function M.delete_session(sessions)
  for _, session in ipairs(sessions) do
    local session_file = session .. '.vim'
    local session_shada = session .. '.shada'

    local ok, err = os.remove(session_path .. session_file)
    if not ok then
      vim.api.nvim_err_writeln('fatal: ' .. err)
    end

    if shada ~= false then
      ok, err = os.remove(SHADA_PATH .. session_shada)
      if not ok then
        vim.api.nvim_err_writeln('fatal: ' .. err)
      end
    end

    if ok then
      vim.api.nvim_echo({ { 'souvenir: session `' .. session .. '` deleted', 'Normal' } }, true, {})
    end
  end
end

function M.record_session(session_name)
  vim.api.nvim_create_augroup('SouvenirRecordLayout', { clear = true })
  vim.api.nvim_create_autocmd('BufEnter', {
    group = 'SouvenirRecordLayout',
    pattern = '*',
    callback = function()
      M.save_session({ session_name, true })
    end,
    desc = 'save session upon layout changes',
  })
  vim.api.nvim_create_augroup('SouvenirRecordBeforeLeave', { clear = true })
  vim.api.nvim_create_autocmd('VimLeavePre', {
    group = 'SouvenirRecordBeforeLeave',
    pattern = '*',
    callback = function()
      M.save_session({ session_name, true })
    end,
    desc = 'save session just before leaving',
  })
end

function M.stop_record_session()
  vim.api.nvim_del_augroup_by_name('SouvenirRecordLayout')
  vim.api.nvim_del_augroup_by_name('SouvenirRecordBeforeLeave')
end

function M.is_session_exists(name)
  local sessions = fs_table:scandir(session_path)
  vim.print(sessions)

  for _, session in ipairs(sessions) do
    if name == session then
      return true
    end
  end

  return false
end

function M.setup(cfg_tbl)
  local sp = cfg_tbl['session_path']

  session_path = session_path_init(sp)

  if cfg_tbl['override'] ~= nil then
    override_opt = cfg_tbl['override']
  end
  if cfg_tbl['shada'] ~= nil then
    shada = cfg_tbl['shada']
  end

  local function session_name_completion(lead, cmd_line, cursor_pos)
    local file_list = fs_table:scandir(session_path)
    return file_list
  end

  vim.api.nvim_create_user_command('SouvenirSave', function(args)
    M.save_session({ args.args, args.bang })
  end, { nargs = 1, bang = true, complete = session_name_completion })
  vim.api.nvim_create_user_command('SouvenirRestore', function(args)
    M.restore_session(args.args)
  end, { nargs = 1, complete = session_name_completion })
  vim.api.nvim_create_user_command('SouvenirDelete', function(args)
    M.delete_session(args.fargs)
  end, { nargs = '+', complete = session_name_completion })
  vim.api.nvim_create_user_command('SouvenirRecord', function(args)
    M.record_session(args.args)
  end, { nargs = 1, complete = session_name_completion })
  vim.api.nvim_create_user_command('SouvenirStopRecord', M.stop_record_session, { nargs = 0 })
  vim.api.nvim_create_user_command('SouvenirList', M.list_session, { nargs = 0 })
end

return M
