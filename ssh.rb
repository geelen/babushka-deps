dep 'SSH alias' do
  define_var :ssh_config_file, :default => '~/.ssh/config'
  define_var :hostname
  define_var :alias
  define_var :user, :default => shell('whoami')
  friendly_blank_msg = '(just put a single space to indicate blank and use the default)'
  define_var :port, :message => "port for ssh alias #{friendly_blank_msg}"
  define_var :key_file, :message => "path to the private key to use #{friendly_blank_msg}", :blank => true

  met? { grep(/^Host #{var(:alias)}/,  var(:ssh_config_file).p) }
  meet {
    require 'erb'
    # annoying! append_to_file fails if the file is missing (because fancypath defines empty? but blows up for some reason)
    shell "touch #{var(:ssh_config_file).p}"
    append_to_file render_erb_in_memory('ssh/config.erb'), var(:ssh_config_file).p, :newline => true
  }
end
