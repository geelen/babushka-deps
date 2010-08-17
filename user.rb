dep 'user set up from root', :on => :linux do
  setup { set :home_dir_base, "/home" }
  requires 'user exists with password', 'authorized key present for user'
end

dep 'authorized key present for user' do
  requires 'benhoskings:user exists'
  helper(:ssh_dir) { "#{var(:home_dir_base) / var(:username)}/.ssh" }
  met? { sudo "grep '#{var(:your_ssh_public_key)}' '#{ssh_dir}/authorized_keys'" }
  before { sudo "mkdir -p '#{ssh_dir}'; chmod 700 '#{ssh_dir}'" }
  meet { append_to_file var(:your_ssh_public_key), "#{ssh_dir}/authorized_keys", :sudo => true }
  after { sudo "chown -R #{var(:username)}:#{var(:username)} '#{ssh_dir}'; chmod 600 '#{ssh_dir}/authorized_keys'" }
end

dep 'user setup' do
  requires 'benhoskings:user setup', 'bash-completion'
  setup {
    set :github_user, 'geelen'
    set :dot_files_repo, 'dot-files'
  }
end

dep 'user exists with password' do
  requires 'user exists'
  on :linux do
    met? { grep(/^#{var(:username)}:[^\*!]/, '/etc/shadow') }
    meet {
      sudo "echo -e '#{var(:password)}\n#{var(:password)}' | passwd #{var(:username)}"
    }
  end
end

dep 'user exists' do
  met? { grep(/^#{var(:username)}:/, '/etc/passwd') }
  meet {
    sudo "mkdir -p #{var :home_dir_base}" and
      sudo "groupadd -g #{var :fixed_uid_and_gid} #{var :username}" and
      sudo "useradd -m -s /bin/bash -b #{var :home_dir_base} -G admin #{var(:username)} -u #{var :fixed_uid_and_gid}" and
      sudo "chmod 701 #{var(:home_dir_base) / var(:username)}"
  }
end
