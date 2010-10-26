dep 'mongodb source' do
  met? {  shell("cat /etc/apt/sources.list").split("\n").grep(/downloads.mongodb.org/).empty? } 
  meet {  
    append_to_file "deb http://downloads.mongodb.org/distros/ubuntu 10.4 10gen", "/etc/apt/sources", :sudo=>true 
  }
  after { Babushka::AptHelper.update_pkg_lists }
end

dep 'mongo startup' do
  met? { Dir["/etc/rc2.d/*mongodb"].empty? }
  meet { shell("sudo update-rc.d mongodb defaults",:sudo=>true) }
end

dep 'mongodb' do
  requires 'mongodb source', "mongodb.managed", 'mongo startup'
  met? { File.exist?("/data/db") }
  meet { shell("mkdir -p /data/db", :sudo=>true) }
end