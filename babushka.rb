dep 'reverse babushka sources order' do
  reversed = false
  sources_file = "/usr/local/babushka/sources.yml"
  met? { reversed }
  meet {
    require 'yaml'
    reversed_yaml = {:sources => YAML.load(File.read(sources_file))[:sources].reverse}.to_yaml
    File.open(sources_file, 'w') { |f| f.puts reversed_yaml }
    reversed = true
  }
end

dep 'switch babushka install to fork' do
  define_var :branch_name, :message => "Which branch to reset to?", :default => "master"
  helper :fork_at_origin do
    shell("git remote -v")[/origin\W*git:\/\/github\.com\/(\w+)\/babushka\.git/, 1]
  end
  met? {
    in_dir(Babushka::Path.prefix / 'babushka') {
      current_fork = fork_at_origin
      define_var :fork_name, :message => "Whose fork do you want to be on?", :default => current_fork
      log "Currently on branch #{current_fork}"
      current_fork == var(:fork_name)
    }
  }
  meet {
    in_dir(Babushka::Path.prefix / 'babushka') {
      current_fork = fork_at_origin
      shell("git remote rm #{current_fork}") #this will fail nicely if it isn't there
      shell("git remote rename origin #{current_fork}")
      shell("git remote add origin git://github.com/#{var(:fork_name)}/babushka.git")
      shell("git fetch origin")
      shell("git reset --hard origin/#{var(:branch_name)}")
    }
  }
end
