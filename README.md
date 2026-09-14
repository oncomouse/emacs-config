# oncomouse's Emacs Configuration

My personal [GNU Emacs](https://www.gnu.org/software/emacs/) configuration,
tuned for people who live in **Vim**, **Neovim** and **Vi**.

It is built around [`evil`](https://evil.readthedocs.io/) and the surrounding
evil ecosystem, so the modal editing you already know works out of the box,
while Emacs' own machinery — `Vertico`, `Consult`, `Corfu`, `Orderless`,
`Embark`, `Marginalia`, `which-key`, `lsp-mode`, `tree-sitter`, `org`, `magit`
and friends — gives you a modern, batteries-included editing environment.

The whole thing is driven by the built-in [`use-package`](https://github.com/jwiegley/use-package)
macro on top of Emacs' built-in package manager, [`package.el`](https://www.gnu.org/software/emacs/manual/html_node/emacs/Packages.html).
No external bootstrap framework: packages come from MELPA / GNU ELPA via
`:ensure`, and the handful that are not published to an archive are installed
straight from their source repository with the built-in
[`package-vc`](https://www.gnu.org/software/emacs/manual/html_node/emacs/VC-Packages.html).

> This is **my** configuration, not a distribution. It is opinionated and meant
> to be a *starting point* you fork and bend to your own taste — not a framework
> you configure from the outside. It happens to be a good one for Vim/Neovim
> users who want to drop into Emacs (TUI or GUI, inside `tmux`/`Zellij`, next to
> `yazi`/`starship`/`lazygit`) without relearning their editor.

**Emacs 30.1+** · GPL-2.0-or-later

---

## Table of contents

- [Requirements](#requirements)
- [Installation](#installation)
- [Maintaining packages](#maintaining-packages)
- [Available commands](#available-commands)
- [Contributing](#contributing)
- [Credits](#credits)

## Requirements

- **Emacs >= 30.1**, ideally built with **native compilation** (`libgccjit`)
  and **tree-sitter** (`libtree-sitter`) — this config leans heavily on
  `tree-sitter`, and native compilation is enabled here by default. The `:vc`
  keyword and `package-vc` are built into Emacs 30+, so older builds are not
  supported.
- [`git`](https://git-scm.com/) — `package-vc` clones the source-only packages
  and several features shell out to it.
- Optionally [`pixi`](https://pixi.sh/) — `ek/first-install` runs `pixi install`
  to provision Python tooling for `gptel`. Without it that step is skipped.
- Check your version:

```bash
emacs --version
```

## Installation

> If you already have a config in `~/.emacs.d`, back it up first:
> `mv ~/.emacs.d ~/.emacs.d.backup`. Also clear any stray
> `~/.emacs`, `~/.config/emacs`, `~/.config/doom`, etc.

1. **Clone the repository** into `~/.emacs.d`:

```bash
git clone https://github.com/oncomouse/emacs-config.git ~/.emacs.d
```

1. **Run the setup.** First launch installs everything (MELPA packages, the
   `package-vc` source packages, tree-sitter grammars, Nerd Fonts) via the
   helper defined in `init.el`:

```bash
emacs -nw --eval "(ek/first-install)"
```

   The simplest path is usually just to launch Emacs once and let the bootstrap
   install packages on load; `ek/first-install` additionally does the
   tree-sitter / fonts / pixi steps. You can also run the provided script, which
   wipes `~/.emacs.d/elpa` and reinstalls from scratch:

```bash
cd ~/.emacs.d && ./ek-reinstall.sh
```

   **What to expect on first boot:** MELPA packages are downloaded and
   byte-compiled, the `package-vc` packages are `git clone`d and compiled, and
   (with native compilation enabled) `.eln` files are generated in the
   background. This is normal and only happens once per package.

1. **Start using it:**

```bash
emacs        # GUI
emacs -nw    # terminal
```

   To always open in the terminal, add `alias emacs='emacs -nw'` to your
   `.bashrc` / `.zshrc`.

**Tips**

- The **leader key is `SPC`**; `which-key` pops up to help you discover bindings.
- `SPC h i` opens the Emacs info manual; `SPC h k` describes a key;
  `SPC h f` / `SPC h v` describe functions / variables.

**Troubleshooting**

- Check the `*Messages*` buffer (`SPC b b`, then look for `*Messages*`) for
  install/compile errors.
- **`Error loading autoloads: (void-function define-compilation-mode)`** means a
  package put `;;;###autoload` on a *non-`defun`* form — `typst-ts-mode` tags a
  `define-compilation-mode` call, and `loaddefs-generate` copies such forms
  verbatim into the generated autoloads file. Evaluating that copy requires
  `compile.el` to be loaded already; otherwise `package-activate` aborts the
  rest of the file and silently drops every autoload that follows it, including
  `typst-ts-mode` itself and its `.typ` entry in `auto-mode-alist`. `init.el`
  registers an autoload stub for the macro **before** `(package-initialize)` to
  prevent this — if the message comes back, that stub has drifted below
  `(package-initialize)`.

## Maintaining packages

Packages live in two places and are updated differently. Everything below runs
inside Emacs with `M-x` (or `SPC SPC` / `M-x` via `vertico`).

| Kind                | How it's installed          | How to update                        |
| ------------------- | --------------------------- | ------------------------------------ |
| **Archive** packages | `:ensure t` from MELPA/ELPA | `package-upgrade-all`                |
| **Source** packages  | `:vc (…)` from a git repo    | `ek-vc-upgrade-stale`                |

### Refresh the archive list

Before upgrading, fetch the newest package list from MELPA/ELPA:

```
M-x package-refresh-contents
```

### Update MELPA / ELPA (`:ensure`) packages

Browse and pick, upgrading everything upgradable with `U` then `x`:

```
M-x list-packages
```

…or upgrade in one shot:

```
M-x package-upgrade-all        # everything
M-x package-upgrade            # one package (prompts)
```

### Update source (`package-vc`) packages

These are the few packages installed from git rather than an archive
(`typst-ts-mode`, `svelte-ts-mode`, `md-mode`, `targets`, `lsp-biome`,
`rainbow-mode`, `modus-catppuccin`, `gptel-preset-collection`,
`gptel-openrouter`, `llm-tool-collection`, …):

Prefer the helpers from `lisp/init-vc-maintenance.el`, which fast-forward each
checkout and rebuild it:

```
M-x ek-vc-status           # what each :vc package is ACTUALLY checked out at
M-x ek-vc-upgrade-stale    # fetch + merge --ff-only + rebuild everything behind
```

`ek-vc-upgrade-stale` never merges, resets or stashes: it refuses any checkout
that is not fast-forwardable or that carries tracked modifications, and reports
why. The same work also runs automatically on an idle timer at most once every
`ek-vc-upgrade-interval-days` days (default 7) — set `ek-vc-auto-upgrade` to
`nil` to keep it strictly manual. The last pass is stamped in
`~/.emacs.d/.vc-upgrade.stamp`; delete that file to force one.

The built-in equivalents still exist, but read the caveats first:

```
M-x package-vc-upgrade-all   # pull + rebuild every :vc package
M-x package-vc-upgrade       # just one (prompts)
M-x package-vc-log-incoming  # preview what a pull would bring
```

**Why the helpers exist.** `use-package` installs a `:vc` package exactly once:
`use-package-vc-install` is wrapped in `(unless (package-installed-p name) ...)`,
so nothing in the declaration ever refreshes an installed package afterwards.
And `use-package-vc-prefer-newest` (set in `init.el`) only decides which
revision a *fresh* install resolves to — it is not an update policy. Without it,
a `:vc` install resolves to `:last-release`, which `package-vc` defines as
**the last commit that touched the package's `Version:` header**. For upstreams
that add features without re-versioning, that is arbitrarily stale: for
`llm-tool-collection` it was the empty "package scaffolding" commit, so the
package loaded cleanly and defined nothing at all. The release pin also leaves
the checkout on a **detached HEAD**, where a later `git pull` fails outright
with *"You are not currently on a branch."*

Two rules follow:

- Keep `use-package-vc-prefer-newest t`. Use `:rev` only for a deliberate pin
  (prefer a tag or a SHA), and `:branch` only for a genuinely non-default
  branch — note that `:branch` does **not** protect you from the release pin.
- Trust `M-x ek-vc-status` over your init file. A `:rev` naming a ref that does
  not exist is silently ignored by `vc-git-clone`: no error, you just get
  whatever the default branch happens to be.

### Byte-compiling and native compilation

- **Normally you do nothing.** On install, `package.el` byte-compiles each
  package, and this config turns on **native compilation**, so packages are
  ahead-of-time compiled to `.eln` automatically (deferred, in the background).
- Upgrading via `list-packages` / `package-upgrade-all` /
  `package-vc-upgrade-all` recompiles the updated packages for you.
- **Force a rebuild** of a source package: `M-x package-vc-rebuild`.
- **Recompile the config's own Elisp** in `~/.emacs.d/lisp` (loaded as source,
  *not* managed by `package.el`):

  ```
  M-x byte-recompile-directory      # enter ~/.emacs.d/lisp, answer yes
  ```

  …or a single file with `M-x byte-compile-file`.

- Native `.eln` output is cached in `~/.emacs.d/eln-cache/` (and
  `~/.cache/emacs/eln-cache/`). Deleting that cache just makes Emacs regenerate
  it on the next start.

### Removing leftovers

```
M-x package-autoremove         # delete deps nothing in your config needs anymore
M-x package-delete             # remove one specific package
```

Run `package-autoremove` after dropping packages from the config.

### A routine that covers everything

```
1. cd ~/.emacs.d && git pull          # config changes
2. M-x package-refresh-contents
3. M-x package-upgrade-all            # MELPA / ELPA
4. M-x ek-vc-upgrade-stale            # source packages (ff-only + rebuild)
5. M-x package-autoremove
6. restart Emacs
```

To start completely from scratch (wipe and reinstall all packages), close Emacs
and run `./ek-reinstall.sh` from `~/.emacs.d`.

## Available commands

| Keybinding     | Action                                    |
| -------------- | ----------------------------------------- |
| `SPC`          | Leader key                                |
| `C-d`          | Scroll down                               |
| `C-u`          | Scroll up                                 |
| `<leader> s f` | Find file                                 |
| `<leader> s g` | Grep                                      |
| `<leader> s G` | Git grep                                  |
| `<leader> s r` | Ripgrep                                   |
| `<leader> s h` | Consult info                              |
| `<leader> /`   | Consult line                              |
| `<leader> x x` | Consult Flymake                           |
| `] d`          | Next Flymake error                        |
| `[ d`          | Previous Flymake error                    |
| `<leader> x d` | Dired                                     |
| `<leader> x j` | Dired jump                                |
| `<leader> x f` | Find file                                 |
| `] c`          | Next diff hunk                            |
| `[ c`          | Previous diff hunk                        |
| `<leader> x d` | Dired                                     |
| `<leader> g g` | Open Magit status                         |
| `<leader> g l` | Show current log                          |
| `<leader> g d` | Show diff for current file                |
| `<leader> g D` | Show diff for hunk                        |
| `<leader> g b` | Annotate buffer with version control info |
| `] b`          | Switch to next buffer                     |
| `[ b`          | Switch to previous buffer                 |
| `<leader> b i` | Consult buffer list                       |
| `<leader> b b` | Open Ibuffer                              |
| `<leader> b d` | Kill current buffer                       |
| `<leader> b s` | Save buffer                               |
| `<leader> b l` | Consult buffer                            |
| `<leader>SPC`  | Consult buffer                            |
| `<leader> p b` | Consult project buffer                    |
| `<leader> p p` | Switch project                            |
| `<leader> p f` | Find file in project                      |
| `<leader> p g` | Find regexp in project                    |
| `<leader> p k` | Kill project buffers                      |
| `<leader> p D` | Dired for project                         |
| `P`            | Yank from kill ring                       |
| `<leader> .`   | Embark act                                |
| `<leader> u`   | Undo tree visualize                       |
| `<leader> h m` | Describe current mode                     |
| `<leader> h f` | Describe function                         |
| `<leader> h v` | Describe variable                         |
| `<leader> h k` | Describe key                              |
| `] t`          | Go to next tab                            |
| `[ t`          | Go to previous tab                        |
| `<leader> m p` | Format with Prettier                      |
| `<leader> c a` | Execute code action                       |
| `<leader> r n` | Rename symbol                             |
| `gI`           | Find implementation                       |
| `<leader> l f` | Format buffer via LSP                     |
| `K`            | Show hover documentation                  |
| `gcc`          | Comment/uncomment current line            |
| `gc`           | Comment/uncomment selected region         |
| `gd`           | Goto definitions                          |
| `gr`           | Goto references                           |

…and a lot more, discoverable with `which-key`.

## Contributing

This is my personal, opinionated config. Issues and pull requests are welcome
and will be read carefully, but I make no promises about accepting changes —
decisions here reflect how I want *my* editor to behave. If something is broken,
though, do open an issue.

## Credits

This configuration began as a fork of
[**Emacs-Kick**](https://github.com/LionyxML/emacs-kick) by Rahul Martim
Juliato, and has since diverged substantially (notably: moving off `straight.el`
onto built-in `package.el` + `package-vc`). Thanks to Rahul for the foundation.
