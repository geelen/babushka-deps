dep 'rails app db yaml present' do
  helper(:db_yaml) { var(:rails_root) / "config" / "database.yml" }
  met? { db_yaml.exists? }
  meet { shell "cp #{var(:rails_root) / "config" / "database.*#{var(:rails_env)}*"} #{db_yaml}" }
end

dep 'bundler installed' do
  requires 'bundler.gem', 'local gemdir writable'
  define_var :bundler_installed_locally, :default => 'n'
  met? { in_dir(var(:rails_root)) { shell "bundle check", :log => true } }
  meet { in_dir(var(:rails_root)) { sudo "bundle install --without test,cucumber #{'--local' if var(:bundle_local).to_s =~ /^y/} #{'--path vendor/bundle' if var(:bundle_into_vendor).to_s =~ /^y/}", :log => true }}
end

dep 'bundler.gem' do
  installs 'bundler' => '1.0.0.rc.5'
  provides 'bundle'
end

dep 'local gemdir writable' do
  helper(:local_path) { "~/.gem".p }
  met? { File.writable_real?(local_path) }
  meet {
    sudo "mkdir -p #{local_path}"
    sudo "chown #{var(:username)}:#{var(:username)} #{local_path}"
  }
end

dep 'rails app' do
  requires 'webapp', 'benhoskings:passenger deploy repo', 'benhoskings:db gem', 'bundler installed', 'db set up'
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

dep 'nokogiri.gem' do
  requires 'libxslt-dev.managed', 'benhoskings:libxml.managed'
  provides []
end

dep 'libxslt-dev.managed' do
  installs { via :apt, 'libxslt1-dev' }
  provides []
end
