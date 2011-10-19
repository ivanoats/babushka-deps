dep 'ddclient.managed' do
  installs { via :apt, 'ddclient' }
  provides 'ddclient'
  puts 'do not forget to configure /etc/ddclient.conf'
end
