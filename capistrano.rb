dep "capify" do 
  requires 'capistrano bundler setup'
  met? { 
    in_dir(var(:rails_root)) { File.exist?("Capfile")}
  }
  meet {
    in_dir(var(:rails_root)) { 
      shell("capify .")      
    }
  }
end

dep "capistrano bundler setup" do
  met? { 
    in_dir(var(:rails_root)) { !shell("cat Gemfile").split("\n").grep('gem "capistrano"').empty? }
  }
  meet {
    append_to_file('gem "capistrano"\ngem "capistrano-ext"', "#{var(:rails_root)}/Gemfile")
  }  
end

dep "capistrano config files" do
  met? {
    in_dir(var(:rails_root)) { File.exist?("config/deploy") && File.exist?("config/deploy/staging.rb")
  }
  meet {
    in_dir(var(:rails_root)) { 
      shell("mkdir -p config/deploy") 
      shell("mv config/deploy.rb config/deploy.rb.#{Time.now}")
    }
    render_erb "capistrano/staging", :to=>"#{var(:rails_root)}/config/deploy/staging.rb"
    render_erb "capistrano/main", :to=>"#{var(:rails_root)}/config/deploy.rb"
  }
end