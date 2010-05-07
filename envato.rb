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
