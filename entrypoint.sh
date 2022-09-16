#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

# -----------------------------------------------------------------------------
# Globals
# -----------------------------------------------------------------------------
# Set user account and run values
declare -r SCRIPT=${0##*/}
declare -r AUTHOR="Urs Roesch"
declare -r VERSION=0.5.0
declare -r LICENSE=MIT
declare -g USER_NAME=${USER_NAME:-packer}
declare -g USER_UID=${USER_UID:-1010}
declare -g USER_GID=${USER_GID:-"${USER_UID}"}
declare -g USER_HOME=${USER_HOME:-/home/"${USER_NAME}"}
declare -r DEFAULT_PASSWD="$(openssl passwd -1 -salt "$(openssl rand -base64 6)" "${USER_NAME}")"}
declare -g USER_PASSWD=${USER_PASSWD:-${DEFAULT_PASSWD}}
declare -g RUN_AS_ROOT=${RUN_AS_ROOT:-no}
declare -g FORCED_OWNERSHIP=${FORCED_OWNERSHIP:-no}
declare -g TZ=${TZ:-UTC}

# -----------------------------------------------------------------------------
# Functions
# -----------------------------------------------------------------------------
function is_enabled() {
  [[ ${1} =~ ^(yes|on|true|1)$ ]]
}

function is_disabled() {
  [[ ${1} =~ ^(no|off|false|0)$ ]]
}

function create_user() {
  # Create the user account
  ! grep -q ":${USER_GID}:$" /etc/group && \
  groupadd --gid "${USER_GID}" "${USER_NAME}"
  useradd \
    --shell /bin/bash \
    --uid "${USER_UID}" \
    --gid "${USER_GID}" \
    --password "${USER_PASSWD}" \
    --no-create-home \
    --home-dir "${USER_HOME}" \
    "${USER_NAME}"
}

function create_homedir() {
  # Create the user's home if it doesn't exist
  [[ ! -d ${USER_HOME} ]] && mkdir -p "${USER_HOME}"

  # Take ownership of user's home directory if owned by root or
  # if FORCED_OWNERSHIP is enabled
  OWNER_IDS="$(stat -c "%u:%g" "${USER_HOME}")"
  if [[ ${OWNER_IDS} != ${USER_UID}:${USER_GID} ]]; then
    if [[ ${OWNER_IDS} == 0:0 ]] || is_enabled "${FORCED_OWNERSHIP}"; then
      chown -R "${USER_UID}":"${USER_GID}" "${USER_HOME}"
    else
      printf "ERROR: User's home '%s' is currently owned by %s\n" \
        "${USER_HOME}" \
        "$(stat -c "%U:%G" "${USER_HOME}")"
      printf "Use option --force-owner to enable user '%s' to take ownership" \
        "${USER_NAME}"
      exit 1
    fi
  fi
}

function configure_kvm() {
  [[ -c /dev/kvm ]] && chgrp ${USER_GID} /dev/kvm
}

function configure_timezone() {
  ln -snf "/usr/share/zoneinfo/${TZ}" /etc/localtime && \
    echo "${TZ}" > /etc/timezone
}

function run_command() {
  # Run in X11 redirection mode as $USER_NAME (default)
  if is_disabled "${RUN_AS_ROOT}"; then
    # Run in X11 redirection mode as user
    exec gosu "${USER_NAME}" "${@}"
    # Run in X11 redirection mode as root
  elif is_enabled "${RUN_AS_ROOT}"; then
    exec "${@}"
  fi
}

function start_vnc_proxy() {
  [[ -f /vnc-proxy.sh ]] && /vnc-proxy.sh &
}

# -----------------------------------------------------------------------------
# main
# -----------------------------------------------------------------------------
create_user
create_homedir
configure_timezone
configure_kvm
start_vnc_proxy
run_command "${@}"
