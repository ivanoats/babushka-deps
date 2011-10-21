# builds a base server for dynamic ip and chef management for ubuntu
dep 'base server', :for => :linux  do
    sudo "dpkg-reconfigure debconf -f readline -p high"
    requires 'admins can sudo'
    requires 'hostname'
    requires 'openssh-server.managed'
    requires 'passwordless ssh logins'
    requires 'secured ssh logins'
    requires 'ddclient.managed'
    requires 'byobu.managed'
    requires 'vim-nox.managed'
    requires 'chef install dependencies.managed'
end
