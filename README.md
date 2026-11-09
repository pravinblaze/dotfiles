# Personal dotfiles

Install GNU Stow with `brew install stow` on macOS or your Linux package manager.
Install Neovim 0.12 or later, tmux, Zsh, and Oh My Zsh. Neovim installs
Tree-sitter parsers on startup and needs a C compiler, `curl`, `tar`, and
Tree-sitter CLI 0.26.1 or later (`brew install tree-sitter-cli` on macOS).
The Zsh package expects Oh My Zsh at
`~/.oh-my-zsh`. The custom theme is available as `my` in Oh My Zsh.

From the checkout root, preview the links:

```sh
stow --no-folding --target="$HOME" --simulate --verbose nvim tmux zsh scripts
```

If Stow reports conflicts, move the conflicting files to a backup location and
repeat the preview. Keep local files such as
`~/.config/nvim/lazy-lock.json` and `~/.config/tmux/plugins/` in place.
Once the preview succeeds, apply the links:

```sh
stow --no-folding --target="$HOME" nvim tmux zsh scripts
```

Open a new Zsh session to load the configuration. For tmux plugins, install TPM
at `~/.config/tmux/plugins/tpm` and press `Ctrl-a` then `I` in tmux.

The scripts are available on Zsh's PATH. `tspawn.sh` requires Bash 4 or later
(`brew install bash` on macOS). `tide.sh` uses tmux, Neovim, and `realpath`,
and launches Codex unless you pass `-nc`.

Edits to linked files are already in the checkout. To remove the links, run
`stow --no-folding --target="$HOME" --delete nvim tmux zsh scripts`
from the checkout root.
