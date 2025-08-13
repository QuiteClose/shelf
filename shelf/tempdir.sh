##############################################################
# tempdir.sh
# Quickly create/search/switch-to temporary directories.
##############################################################

tempdir_usage() {
  >&2 echo "Usage: tempdir -c | -p | [<SORT>] [<TERMS...>] [--browse]
  Creates & searches tempdirs. Changes to that directory when only one matches.

  -c           Create a tempdir (optionally with a <LABEL>)
  -p, --prune  Delete unused tempdirs.
  -b, --browse Do not changedir.
  -t, --tree   View the tempdirs as a tree.

  SORT options (upper-case reverses the sort):
  -d,-D        Sort by tempdir selection history.
  -f,-F        Sort by file-name.
  -n,-N        Sort by name.

  TERMS:       A series of filters that apply successively to previous results.

               Find expressions start with a dash (-) (or ! for negation) and
               are applied to each matching tempdir. They generate output that
               can be filtered or browsed. Find expressions come in a series of
               key-value pairs, and are passed directly to the find command.
               Note that only the following find expressions are allowed:
                 -ctime
                 -maxdepth
                 -mindepth
                 -mtime
                 -name
                 -type

               Grep filters are terms that DO NOT start with a dash. They are
               fed the input of the previous find command (or grep.) Successive
               grep filters reduce the results. You can generate more results
               by issuing a find expression on the current-matches.

               Note that if the 1st term is a grep filter, a default find
               command will be used to seed the initial search.
"
}

