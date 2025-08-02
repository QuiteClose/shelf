##############################################################
# tempdir.sh
# Quickly create/search/switch-to temporary directories.
##############################################################

tempdir_usage() {
  >&2 echo "Usage: tempdir -b [<LEVEL>] | -c | -r | [<SORT>] [<TERMS...>]
  Creates & searches tempdirs. Changes to that directory when only one matches.

  -b, --browse Scroll through all tempdirs (down to <LEVEL>)
  -c           Create a tempdir (optionally with a <LABEL>)
  -r           Rotate tempdirs (delete older than 256 days)

  SORT options:
  -d           Sort by tempdir selection history.
  -t           Sort by tempdir timestamp (default)
  -n           Sort by file-name

  TERMS:       A series of filters that apply successively to previous matches.

               Terms that start with a dash (-) begin a series of key-value
               pairs that are passed to the find command. The find-command is
               applied to any currently-matching tempdir and the results are
               piped into the next filter. Note that only the following find
               expressions are allowed:
                 -ctime
                 -maxdepth
                 -mindepth
                 -mtime
                 -name
                 -type

               Terms that DO NOT start with a dash are used as grep filters.
               If the first-term is a grep filter, then a default find-command
               is used with a max-depth of 2.
"
}


TEMPDIR_ROOT="$(realpath -m ~/tempdirs)"
TEMPDIR_LIST="${TEMPDIR_ROOT}/_manifest.txt"

tempdir_all() {
  find "${TEMPDIR_ROOT}" -mindepth 1 -maxdepth 1 -type d "${FIND_SUFFIX[@]}"
}

tempdir_create() {
  tempdir_init
  local STAMP="$(date '+%y%m%d')"
  mktemp -d -p "${TEMPDIR_ROOT}" "${STAMP}.XXXXXX" | sed 's|^'"${TEMPDIR_ROOT}"'/||' | tee -a ${TEMPDIR_LIST}
}


tempdir_init() {
  if [[ ! -d "${TEMPDIR_ROOT}" ]]; then mkdir -p "${TEMPDIR_ROOT}"; fi
  if [[ ! -f "${TEMPDIR_LIST}" ]];  then  tempdir_all | sed "s|${TEMPDIR_ROOT}/||" | sort -n > "${TEMPDIR_LIST}"; fi
}

tempdir_reset() {
  if [[ -f "${TEMPDIR_LIST}" ]];  then
    >&2 echo "Resetting ${TEMPDIR_LIST}"
    rm -f "${TEMPDIR_LIST}"
  fi
  tempdir_init
}

