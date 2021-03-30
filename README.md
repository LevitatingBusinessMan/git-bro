# git-bro
git-bro is a small ruby script that keeps track of git repositories for you. You can use it to automate tasks.

## Installing
For git-bro to work you just need `git-bro.rb` somewhere in your path.
There is also an install script which installs git-bro and its systemd services. Please review it before you use it.
```SH
git clone https://github.com/LevitatingBusinessMan/git-bro.git
cd git-bro
./install.sh
```

## Config
git-bro is completely controlled via its config file in `~/.config/git-bro/config.toml`. 
```SH
#Add a repo like this
[linux]
# The remote address to fetch the repo from
url=https://github.com/torvalds/linux.git

# Global settings go here
[settings]
# If git-bro should make notifications when it detects an update
silent = false
```
The name of the repo should be unique. The a copy of the tracked repositories is stored at `~/.local/share/git-bro/repos`. More config options should be available in the future.

## Scripts
The main point of git-bro is the ability to define custom behavior in scripts. Scripts are stored in `~/.config/git-bro/config.toml`. Any executable file in the scripts directory is automatically run by git-bro when changes to a repo are detected.
```SH
# Scripts are run with the arguments "repo-name remote-url"
# You can test them by manually running them

# You can for instance make a detailed notification showing the latest commit
# These can replace the built-in notifications from git-bro (disable these in the config.toml)
#!/bin/sh
cd $HOME/.local/share/git-bro/repos/$1
DETAILS=$(git show -s --format="%an %s (%h)")
notify-send $1 "$DETAILS"
```
See more examples of scripts at the end of this readme.

## Starting
```SH
#If you used the install script, git-bro.rb is in path (~./local/bin/git-bro.rb)
#You can use this to manually start git-bro
git-bro.rb

#The install script also installs a systemctl timer (starts every 5m)
systemctl --user start git-bro.timer

# You can also use a cronjob or add git-bro.rb to your bash_profile etc
```

## Examples
#### Build and install a package
```SH
#!/bin/sh
mkdir -p $HOME/autobuild

# Only run if the updated repo is linux
if [ "$1" == "linux" ]
then
	notify-send "Builder" "Building linux aur package"
	pushd $HOME/autobuild
	git clone https://aur.archlinux.org/linux-git.git linux
	pushd linux
	makepkg -si --noconfirm
	notify-send "Builder" "Linux package built"
fi
```
#### Notification with the commit message
```SH
#!/bin/sh
cd $HOME/.local/share/git-bro/repos/$1
DETAILS=$(git show -s --format="%an %s (%h)")
notify-send $1 "$DETAILS"
```
#### Clickable notifications via dunst
This script will make a notification which when clicked will bring you to the github page for the commit.
```SH
#!/bin/sh
cd $HOME/.local/share/git-bro/repos/$1
DETAILS=$(git show -s --format="%an %s (%h)")

HASH=$(git rev-parse HEAD)
REMOTE=$(git config --get remote.origin.url)
AUTHOR=$(echo -n $REMOTE | sed -E 's/.*github.com[/:]([[:alnum:]-]+)\/([[:alnum:]-]+)(\.git)?$/\1/')
if [[ $REMOTE == *"github"* ]]; then
	{
		ACTION=$(dunstify --action="open,Open on github" "$1" "$DETAILS")
		if [[ $ACTION == "open" ]]; then
			xdg-open "https://github.com/${AUTHOR}/${1}/commit/${HASH}"
		fi
	} &
else
	dunstify "$1" "$DETAILS"
fi
```
