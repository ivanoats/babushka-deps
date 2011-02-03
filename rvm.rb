meta :system_rvm do
  def system_rvm args
    shell "/usr/local/lib/rvm/bin/rvm #{args}", :log => args['install']
  end
end

# set up the system libraries
dep 'rvm requirements' do 
  requires %w(build-essential.managed bison.managed openssl.managed libreadline5.managed libreadline_dev.managed zlib1g.managed libssl_dev.managed libsqlite3.managed libxml2-dev.managed)  
end

dep 'rvm system-wide' do
  requires 'rvm requirements'
  requires 'rvm current user group'
  requires 'rvm user group'
  requires 'curl.managed'
  requires 'default ruby'
  met? { File.exist?("/usr/local/bin/rvm") }
  meet { sudo("curl -L http://bit.ly/rvm-install-system-wide > /tmp/rvm-install-system-wide && bash /tmp/rvm-install-system-wide && rm /tmp/rvm-install-system-wide") }
end

dep 'rvm current user group' do
  requires 'rvm group exists'
  met?{ 
    current_user = shell("whoami")
    shell("groups #{current_user}").split(" ").include?("rvm")
  }
  meet{     
    current_user = shell("whoami")
    sudo("adduser #{current_user} rvm")
  }
end


dep 'rvm user group' do
  requires 'rvm group exists'
  before {
    var(:rvm_username, :default => shell("whoami"))
  }
  met?{ 
    shell("groups #{var(:rvm_username)}").split(" ").include?("rvm")
  }
  meet{     
    sudo("adduser #{var(:rvm_username)} rvm")
  }
end

dep 'installed default ruby' do
  before { var(:default_ruby, :default => "ree") }
  met? { shell("rvm list").include?(var(:default_ruby)) }  
  meet { shell("rvm use #{var(:default_ruby)} --default") }
end

dep 'default ruby' do
  requires 'rvm user group'  
  requires 'installed default ruby'
  before { var(:default_ruby, :default => "ree") }
  met? { shell("rvm list").include?("=>") }
  meet { shell("rvm use #{var(:default_ruby)} --default")}
end

dep 'rvm group exists' do
  met? { !shell("grep rvm /etc/group").nil? }
  meet { sudo("groupadd rvm") }
end

dep 'rvmd passenger install' do
  requires 'rvmd passenger gem'
  requires 'rvmd passenger config'
end

dep 'rvmd passenger gem' do
  before { var(:passenger_ruby, :default => "ree") }
  met? { shell("rvm use #{var(:passenger_ruby)} && gem list").include?("passenger") }
  meet { 
    var(:install_passenger_version, :default=>"3.0.2")
    shell("rvm use #{var(:passenger_ruby)} && gem install passenger --version=#{var(:install_passenger_version)}") 
  }  
end

dep 'rvmd passenger module' do
  requires 'apache2-prefork-dev.managed', 'libapr1-dev.managed', 'libaprutil1-dev.managed'
  met? { File.exists?("/usr/local/rvm/gems/#{var(:passenger_ruby)}/gems/passenger-#{var(:install_passenger_version)}/ext/apache2/mod_passenger.so") }
  meet { shell("passenger-install-apache2-module -a") }
end

dep 'rvmd passenger config' do
  requires 'rvmd passenger module'
  met? { !shell("grep passenger /etc/apache2/apache2.conf").nil? }
  meet {     
    str = [
      "LoadModule passenger_module /usr/local/rvm/gems/#{var(:passenger_ruby)}/gems/passenger-#{var(:install_passenger_version)}/ext/apache2/mod_passenger.so",
      "PassengerRoot /usr/local/rvm/gems/#{var(:passenger_ruby)}/gems/passenger-#{var(:install_passenger_version)}",
      "PassengerRuby /usr/local/rvm/wrappers/#{var(:passenger_ruby)}/ruby"
      ]    
    append_to_file str.join("\n "), "/etc/apache2/apache2.conf", :sudo => true
  }
end
