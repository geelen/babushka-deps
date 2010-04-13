def 'chef installed' do
  requires 'chef', 'ohai'
  define_var :server_name, :default => shell('hostname -f')
  
  # this needs to go somewhere, like ~/solo.rb
  solo_rb = %Q{
    file_cache_path "/tmp/chef-solo"
    cookbook_path "/tmp/chef-solo/cookbooks"
    recipe_url "http://s3.amazonaws.com/chef-solo/bootstrap-latest.tar.gz"
  }
  
  # render this somewhere like ~/chef.json
  chef_json = %Q{
    {
      "bootstrap": {
        "chef": {
          "url_type": "http",
          "init_style": "runit",
          "path": "/srv/chef",
          "serve_path": "/srv/chef",
          "server_fqdn": "#{var :server_name}",
          "webui_enabled": true
        }
      },
      "run_list": [ "recipe[bootstrap::server]" ]
    }
  }
  
  #on my manual deployment, one of these steps failed because apt-get update hadn't been run :/ Can I script that here?
  
  `sudo chef-solo -c ~/solo.rb -j ~/chef.json`
  
  #then I want to install nginx and use this proxy to access the chef server config. Not that I exactly understand what I want this to do :)
  
  nginx_proxy = %Q{
    location /chef_admin {
      auth_basic "Restricted";
      auth_basic_user_file /etc/nginx/haproxy.users;

      proxy_pass http://localhost:4040/;
    }
  }
end

gem 'chef'
gem 'ohai'
