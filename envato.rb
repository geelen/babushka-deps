gem 'right_aws' do
  provides []
end

dep 'marketplace configured' do
  requires 'right_aws', 'rails app'
  setup {
    set :username, 'app'
    set :nginx_prefix, '/opt/nginx'
  }
end

dep 'rails user configured' do
  requires {
    'switch babushka install to fork'
  }
end
