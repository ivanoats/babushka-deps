dep "capify" do 
  requires 'capistrano gem'
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

dep "capistrano gem" do
  met? { 
    in_dir(var(:rails_root)) { shell("cat Gemfile").split("\n").grep("capistrano") }
  }
  meet {
    in_dir(var(:rails_root)) { append_to_file("# Capistrano deploy files\ngem 'capistrano'\n gem 'capistrano-ext'\n", "Gemfile") }
  }  
end