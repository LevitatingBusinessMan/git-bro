#!/bin/bash
: ${PREFIX:=$HOME/.local}

install -Dvm 755 git-bro.rb $PREFIX/bin/git-bro
install -Dvm 644 systemd/git-bro.service $PREFIX/share/systemd/user/git-bro.service
install -Dvm 644 systemd/git-bro.timer $PREFIX/share/systemd/user/git-bro.timer

#Setup config
mkdir -pv $HOME/.config/git-bro/scripts
touch $HOME/.config/git-bro/config.toml
