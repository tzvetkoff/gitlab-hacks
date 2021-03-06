#!/bin/bash

##
## Who can delete tags?
## Format: key-<SSH-Key IDs from GitLab's database>
## The easiest way to find those IDs is from GitLab's console:
##   $ gitlab-rails console
##   >> User.find_by(email: 'admin@example.com').key_ids
##   >> User.find_by(username: 'root').key_ids
##

ALLOWED_KEY_IDS=('key-1' 'key-XXX' 'key-XXY')

##
## Log file
##

LOG_FILE=''

##
## Code
##

in_array() {
  local element

  for element in "${@:2}"; do
    if [[ "${element}" = "${1}" ]]; then
      return 0
    fi
  done

  return 1
}

msg() {
  echo "${@}" >&2
}

log() {
  [[ -n "${LOG_FILE}" ]] && echo "${@}" >> "${LOG_FILE}"
}

case "${1}" in
  refs/tags/*)
    if [[ "${3}" = '0000000000000000000000000000000000000000' ]]; then
      # Delete tag
      if ! in_array "${GL_ID}" "${ALLOWED_KEY_IDS[@]}"; then
        msg "you're not allowed to delete tags"
        msg ''
        log "DENY_TAG_DELETE: ${GL_ID}: ${@}"
        exit 1
      else
        log "ALLOW_TAG_DELETE: ${GL_ID}: ${@}"
      fi
    elif [[ "${2}" != '0000000000000000000000000000000000000000' ]]; then
      # Move tag
      if ! in_array "${GL_ID}" "${ALLOWED_KEY_IDS[@]}"; then
        msg "you're not allowed to move tags"
        msg ''
        log "DENY_TAG_MOVE: ${GL_ID}: ${@}"
        exit 1
      else
        log "ALLOW_TAG_MOVE: ${GL_ID}: ${@}"
      fi
    fi

    ;;
esac
