#os x only for now
dep 'locate' do
  met? { shell "ls /var/db/locate.database" }
  meet :on => :osx do
    shell "sudo launchctl load -w /System/Library/LaunchDaemons/com.apple.locate.plist"
  end
end
