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

dep 'tfg ruby update' do
  before { 
    var(:alias) 
    var(:passenger_ruby)
    set(:ruby_version, var(:passenger_ruby)) 
  }
  requires 'rvm alias update'
  requires 'rvmd passenger install'
end

dep 'tfg vhost bundle install' do
  met? { @actioned = false}
  meet { 
    Dir["/var/vhosts/*"].each do |dir|      
      log_shell("Bundling #{dir}...","cd #{dir}/current; bash .rvmrc; bundle install")
    end
    @actioned = true
  }
end