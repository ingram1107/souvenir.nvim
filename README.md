# souvenir.nvim
A Neovim plugin that manages Neovim sessions

## Requirement
Neovim 0.7+

## Installation
vim-plug

```viml
Plug 'ingram1107/souvenir.nvim'
```

packer

```lua
use {
  'ingram1107/souvenir.nvim',
}
```

## Usage

You could set-up your session path as follows:

```lua
require('souvenir').setup {
  session_path = '~/.config/nvim/sessions'
}
```

Or else the default session path would be set to a directory named `souvenirs`
in your system's standard data path. (`$XDG_DATA_HOME/nvim` if you are using
Linux, `~/AppData/Local/nvim-data` if you are using Windows)

Other settings such as `override` and `shada` are available too. Set `override`
to `true` will allow the behaviour of overriding an existing session to be the
default behaviour. Set `shada` to `true` will allow more information in the
current session to be stored such as command line history, contents of registers
and marks for files. (more details see `:h shada`) Defaults values are set as
below:

```lua
require('souvenir').setup {
  override = false,
  shada = true,
}
```

souvenir.nvim currently provides 4 functionalities: save Vim session, restore
Vim session, delete Vim session and list Vim sessions. Commands to call these 4
functionalities are shown as below:

```viml
:SouvenirSave[!]    " save session (`!` to override)
:SouvenirRestore
:SouvenirDelete     " accept multiple files
:SouvenirList
```

```lua
:lua require('souvenir').save_session{'souvenir'} -- don't override existing session file
:lua require('souvenir').save_session{'souvenir', true} -- override exisitng session file
:lua require('souvenir').restore_session('souvenir')
:lua require('souvenir').delete_session({ 'souvenir', 'memoir', 'nostalgic' })
:lua require('souvenir').list_session()
```

If option `override` is set to true, there should be no behavioural differences
between `:SouvenirSave` and `:SouvenirSave!` or their lua counterparts.

## Inspiration

[xolox/vim-session](https://github.com/xolox/vim-session)

## Todo
- [x] documentation
- [x] save session to a pre-configured location
- [x] restore session
- [x] delete session
  - [x] delete multiple sessions
- [x] list sessions
- [x] session name completion
- [x] interactive buffer (telescope)
- [x] cross-platform
  - [x] Windows
  - [x] Linux
  - [ ] macOS (waiting for someone to test)
  - [ ] BSD-variants (waiting for someone to test)
