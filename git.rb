dep 'add remote and switch to tracking branch' do
  define_var :repo, :default => ".", :message => "Path to local repo"
  define_var :remote, :message => "Name of remote repo"
  define_var :branch, :message => "Branch to track"
  met? {
    in_dir(var(:repo)) {
      current_branch = shell("git branch")[/^\*\W*(\w+)/, 1]
      current_branch == var(:branch)
    }
  }
  meet {
    in_dir(var(:repo)) {
      if shell("git branch")[/#{var(:branch)}/]
        #better than this, surely?
        raise "Branch #{var(:branch)} already exists!"
      end
      shell("git remote add #{var(:remote)} #{var(:remote_url)}")
      shell("git fetch #{var(:remote)}")
      shell("git checkout -f -b #{var(:branch)} #{var(:remote)}/#{var(:branch)}", :log => true)
    }
  }
end

dep 'git submodules up-to-date' do
  met? {
    in_dir(var(:repo)) {
      shell("git submodule").lines.all? { |l| l[/^ /] }
    }
  }
  meet {
    in_dir(var(:repo)) {
      shell("git submodule update --init")
    }
  }
end

dep 'github alias' do
  requires 'SSH alias'
  setup {
    set :ssh_config_file, "~/.ssh/config"
    set :hostname, "github.com"
    set :alias, "github"
    set :user, "git"
    set :port, " "
    set :key_file, "~/.ssh/github_key"
  }
end

dep 'tracking branch up-to-date' do
  requires 'add remote and switch to tracking branch'
  met? { in_dir(var(:repo)) {
    shell "git fetch #{var(:remote)}"
    shell("cat .git/refs/heads/#{var(:branch)}") == shell("cat .git/refs/remotes/#{var(:remote)}/#{var(:branch)}")
  } }
  meet { in_dir(var(:repo)) { shell "git merge --ff-only #{var(:remote)}/#{var(:branch)}" } }
end
