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
