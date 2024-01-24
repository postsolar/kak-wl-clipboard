#! /usr/bin/env sh
# shellcheck disable=SC2016

set -eu

error () {
  me="$(basename "$0")"
  msg="[$me]: $1"
  printf 'echo -debug %s\n' "$msg"
  printf 'echo -markup {Error}%s\n' "$msg"
  exit "${2:-1}"
}

notify () {
  printf 'echo -markup {Information}%s' "$1"
}

parseRegister () {
  case "$1" in
    dquote|slash|arobase|caret|pipe|percent|dot|hash|underscore|colon)
      register="$1"
      ;;
    *)
      error 'invalid register passed to parameter `-register`: '"'$1'"
      ;;
  esac
}

# ~~~~~ Copy ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

parseCopyModeArgs () {
  while [ $# -gt 0 ]; do
    case "$1" in
      -register)
        if [ -z "${2-}" ]; then
          error 'register argument for parameter `-register` not set'
        else
          parseRegister "$2"
        fi
        shift
        ;;
      -join)
        if [ "${2-}" ]; then
        	separator="$2"
        else
          error 'separator argument for parameter `-join` not set'
        fi
        join=yes
        shift
        ;;
      -primary)
        copyTarget="primary clipboard"
        wlCopy="$wlCopy --primary"
        ;;
      -trim-newline)
        wlCopy="$wlCopy --trim-newline"
        ;;
      -main-only)
        mainOnly=yes
        ;;
      -silent)
        silent=yes
        ;;
      *)
        error "unrecognized argument: $1"
        ;;
    esac
    shift
  done

  [ "${register-}" ] || error 'parameter `-register` not specified'
  : "${copyTarget:="system clipboard"}"
}

copyUnlessEmpty () {
  if [ "${1-}" ]; then
    printf '%s\n' "$1" | $wlCopy > /dev/null 2>&1
  else
    error "register $register is empty"
  fi
}

# shellcheck disable=SC2120 # parsing bug in SC
performCopy () {
  if [ "${mainOnly-}" ]; then
    # copyContent is the raw content of a single selection
    copyContent="$(eval printf '%s' \"\$kak_main_reg_"$register"\"))"
    copyUnlessEmpty "$copyContent"
  elif [ "${join-}" ]; then
    # copyContentQuoted is the content (not name)
    # of the respective $kak_quoted_ variable
    copyContentQuoted="$(eval printf '%s' \"\$kak_quoted_reg_"$register"\")"
    sep="$(printf '%s' "$separator" | sed 's/%/%%/')"
    eval set -- "$copyContentQuoted"
    copyUnlessEmpty \
      "$( joined="$(printf "%s${sep}" "$@")"
          printf '%s' "${joined%"$separator"}"
        )"
  else
    copyContentQuoted="$(eval printf '%s' \"\$kak_quoted_reg_"$register"\")"
    eval set -- "$copyContentQuoted"
    for s; do copyUnlessEmpty "$s"; done
  fi
}

notifyCopy () {
  # shellcheck disable=SC2154 # $kak_selection_count referenced but not assigned
  if [ "${mainOnly-}" ] && [ "$register" = dot ]; then
    notify "copied main selection to $copyTarget"
  elif [ "${mainOnly-}" ]; then
    notify "copied main entry of register $register to $copyTarget"
  elif [ "${join-}" ] && [ "$register" = dot ] && [ "$kak_selection_count" -gt 1 ]; then
    notify "copied joined $kak_selection_count selections to $copyTarget"
  elif [ "${join-}" ] && [ "$register" = dot ]; then
    notify "copied selection to $copyTarget"
  elif [ "${join-}" ]; then
    notify "copied joined entries of register $register to $copyTarget"
  elif [ "$copyTarget" = "primary clipboard" ]; then
    notify "copied register $register to $copyTarget"
  else
    notify "copied entries of register $register to $copyTarget"
  fi
}

# ~~~~~ Set ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

parseSetModeArgs () {
  while [ $# -gt 0 ]; do
  	case "$1" in
      -register)
        if [ -z "${2-}" ]; then
          error 'register argument for parameter `-register` not set'
        else
          parseRegister "$2"
        fi
        shift
        ;;
      -primary)
        wlPaste="$wlPaste --primary"
        setRegisterTarget="primary clipboard"
        ;;
      -trim-newline)
        wlPaste="$wlPaste --trim-newline"
        ;;
      -silent)
        silent=yes
        ;;
      *)
        error "unrecognized argument: $1"
        ;;
    esac
    shift
  done

  [ "${register-}" ] || error 'parameter `-register` not specified'
  : "${setRegisterTarget:="system clipboard"}"
}

performSetRegister () {
  printf '%s\n' "set-register $register %sh{ $wlPaste }"
}

notifySetRegister () {
  notify "register $register set to $setRegisterTarget"
}

# ~~~~~ Main ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

main () {
  if [ "${1-}" ]; then
    mode="$1"
    shift
  else
    error 'no arguments passed'
  fi

  case "$mode" in
    copy-register)
      wlCopy="wl-copy"
      parseCopyModeArgs "$@"
      performCopy
      [ "${silent-}" ] || notifyCopy
      ;;
    set-register)
      wlPaste="wl-paste"
      parseSetModeArgs "$@"
      performSetRegister
      [ "${silent-}" ] || notifySetRegister
      ;;
    *)
      error "invalid argument: $mode"
      ;;
  esac
}

main "$@"

