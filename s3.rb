dep 's3cmd configured', :for => :linux do
  requires 's3cmd'
  define_var :aws_key
  define_var :aws_secret_key

  file = "~/.s3cfg"
  met {
    file.p.exists?
  }
  meet {
    render_erb "s3cmd/.s3cfg.erb", :to => file
  }
end

pkg 's3cmd'
