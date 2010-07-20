# wish there was a better way to overwrite deps, but here we are

dep 'user exists with password' do
  requires 'benhoskings:user exists'
  on :linux do
    met? { grep(/^#{var(:username)}:[^\*!]/, '/etc/shadow') }
    meet {
      sudo "echo -e '#{var(:password)}\n#{var(:password)}' | passwd #{var(:username)}"
    }
  end
end
