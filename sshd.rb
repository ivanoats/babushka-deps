dep 'sshd' do
  installs { via :apt, 'openssh-server' }
  provides 'sshd'
end
