#!/bin/bash
install -Dvm 755 git-bro.rb $HOME/.local/bin/git-bro.rb
install -DCv systemd/git-bro.service $HOME/.local/share/systemd/user/git-bro.service
install -DCv systemd/git-bro.timer $HOME/.local/share/systemd/user/git-bro.timer

#Setup config
mkdir -pv $HOME/.config/git-bro/scripts
touch $HOME/.config/git-bro/config.toml
