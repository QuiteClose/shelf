##############################################################
# changedir.sh
# Used by other shelf utils to change working-directory.
##############################################################

changedir() {
  # Change the current working-directory to the given path
  # and print the transition to stdout.
  local TARGET="$1"
  if [[ -z "${TARGET}" ]]; then
    TARGET="${HOME}"
  fi
  TARGET="$(realpath -m "${TARGET}")"
  echo "${PWD}  ${TARGET}" | sed "s|${HOME}|~|g"
  cd "${TARGET}"
}
