dep 'rails app' do
  requires 'webapp', 'benhoskings:passenger deploy repo', 'benhoskings:db gem', 'bundler installed', 'db set up'
  define_var :rails_env, :default => 'production'
  define_var :rails_root, :default => '~/current', :type => :path
  setup {
    set :vhost_type, 'passenger'
  }
end
