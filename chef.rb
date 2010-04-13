def 'chef installed' do
  requires 'chef', 'ohai'
  
  # this needs to go somewhere, like ~/solo.rb
  solo_rb = %Q{
    file_cache_path "/tmp/chef-solo"
    cookbook_path "/tmp/chef-solo/cookbooks"
    recipe_url "http://s3.amazonaws.com/chef-solo/bootstrap-latest.tar.gz"
  }
  
  # somewhere like ~/chef.json
  chef_json = %Q{
    {
      "bootstrap": {
        "chef": {
          "url_type": "http",
          "init_style": "runit",
          "path": "/srv/chef",
          "serve_path": "/srv/chef",
          "server_fqdn": "#{server_name or `hostname -f`}",
          "webui_enabled": true
        }
      },
      "run_list": [ "recipe[bootstrap::server]" ]
    }
  }
end

gem 'chef', 'ohai'