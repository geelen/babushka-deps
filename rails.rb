dep 'rails app db yaml present' do
  helper :db_yaml do
    (var(:rails_root) / "config" / "database.yml")
  end
  met? { db_yaml.exists? }
  meet { shell "cp #{var(:rails_root) / "config" / "database.*#{var(:rails_env)}*"} #{db_yaml}" }
end

dep 'bundler installed and locked' do
  requires 'bundler.gem', 'local gemdir writable'
  met? { (var(:rails_root) / "Gemfile.lock").exists? && in_dir(var(:rails_root)) { shell "bundle check" } }
  meet { in_dir(var(:rails_root)) { shell "bundle install --relock" }}
end

dep 'bundler.gem' do
  provides 'bundle'
end

dep 'local gemdir writable' do
  met? { File.writable_real?("~/.gem".p) }
  meet { sudo "chown #{var(:username)} #{"~/.gem".p}"}
end

dep 'rails app' do
  requires 'webapp', 'benhoskings:passenger deploy repo', 'benhoskings:db gem', 'bundler installed and locked', 'db set up'
  define_var :rails_env, :default => 'production'
  define_var :rails_root, :default => '~/current', :type => :path
  setup {
    set :vhost_type, 'passenger'
  }
end

dep 'db set up' do
  requires 'benhoskings:deployed app', 'existing db'
  setup {
    if (db_config = yaml(var(:rails_root) / 'config/database.yml')[var(:rails_env)]).nil?
      log_error "There's no database.yml entry for the #{var(:rails_env)} environment."
    else
      set :db_name, db_config['database']
    end
  }
end

dep 'webapp' do
  requires 'benhoskings:user exists', 'benhoskings:vhost enabled.nginx', 'benhoskings:webserver running.nginx'
end
