# encoding: UTF-8

dep 'postgres has a unaccenting stemming dictionary', :db_name, :dictionary_name, :search_configuration_name, :postgres_shared_path do
  if !db_name.set? && ENV["DATABASE_URL"]
    begin
      uri = URI.parse(ENV["DATABASE_URL"])
    rescue URI::InvalidURIError
      raise "Invalid DATABASE_URL"
    end
    db_name = uri.path.split("/")[1]
  end

  dictionary_name.default! 'english_stemmer'
  search_configuration_name.default! 'unaccenting_english_stemmer'
  postgres_shared_path.default! '/usr/share/postgresql/9.1'
  requires [
    'unaccenting installed'.with(db_name, postgres_shared_path),
    'english stemming dictionary installed'.with(db_name, dictionary_name),
    'text search configuration installed'.with(db_name, dictionary_name, search_configuration_name)
  ]
end

dep 'unaccenting installed', :db_name, :postgres_shared_path do
  requires 'unaccent files exist'.with(postgres_shared_path), 'interpunct is a dash'.with(postgres_shared_path)
  met? { shell("psql #{db_name} -c '\\dFd'") =~ /public.*unaccent/ }
  meet {
    sudo "cat #{postgres_shared_path / 'contrib/unaccent.sql'} | psql #{db_name}",
         :as => 'postgres'
  }
end

dep 'unaccent files exist', :postgres_shared_path do
  requires_when_unmet 'postgresql-contrib.managed'
  met? {
    (postgres_shared_path / 'contrib/unaccent.sql').exists? &&
    (postgres_shared_path / 'tsearch_data/unaccent.rules').exists?
  }
end

dep 'postgresql-contrib.managed' do
  requires 'benhoskings:postgres.managed'
  provides []
end

dep 'interpunct is a dash', :postgres_shared_path do
  met? { grep /•\t-/, postgres_shared_path / 'tsearch_data/unaccent.rules' }
  meet { sudo 'echo -e "•\t-" >> ' + postgres_shared_path / 'tsearch_data/unaccent.rules' }
end

dep 'english stemming dictionary installed', :db_name, :dictionary_name do
  met? { shell("psql #{db_name} -c '\\dFd'") =~ /public.*#{dictionary_name}/ }
  meet {
    shell "psql #{db_name}", :input => %Q{
CREATE TEXT SEARCH DICTIONARY public.#{dictionary_name} (TEMPLATE = pg_catalog.snowball, LANGUAGE = english);
}
    }
end

dep 'text search configuration installed', :db_name, :dictionary_name, :search_configuration_name do
  met? { shell("psql #{db_name} -c '\\dF'") =~ /public.*#{search_configuration_name}/ }
  meet {
    shell "psql #{db_name}", :input => %Q{
create text search configuration public.#{search_configuration_name} (copy = pg_catalog.english);
alter text search configuration #{search_configuration_name}
  alter mapping for asciihword, asciiword, hword, hword_asciipart, hword_numpart, hword_part, word
  with unaccent, #{dictionary_name};
}
  }
end
