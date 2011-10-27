dep 'setup system rvm' do
  requires 'rvm install'
  requires 'rvm current user group', 'rvm user group'
  requires 'default ruby'
end

dep 'rvm install' do
  requires 'rvm requirements', 'curl.managed'
  met? { which 'rvm' }
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
  before { var(:default_ruby, :default => "1.9.2-p290") }
  met? { shell("rvm list").include?(var(:default_ruby)) }  
  meet { shell("rvm use #{var(:default_ruby)} --default") }
end

dep 'default ruby' do
  requires 'rvm user group'  
  requires 'installed default ruby'
  before { var(:default_ruby, :default => "1.9.2-p290") }
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
  setup { 
    shell("rvm use #{var(:ruby_version)}@global")
    var(:ruby_version, :default => "ree") 
    log("Currently installed #{Babushka::GemHelper.with_ruby(var(:ruby_version)).installed_versions("passenger")}")
    var(:passenger_version)
    }
  met? { Babushka::GemHelper.with_ruby(var(:ruby_version)).has?("passenger", :version => var(:passenger_version)) }
  meet { Babushka::GemHelper.with_ruby(var(:ruby_version)).install("passenger", var(:passenger_version)) }  
end

dep 'rvmd passenger module' do
  setup{
    shell("rvm use #{var(:ruby_version)}@global")
    set( :passenger_version, Babushka::GemHelper.send(:versions_of, "passenger").to_s  )
    set( :passenger_path, Babushka::GemHelper.gem_path_for("passenger"))
  }
# requires nginx? 
#  met? { File.exists?("#{var(:passenger_path)}/ext/apache2/mod_passenger.so") }
#  meet { shell("passenger-install-apache2-module -a") }
end

dep 'rvmd passenger config' do
  requires 'rvmd passenger module'
  met? { File.exist?("/etc/apache2/other/passenger.conf") }
  meet {   
    str = [
      "LoadModule passenger_module #{var(:passenger_path)}/ext/apache2/mod_passenger.so",
      "PassengerRoot #{var(:passenger_path)}",
      "PassengerRuby #{ Babushka::GemHelper.ruby_wrapper_path }"
      ]    
    append_to_file str.join("\n "), "/etc/apache2/other/passenger.conf", :sudo => true
  }
end

# make sure an alias is set. WARNING - doesn't check what is set
dep 'rvm alias set' do
  setup { log("\nCurrent Rubies:\n\n"); log(shell("rvm list rubies")); ;log("\n\n") ; var(:alias); var(:ruby_version) }  
  met? { shell("rvm alias list").include?("#{var(:alias)} ") }
  meet { shell "rvm alias create #{var(:alias)} #{var(:ruby_version)}" }
end

# clear out any existing alias and update to new ruby
dep 'rvm alias update' do
  setup { var(:alias); var(:ruby_version) }
  requires "rvm alias remove", 'rvm alias set'
end

# remove any existing alias.
dep "rvm alias remove" do
  setup { log("\nCurrent Aliases:\n\n"); log(shell("rvm alias list")); ;log("\n\n") }
  met? { !shell("rvm alias list").include?("#{var(:alias)} ")}
  meet { shell("rvm alias delete #{var(:alias)}") }
end
