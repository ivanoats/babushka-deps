dep 'openssh-server.managed' do
  installs { via :apt, 'openssh-server' }
  provides 'sshd'
end
