dep 'SSH alias' do
  define_var :ssh_config_file, :default => '~/.ssh/config'.p
  define_var :hostname
  define_var :alias
  define_var :user, :default => shell('whoami')
  friendly_blank_msg = '(just put a single space to indicate blank and use the default)'
  define_var :port, :message => "port for ssh alias #{friendly_blank_msg}"
  define_var :key_file, :message => "path to the private key to use #{friendly_blank_msg}", :blank => true

  met? { grep(/^Host #{var(:alias)}/,  var(:ssh_config_file)) }
  meet {
    require 'erb'
    # can't use render_erb because it writes to a file
    append_to_file render_erb_in_memory('ssh/config.erb'), var(:ssh_config_file), :newline => true
  }
end
