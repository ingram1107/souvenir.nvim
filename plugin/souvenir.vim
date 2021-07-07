if !has('nvim-0.5.0') || exists("g:loaded_souvenir")
  finish
endif

let g:loaded_souvenir=1

command! -nargs=1 SouvenirSave lua require('souvenir').save_session{"<args>"}
command! -nargs=1 SouvenirSaveForce lua require('souvenir').save_session{"<args>", true}
command! -nargs=1 SouvenirRestore lua require('souvenir').restore_session("<args>")
command! -nargs=1 SouvenirDelete lua require('souvenir').delete_session("<args>")
command! -nargs=0 SouvenirList lua require('souvenir').list_session()
