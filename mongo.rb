dep 'mongodb source' do
  met? {  shell("cat /etc/apt/sources").split("\n").grep(/downloads.mongodb.org/).empty? } 
  meet {  
    append_to_file "deb http://downloads.mongodb.org/distros/ubuntu 10.4 10gen", "/etc/apt/sources", :sudo=>true 
  }
end

dep 'mongodb' do
  requires 'mongodb source'
  
end