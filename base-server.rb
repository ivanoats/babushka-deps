dep 'base server' do
    sudo "dpkg-reconfigure debconf -f readline -p high"
    requires 'openssh-server.managed'
    requires 'ddclient.managed'
    requires 'byobu.managed'
    requires 'vim-nox.managed'
end
