dep 'libxslt-dev.managed' do
  installs { via :apt, 'libxslt1-dev' }
  provides []
end

dep('bash-completion', :template => 'managed') { provides [] }
