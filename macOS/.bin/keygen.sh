#!/usr/bin/env zsh

echo "------- Start generate keys."

#gitname=$(git config --get user.name)
gitemail=$(git config --get user.email)

if [ ! -f ~/.ssh/id_25519 ]; then
  sshkeypasswd=`RAND=$RANDOM && echo ${RAND} | sha256sum | base64 | head -c 32`
  ssh-keygen -t ed25519 -C ${gitemail} -N ${sshkeypasswd} -f ~/.ssh/id_ed25519
  echo "sshpasswd: ${sshkeypasswd}" >> ~/.dotfiles_tmp
fi

#gpgkeypasswd=`RAND=$RANDOM && echo ${RAND} | sha256sum | base64 | head -c 32`
#gpg --pinentry-mode loopback --passphrase ${gpgkeypasswd} --quick-generate-key "${gitname} <${gitemail}>" future-default default 0
#echo "gpgpasswd: ${gpgkeypasswd}" >> ~/.dotfiles_tmp

#[ -f ~/.gitconfig_device_local ] || touch ~/.gitconfig_device_local
#gpgkeyid=$(gpg --list-secret-keys --keyid-format=long ${gitname} | grep "sec" | awk '{print $2}' | sed -E 's_.+/__g')
#git config --file ~/.gitconfig_device_local user.signingkey ${gpgkeyid}

cat ~/.dotfiles_tmp && ~/.dotfiles_tmp

eval "$(ssh-agent -s)"
ssh-add --apple-use-keychain ~/.ssh/id_ed25519

echo "------- Finish generate keys."
