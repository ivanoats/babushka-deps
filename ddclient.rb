dep 'ddclient.managed' do
  installs { via :apt, 'ddclient' }
  provides 'ddclient'
end
