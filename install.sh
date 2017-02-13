#!/bin/bash

# this script's path
root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# omnibus'es path
omni='/opt/gitlab/embedded/service/'

# install the rails initializer
cp -v "${root}/gitlab-rails/config/initializers/zzz_protected_tags.rb" \
      "${omni}/gitlab-rails/config/initializers/zzz_protected_tags.rb"
cp -v "${root}/gitlab-rails/config/initializers/zzz_protected_tags.conf" \
      "${omni}/gitlab-rails/config/initializers/zzz_protected_tags.conf"

# install the custom update hook
mkdir -p "${omni}/gitlab-shell/hooks/update.d"
cp -v "${root}/gitlab-shell/hooks/update.d/zzz_protected_tags.sh" \
      "${omni}/gitlab-shell/hooks/update.d/zzz_protected_tags.sh"
