dep 'apache2 remove defaults' do
  met? { !File.exist?("/etc/apache2/sites-enabled/000-default") }
  meet { sudo("rm /etc/apache2/sites-enabled/000-default") }
end