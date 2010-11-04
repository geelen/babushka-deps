dep 'webapp' do
  requires 'benhoskings:user exists', 'webserver capable of starting', 'benhoskings:vhost enabled.nginx'
end
