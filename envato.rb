marketplace_gems = %w[right_aws hpricot json money cgi_multipart_eof_fix chronic paypal erubis flog flay metric_fu]

marketplace_gems.each { |g| gem(g) { provides [] } }

dep 'marketplace gems' do
  #gems that aren't defined properly in environment.rb or a bundler file
  requires marketplace_gems
end

dep 'marketplace configured' do
  requires 'marketplace gems', 'rails app'
  setup {
    set :username, 'app'
    set :nginx_prefix, '/opt/nginx'
    set :passenger_repo_root, '~/current'
    set :rails_root, '~/current'
    set :rails_env, 'staging'
    set :db, 'mysql'
  }
end

dep 'envato app user configured' do
  requires 'switch babushka install to fork', 'system', 'user exists', 'user setup'
  setup {
    set :branch_name, 'master'
    set :fork_name, 'geelen'
    set :username, 'app'
    set :github_user, 'geelen'
    set :dot_files_repo, 'dot-files'
  }
  after {
    definer.requires 'writable install location'
  }
end