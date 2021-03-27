#!/usr/bin/ruby
require "tomlrb"
require "fileutils"
require "notify"

=begin
TODO

branches
supporting repos with the same name but different author
support deleting repos not mentioned in config

maybe better toml syntax:
[name]
url=
branch=

=end

def notify(repo, msg)
	Notify.notify "git-bro: #{repo}", msg, { app_name: "git-bro" }
end

config = Tomlrb.load_file "#{Dir.home}/.config/git-bro/config.toml"

#Make sure we have a repos folder
REPOS_DIR = "#{Dir.home}/.local/share/git-bro/repos"
SCRIPTS_DIR = "#{Dir.home}/.config/git-bro/scripts"
FileUtils.mkdir_p REPOS_DIR
FileUtils.mkdir_p SCRIPTS_DIR

def run_scripts(repo)
	for script in Dir.entries(SCRIPTS_DIR)
		if system("#{SCRIPTS_DIR}/#{script} #{repo}")
			puts "Ran script #{script} successfully}"
		else
			STDERR.puts "Script #{script} failed"
		end

	end
end

repos = []
for repo in Dir.entries(REPOS_DIR)
	next if repo == "." or repo == ".."
	puts "Found #{repo}"
	repos.push repo
	#url = `git --git-dir #{REPOS_DIR}/#{repo}/.git config --get remote.origin.url`.delete_suffix "\n"
	fetch = `2>&1 git --git-dir #{REPOS_DIR}/#{repo}/.git fetch origin`
	
	if $?.exitstatus != 0
		STDERR.puts "Failed to fetch #{repo}:\n#{fetch}"
		notify(repo, "Failed to fetch")
		next
	end

	#New stuff fetched
	if fetch != ""
		puts "New commits on #{repo}"
		notify(repo, "New commits found")
		run_scripts repo
	end

end

#make sure all repos exist
for url in config["repos"]
	name = url.split("/").last.delete_suffix ".git"
	
	#clone repo
	if !repos.include?(name)
		puts "Initializing #{name}"
		notify(name, "Repo #{name} is missing. Cloning it now.")
		clone = `git clone #{url} #{REPOS_DIR}/#{name}`
		if $?.exitstatus != 0
			STDERR.puts "Failed to clone #{name}:\n#{clone}"
			notify(name, "Failed to clone")
			next
		end
	end
end
