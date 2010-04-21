dep 'rails app db yaml present' do
  db_yaml = (var(:rails_root) / "config" / "database.yml")
  met? { db_yaml.exists? }
  meet { shell "cp #{var(:rails_root) / "config" / "database.yml.#{var(:rails_env)}"} #{db_yaml}" }
end
