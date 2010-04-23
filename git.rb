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
      shell("git checkout #{var(:remote)}/#{var(:branch)} -b #{var(:branch)} -f")
    }
  }
end

dep 'git submodules up-to-date' do
  met? {
    shell("git submodule").lines.all? { |l| l[/^ /] }
  }
  meet {
    shell("git submodule update --init --recursive")
  }
end
