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

dep 'git.src' do
  provides 'git 1.7.3.4'
  source 'http://kernel.org/pub/software/scm/git/git-1.7.3.4.tar.bz2'
  configure_args '--without-tcltk'
end
