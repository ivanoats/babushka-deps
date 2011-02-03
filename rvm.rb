meta :system_rvm do
  accepts_list_for :source
  accepts_list_for :extra_source
  template {
    helper(:nginx_bin) { var(:nginx_prefix) / 'sbin/nginx' }
    helper(:nginx_conf) { var(:nginx_prefix) / 'conf/nginx.conf' }
    helper(:nginx_cert_path) { var(:nginx_prefix) / 'conf/certs' }
    helper(:nginx_conf_for) {|domain,ext| var(:nginx_prefix) / "conf/vhosts/#{domain}.#{ext}" }
    helper(:nginx_conf_link_for) {|domain| var(:nginx_prefix) / "conf/vhosts/on/#{domain}.conf" }

    helper(:passenger_root) { Babushka::GemHelper.gem_path_for('passenger') }
  }
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
  before{
    set( :installed_passenger_version, Babushka::GemHelper.send(:versions_of, "passenger").to_s  )
    set( :passenger_path, Babushka::GemHelper.gem_path_for "passenger")
  }
  requires 'apache2-prefork-dev.managed', 'libapr1-dev.managed', 'libaprutil1-dev.managed'
  met? { File.exists?("#{var(:passenger_path)}/ext/apache2/mod_passenger.so") }
  meet { shell("passenger-install-apache2-module -a") }
end

dep 'rvmd passenger config' do
  requires 'rvmd passenger module'
  met? { !shell("grep passenger /etc/apache2/apache2.conf").nil? }
  meet {   
    str = [
      "LoadModule passenger_module #{var(:passenger_path)}/ext/apache2/mod_passenger.so",
      "PassengerRoot #{var(:passenger_path)}",
      "PassengerRuby #{ Babushka::GemHelper.ruby_wrapper_path }"
      ]    
    append_to_file str.join("\n "), "/etc/apache2/apache2.conf", :sudo => true
  }
end
