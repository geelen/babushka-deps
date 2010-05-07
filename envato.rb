gem 'right_aws' do
  provides []
end

gem 'hpricot' do
  provides []
end

dep 'marketplace configured' do
  requires 'right_aws', 'rails app'
  setup {
    set :username, 'app'
    set :nginx_prefix, '/opt/nginx'
    set :domain, 'staging-ec2.activeden.net'
    set :passenger_repo_root, '~/current'
    set :rails_root, '~/current'
    set :rails_env, 'staging'
    set :db, 'mysql'
  }
end

dep 'rails user configured' do
  requires {
    'switch babushka install to fork'
  }
end
