# linear.nvim

Author: Vianney Gremmel

Linear navigation from inside vim.

## ⚠ This is a work in progress.


## Installation

Install with your favorite plugin manager.

Example with [folke/lazy.nvim]: 

```lua
use {
  'vianney-g/linear.nvim',
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

Until now the only use case is to fuzzy find issue to copy the attached branch name to the current buffer.
(more to come).


Fuzzy search for issues assigned to you:

```vim
:lua require'linear'.issues{assignee = 'me'}
```

Fuzzy search for issues belonging to a team:

```vim
:lua require'linear'.issues{team = 'TEAM'}
```

This will open a Telescope finder.

## Keybindings

Not configurable yet.

 - Press <CR> to copy the ticket identifier to the current buffer.
 - Press <C-b> to copy the branch name to the current buffer.

## TODO

 - [ ] Detect the current ticket from the current branch name.
  - [ ] Go to the ticket page.
  - [ ] Get the ticket information (title, description, etc.).
  - [ ] Update the current ticket
    - [ ] Change the status.
    - [ ] Assign to someone.
    - [ ] Add a comment.
 - [ ] Make the keybindings configurable.
 - [ ] Add others keybindings.
   - [ ] Go to the ticket page.
   - [ ] Checkout the branch.
 - [ ] Add other filters to the issues finder.
   - [ ] By status.
