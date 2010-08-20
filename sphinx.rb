dep 'sphinx.src' do
  source "http://www.sphinxsearch.com/downloads/sphinx-0.9.8.tar.gz"
  provides 'search', 'searchd', 'indexer'
end

dep 'sphinx configured' do
  requires 'sphinx.src', 'sphinx directory setup', 'sphinx yml in place', 'sphinx indexed', 'sphinx monit configured'
  define_var :ts_generated_config, :default =>  L{ File.expand_path(var(:data_dir)) / "shared/config/thinkingsphinx/#{var(:rails_env)}.sphinx.conf" }
end

dep 'sphinx directory setup' do
  define_var :sphinx_dir, :default => '/var/sphinx'
  met? { (var(:sphinx_dir) / 'indexes').exists? && var(:sphinx_dir).p.writable_real? }
  meet {
    sudo "mkdir -p #{var(:sphinx_dir) / 'indexes'}"
    sudo("chown -R #{var(:username)}:#{var(:username)} #{var(:sphinx_dir)}")
  }
end

dep 'sphinx yml in place' do
  requires 'sphinx yml generated'
  helper(:sphinx_config_within_app) { var(:rails_root) / 'config' / 'sphinx.yml' }
  met? { sphinx_config_within_app.exists? }
  met? { shell "ln -sf #{var(:data_dir) / 'shared/config/sphinx.yml'} #{sphinx_config_within_app}" }
end

dep 'sphinx yml generated' do
  define_var :sphinx_port, :default => 3312
  define_var :sphinx_mem_limit, :default => '384M'
  helper(:sphinx_config) { var(:data_dir) / 'shared/config/sphinx.yml' }
  met? { babushka_config? sphinx_config }
  meet { render_erb 'sphinx/sphinx.yml.erb', :to => sphinx_config }
end

dep 'sphinx indexed' do
  met? { var(:ts_generated_config).p.exists? }
  meet {
    shell "mkdir -p #{File.dirname(var(:ts_generated_config))}"
    in_dir(var(:rails_root)) { shell "rake RAILS_ENV=#{var :rails_env} thinking_sphinx:index", :log => true }
  }
end

dep 'sphinx monit configured' do
  requires 'monit running', 'writable app pid directory'
  helper(:monitrc) { "/etc/monit/conf.d/sphinx.#{var(:app_name)}.monitrc" }
  met? { sudo "grep 'Generated by babushka' #{monitrc}" }
  meet { render_erb "monit/sphinx.monitrc.erb", :to => monitrc, :sudo => true }
  after {
    sudo "monit reload"
    sudo "monit restart sphinx_#{var(:app_name)}"
  }
end
