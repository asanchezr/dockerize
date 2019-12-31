#!/bin/bash
#
# `install.sh` is a simple one-liner shell script to install this developer toolkit
#
# For newest version:
#
#   $ curl -sL https://raw.githubusercontent.com/asanchezr/dockerize/master/install.sh | bash
#
# Patches welcome!
# https://github.com/asanchezr/dockerize
# Alejandro Sanchez <emailforasr@gmail.com>
#
set -euo pipefail

BOLD="$(tput bold 2>/dev/null || echo '')"
GREY="$(tput setaf 0 2>/dev/null || echo '')"
UNDERLINE="$(tput smul 2>/dev/null || echo '')"
RED="$(tput setaf 1 2>/dev/null || echo '')"
GREEN="$(tput setaf 2 2>/dev/null || echo '')"
YELLOW="$(tput setaf 3 2>/dev/null || echo '')"
BLUE="$(tput setaf 4 2>/dev/null || echo '')"
MAGENTA="$(tput setaf 5 2>/dev/null || echo '')"
CYAN="$(tput setaf 6 2>/dev/null || echo '')"
NO_COLOR="$(tput sgr0 2>/dev/null || echo '')"

function main() {
  # defaults
  if [ -z "${VERSION-}" ]; then
    VERSION=latest
  fi

  if [ -z "${PLATFORM-}" ]; then
    PLATFORM="$(detect_platform)"
  fi

  if [ -z "${DEST-}" ]; then
    # DEST=/usr/local
    DEST=$(pwd)
  fi

  if [ -z "${ARCH-}" ]; then
    ARCH="$(detect_arch)"
  fi

  if [ -z "${BASE_URL-}" ]; then
    BASE_URL="https://raw.githubusercontent.com/asanchezr/dockerize/master/"
  fi

  printf "  ${UNDERLINE}Configuration${NO_COLOR}\n"
  info "${BOLD}Version${NO_COLOR}:  ${GREEN}${VERSION}${NO_COLOR}"
  info "${BOLD}Destination${NO_COLOR}:   ${GREEN}${DEST}${NO_COLOR}"
  info "${BOLD}Platform${NO_COLOR}: ${GREEN}${PLATFORM}${NO_COLOR}"
  info "${BOLD}Arch${NO_COLOR}:     ${GREEN}${ARCH}${NO_COLOR}"

  # non-empty VERBOSE enables verbose untarring
  if [ ! -z "${VERBOSE-}" ]; then
    VERBOSE=v
    info "${BOLD}Verbose${NO_COLOR}: yes"
  else
    VERBOSE=
  fi

  echo

  # check_dest "${DEST}"
  confirm "Install Docker DEV scripts ${GREEN}${VERSION}${NO_COLOR} to ${BOLD}${GREEN}${DEST}${NO_COLOR}?"

  bot "installing dotfiles..."
  dotfiles=( dockerignore gitignore )
  for file in "${dotfiles[@]}"
  do
    action "installing .$file"
    download_file ".$file"
    if [[ $? != 0 ]]; then
      echo; warn ".$file already present (ignoring)"
    else
      ok
    fi
    ensure_exists ".$file"
    ok
  done

  bot "installing docker developer scripts..."
  dev_scripts=( dev dev.config )
  for dev_script in "${dev_scripts[@]}"
  do
    action "installing $dev_script"
    download_file "$dev_script"
    if [[ $? != 0 ]]; then
      echo; warn "$dev_script already present (ignoring)"
    else
      ok
    fi
    ensure_exists "$dev_script"
    chmod +x "$DEST/$dev_script"
    ok
  done

  # Done!
  complete "docker-dev toolkit has been installed into ${DEST}"
  echo
  echo "To update docker-dev, install it again."
  echo
  echo "For more info visit:"
  echo "https://github.com/asanchezr/dockerize"
  echo
}

