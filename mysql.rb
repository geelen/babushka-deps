dep 'existing mysql db' do
  requires 'mysql db exists', 'mysql gem'
  setup {
    definer.requires 'mysql root password' if confirm('Require root password for MySQL?')
    definer.requires 'mysql access' if confirm('Create MySQL user?')
  }
end

dep 'mysql db exists' do
  requires 'mysql software'
  met? { mysql("SHOW DATABASES", 'root', nil).split("\n")[1..-1].any? {|l| /\b#{var :db_name}\b/ =~ l } }
  meet { mysql "CREATE DATABASE #{var :db_name}", 'root', nil }
end

dep 'load latest backup from s3', :for => :linux do
  requires 's3cmd configured'
  met? {

  }
  meet {

  }
end

dep 'mysql root password' do
  requires 'mysql software'
  met? { failable_shell("echo '\q' | mysql -u root").stderr["Access denied for user 'root'@'localhost' (using password: NO)"] }
  meet { mysql(%Q{GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' IDENTIFIED BY '#{var :db_admin_password}'}, 'root', nil) }
end
