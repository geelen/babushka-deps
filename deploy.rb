dep 'deploy' do #DONE
  requires 'db migrations up-to-date'
  met? { @restarted_app_yet }
  meet {
    sudo "/etc/init.d/unicorn restart"
    sudo "monit restart all -g dj_#{var(:app_name)}"
    @restarted_app_yet = true
  }
end

dep 'db migrations up-to-date' do #DONE
  requires 'bundle up-to-date' #DONE
  met? { in_dir(var(:rails_root)) {
    shell "rake db:abort_if_pending_migrations RAILS_ENV=#{var :rails_env}", :log => true
  } }
  meet { in_dir(var(:rails_root)) {
    shell "rake db:migrate RAILS_ENV=#{var :rails_env}", :log => true
  } }
end

dep 'bundle up-to-date' do
  requires 'codes up-to-date'
           'benhoskings:app bundled'
end

dep 'codes up-to-date' do
  met? { in_dir(var(:rails_root)) {
    # dumb hack, since before blocks aren't working, but stops us fetching twice.
    @fetch_only_once ||= shell "git fetch #{var :remote}"
    shell("git rev-list ..#{var :remote}/#{var :branch}").split("\n").empty?
  } }
  meet { in_dir(var(:rails_root)) {
    shell "git reset --hard #{var :remote}/#{var :branch}", :log => true
  } }
end
