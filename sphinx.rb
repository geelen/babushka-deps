dep 'sphinx.src' do
  source "http://www.sphinxsearch.com/downloads/sphinx-0.9.8.tar.gz"
  provides 'search', 'searchd', 'indexer'
end

dep 'sphinx running' do
  requires 'sphinx.src'
#  met? {}
#  meet {}
end