TEMPDIR_ROOT="$(realpath -m ~/tempdirs)"
TEMPDIR_LIST="${TEMPDIR_ROOT}/_manifest.txt"
TEMPDIR_FIND_PREFIX=( \
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
TEMPDIR_FIND_SUFFIX=(-print)

tempdir_all() {
  find "${TEMPDIR_ROOT}" -mindepth 1 -maxdepth 1 -type d "${TEMPDIR_FIND_SUFFIX[@]}" | sed "s|${TEMPDIR_ROOT}/||"
}

tempdir_create() {
  tempdir_init
  local STAMP="$(date '+%y%m%d')"
  mktemp -d -p "${TEMPDIR_ROOT}" "${STAMP}.XXXXXX" | sed "s|^${TEMPDIR_ROOT}/||" | tee -a "${TEMPDIR_LIST}"
}


tempdir_init() {
  if [[ ! -d "${TEMPDIR_ROOT}" ]]; then mkdir -p "${TEMPDIR_ROOT}"; fi
  if [[ ! -f "${TEMPDIR_LIST}" ]];  then  tempdir_all | sort -n > "${TEMPDIR_LIST}"; fi
}

tempdir_reset() {
  if [[ -f "${TEMPDIR_LIST}" ]];  then
    >&2 echo "Resetting ${TEMPDIR_LIST}"
    rm -f "${TEMPDIR_LIST}"
  fi
  tempdir_init
}

tempdir_sort_by_filename() {
  # Sorts input lines (tempdirs) by their file name.
  awk -F/ '{print $NF, $0}' | sort | cut -d' ' -f2-
}

tempdir_sort_by_history() {
  # Sorts input lines (tempdirs) by their history in TEMPDIR_LIST.
  awk -F/ '
    NR==FNR { o[$1]=++n; next }
    { key=$1; print (o[key] ? o[key] : 999999), $0 }
  ' <(tac "${TEMPDIR_LIST}") - | sort -n | cut -d' ' -f2-
}

tempdir_sort_by_name() {
  # Sorts input lines numerically by timestamp prefix (assumes it's at the start).
  sort "${1:-/dev/stdin}"
}


tempdir_reverse_by_filename() {
  tempdir_sort_by_filename | tac
}

tempdir_reverse_by_history() {
  tempdir_sort_by_history | tac
}

tempdir_reverse_by_name() {
  # Sorts input lines numerically by timestamp prefix (assumes it's at the start).
  tac "${1:-/dev/stdin}"
}

tempdir() {
  tempdir_init
  case "$1" in
    -c|--create) changedir "${TEMPDIR_ROOT}/$(tempdir_create)"; return $?;;
    -p|--prune)  tempdir_prune; return $?;;
    -h|--help)   tempdir_usage; return 0;;
  esac
  local ACTION="seek"     # either "seek" or "browse"
  local RENDER="list"     # either "list" or "tree"
  local GIVEN_ARGS=()     # because we consume them as we iterate
  local TERM_SORT="-d"    # either -d, -f, or -n
  local TERMS=()          # search terms
  local RESULTS=""        # full search results
  local MATCHES=""        # tempdirs that match the search
  local COUNT=0           # number of matches
  local SORTER=()         # sort command
  local SELECT=""         # which tempdir to navigate to
  local FIND_GLOBAL=()    # global find options
  local FIND_EXPR=()      # find expression options
  local GREP_PREFIX=(-iE) # grep options
  local TREE_PREFIX=(-L3) # tree options
  local HISTORY_MATCH=""  # single selection history line
  local HISTORY_ALL=""    # all tempdir selection history
  if [[ "$1" =~ ^-(d|f|n|D|F|N)$ ]]; then
    TERM_SORT="$1";
    shift;
  fi
  case "${TERM_SORT}" in
    -d)   SORTER=tempdir_sort_by_history;;
    -f)   SORTER=tempdir_sort_by_filename;;
    -n)   SORTER=tempdir_sort_by_name;;
    -D)   SORTER=tempdir_reverse_by_history;;
    -F)   SORTER=tempdir_reverse_by_filename;;
    -N)   SORTER=tempdir_reverse_by_name;;
  esac
  MATCHES="$(tempdir_all)"
  if [ -z "${MATCHES}" ]; then
    >&2 echo "No tempdirs found."
    return 1
  fi
  GIVEN_ARGS=("$@")
  if [ -z "${GIVEN_ARGS[*]}" ]; then
    # No args, so just sort tempdirs
    MATCHES="$(echo "${MATCHES}" | $SORTER)"
  elif [[ ! "$1" =~ ^-[^-] && ! "$1" == "!" ]]; then
    # No find expression, so seed results for grep
    FIND_GLOBAL=(-mindepth 0 -maxdepth 2)
    RESULTS="$(echo "${MATCHES}" | sed "s|^|${TEMPDIR_ROOT}/|" | xargs -d '\n' -I{} find {} "${FIND_GLOBAL[@]}" "${TEMPDIR_FIND_PREFIX[@]}" "${FIND_EXPR[@]}" "${TEMPDIR_FIND_SUFFIX[@]}" | sed "s|${TEMPDIR_ROOT}/||" | $SORTER )"
  fi
  # Build & apply filters from command-line arguments
  while [ -n "$1"  ]; do
    case "$1" in
      -b|--browse) ACTION="browse"; shift 1; continue;;
      -t|--tree)   RENDER="tree";   shift 1; continue;;
    esac
    if [[ "$1" =~ ^-[^-] || "$1" == "!" ]]; then
      # consume find expression
      FIND_GLOBAL=()
      FIND_EXPR=()
      while [[ "$1" =~ ^-[^-] || "$1" == "!" ]]; do
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
      TERMS+=("/")
      RESULTS="$(echo "${MATCHES}" | sed "s|^|${TEMPDIR_ROOT}/|" | xargs -d '\n' -I{} find {} "${FIND_GLOBAL[@]}" "${TEMPDIR_FIND_PREFIX[@]}" "${FIND_EXPR[@]}" "${TEMPDIR_FIND_SUFFIX[@]}" | sed "s|${TEMPDIR_ROOT}/||" | $SORTER )"
    else
      # consume grep filter
      TERMS+=("$1")
      RESULTS="$(echo "${RESULTS}" | grep ${GREP_PREFIX[@]} "$1" | $SORTER )"
      shift 1
    fi
    MATCHES="$(echo "${RESULTS}" | sed "s/\/.*//" | awk '!seen[$0]++' )"
  done
  if [ ${#GIVEN_ARGS[@]} -eq 0 ]; then
    # No args, so user expects to changedir
    SELECT="$(echo "${MATCHES}" | head -n1 | xargs)"
    if [ -z "${SELECT}" ]; then
      >&2 echo "Unexpected: No tempdirs found?"
      tempdir_reset
      return 1
    fi
  else
    # Args given, so maybe we must render results
    if [ -t 1 ]; then 
      GREP_PREFIX+=(--color=always)
    fi
    COUNT="$(echo "${MATCHES}" | wc -l | xargs)"
    if [ "$COUNT" -eq 1 ] && [ "$ACTION" != "browse" ]; then
      SELECT="$(echo "${MATCHES}" | head -n1 | xargs)"
    elif [ "${RENDER}" = "tree" ]; then
      echo "${MATCHES}" | sed "s|^|${TEMPDIR_ROOT}/|" | xargs -d '\n' -- tree --noreport $TREE_PREFIX | grep ${GREP_PREFIX[@]} "^|$(IFS="|"; echo "${TERMS[*]}")" | less -RF
    elif [ "${RENDER}" = "list" ]; then
      >&2 echo "Found ${COUNT} matching tempdirs."
      echo "${RESULTS}" | sed "s|^${TEMPDIR_ROOT}/|  |" | grep ${GREP_PREFIX[@]} "^|$(IFS="|"; echo "${TERMS[*]}")" | less -RF
    fi
  fi
  if [ -n "${SELECT}" ] && [ "${ACTION}" = "seek" ]; then
    # trim TEMPDIR_ROOT and trailing slash
    SELECT="$(echo "${SELECT}" | sed "s|^${TEMPDIR_ROOT}/||;s|/$||")"
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
  fi
  return 0
}
