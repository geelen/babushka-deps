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
end

dep 'monitrc configured'

dep 'monit configured' do

end
