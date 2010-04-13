dep 'chef' do
  requires 'chef gem', 'ohai', 'chef bootstrap', 'chef vhost enabled'
end

dep 'chef bootstrap' do
  requires 'chef bootstrap config files'
  meet { sudo "chef-solo -c ~/solo.rb -j ~/chef.json" }
end

dep 'chef bootstrap config files' do
  define_var :server_name, :default => shell "hostname -f", :message => "Fully qualified domain name for Chef?"
  helper :files do
    %w[solo.rb chef.json]
  end
  met? { files.all? {|file| babushka_config? "~/#{file}" } }
  meet { files.each {|file| render_erb "chef/#{file}.erb", :to => "~/#{file}" } }
end

nginx 'chef vhost enabled' do
  requires 'chef vhost configured'
  setup {
    set :chef_vhost_link, (var(:nginx_prefix) / "conf/vhosts/on/chef_admin.conf")
  }
  met? { var(:chef_vhost_link).exists? }
  meet { sudo "ln -sf '#{var(:chef_vhost_conf)}' '#{var(:chef_vhost_link)}'" }
  after { restart_nginx }
end

nginx 'chef vhost configured' do
  requires 'webserver configured'
  setup {
    set :chef_vhost_conf, (var(:nginx_prefix) / "conf/vhosts/chef_admin.conf")
  }
  met? { var(:chef_vhost_conf).exists? }
  meet { render_erb "chef/chef_admin_vhost.conf.erb", :to => var(:chef_vhost_conf), :sudo => true }
  after { restart_nginx if var(:chef_vhost_link).exists? }
end

gem 'chef gem' do
  installs 'chef'
  provides 'chef-client', 'chef-solo'
end
gem 'ohai'