##############################################################
# git.sh
# Little git helpers.
##############################################################

function git-go() {
  if [ -d ".git" ]; then
    echo ".git already exists in the current working-directory."
    return 1
  fi
  local PARENT=".."
  local SEARCH="$PARENT"
  while true; do
    if [ -d "$SEARCH/.git" ]; then
      echo "$PWD"
      cd "$SEARCH"
      return 0
    elif [ "$(realpath "$SEARCH")" = "/" ]; then
      echo "No parent .git project."
      return 1
    else
      SEARCH="$PARENT/$SEARCH"
    fi
  done
}

function git-scrub() {
  local CURRENT_BRANCH="$(git branch --show-current)"
  if [[ "$CURRENT_BRANCH" != "main" && "$CURRENT_BRANCH" != "master" ]]; then
    echo "Must be on main or master branch to git-scrub!"
    return 1
  fi
  for branch in $(git branch --merged HEAD | grep -vw "$CURRENT_BRANCH"); do
    git branch -d "$branch"
  done
}

git-strip() {
  local files=()
  local since_ref=""
  while [[ $# -gt 0 ]]; do
    case $1 in
      --since)
        since_ref="$2"
        shift 2
        ;;
      *)
        files+=("$1")
        shift
        ;;
    esac
  done

  if [[ -n "$since_ref" ]]; then
    echo "Finding files changed since $since_ref..."
    local git_files=()
    while IFS= read -r -d $'\0' file; do
      git_files+=("$file")
    done < <(git diff --name-only -z --diff-filter=ACMR "$since_ref")
    files+=("${git_files[@]}")
  fi

  if [[ ${#files[@]} -eq 0 ]]; then
    echo "Usage: git-strip [--since <ref>] [files...]"
    echo "  --since <ref>  Process files changed since git ref"
    echo "  files...       Process specific files"
    return 1
  fi

  local processed=0
  for file in "${files[@]}"; do
    if [[ ! -f "$file" ]]; then
      echo "Skipping $file (not a regular file)"
      continue
    fi

    if sed --version &>/dev/null 2>&1; then
      sed -i 's/[[:space:]]*$//' "$file"
    else
      sed -i '' 's/[[:space:]]*$//' "$file"
    fi

    echo "✓ $file"
    ((processed++))
  done

  echo ""
  echo "Processed $processed file(s)"
}
