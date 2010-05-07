dep 's3cmd configured', :for => :linux do
  requires 's3cmd'
  define_var :aws_key
  define_var :aws_secret_key

  helper(:file) { "~/.s3cfg" }
  met? { babushka_config? file }
  meet { render_erb "s3cmd/.s3cfg.erb", :to => file }
end

pkg 's3cmd', :for => :linux

pkg 'ec2-api-tools' do
  provides 'ec2-run-instances', 'ec2-create-volume'
end

dep 'EBS attached' do
  requires 'ec2-api-tools'
  # follow along here http://developer.amazonwebservices.com/connect/entry.jspa?externalID=1663
end