tempdir() {
  tempdir_init
  case "$1" in
    -c) changedir "${TEMPDIR_ROOT}/$(tempdir_create)"; return $?;;
    -r) tempdir_rotate; return $?;;
    -h|--help) tempdir_usage; return 0;;
  esac
  local TERM_SORT="-t"    # either -d, -t, or -n
  local TERMS=()          # search terms
  local RESULTS=""        # full search results
  local MATCHES=""        # tempdirs that match the search
  local COUNT=0           # number of matches
  local SORTER=(sort)     # sort command
  local FIELDS=(-nk3,3)   # sort flags
  local SELECT=""         # which tempdir to navigate to
  local FIND_GLOBAL=()    # global find options
  local FIND_PREFIX=()    # find prefix options
  local FIND_EXPR=()      # find expression options
  local FIND_SUFFIX=()    # find suffix options
  local FIND_OPERATOR=""  # 1st part of a find expression
  local FIND_OPERAND=""   # 2nd part of a find expression
  local HISTORY_MATCH=""  # single selection history line
  local HISTORY_ALL=""    # all tempdir selection history
  local FIND_PREFIX=( \
    \( \
      -name .git -o -name .github -o -name node_modules -o -name venv -o -name .venv \
      -o -name dist -o -name build -o -name out -o -name target -o -name __pycache__ \
      -o -name .idea -o -name .vscode -o -name .tox -o -name .eggs -o -name .cache \
      -o -name .mypy_cache -o -name .pytest_cache -o -name .egg-info \
      -o -name .DS_Store -o -name .directory -o -name .project -o -name .classpath \
      -o -name .settings -o -name .gitignore -o -name .gitattributes -o -name .gitmodules \
      -o -name .hg -o -name .hgignore -o -name .hgrc -o -name .svn -o -name .bzr \
      -o -name LICENSE -o -name COPYING -o -name README.md -o -name CHANGELOG.md \
    \) \
    -prune -o \
  )
  local FIND_SUFFIX=( \
    -print \
  )
  local GREP_PREFIX=( \
    -i \
    --color=auto \
  )
  case "$1" in
    -d) TERM_SORT="history"; shift 1;;
    -t) TERM_SORT="timestamp"; shift 1;;
    -n) TERM_SORT="file-name"; shift 1;;
  esac
  MATCHES="$(tempdir_all)"
  if [ -z "${MATCHES}" ]; then
    >&2 echo "No tempdirs found."
    return 1
  fi
  # Initialize by matching everything
  FIND_GLOBAL=(-mindepth 0 -maxdepth 2)
  RESULTS="$(echo "${MATCHES}" | xargs -d '\n' -I{} find {} "${FIND_GLOBAL[@]}" "${FIND_PREFIX[@]}" "${FIND_EXPR[@]}" "${FIND_SUFFIX[@]}")"
  MATCHES="$(echo "${RESULTS}" | sed "s|${TEMPDIR_ROOT}/||g;s/\/.*//;s|^|${TEMPDIR_ROOT}/|;/^$/d" | sort -u)"
  # Build & apply filters from command-line arguments
  while [[ -n "$1"  ]]; do
    if [[ "$1" =~ ^- || "$1" == "!" ]]; then
      # consume find expression
      FIND_GLOBAL=()
      FIND_EXPR=()
      while [[ "$1" =~ ^- || "$1" == "!" ]]; do
        if [[ "$1" == "-name" ]]; then
          TERMS+=("$(echo "$2" | sed 's|*|.*|g;s|?|.|g')")
        fi
        case "$1" in
          -maxdepth|-mindepth)
            FIND_GLOBAL+=("$1" "$2"); shift 2;;
          -ctime|-mtime|-name|-type)
            FIND_EXPR+=("$1" "$2"); shift 2;;
          -o|-or|-a|-and|!|-not)
            FIND_EXPR+=("$1"); shift 1;;
          *) >&2 echo "Blocked find option: $1"; return 1;;
        esac
      done
      RESULTS="$(echo "${MATCHES}" | xargs -d '\n' -I{} find {} "${FIND_GLOBAL[@]}" "${FIND_PREFIX[@]}" "${FIND_EXPR[@]}" "${FIND_SUFFIX[@]}")"
    else
      # consume grep filter
      TERMS+=("$1")
      RESULTS="$(echo "${RESULTS}" | grep ${GREP_PREFIX[@]} "$1")"
      shift 1
    fi
    MATCHES="$(echo "${RESULTS}" | sed "s|${TEMPDIR_ROOT}/||g;s/\/.*//;/^$/d;s|^|${TEMPDIR_ROOT}/|" | sort -u)"
  done
  if [ ${#TERMS[@]} -eq 0 ]; then
    SELECT="$(echo "${MATCHES}" | head -n1 | sed "s|${TEMPDIR_ROOT}/||" | xargs)"
    if [ -z "${SELECT}" ]; then
      >&2 echo "Unexpected: No tempdirs found?"
      tempdir_reset
      return 1
    fi
  else
    COUNT="$(echo "${MATCHES}" | wc -l | xargs)"
    if [ "${COUNT}" -eq 1 ]; then
      SELECT="$(echo "${MATCHES}" | sed "s|${TEMPDIR_ROOT}/||" | head -n1 | xargs)"
    else
      >&2 echo "Found ${COUNT} matching tempdirs."
      if [[ "${TERM_SORT}" = "activity" ]]; then FIELDS="-nk1,3"; fi
      if [[ "${ORDER}" = "clone" ]];    then FIELDS="-nk2,3"; fi
      if [[ "${ORDER}" = "history" ]];  then FIELDS=""; SORTER="cat"; fi
      if [[ "${ORDER}" = "name" ]];     then FIELDS="-k3"; fi
      MATCHES="$(${SORTER} ${FIELDS} "${REPO_LIST}" | awk '{print $NF}')"
      echo "${RESULTS}" | sed "s|^${TEMPDIR_ROOT}/|  |" |  grep -iE --color "$(IFS="|"; echo "${TERMS[*]}")"
    fi
  fi
  if [ -n "${SELECT}" ]; then
    HISTORY_MATCH="$(grep -wm1 "${SELECT}" "${TEMPDIR_LIST}")"
    if [ -n "${HISTORY_MATCH}" ]; then
      # If the tempdir is already in the history, remove it first
      HISTORY_ALL="$(grep -vw "${SELECT}" "${TEMPDIR_LIST}")"
      {echo "${HISTORY_ALL}"; echo "${HISTORY_MATCH}"} > "${TEMPDIR_LIST}"
    else
      # Otherwise, append it to the history
      echo "${SELECT}" >> "${TEMPDIR_LIST}"
    fi
    changedir "${TEMPDIR_ROOT}/${SELECT}"
    return 0
  fi
}
