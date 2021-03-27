#!/usr/bin/ruby
require "tomlrb"
require "fileutils"
require "notify"

def notify(repo, msg)
	Notify.notify "git-bro: #{repo}", msg, { app_name: "git-bro" }
end

config = Tomlrb.load_file "#{Dir.home}/.config/git-bro/config.toml"

#Make sure we have a repos folder
REPOS_DIR = "#{Dir.home}/.local/share/git-bro/repos"
SCRIPTS_DIR = "#{Dir.home}/.config/git-bro/scripts"
FileUtils.mkdir_p REPOS_DIR
FileUtils.mkdir_p SCRIPTS_DIR

def run_scripts(repo, url)
	for script in Dir.entries(SCRIPTS_DIR)
		next if script == "." or script == ".."

		if system("#{SCRIPTS_DIR}/#{script} #{repo} #{url}")
			puts "Ran script #{script} successfully"
		else
			STDERR.puts "Script #{script} failed"
		end

	end
end

found_repos = []
for repo in Dir.entries(REPOS_DIR)
	next if repo == "." or repo == ".."

	#Delete
	if !config[repo]
		puts "Deleting #{repo}"
		FileUtils.rm_rf("#{REPOS_DIR}/#{repo}")
		next
	end

	puts "Found #{repo}"
	found_repos.push repo
	url = `git --git-dir #{REPOS_DIR}/#{repo}/.git config --get remote.origin.url`.delete_suffix "\n"
	
	if url != config[repo]["url"]
		puts "Warning: url mis-match at #{repo}"
	end
	
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
		run_scripts repo, url
	end

end

#make sure all repos exist
for name in config.keys
	url = config[name]["url"]
	
	#clone missing repo
	if !found_repos.include?(name)
		puts "Cloning #{name} (missing)"
		notify(name, "Repo #{name} is missing. Cloning it now.")
		clone = `git clone #{url} #{REPOS_DIR}/#{name}`
		if $?.exitstatus != 0
			STDERR.puts "Failed to clone #{name}:\n#{clone}"
			notify(name, "Failed to clone")
			next
		end
		run_scripts name, url
	end
end
