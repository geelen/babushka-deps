dep 'webapp' do
  requires 'benhoskings:user exists', 'webserver capable of starting', 'benhoskings:vhost enabled.nginx'
end

dep 'webserver capable of starting' do
  requires 'benhoskings:webserver installed.src', 'benhoskings:www user and group',
    'benhoskings:webserver startup script.nginx'
  define_var :nginx_prefix, :default => '/opt/nginx'
end
