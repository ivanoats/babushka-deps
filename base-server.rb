dep 'base server' do
    requires 'openssh-server.managed'
    requires 'ddclient.managed'
    requires 'byobu'
end
