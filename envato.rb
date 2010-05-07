#gems that aren't defined properly in environment.rb or a bundler file
marketplace_gems = %w[right_aws hpricot json money cgi_multipart_eof_fix chronic paypal erubis flog flay metric_fu]

marketplace_gems.each { |g| gem(g) { provides [] } }

dep 'marketplace gems' do
  requires *marketplace_gems
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

dep 'marketplace repo' do
  requires 'passenger deploy repo', 'github alias', 'add remote and switch to tracking branch', 'git submodules up-to-date'
  setup {
    set :passenger_repo_root, '~/current'
    set :repo, '~/current'
    set :remote, 'origin'
    set :branch, 'master'
    set :remote_url, 'github:envato/marketplace.git'
  }
end

dep 'marketplace configured' do
  requires 'marketplace repo', 'rails app db yaml present', 'marketplace gems', 'rails app'
  setup {
    set :username, 'app'
    set :nginx_prefix, '/opt/nginx'
    set :rails_root, '~/current'
    set :rails_env, 'staging'
    set :db, 'mysql'
  }
end

dep 'envato server configured' do
  requires 'switch babushka install to fork', 'system', 'user exists', 'mysql runs from EBS'
  setup {
    set :branch_name, 'master'
    set :fork_name, 'geelen'
    set :username, 'app'
    set :home_dir_base, '/srv/http'
    set :device, '/dev/sdf'
    set :mount_point, '/data'
  }
  after {
    definer.requires 'writable install location'
    log_extra %Q{Ok, now run: su - app -c "babushka 'geelen user setup'"}
  }
end

dep 'geelen user setup' do
  requires 'user setup'
  setup {
    set :github_user, 'geelen'
    set :dot_files_repo, 'dot-files'
  }
end
