##############################################################
# repo.sh
# Quickly clone/search/switch-to repo directories.
##############################################################

REPO_ROOT="${SHELF_REPOS:-$(realpath ~/repos)}"
REPO_STAT="%Y %W %n"
REPO_LIST="$REPO_ROOT/_manifest.txt"
REPO_HOST="_server.txt"

repo_git_all() {
  find "${REPO_ROOT}" -mindepth 4 -maxdepth 4 -type d -name .git -printf "%p "
}

repo_init() {
  if [[ ! -d "${REPO_ROOT}" ]]; then mkdir -p "${REPO_ROOT}"; fi
  if [[ ! -f "${REPO_LIST}" ]];  then  repo_git_all | xargs -- stat -c "${REPO_STAT}" | sed "s|${REPO_ROOT}/||;s|/\.git\$||" > "${REPO_LIST}"; fi
}

repo_reset() {
  if [[ -f "${REPO_LIST}" ]];  then
    >&2 echo "Resetting ${REPO_LIST}"
    rm -f "${REPO_LIST}"
  fi
  repo_init
}

repo_stat() {
  local SELECT="$1"
  stat -c "${REPO_STAT}" "${REPO_ROOT}/${SELECT}/.git" | sed "s|${REPO_ROOT}/||;s|/\.git\$||"
}

repo_usage() {
  >&2 echo "Usage: repo [-c <URL> | -s | [-d] <TERMS...>]
  Searches cloned repositories for given TERMS and changes-dir to the match.
  More terms can be added to narrow down the search. Changes directory to the
  matching repository if only one match is found.

  -b, --browse Scroll through all cloned repositories (or a specific remote).
  --clone      Clone a repository with the given terms.
  -c           Sort by git clone date.
  -d           Sort by repo selection history.
  -g           Sort by git activity date.

  If no terms are given, switches to most recently-accessed repo."
}

