dep 'unicorn.gem' do
  provides "unicorn", "unicorn_rails"
end

dep 'unicorn configured' do
  requires 'unicorn.gem', 'unicorn config in place', 'unicorn started', 'unicorn workers monitored'
end

dep 'unicorn config in place' do
  requires 'unicorn config generated'
  setup {
    set :absolute_rails_root, var(:rails_root).p
    set :unicorn_config, var(:data_dir) / 'shared/config/unicorn.rb'
    set :unicorn_config_within_app, var(:rails_root) / 'config/unicorn.rb'
  }
  met? { var(:unicorn_config_within_app).exists? }
  met? { shell "ln -sf #{var :unicorn_config} #{var :unicorn_config_within_app}" }
end

dep 'unicorn config generated' do
  met? { babushka_config? var(:unicorn_config) }
  meet { render_erb 'unicorn/unicorn.rb.erb', :to => var(:unicorn_config) }
end

dep 'unicorn started' do
  requires 'benhoskings:rcconf.managed'
  met? { shell("rcconf --list").val_for('unicorn') == 'on' }
  meet {
    render_erb 'unicorn/unicorn.init.d.erb', :to => '/etc/init.d/unicorn', :perms => '755', :sudo => true
    sudo 'update-rc.d unicorn defaults'
  }
  after { sudo "/etc/init.d/unicorn start" }
end

dep 'unicorn workers monitored' do
  helper(:monitrc) { "/etc/monit/conf.d/unicorn_workers.#{var(:app_name)}.monitrc" }
  met? { sudo "grep 'Generated by babushka' #{monitrc}" }
  meet { render_erb "monit/unicorn_workers.monitrc.erb", :to => monitrc, :sudo => true }
  after { sudo "monit reload" }
end
