dep 'setup system rvm' do
  requires 'rvm install'
  requires 'rvm current user group', 'rvm user group'
  requires 'default ruby'
end

dep 'rvm install' do
  requires 'rvm requirements', 'curl.managed'
  met? { raw_which 'rvm', login_shell('which rvm') }
  meet {
    if confirm("Install rvm system-wide?", :default => 'n')
      log_shell "Installing rvm using rvm-install-system-wide", 'bash < <( curl -L http://bit.ly/rvm-install-system-wide )'
    else
      log_shell "Installing rvm using rvm-install-head", 'bash -c "`curl http://rvm.beginrescueend.com/releases/rvm-install-head`"'
    end
  }
end

dep 'rvm requirements' do 
  requires %w(build-essential.managed bison.managed openssl.managed libreadline5.managed libreadline_dev.managed zlib1g.managed libssl_dev.managed libsqlite3.managed libxml2-dev.managed)  
end

dep 'rvm current user group' do
  requires 'rvm group exists'
  before { set :current_username, shell("whoami") }
  met? { shell("groups #{var(:current_username)}").split(" ").include?("rvm") }
  meet { sudo("adduser #{var(:current_username)} rvm") }
end


dep 'rvm user group' do
  requires 'rvm group exists'
  before { var(:rvm_username, :default => shell("whoami")) }
  met? { shell("groups #{var(:rvm_username)}").split(" ").include?("rvm") }
  meet { sudo("adduser #{var(:rvm_username)} rvm") }
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
  before { 
    var(:passenger_ruby, :default => "ree") 
    var(:install_passenger_version, :default=>"3.0.2")
    }
  met? { shell("rvm #{var(:passenger_ruby)} gem list").include?("passenger") }
  meet { shell("rvm #{var(:passenger_ruby)} gem install passenger --version=#{var(:install_passenger_version)}") }  
end

dep 'rvmd passenger module' do
  before{
    set( :installed_passenger_version, Babushka::GemHelper.send(:versions_of, "passenger").to_s  )
    set( :passenger_path, Babushka::GemHelper.gem_path_for("passenger"))
  }
  requires 'apache2-prefork-dev.managed', 'libapr1-dev.managed', 'libaprutil1-dev.managed'
  met? { File.exists?("#{var(:passenger_path)}/ext/apache2/mod_passenger.so") }
  meet { shell("passenger-install-apache2-module -a") }
end

dep 'rvmd passenger config' do
  requires 'rvmd passenger module'
  met? { !shell("grep passenger /etc/apache2/other/passenger.conf").nil? }
  meet {   
    str = [
      "LoadModule passenger_module #{var(:passenger_path)}/ext/apache2/mod_passenger.so",
      "PassengerRoot #{var(:passenger_path)}",
      "PassengerRuby #{ Babushka::GemHelper.ruby_wrapper_path }"
      ]    
    append_to_file str.join("\n "), "/etc/apache2/other/passenger.conf", :sudo => true
  }
end


dep 'rvm alias set' do
  before {
    var(:alias) 
    var(:ruby_version) 
  }
  met? { shell("rvm alias list").include?("#{var(:alias)} ") }
  meet { shell "rvm alias create #{var(:alias)} #{var(:ruby_version)}" }
end


dep 'rvm alias update' do
  before {
    var(:alias) 
    var(:ruby_version) 
    @done=false
  }
  met? { @done }
  meet { shell("rvm alias create #{var(:alias)} #{var(:ruby_version)}"); @done=true }
end

dep "rvm alias remove" do
  setup { log("\nCurrent Aliases:\n\n"); log(shell("rvm alias list")); ;log("\n\n") }
  met? { !shell("rvm alias list").include?("#{var(:remove_alias)} ")}
  meet { shell("rvm alias delete #{var(:remove_alias)}") }
end