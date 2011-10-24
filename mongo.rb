dep 'mongodb 64bit.src' do
  on :linux do
    requires 'mongo startup'
    source 'http://fastdl.mongodb.org/linux/mongodb-linux-x86_64-1.6.3.tgz'
    provides 'mongod'
    configure {
      shell "mkdir -p /usr/local/mongo", :sudo=>true
    }
    build { shell "ls" }
    install {
      shell "cp -R bin /usr/local/mongo",:sudo=>true
      Dir["/usr/local/mongo/bin/*"].each do |link|
        filename = link.split("/").last
        shell "ln -s #{link} /usr/bin/#{filename}", :sudo=>true
      end    
    }
  end
end

dep 'mongo startup' do
  on :linux do
    met? { File.exist?("/etc/init.d/mongodb") }
    meet { 
      render_erb "mongo/mongo_init", :to => "/etc/init.d/mongodb", :sudo=>true 
      shell "chmod 744 /etc/init.d/mongodb", :sudo=>true
    }
  end
end