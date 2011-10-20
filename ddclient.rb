dep 'ddclient.managed' do
  installs { via :apt, 'ddclient' }
  provides 'ddclient'
  log_warn "do not forget to configure /etc/ddclient.conf
  # Configuration file for ddclient generated by debconf
  #
  # /etc/ddclient.conf

  protocol=dyndns2
  ssl=yes
  daemon=300
  use=web, web=checkip.dyndns.com, web-skip='IP Address'
  server=members.dyndns.org
  login=#{var :username, :default => 'ivanoats'}
  password='#{var :password}'
  #{var :sub_domain_name, :default => 'subdomain'}.dyndns.org"
end
