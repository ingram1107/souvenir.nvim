if !has('nvim-0.5.0') || exists("g:loaded_souvenir")
  finish
endif

let g:loaded_souvenir=1

func s:base_file(path)
  let base_fname = substitute(a:path, '.*/', '', '')
  return base_fname
endfunc

func s:session_name(path)
  let base_fname = s:base_file(a:path)
  let session_name = substitute(base_fname, '\.vim$', '', '')
  return session_name
endfunc

func souvenir#completion(lead, cmd_line, cusor_pos) abort
  let session_path = luaeval('require("souvenir")._session_path()')
  let file_list = luaeval('require("souvenir.fs_table"):scandir(_A)', session_path)
  let file_list = map(file_list, {_, val -> s:session_name(val)})
  return file_list
endfunc

command! -nargs=1 -bang -complete=customlist,souvenir#completion SouvenirSave lua require('souvenir').save_session_wrap("<args>", "<bang>")
command! -nargs=1 -complete=customlist,souvenir#completion SouvenirRestore lua require('souvenir').restore_session("<args>")
command! -nargs=+ -complete=customlist,souvenir#completion SouvenirDelete lua require('souvenir').delete_session(<f-args>)
command! -nargs=0 SouvenirList lua require('souvenir').list_session()
