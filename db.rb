dep 'existing db' do
  setup {
    requires var(:db) == 'postgres' ? "benhoskings:existing postgres db" : "existing mysql db"
  }
end

dep 'existing mysql db' do
  requires 'benhoskings:mysql.managed'
  # figure out root passwords / users / etc later.
  met? { shell("echo 'SHOW DATABASES;' | mysql -u root").split("\n")[1..-1].any? {|l| /\b#{var :db_name}\b/ =~ l } }
  meet { shell "echo 'CREATE DATABASE #{var :db_name};' | mysql -u root" }
end
