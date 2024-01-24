# path to the source code of this file.
try %{ declare-option -hidden str wl_clipboard_source_path %sh{ dirname -- "$kak_source" } }

provide-module -override wl-clipboard %•

define-command wl-copy-register -override -params .. -docstring '
  Copy a named register (except null register) to system or primary clipboard, optionally joining multiple entries with a separator.
    If no joining is being done and multiple entries are copied, then this is equivalent to copying each of them one by one.
    A register must be specified.
    Switches:
      -register <name> Name of the register to use (e.g. `dquote`, `slash`, etc). See `:doc registers` for the list of names.
      -join <sep>      Use separator <sep> to join selections. Use `-join ''''` to join without a separator.
      -primary         Use ''primary'' (aka ''selection'') clipboard buffer instead of the ''system'' buffer. This gets passed to `wl-copy` as `--primary` flag.
      -trim-newline    Trim trailing newline characters when copying. This gets passed to `wl-copy` as `--trim-newline` flag.
      -main-only       Copy only the main entry of a register, as opposed to all entries. For example, copy only the main selection, or only the main selection index.
      -silent          Don''t show an info message after copying.
  ' \
  %{
    evaluate-commands %sh{
      # kak_selection_count
      # kak_reg_dquote kak_reg_slash kak_reg_arobase kak_reg_caret kak_reg_pipe kak_reg_percent kak_reg_dot kak_reg_hash kak_reg_underscore kak_reg_colon
      # kak_quoted_reg_dquote kak_quoted_reg_slash kak_quoted_reg_arobase kak_quoted_reg_caret kak_quoted_reg_pipe kak_quoted_reg_percent kak_quoted_reg_dot kak_quoted_reg_hash kak_quoted_reg_underscore kak_quoted_reg_colon
      # kak_main_reg_dquote kak_main_reg_slash kak_main_reg_arobase kak_main_reg_caret kak_main_reg_pipe kak_main_reg_percent kak_main_reg_dot kak_main_reg_hash kak_main_reg_underscore kak_main_reg_colon
      "$kak_opt_wl_clipboard_source_path/kak-wl-clipboard.sh" copy-register "$@"
    }
}

define-command wl-paste-to-register -override -params .. -docstring '
  Fill a named register with the contents of system or primary clipboard.
    Switches:
      -register <name> Name of the register to use (e.g. `dquote`, `slash`, etc). See `:doc registers` for the list of names.
      -primary         Use ''primary'' (aka ''selection'') clipboard buffer instead of the ''system'' buffer. This gets passed to `wl-paste` as `--primary` flag.
      -trim-newline    Do not append a newline character. This gets passed to `wl-copy` as `--no-newline` flag.
      -silent          Don''t show an info message after setting the register.
  ' \
  %{
    evaluate-commands %sh{
      # kak_selection_count
      # kak_reg_dquote kak_reg_slash kak_reg_arobase kak_reg_caret kak_reg_pipe kak_reg_percent kak_reg_dot kak_reg_hash kak_reg_underscore kak_reg_colon
      # kak_quoted_reg_dquote kak_quoted_reg_slash kak_quoted_reg_arobase kak_quoted_reg_caret kak_quoted_reg_pipe kak_quoted_reg_percent kak_quoted_reg_dot kak_quoted_reg_hash kak_quoted_reg_underscore kak_quoted_reg_colon
      # kak_main_reg_dquote kak_main_reg_slash kak_main_reg_arobase kak_main_reg_caret kak_main_reg_pipe kak_main_reg_percent kak_main_reg_dot kak_main_reg_hash kak_main_reg_underscore kak_main_reg_colon
      "${kak_opt_wl_clipboard_source_path}/kak-wl-clipboard.sh" set-register "$@"
    }
}

•
