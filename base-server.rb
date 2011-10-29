# builds a base server for dynamic ip and chef management for ubuntu
# assumes you've alrady done a multi-user install of rvm and of course, babushka
# adduser deploy first, too
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
    requires 'mysql.managed'
    requires 'apache2.managed'
end