repo() {
  repo_init
  local GIT_URI_REGEX='^git@[A-Za-z0-9_.-]+(:[0-9]+)?:[A-Za-z0-9_.\/-]+\.git$'
  local GIT_HTTP_REGEX='^https?://[A-Za-z0-9_.-]+(/[A-Za-z0-9_.\/-]+)?\.git$'
  local ACTION="search"
  local ORDER="name"
  local REMOTE=""
  local SEARCH=""
  local FILTER=""
  local MATCHES=""
  local COUNT=""
  local SORTER="sort"
  local FIELDS="-nk3,3"
  local GITURI=""
  local SERVER=""
  local SELECT=""
  case "$1" in
    -h|--help)   repo_usage; return 0 ;;
    -b|--browse) ACTION="browse"; REMOTE="$2"; ;;
    --clone)     ACTION="clone";  REMOTE="$2"; SEARCH="$3" ;;
    -c) ORDER="clone";    shift 1; SEARCH="$*" ;;
    -d) ORDER="history";  shift 1; SEARCH="$*" ;;
    -g) ORDER="activity"; shift 1; SEARCH="$*" ;;
    -n) ORDER="name";     shift 1; SEARCH="$*" ;;
    *)  SEARCH="$*" ;;
  esac
  case "${ACTION}" in
    browse)
      if [[ -z "${REMOTE}" ]]; then
        tree -dL3 "${REPO_ROOT}" | less
        return $?
      elif [[ -d "${REPO_ROOT}/${REMOTE}" ]]; then
        tree -dL2 "${REPO_ROOT}/${REMOTE}" | less
        return $?
      else
        >&2 echo "Remote ${REMOTE} is not one of the known remotes:" 
        tree -dL1 "${REPO_ROOT}"
        return 1
      fi
      ;;
    clone)
      if [[ -z "${SEARCH}" ]]; then
        GITURI="${REMOTE}"
        if [[ "${GITURI}" =~ $GIT_URI_REGEX ]]; then
          SEARCH="${GITURI##*:}"
          SEARCH="${SEARCH%.git}"
          SERVER="${GITURI%:*}"
          SERVER="${SERVER#git@}"
        elif [[ "${GITURI}" =~ $GIT_HTTP_REGEX ]]; then
          SERVER="${GITURI#*://}"
          SERVER="${SERVER%%/*}"
          SEARCH="${GITURI#*://}"
          SEARCH="${SEARCH#*/}"
          SEARCH="${SEARCH%.git}"
        else
          >&2 echo "Either provide a git@ URI, an HTTPS URL or <remote> <name>/<repo>"
          return 1
        fi
        REMOTE=""
        for name in "${REPO_ROOT}"/*; do
          if [[ ! -d "${name}" || ! -f "${name}/${REPO_HOST}" ]]; then continue; fi
          name="$(basename "${name}")"
          if [[ "${SERVER}" = "$(cat "${REPO_ROOT}/${name}/${REPO_HOST}")" ]]; then
            REMOTE="${name}"
            break
          fi
        done
        if [[ -z "${REMOTE}" ]]; then
          >&2 echo "Remote not found for ${SERVER}"
          REMOTE="${SERVER%%[^a-zA-Z0-9]*}"
          if [[ -z "${REMOTE}" ]]; then
            >&2 echo "Remote name is empty. Cannot create remote."
            return 1
          elif [[ -d "${REPO_ROOT}/${REMOTE}" ]]; then
            >&2 echo "Remote ${REMOTE} already exists."
            return 1
          fi
          >&2 echo "Creating remote ${REMOTE} for ${SERVER}"
          mkdir -p "${REPO_ROOT}/${REMOTE}"
          echo "${SERVER}" > "${REPO_ROOT}/${REMOTE}/${REPO_HOST}"
        fi
      else
        # REMOTE and SEARCH given separately (e.g. repo --clone github quiteclose/shelf)
        if [[ ! -f "${REPO_ROOT}/${REMOTE}/${REPO_HOST}" ]]; then
          >&2 echo "Remote ${REMOTE} does not have a ${REPO_HOST} file."
          return 1
        fi
        SERVER="$(cat "${REPO_ROOT}/${REMOTE}/${REPO_HOST}")"
        GITURI="git@${SERVER}:${SEARCH}.git"
      fi
      if [[ ! -d "${REPO_ROOT}/${REMOTE}" ]]; then
        >&2 echo "Remote ${REMOTE} does not exist. Try cloning a full git@ URI."
        return 1
      fi
      if [[ ! -f "${REPO_ROOT}/${REMOTE}/${REPO_HOST}" ]]; then
        >&2 echo "Remote ${REMOTE} does not have a ${REPO_HOST} file."
        return 1
      fi
      if [[ -e "${REPO_ROOT}/${REMOTE}/${SEARCH}" ]]; then
        >&2 echo "${SEARCH} already exists at ${REPO_ROOT}/${REMOTE}/${SEARCH}"
        return 1
      fi
      SERVER="$(cat "${REPO_ROOT}/${REMOTE}/${REPO_HOST}")"
      SELECT="${REMOTE}/${SEARCH}"
      mkdir -p "$(dirname "${REPO_ROOT}/${SELECT}")"
      if [[ -z "${GITURI}" ]]; then
        GITURI="git@${SERVER}:${SEARCH}.git"
      fi
      git clone "${GITURI}" "${REPO_ROOT}/${SELECT}"
      ;;
    search)
      FILTER="$(echo "${SEARCH}" | sed 's/ /\\\|/g')"
      if [[ "${ORDER}" = "activity" ]]; then FIELDS="-nk1,3"; fi
      if [[ "${ORDER}" = "clone" ]];    then FIELDS="-nk2,3"; fi
      if [[ "${ORDER}" = "history" ]];  then FIELDS=""; SORTER="cat"; fi
      if [[ "${ORDER}" = "name" ]];     then FIELDS="-k3"; fi
      MATCHES="$(${SORTER} ${FIELDS} "${REPO_LIST}" | awk '{print $NF}')"
      while [[ -n "$1" && -n "${MATCHES}" ]]; do
        MATCHES="$(echo "${MATCHES}" | grep -i "$1")"
        shift 1
      done
      if [[ -z "${SEARCH}" ]]; then
        SELECT="$(echo "${MATCHES}" | tail -n1 | xargs)"
        if [[ -z "${SELECT}" ]]; then
          >&2 echo "Unexpected: No repositories found?"
          repo_reset
          return 1
        fi
      else
        COUNT="$(echo "${MATCHES}" | wc -l | xargs)"
        if [[ "${COUNT}" -eq 1 ]]; then
          SELECT="$(echo "${MATCHES}" | head -n1 | xargs)"
        else
          >&2 echo "Found ${COUNT} matching repositories:"
          echo "${MATCHES}" | sed 's/^/  /' | grep -i --color "${FILTER}"
        fi
      fi
      ;;
  esac
  if [[ -n "${SELECT}" ]]; then
    local MATCH="$(grep -m1 -w "${SELECT}" "${REPO_LIST}")"
    if [[ -n "${MATCH}" ]]; then
      local OTHERS="$(grep -vw "${SELECT}" "${REPO_LIST}")"
      { echo "${OTHERS}"; echo "${MATCH}"; } > "${REPO_LIST}"
    else
      repo_stat "${SELECT}" >> "${REPO_LIST}"
    fi
    changedir "${REPO_ROOT}/${SELECT}"
  fi
  return 0
}
