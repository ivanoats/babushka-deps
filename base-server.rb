dep 'base server' do
    requires 'openssh-server.managed'
    requires 'ddclient.managed'
    requires 'byobu.managed'
    dep 'vim-common.managed'
end
