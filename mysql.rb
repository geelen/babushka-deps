#LLLLLLLLLLLLLLLLLLLOL ben

dep 'existing mysql db' do
  requires 'mysql db exists'
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
