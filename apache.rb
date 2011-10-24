dep 'lamp stack removed', :template => 'apt_packages_removed', :for => :apt do
  removes %r{apache|mysql|php}
end
dep 'apache2 remove defaults' do
  met? { !File.exist?("/etc/apache2/sites-enabled/000-default") }
  meet { sudo("rm /etc/apache2/sites-enabled/000-default") }
  after { sudo "/etc/init.d/apache2 reload" }
end
