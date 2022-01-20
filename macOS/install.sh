#!/bin/bash -eu

echo "------- Start configuration."

GIT_BASE_DIR=${GIT_BASE_DIR:=~/git}
export DOTFILES_REPO_DIR=${GIT_BASE_DIR}/dotfiles

if [ ! -d "${DOTFILES_REPO_DIR}/.git" ]; then
  git clone https://github.com/sata365/dotfiles.git "${DOTFILES_REPO_DIR}"
else
  pushd ${DOTFILES_REPO_DIR}
  git pull origin
  popd
fi

export LOCAL_DOTFILES_REPO_DIR=${GIT_BASE_DIR}/dotfiles.local
if [[ ${LOCAL_DOTFILES_REPO:-x} != x ]] ; then
  if [ ! -d "${LOCAL_DOTFILES_REPO_DIR}/.git" ]; then
    git clone "${LOCAL_DOTFILES_REPO}" "${LOCAL_DOTFILES_REPO_DIR}"
  else
    pushd ${LOCAL_DOTFILES_REPO_DIR}
    git pull origin
    popd
  fi
fi

/bin/bash ${DOTFILES_REPO_DIR}/macOS/.bin/defaults.sh
/bin/bash ${DOTFILES_REPO_DIR}/macOS/.bin/resources.sh
/bin/bash ${DOTFILES_REPO_DIR}/macOS/.bin/brew.sh

if [[ -d ${LOCAL_DOTFILES_REPO} ]]; then
  /bin/bash ${LOCAL_DOTFILES_REPO}/macOS/install.sh
fi

/bin/bash ${DOTFILES_REPO_DIR}/macOS/.bin/keygen.sh

echo "------- Finish configuration."
