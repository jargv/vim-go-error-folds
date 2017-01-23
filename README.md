# vim-go-error-folds

Lets get one thing out of the way: Go error handling is
awesome. This plugin exists to make it even better.

This plugin uses vim's `foldmethod=expr` to create folds
around your error handling code.  You still write your go
code as before, but you can toggle the folds off and on.
You can think of this as a way to "zoom out" on your go
code, to get a 10,000 foot view, with error handling code
summarized.

## Installation

Vundle is a great way to go:
```vim
Plugin 'jargv/vim-go-error-folds'
```

TODO: add aditional installation instructions

## Usage

at the moment a single command is provided:
```vim
:ToggleGoErrorFolding
```

which you can create a keybinding for:
```vim
nnoremap <leader>;f :ToggleGoErrorFolding<cr>
```

This command saves and restores the previous values of
`foldmethod` and `foldexpr`
