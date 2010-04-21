dep 'existing mysql db' do
  requires 'mysql db exists', 'mysql gem'
  setup {
    definer.requires 'mysql root password' if confirm('Require root password for MySQL?')
    definer.requires 'mysql access' if confirm('Create MySQL user?')
  }
end

dep 'mysql db exists' do
  requires 'mysql software'
  met? { mysql("SHOW DATABASES").split("\n")[1..-1].any? {|l| /\b#{var :db_name}\b/ =~ l } }
  meet { mysql "CREATE DATABASE #{var :db_name}" }
end

dep 'mysql db in correct location', :for => :linux do
  define_var :db_location, :default => '/mnt/mysql'
  met? {
    (var(:db_location) / "ibdata1").exists?
  }
  before {
    sudo "/etc/init.d/mysql stop"
  }
  meet {
    var(:db_location).p.mkdir
    sudo "chown mysql:mysql #{var :db_location}"

    escaped_path = Regexp.escape(var(:db_location)).gsub("/", "\\/")
    #line in config usually datadir
    shell("#{sed} -ri 's/^(\s*datadir\s*=).*/\1 #{escaped_path}/' #{file}", :sudo => !File.writable?(file))
  }
  after {
    sudo "/etc/init.d/mysql start"
  }
end

dep 'load marketplace backup', :for => :linux do
  requires 's3cmd configured', 'mysql db in correct location'
end

dep 'mysql root password' do
  requires 'mysql software'
  met? { failable_shell("echo '\q' | mysql -u root").stderr["Access denied for user 'root'@'localhost' (using password: NO)"] }
  meet { mysql(%Q{GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' IDENTIFIED BY '#{var :db_admin_password}'}, 'root', nil) }
end
