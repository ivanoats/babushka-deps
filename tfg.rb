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
    var(:ruby_version)
    sudo("mv /etc/apache2/other/passenger.conf /etc/apache2/other/passenger.conf.#{Time.now.to_i}")
  }
  requires 'rvm alias update'
  requires 'rvmd passenger install'
  requires 'tfg vhost bundle install'
end

dep 'tfg vhost bundle install' do
  setup { @actioned = false }
  met? { @actioned }
  meet { 
    Dir["/var/vhosts/*"].each do |dir|      
      target_dir = File.exist?(File.join(dir, "current")) ? File.join(dir, "current") : dir
      if(File.exist?(File.join(target_dir, "Gemfile")))        
        log_shell("Bundling #{dir}...","cd #{target_dir}; bash .rvmrc; bundle install")
      else
        log("Skipping non bundler app #{dir}")
      end
    end
    @actioned = true
  }
end