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

pkg 'xfsprogs', :on => :linux

dep 'EBS volume mounted', :on => :linux do
  requires_when_unmet 'xfsprogs'
  define_var :device, :default => '/dev/sdf'
  define_var :mount_point, :default => '/data'
  met? { shell("mount")[Regexp.escape(var(:device))] or var(:mount_point).p.exists? }
  meet {
    shell("grep -q xfs /proc/filesystems || modprobe xfs", :sudo => true)
    shell("mkfs.xfs #{var(:device)}", :sudo => true)
    append_to_file "#{var(:device)} #{var(:mount_point)} xfs noatime 0 0", '/etc/fstab', :sudo => true
    shell("mkdir -m 000 #{var(:mount_point)}", :sudo => true)
    shell("mount #{var(:mount_point)}", :sudo => true)
  }
end

dep 'mysql runs from EBS', :on => :linux do
  requires 'mysql software', 'EBS volume mounted'
  met? { shell("mount")[Regexp.escape(var(:mount_point) / 'lib' / 'mysql')] }
  meet {
    shell("/etc/init.d/mysql stop", :sudo => true)

    shell("mkdir #{var(:mount_point)}/etc #{var(:mount_point)}/lib #{var(:mount_point)}/log", :sudo => true)
    shell("mv /etc/mysql     #{var(:mount_point)}/etc/", :sudo => true)
    shell("mv /var/lib/mysql #{var(:mount_point)}/lib/", :sudo => true)
    shell("mv /var/log/mysql #{var(:mount_point)}/log/", :sudo => true)
    shell("mkdir /etc/mysql", :sudo => true)
    shell("mkdir /var/lib/mysql", :sudo => true)
    shell("mkdir /var/log/mysql", :sudo => true)
    append_to_file <<EOS, "/etc/fstab", :sudo => true
#{var(:mount_point)}/etc/mysql /etc/mysql      none bind
#{var(:mount_point)}/lib/mysql /var/lib/mysql  none bind
#{var(:mount_point)}/log/mysql /var/log/mysql  none bind
EOS
    shell("mount /etc/mysql", :sudo => true)
    shell("mount /var/lib/mysql", :sudo => true)
    shell("mount /var/log/mysql", :sudo => true)

    shell("/etc/init.d/mysql start", :sudo => true)
  }
end
