## Install

You can install this configuration automatically using the following curl command:

```bash
curl -fsSL https://raw.githubusercontent.com/tomowang/tomo.nvim/main/install.sh | bash
```

Alternatively, if you have already cloned the repository locally, run the installer directly:

```bash
./install.sh
```

### Script Features
- **Compatibility**: Runs seamlessly on macOS and Linux.
- **Dependency Checking**: Verifies required (`git`, `neovim >= 0.8.0`) and recommended (`gcc`/`clang`, `make`, `ripgrep`, `fd`) dependencies and gives commands to install them if missing.
- **Smart Updates & Backups**: 
  - If `~/.config/nvim` is already a clone of `tomo.nvim`, it performs a safe update (`git pull`).
  - If another directory exists, it prompts to safely back it up (`~/.config/nvim_backup_<timestamp>`) and overwrite it.
- **Automated Bootstrap**: Offers to pre-install and build plugins headlessly (`lazy.nvim`, treesitter parsers, `fzf-native` compilation) so it's ready to use instantly.

## Shortcuts

> mapleader: Spacebar (<Space>)  as defined by lazy

* Change Root Interactively: <kbd>Ctrl</kbd> + <kbd>]</kbd>
* Quick jump to charactor: <kbd>Space</kbd> + <kbd>f</kbd>

