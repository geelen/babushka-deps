dep 'rails app db yaml present' do
  helper :db_yaml do
    (var(:rails_root) / "config" / "database.yml")
  end
  met? { db_yaml.exists? }
  meet { shell "cp #{var(:rails_root) / "config" / "database.*#{var(:rails_env)}*"} #{db_yaml}" }
end
