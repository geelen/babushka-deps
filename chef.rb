dep 'chef' do
  requires 'chef gem', 'ohai', 'chef solo', 'chef vhost enabled'
end

dep 'chef solo' do
  requires 'chef solo config files'
  met? { dunno }
  meet { sudo "chef-solo -c ~/solo.rb -j ~/chef.json" }
end

dep 'chef solo config files' do
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
end
gem 'ohai'