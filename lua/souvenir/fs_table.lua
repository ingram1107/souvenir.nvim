local M = {}

function M:insert(file_name, type)
  if type == 'file' then
    local offset = string.find(file_name, '%.vim$')
    if offset ~= nil then
      file_name = string.sub(file_name, 1, offset-1)
    end

    table.insert(M, file_name)
  end
end

function M:is_empty()
  if #M == 0 then
    return true
  else
    return false
  end
end

function M:make_empty()
  for i, _ in ipairs(self) do
    M[i] = nil
  end
end

function M:scandir(p)
  M:make_empty()
  local iter = vim.loop.fs_scandir(p)

  local file_name, type = vim.loop.fs_scandir_next(iter)
  while file_name ~= nil do
    M:insert(file_name, type)
    file_name, type = vim.loop.fs_scandir_next(iter)
  end

  return vim.tbl_flatten(M)
end

function M:print()
  for i, file_name in ipairs(self) do
    print('    '..i..'. '..file_name)
  end
end

return M