function info() {
  printf "${BOLD}${GREY}>${NO_COLOR} $@\n"
}
function warn() {
  printf "${YELLOW}! $@${NO_COLOR}\n"
}
function error() {
  printf "${RED}x $@${NO_COLOR}\n" >&2
}
function complete() {
  printf "${GREEN}√${NO_COLOR} $@\n"
}
function bot() {
  echo; echo -e "${GREEN}\[._.]/${NO_COLOR} - "$1
}
function action() {
  echo -en $1"..."
}
function ok() {
  echo -e "${GREEN}[ok]${NO_COLOR} "$1
}

function fetch() {
  local command
  if hash curl 2>/dev/null; then
    set +e
    command="curl -sLf $1"
    curl -sLf "$1"
    rc=$?
    set -e
  else
    if hash wget 2>/dev/null; then
      set +e
      command="wget -O- -q $1"
      wget -O- -q "$1"
      rc=$?
      set -e
    else
      error "No HTTP download program (curl, wget) found…"
      exit 1
    fi
  fi

  if [ $rc -ne 0 ]; then
    error "Command failed (exit code $rc): ${BLUE}${command}${NO_COLOR}"
    exit $rc
  fi
}

# download file, unless already present
function download_file() {
  if [[ ! -e "$DEST/$1" ]]; then
    {
      fetch "${BASE_URL}$1" > $DEST/$1
    } &> /dev/null
    return 0
  else
    return 1
  fi
}

function ensure_exists() {
  if [ ! -f "${DEST}/$1" ]; then
    echo
    error "Oops! Cannot copy '$1' to ${DEST}, installation failed."
    echo "Try to rerun with sudo or specify a custom directory."
    exit 1
  fi
}

# Currently known to support:
#   - win (Git Bash)
#   - darwin
#   - linux
#   - linux_musl (Alpine)
function detect_platform() {
  local platform="$(uname -s | tr '[:upper:]' '[:lower:]')"

  # check for MUSL
  if [ "${platform}" = "linux" ]; then
    if ldd /bin/sh | grep -i musl >/dev/null; then
      platform=linux_musl
    fi
  fi

  # mingw is Git-Bash
  if echo "${platform}" | grep -i mingw >/dev/null; then
    platform=win
  fi

  echo "${platform}"
}

# Currently known to support:
#   - x64 (x86_64)
#   - x86 (i386)
#   - armv6l (Raspbian on Pi 1/Zero)
#   - armv7l (Raspbian on Pi 2/3)
function detect_arch() {
  local arch="$(uname -m | tr '[:upper:]' '[:lower:]')"

  if echo "${arch}" | grep -i arm >/dev/null; then
    # ARM is fine
    echo "${arch}"
  else
    if [ "${arch}" = "i386" ]; then
      arch=x86
    elif [ "${arch}" = "x86_64" ]; then
      arch=x64
    fi

    # `uname -m` in some cases mis-reports 32-bit OS as 64-bit, so double check
    if [ "${arch}" = "x64" ] && [ "$(getconf LONG_BIT)" -eq 32 ]; then
      arch=x86
    fi

    echo "${arch}"
  fi
}

function confirm() {
  if [ -z "${FORCE-}" ]; then
    printf "${MAGENTA}?${NO_COLOR} $@ ${BOLD}[yN]${NO_COLOR} "
    set +e
    read yn < /dev/tty
    rc=$?
    set -e
    if [ $rc -ne 0 ]; then
      error "Error reading from prompt (please re-run with the \`--yes\` option)"
      exit 1
    fi
    if [ "$yn" != "y" ] && [ "$yn" != "yes" ]; then
      error "Aborting (please answer \"yes\" to continue)"
      exit 1
    fi
  fi
}

function check_dest() {
  local bin="$1/bin"

  # https://stackoverflow.com/a/11655875
  local good=$( IFS=:
    for path in $PATH; do
      if [ "${path}" = "${bin}" ]; then
        echo 1
        break
      fi
    done
  )

  if [ "${good}" != "1" ]; then
    warn "Destination directory ${bin} is not in your \$PATH"
  fi
}

main "$@"; exit
