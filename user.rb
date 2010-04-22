# wish there was a better way to overwrite deps, but here we are

dep 'user exists' do
  on :osx do
    met? { !shell("dscl . -list /Users").split("\n").grep(var(:username)).empty? }
    meet {
      homedir = var(:home_dir_base) / var(:username)
      {
        'Password' => '*',
        'UniqueID' => (501...1024).detect {|i| (Etc.getpwuid i rescue nil).nil? },
        'PrimaryGroupID' => 'admin',
        'RealName' => var(:username),
        'NFSHomeDirectory' => homedir,
        'UserShell' => '/dev/null'
      }.each_pair {|k,v|
        # /Users/... here is a dscl path, not a filesystem path.
        sudo "dscl . -create #{'/Users' / var(:username)} #{k} '#{v}'"
      }
      sudo "mkdir -p '#{homedir}'"
      sudo "chown #{var(:username)}:admin '#{homedir}'"
      sudo "chmod 701 '#{homedir}'"
    }
  end
  on :linux do
    met? { grep(/^#{var(:username)}:/, '/etc/passwd') }
    meet {
      sudo "mkdir -p #{var :home_dir_base}" and
      sudo "useradd -m -s /bin/bash -b #{var :home_dir_base} -G admin #{var(:username)}" and
      sudo "chmod 701 #{var(:home_dir_base) / var(:username)}"
      #only changed line
      sudo "echo -e '#{var(:password)}\n#{var(:password)}' | passwd #{var(:username)}"
    }
  end
end
