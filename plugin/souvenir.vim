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
  let session_name = substitute(base_fname, '.vim', '', '')
  return session_name
endfunc

func souvenir#completion(lead, cmd_line, cusor_pos) abort
  let file_list = luaeval('require("plenary.scandir").scan_dir(require("souvenir")._session_path(), { depth = 1 })')
  let file_list = map(file_list, {_, val -> s:session_name(val)})
  return file_list
endfunc

command! -nargs=1 -complete=customlist,souvenir#completion SouvenirSave lua require('souvenir').save_session{"<args>"}
command! -nargs=1 -complete=customlist,souvenir#completion SouvenirSaveForce lua require('souvenir').save_session{"<args>", true}
command! -nargs=1 -complete=customlist,souvenir#completion SouvenirRestore lua require('souvenir').restore_session("<args>")
command! -nargs=1 -complete=customlist,souvenir#completion SouvenirDelete lua require('souvenir').delete_session("<args>")
command! -nargs=0 SouvenirList lua require('souvenir').list_session()
