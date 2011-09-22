packages = [
  'lsof',
  'iptables',
  'jwhois',
  'whois',
  'curl',
  'wget',
  'rsync',
  'jnettop',
  'nmap',
  'traceroute',
  'ethtool',
  'tcpdump',
  'elinks',
  'lynx'
].each do |package|
  dep [package, 'managed'].join('.')
end

packages_without_binary = [
  'iproute',
  'iputils-ping',
  'netcat-openbsd',
  'bind9-host',
  'libreadline5-dev',
  'libssl-dev',
  'libxml2-dev',
  'libxslt1-dev',
  'zlib1g-dev'
].each { |p|
  dep [p, 'managed'].join('.') do
    provides []
  end
}

dep('vagrant host dependencies') {
  requires (packages + packages_without_binary).map { |p| "#{p}.managed" }
}

dep('rvm installed') {
  met? {
    shell("type rvm | head -1") == 'function'
  }

  meet {
    shell('wget http://rvm.beginrescueend.com/install/rvm -O ~/rvm.sh')
    shell('chmod +x ~/rvm.sh')
    shell('~/rvm.sh')
    shell('rm -f ~/rvm.sh')
    shell("mkdir -p /etc/profile.d", :sudo => true)
    render_erb 'rvm/rvm.sh.erb', :to => '/etc/profile.d/rvm.sh', :perms => '755', :sudo => true
  }
}

dep('vagrant host setup') {
  requires ['vagrant host dependencies', 'rvm installed']
}