#!/bin/bash

mirrorlist="/etc/pacman.d/mirrorlist"
pmcachedir="/var/cache/pacman/pkg"
pmdbpath="/var/lib/pacman"
pmdblock=${pmdbpath}/db.lck
runreflector=
printmetalink=

re_server='^ *Server *= *([a-z]+://.*)/\$repo/os/\$arch$'
re_fileurl='^[a-z]+://[^ ]+/([a-z-]+)/os/([a-z0-9_]+)/([^/ ]+\.pkg\.[^/ ]+)$'

declare -a server_base_uris
declare -a repo arch name

# @param: ml_file, mirrorlist file
# @global: set server_base_uris
collect_servers_from_mirrorlist()
{
  local ml_file=${1}
  local line
  server_base_uris=()
  while read line; do
    if [[ "${line}" =~ ${re_server} ]]; then
      server_base_uris+=("${BASH_REMATCH[1]}")
    fi
  done < "${ml_file}"
}

# @param: fileurl output by `pacman -Sp --print-format '%l' <pkgname>`
# @global: set (append) repo arch name
collect_fileinfo_from_pacman_print()
{
  local fileurl=${1}
  if [[ "${fileurl}" =~ ${re_fileurl} ]]; then
    repo+=("${BASH_REMATCH[1]}")
    arch+=("${BASH_REMATCH[2]}")
    name+=("${BASH_REMATCH[3]}")
  fi
}

# @params: repo arch name
fileinfo_to_metalink_section()
{
  local _repo=${1} _arch=${2} _name=${3}
  local metalink= url urltype server
  metalink+="  <file name=\"${_name}\">"
  metalink+=$'\n'"    <resources>"
  for server in "${server_base_uris[@]}"; do
    url=${server}/${_repo}/os/${_arch}/${_name}
    urltype=${url%%://*}
    metalink+=$'\n'"      <url type=\"${urltype}\">${url}</url>"
  done
  metalink+=$'\n'"    </resources>"
  metalink+=$'\n'"  </file>"
  echo "${metalink}"
}

# @global: read repo arch name
compose_aria2c_metalink()
{
  local i
  echo '<?xml version="1.0" encoding="utf-8"?>'
  echo '<metalink version="3.0" xmlns="http://www.metalinker.org/">'
  echo '<files>'
  for ((i=0;i<${#name[@]};i++)); do
    fileinfo_to_metalink_section "${repo[i]}" "${arch[i]}" "${name[i]}"
  done
  echo '</files>'
  echo '</metalink>'
}

aria2c_metalink()
{
  /usr/bin/aria2c --metalink-file=- --metalink-servers=50 --min-split-size=1M --lowest-speed-limit=10K --continue "$@"
}

check_cachedir()
{
  if [ ! -d "${pmcachedir}" ]; then
    echo "Not a directory: ${pmcachedir}" >&2
    exit 1
  elif [ ! -w "${pmcachedir}" ]; then
    echo "You don't have write permissions to directory: ${pmcachedir}" >&2
    exit 1
  else
    cd "${pmcachedir}" || exit 1
    echo "Current directory: ${pmcachedir}" >&2
  fi
}

# @global: read pmdblock
check_dblock()
{
  if [ -e "${pmdblock}" ]; then
    echo "Pacman database is locked." >&2
    exit 2
  fi
}

usage()
{
  cat <<EOF
USAGE: ${0##*/} [options] [arguments]

OPTIONS:
  -h,--help       Print this message and exit.
  --d <directory> Download files to directory.
  --m <file>      Use file as mirrorlist file.
  --r             Run reflector to retrieve server list.
  --p             Print metalink to stdout and don't download.

NOTES:
  Arguments are passed to pacman in addition to -Sp.
  If no arguments are passed, -u is passed to pacman.
EOF
}

pmargs=()
until [ -z "${1}" ]; do
  case "${1}" in
    -h|--help) usage; exit;;
    --d) pmcachedir=${2}; shift 2;;
    --m) mirrorlist=${2}; shift 2;;
    --r) runreflector=1; shift;;
    --p) printmetalink=1; shift;;
    *) pmargs+=("${1}"); shift;;
  esac
done

check_dblock

[ -z "${printmetalink}" ] && check_cachedir

if [ -n "${reflector}" ]; then
  collect_servers_from_mirrorlist <(/usr/bin/reflector -l 50)
else
  collect_servers_from_mirrorlist "${mirrorlist}"
fi

[ ${#pmargs} -eq 0 ] && pmargs='-u'

pacman_print=$(pacman -Sp --print-format '%l' "${pmargs[@]}") || exit $?

while read fileurl; do
  collect_fileinfo_from_pacman_print "${fileurl}"
done <<< "${pacman_print}"

if [ ${#name[@]} -eq 0 ]; then
  echo "Nothing to do." >&2
  exit
else
  echo "Targets:" >&2
  for ((i=0;i<${#name[@]};i++)); do
    echo "${name[i]}" >&2
  done
  if [ -n "${printmetalink}" ]; then
    compose_aria2c_metalink
  else
    compose_aria2c_metalink | aria2c_metalink
  fi
fi

# vim:ts=2 sw=2 et fdm=marker fdl=0:
