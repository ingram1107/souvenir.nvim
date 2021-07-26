local M = {}

function M.is_dir_exist(dir)
  if vim.fn.isdirectory(dir) == 1 then
    return true
  end
  return false
end

function M.is_file_exist(file)
  if vim.fn.empty(vim.fn.glob(file)) ~= 1 and vim.fn.filereadable(vim.fn.glob(file)) == 1 then
    return true
  end
  return false
end

function M.create_dir_recur(path)
  if vim.loop.os_uname().version:match('Windows') then
    if os.execute('mkdir '..path) > 0 then
      vim.api.nvim_err_writeln('fatal: cannot create directory '..path)
    else
      vim.api.nvim_echo({{'souvenir: directory '..path..' successfully created', 'Normal'}}, true, {})
    end
  else
    if os.execute('mkdir -p '..path) > 0 then
      vim.api.nvim_err_writeln('fatal: cannot create directory '..path)
    else
      vim.api.nvim_echo({{'souvenir: directory '..path..' successfully created', 'Normal'}}, true, {})
    end
  end
end

return M
