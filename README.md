<a name="readme-top"></a>

<h3 align="center">kak-wl-clipboard</h3>

  <p align="center">
    wl-clipboard integration for Kakoune text editor
    <br />
    <br />
    <a href="https://github.com/postsolar/kak-wl-clipboard/issues">report a bug</a>
    ·
    <a href="https://github.com/postsolar/kak-wl-clipboard/issues">request a feature</a>
  </p>
</div>


## About The Project

This plugin provides Kakoune integration with [`wl-clipboard`](https://github.com/bugaevc/wl-clipboard) copy/paste utilities for Wayland.
It operates on all available registers, making it possible to copy a given Kakoune register to system or primary clipboard, or set a register to the value of system or primary clipboard.

<p align="right"><a href="#readme-top">back to top</a></p>


## Getting Started


### Prerequisites

Runtime dependencies include, obviously, `wl-copy` as well as some `coreutils`. The plugin relies on `/usr/bin/env sh` pointing to Dash or other compatible shell.

### Installation

#### With Nix flakes

Import the flake exported by this repo:

```nix
# flake.nix
{

  inputs = {
    …
    kak-wl-clipboard = {
      url = "github:postsolar/kak-wl-clipboard";
      inputs.nixpgs.follows = "nixpkgs";
    };
    …
  }

  outputs = inputs@{ …, kak-wl-clipboard }:
    {
      …
    }

}
```

Then, you can use it as `inputs.kak-wl-clipboard.packages.${system}.kak-wl-clipboard`.
You would likely want to symlink the installation to your plugins directory.
For example, to set it up with Home Manager's `xdg.configFile` API:
```nix
# kakoune/my-plugins/kak-wl-clipboard.nix
{ inputs, system, ... }:
{
  xdg.configFile."kak/plugins/kak-wl-clipboard".source =
    inputs.kak-wl-clipboard.packages.${system}.kak-wl-clipboard
}
```

#### Manual installation

Simply clone the repo to whichever directory you prefer to keep your plugins in.

<p align="right"><a href="#readme-top">back to top</a></p>


## Usage

For all the steps described below, you will likely want to add them to your kakrc.

First of all, source the plugin and require its exported module:
```kakscript
source /path/to/plugin/kak-wl-clipboard.kak
require-module wl-clipboard
```

Now, we have two new commands available to us:
```
wl-copy-register
  Copy a named register (except null register) to system or primary clipboard, optionally joining multiple entries with a separator.
    If no joining is being done and multiple entries are copied, then this is equivalent to copying each of them one by one.
    A register must be specified.
    Switches:
      -register <name> Name of the register to use (e.g. `dquote`, `slash`, etc). See `:doc registers` for the list of names.
      -join <sep>      Use separator <sep> to join selections. Use `-join ''` to join without a separator.
      -primary         Use 'primary' (aka 'selection') clipboard buffer instead of the 'system' buffer. This gets passed to `wl-copy` as `--primary` flag.
      -trim-newline    Trim trailing newline characters when copying. This gets passed to `wl-copy` as `--trim-newline` flag.
      -main-only       Copy only the main entry of a register, as opposed to all entries. For example, copy only the main selection, or only the main selection index.
      -silent          Don't show an info message after copying.

wl-paste-to-register
  Fill a named register with the contents of system or primary clipboard.
    Switches:
      -register <name> Name of the register to use (e.g. `dquote`, `slash`, etc). See `:doc registers` for the list of names.
      -primary         Use 'primary' (aka 'selection') clipboard buffer instead of the 'system' buffer. This gets passed to `wl-paste` as `--primary` flag.
      -trim-newline    Do not append a newline character. This gets passed to `wl-paste` as `--no-newline` flag.
      -silent          Don't show an info message after setting the register.
```

Both of them are somewhat general and have a lot of options, so we'd like to define some small wrappers around them:

For example:
```kakscript
declare-user-mode copy
declare-user-mode paste
declare-user-mode replace

# copy
map global normal <a-y> ":wl-copy-register -register dot -primary -join '\n' -trim-newline<ret>"
map global normal <s-y> ":enter-user-mode copy<ret>"
map global copy b ":wl-copy-register -register dot -main-only -trim-newline<ret>"
map global copy a ":wl-copy-register -register dot -join '\n' -trim-newline<ret>"

# paste
define-command -override paste-primary-after \
  %{ exec -save-regs '"' ":wl-paste-to-register -register dquote -primary -trim-newline<ret>p" }
define-command -override paste-primary-before \
  %{ exec -save-regs '"' ":wl-paste-to-register -register dquote -primary -trim-newline<ret>P" }
define-command -override paste-clipboard-after \
  %{ exec -save-regs '"' ":wl-paste-to-register -register dquote -trim-newline<ret>p" }
define-command -override paste-clipboard-before \
  %{ exec -save-regs '"' ":wl-paste-to-register -register dquote -trim-newline<ret>P" }
define-command -override paste-all-after \
  %{ exec '<a-p>' }
define-command -override paste-all-before \
  %{ exec '<a-s-p>' }

map global normal <a-p> ":enter-user-mode paste<ret>"
map global paste p      ":paste-primary-after<ret>" -docstring "Paste primary after selections"
map global paste <s-p>  ":paste-primary-before<ret>" -docstring "Paste primary before selections"
map global paste b      ":paste-clipboard-after<ret>" -docstring "Paste clipboard after selections"
map global paste <s-b>  ":paste-clipboard-before<ret>" -docstring "Paste clipboard before selections"
map global paste d      ":paste-all-after<ret>" -docstring "Paste all after selections"
map global paste <s-d>  ":paste-all-before<ret>" -docstring "Paste all before selections"

# replace
define-command -override replace-with-primary \
  %{ exec -save-regs '"' ":wl-paste-to-register -register dquote -primary -trim-newline<ret>R" }
define-command -override replace-with-clipboard \
  %{ exec -save-regs '"' ":wl-paste-to-register -register dquote -trim-newline<ret>R" }

map global normal <a-r> ":enter-user-mode replace<ret>"
map global replace p ":replace-with-primary<ret>" -docstring "Replace selections with primary"
map global replace b ":replace-with-clipboard<ret>" -docstring "Replace selections with clipboard"

```

This will give us access to a whole bunch of new commands. Naturally, you're free to pick only
the ones you need, or define some other ones.

<p align="right"><a href="#readme-top">back to top</a></p>


## License

Distributed under the MIT License. See `LICENSE` for more information.

<p align="right"><a href="#readme-top">back to top</a></p>


## Contact

Author: [@postsolar](https://github.com/postsolar)

Project Link: [https://github.com/postsolar/kak-wl-clipboard](https://github.com/postsolar/kak-wl-clipboard)

<p align="right"><a href="#readme-top">back to top</a></p>
