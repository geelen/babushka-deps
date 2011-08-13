# encoding: UTF-8

dep 'postgres has a simple unaccenting dictionary' do
  define_var :search_configuration_name, :default => 'simple_unaccenting'
  define_var :postgres_shared_path, :default => '/usr/share/postgresql/9.0'
  requires 'unaccenting installed', 'text search configuration installed'
end

dep 'unaccenting installed' do
  requires 'unaccent files exist', 'interpunct is a dash'
  met? { shell("psql #{var(:db_name)} -c '\\dFd'") =~ /public.*unaccent/ }
  meet {
    sudo "cat #{var(:postgres_shared_path) / 'contrib/unaccent.sql'} | psql #{var :db_name}",
         :as => 'postgres'
  }
end

dep 'postgresql-contrib.managed' do
  requires 'benhoskings:postgres.managed'
  provides []
end

dep 'unaccent files exist' do
  requires_when_unmet 'postgresql-contrib.managed'
  met? {
    (var(:postgres_shared_path) / 'contrib/unaccent.sql').exists? &&
    (var(:postgres_shared_path) / 'tsearch_data/unaccent.rules').exists?
  }
end

dep 'interpunct is a dash' do
  met? { grep /•\t-/, var(:postgres_shared_path) / 'tsearch_data/unaccent.rules' }
  meet { sudo 'echo -e "•\t-" >> ' + var(:postgres_shared_path) / 'tsearch_data/unaccent.rules' }
end

dep 'text search configuration installed' do
  met? { shell("psql #{var(:db_name)} -c '\\dF'") =~ /public.*#{var :search_configuration_name}/ }
  meet {
    shell "psql #{var(:db_name)}", :input => %Q{
create text search configuration public.#{var :search_configuration_name} (copy = pg_catalog.simple);
alter text search configuration #{var :search_configuration_name} alter mapping for word, hword, hword_part with unaccent, simple;
}
  }
end
