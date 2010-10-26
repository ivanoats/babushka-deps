# set up the system libraries
dep 'rvm requirements' do 
  requires %w(build-essential.managed bison.managed openssl.managed libreadline5.managed libreadline_dev.managed zlib1g.managed libssl_dev.managed libsqlite3.managed libxml2-dev.managed)  
end

dep 'rvm system-wide' do
  requires 'rvm requirements'
  met? { File.exist?("/usr/local/bin/rvm") }
  meet { shell "bash -c "`curl -L http://bit.ly/rvm-install-system-wide`" }
end