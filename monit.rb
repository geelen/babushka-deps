dep 'monit', :template => 'managed'

dep 'monit running' do
  requires 'monit'
  requires_when_unmet 'monit startable'
  met? { (status = sudo("monit status")) && status[/uptime/] }
  meet { sudo "/etc/init.d/monit start" }
end

dep 'monit startable' do
  requires 'running as root', 'monitrc configured', 'monit config is where we expect'
  met? { grep "startup=1", "/etc/default/monit" }
  meet { change_line "startup=0", "startup=1", "/etc/default/monit" }
end

dep 'monitrc configured' do
  requires 'running as root'
  define_var :monit_frequency, :default => 30
  define_var :monit_port, :default => 9111
  define_var :monit_included_dir, :default => '/etc/monit/conf.d/'
  met? { babushka_config? "/etc/monit/monitrc" }
  meet { render_erb "monit/monitrc.erb", :to => "/etc/monit/monitrc" }
  after { shell "chmod 700 /etc/monit/monitrc" }
end

dep 'monit config is where we expect' do
  requires 'running as root'
  met? { "/etc/default/monit".p.exists? }
  meet { shell "echo startup=0 >> /etc/default/monit" }
end
