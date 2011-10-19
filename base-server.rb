dep 'base server' do
    requires 'openssh-server.managed'
    requires 'ddclient.managed'
    requires 'byobu.managed'
    requires 'vim-nox.managed'
end
