# Brew Caveats
#      For ddclient to work, you will need to do the following:
#      
#      1) Create configuration file in /usr/local/etc/ddclient, sample
#         configuration can be found in /usr/local/Cellar/ddclient/3.8.0/share/doc/ddclient
#         NOTE this dep writes file directly to /etc/ddclient.conf for linux compatibility    
#
#      2) Install the launchd item in /Library/LaunchDaemons, like so:
#      
#         sudo cp -vf /usr/local/Cellar/ddclient/3.8.0/org.ddclient.plist /Library/LaunchDaemons/.
#         sudo chown -v root:wheel /Library/LaunchDaemons/org.ddclient.plist
#      
#      3) Start the daemon using:
#       
#         sudo launchctl load /Library/LaunchDaemons/org.ddclient.plist
#    
#      Next boot of system will automatically start ddclient.
dep 'ddclient.managed' do
  met? { `ls /etc/ddclient.conf`}
  meet do
    installs do
        via :apt, 'ddclient' 
        via :brew, 'ddclient'
    end
    provides 'ddclient'
    conf = <<-EOS
    # Configuration file for ddclient generated by debconf
    #
    # /etc/ddclient.conf

    protocol=dyndns2
    ssl=yes
    daemon=300
    use=web, web=checkip.dyndns.com, web-skip='IP Address'
    server=members.dyndns.org
    login=#{var :dyndns_username, :default => 'ivanoats'}
    password='#{var :dyndns_password}'
    #{var :sub_domain_name, :default => '`hostname`'}.dyndns.org
  EOS
    log sudo "cat >/etc/ddclient.conf <<\\EOF #{conf}\nEOF"
    log sudo "echo 'done writing ddclient conf'"
    log sudo "hostname #{var :sub_domain_name}.dyndns.org"
    log sudo "bash -c \"echo '#{var :sub_domain_name}.dyndns.org' > /etc/hostname \""
  end
end
