# glass.nvim

> **Warning** This is in a very early state, do not try to use it.

Track, animate, move swap and resize windows with ease.

# Goals

## Plugin

- [ ] Window moving/swapping "modes" similar to WinShift
  - [ ] Multiselect - move/swap one window, or an entire frame all at once
- [ ] Layout management
  - [ ] Save and restore predefined layouts and sublayouts (neovim/neovim#24507)
- [ ] Flexible autoresizing
  - [ ] Equalize all windows - like <kbd>_<C-w_></kbd><kbd>=</kbd>, but animated and automated
  - [ ] Maximize current window
  - [ ] Keep current window at user-configured size
  - [ ] Golden ratio - keep the current window sized using the golden ratio, inspired by [`nvim-focus/focus.nvim`](https://github.com/nvim-focus/focus.nvim)

## API

Used to build the plugin's features, and exposed publicly for others to use.

- [ ] Maintain an up-to-date window layout tree
- [ ] Provide APIs for:
  - [ ] Manipulating windows and frames (rows / cols of windows)
  - [ ] Creating window layouts
  - [x] Animating arbitrary properties on windows
  - [ ] Saving and restoring layouts to/from disk
- [ ] Don't compromise performance
  - [ ] Update as little as possible
  - [ ] Update by difference / don't update nodes that aren't dirty
  - [x] Cache regularly-used objects
