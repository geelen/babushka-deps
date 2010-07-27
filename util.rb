dep 'monit', :template => 'managed'

dep 'monit running' do
  requires 'monit', 'monit configured for startup'
  met? { !sudo "monit status" }
end

dep 'monit configured for startup' do
  requires 'monit config is where we expect'
  met? { grep "startup=1", "/etc/default/monit" }
  meet { change_line "startup=0", "startup=1", "/etc/default/monit" }
end

dep 'monit config is where we expect' do
  met? { "/etc/default/monit".p.exists? }
  meet { sudo "echo startup=0 >> /etc/default/monit" }
end

dep 'monitrc configured' do
  define_var :monit_frequency, :default => 30
  define_var :monit_port, :default => 9111
  met? { babushka_config? "/etc/monit/monitrc" }
  meet { render_erb "monit/monitrc.erb", :to => "/etc/monit/monitrc" }
end

dep 'monit configured' do

end
