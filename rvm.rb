# set up the system libraries
dep 'rvm requirements' do 
  requires %w(build-essential.managed bison.managed openssl.managed libreadline5.managed libreadline_dev.managed zlib1g.managed libssl_dev.managed libsqlite3.managed libxml2-dev.managed)  
end

dep 'rvm system-wide' do
  requires 'rvm requirements'
  requires 'rvm current user group'
  requires 'rvm user group'
  met? { File.exist?("/usr/local/bin/rvm") }
  meet { shell "bash < <( curl -L http://bit.ly/rvm-install-system-wide )" }
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
  met? { shell("rvm list rubies").include?(var(:default_ruby)) }
  meet { shell("rvm install #{var(:default_ruby)}")}
end

dep 'default ruby' do
  requires 'rvm user group'  
  requires 'installed default ruby'
  before { var(:default_ruby, :default => "ree") }
  met? { shell("rvm list rubies").include?("=>") }
  meet { shell("rvm use #{var(:default_ruby)} --default")}
end

dep 'rvm group exists' do
  met? { shell("grep rvm /etc/group").include?("rvm")}
  meet { sudo("groupadd rvm") }
end