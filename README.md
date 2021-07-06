# souvenir.nvim
A Neovim plugin that manages Neovim sessions

## Requirement
Neovim 0.5+

[plenary.nvim](https://github.com/nvim-lua/plenary.nvim)

## Installation
vim-plug

```viml
Plug 'ingram1107/souvenir.nvim'
Plug 'nvim-lua/plenary.nvim'
```

packer

```lua
use {
  'ingram1107/souvenir.nvim',
  requires = 'nvim-lua/plenary.nvim',
}
```

## Usage

You could set-up your session path as follows:

```lua
require('souvenir').setup {
  session_path = '~/.config/nvim/sessions/' -- a backslash is needed
}
```

Or else the default session path would be set to
`$XDG_DATA_HOME/nvim/souvenirs/` or `$HOME/.local/share/nvim/souvenirs/`
according to your system environment variables. Currently, this plugin only
support Linux path. (Do not work in Windows, may not work in macOS and
BSD-variants)

souvenir.nvim currently provides 4 functionalities: save Vim session, restore
Vim session, delete Vim session and list Vim sessions. Commands to call these 4
functionalities are shown as below:

```vimL
:lua require('souvenir').save_session{'souvenir'} " don't override existing
session file
:lua require('souvenir').save_session{'souvenir', true} " override exisitng
session file
:lua require('souvenir').restore_session('souvenir')
:lua require('souvenir').delete_session('souvenir')
:lua require('souvenir').list_session()
```

## Inspiration

[xolox/vim-session](https://github.com/xolox/vim-session)

## Todo
- [ ] documentation
- [x] save session to a pre-configured location
- [x] restore session
- [x] delete session
  - [ ] delete multiple sessions
- [x] list sessions
- [ ] interactive buffer?
- [ ] cross-platform
  - [ ] Windows
  - [x] Linux
  - [ ] macOS
  - [ ] BSD-variants
