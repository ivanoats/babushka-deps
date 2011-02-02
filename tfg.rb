dep 'build server' do
  requires 'passwordless ssh logins'
  requires 'rvm system-wide'
  requires 'hosts path'  
  requires 'apache2.managed'
  requires 'apache2 remove defaults'  
  requires 'rvmd passenger install'
end

dep 'hosts path' do
  met? { File.exist?("/var/vhosts") }
  meet { 
    sudo("mkdir -p /var/vhosts") 
    sudo("chown www-data /var/vhosts")
  }
end