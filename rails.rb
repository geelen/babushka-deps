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
