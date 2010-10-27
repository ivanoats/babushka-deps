dep "capify" do 
  requires 'capistrano bundler setup'
  met? { 
    in_dir(var(:rails_root)) { File.exist?("Capfile")}
  }
  meet {
    in_dir(var(:rails_root)) { 
      shell("capify .")
      shell("mkdir config/deploy")
      shell("touch config/deploy/staging.rb")
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