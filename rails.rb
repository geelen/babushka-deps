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

dep 'nokogiri.gem' do
  requires 'libxslt-dev.managed', 'benhoskings:libxml.managed'
  provides []
end

dep 'libxslt-dev.managed' do
  installs { via :apt, 'libxslt1-dev' }
  provides []
end

dep 'rails app chowned' do
  met? { @rails_app_chowned_run }
  meet {
    sudo "chown -R #{var(:username)}:#{var(:username)} #{var(:rails_root)}"
    @rails_app_chowned_run = true
  }
end
