#!/bin/bash
install -Dvm 755 git-bro.rb $HOME/.local/bin/git-bro.rb
install -DCv systemd/git-bro.service $HOME/.local/share/systemd/user/git-bro.service
install -DCv systemd/git-bro.timer $HOME/.local/share/systemd/user/git-bro.timer
