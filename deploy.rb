dep 'pre-receive', :git_ref_data do
  requires 'benhoskings:ready for update.repo'.with(git_ref_data)
end

dep 'post-receive', :git_ref_data, :env do
  def ref_info
    old_id, new_id, branch = git_ref_data.to_s.scan(ref_data_regexp).flatten
    {:old_id => old_id, :new_id => new_id, :branch => branch}
  end
  env.default!('production')
  requires [
    'benhoskings:on correct branch.repo'.with(ref_info[:branch]),
    'benhoskings:HEAD up to date.repo'.with(ref_info),
    'benhoskings:app bundled'.with(:root => '.', :env => env),

    # This and the 'maintenace' one below are separate so the 'current dir'
    # deps load lazily from the new code checked out by 'HEAD up to date.repo'.
    'on deploy'.with(ref_info[:old_id], ref_info[:new_id], ref_info[:branch], env),

    'benhoskings:app flagged for restart.task',
    'benhoskings:maintenance page down',
    'after deploy'.with(ref_info[:old_id], ref_info[:new_id], ref_info[:branch], env)
  ]
end

# These are looked up with Dep() so they're just skipped if they don't exist.
dep 'on deploy', :old_id, :new_id, :branch, :env do
  requires 'current dir:on deploy'.with(old_id, new_id, branch, env) if Dep('current dir:on deploy')
end
dep 'after deploy', :old_id, :new_id, :branch, :env do
  requires 'current dir:after deploy'.with(old_id, new_id, branch, env) if Dep('current dir:after deploy')
end
