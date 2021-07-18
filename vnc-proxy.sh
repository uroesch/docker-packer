#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Setup
# -----------------------------------------------------------------------------
set -o errexit
set -o nounset
set -o pipefail

trap restart EXIT

# -----------------------------------------------------------------------------
# Globals
# -----------------------------------------------------------------------------
declare -r SHORTNAME=$(hostname -s)
declare -r NOVNC_PORT=${NOVNC_PORT:-6080}
declare -r PACKER_VNC_START=5900
declare -r PACKER_VNC_END=6000

# -----------------------------------------------------------------------------
# Functions
# -----------------------------------------------------------------------------
function find_vnc_port() {
  ss -Hntl src 127.0.0.1  and \
   \( sport \>= ${PACKER_VNC_START} and sport \<= ${PACKER_VNC_END} \) | \
   awk '{ print $4 }'
}

function wait_for_vnc() {
  local vnc_address=''
  while [[ -z ${vnc_address} ]]; do
    vnc_address=$(find_vnc_port)
    sleep 1
  done
  echo ${vnc_address}
}

function run_proxy() {
  local vnc_address=$(wait_for_vnc)
  local pid=''
  ( novnc_proxy --listen ${NOVNC_PORT} --vnc ${vnc_address} | \
    sed -n -e "/${SHORTNAME}/ { s/${SHORTNAME}/localhost/g; p }"
  ) &
  pid=$!
  while [[ -n $(find_vnc_port) ]]; do sleep 10; done
  [[ -n ${pid} ]] && kill ${pid}
}

function restart() {
  sleep 10
  run_proxy
}

# -----------------------------------------------------------------------------
# Main
# -----------------------------------------------------------------------------
run_proxy
