#!/bin/sh
_mise="${HOME}/.local/bin/mise"

if ! "$_mise" x -- gcloud auth print-access-token >/dev/null 2>&1; then
  printf 'GKE auth expired. Logging in...\n\n'
  if ! "$_mise" x -- gcloud auth login; then
    printf '\nAuth failed. Press Enter to close.'
    read _dummy
    exit 1
  fi
  printf '\nAuth successful. Starting k9s...\n'
fi

exec "$_mise" x -- k9s
