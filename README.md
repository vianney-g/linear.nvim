# linear.nvim

Author: Vianney Gremmel

Linear navigation from inside vim.

## ⚠ This is a work in progress.


## Installation

Install with your favorite plugin manager.

Example with [folke/lazy.nvim]: 

```lua
use {
  'vianney.g/linear.nvim',
  requires = {
    'nvim-lua/plenary.nvim',
    'nvim-telescope/telescope.nvim',
  },
  config = function()
    require'linear'.setup()
  end
}
```

The call to `setup()` will prompt you for your Linear API key at the first call.

## Usage

Fuzzy search for issues assigned to you:

```vim
:lua require'linear'.issues{assignee = 'me'}
```

Fuzzy search for issues belonging to a team:

```vim
:lua require'linear'.issues{team = 'TEAM'}
```
