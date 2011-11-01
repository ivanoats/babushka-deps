dep 'lamp stack removed', :template => 'apt_packages_removed', :for => :apt do
  removes %r{apache|mysql|php}
end
dep 'apache2 remove defaults' do
  met? { !File.exist?("/etc/apache2/sites-enabled/000-default") }
  meet { sudo("rm /etc/apache2/sites-enabled/000-default") }
  after { sudo "/etc/init.d/apache2 reload" }
end

# taken from http://github.com/tricycle/babushka-deps and adapted for my needs (same for apache2/*) 
# hard works been done by them ;)
meta :apache2 do
  template {
    def apachectl_command(command)
      "/usr/sbin/apache2ctl #{command}"
    end
    def apachectl(command)
      sudo apachectl_command(command)
    end
    def config_path
      '/etc/apache2'
    end
    def apache2_running?
      shell "netstat -an | grep -E '^tcp.*[.:]80 +.*LISTEN'"
    end
    def restart_gracefully
      if apache2_running?
        log_shell "Restarting apache2", apachectl_command("graceful"), :sudo => true
      end
    end
    def vhost_config_path(domain)
      config_path / "sites-available/#{domain}"
    end
    def site_available?(domain)
      shell "[ -e #{vhost_config_path(domain)} ]"
    end
    def site_enabled?(domain)
      shell "[ -e #{config_path}/sites-enabled/*#{domain} ]"
    end
    def site_disabled?(domain)
      not site_enabled?(domain)
    end
    def enable_site(domain)
      sudo "a2ensite #{domain}"
    end
    def disable_site(domain)
      sudo "a2dissite #{domain}"
    end
    def mod_enabled?(mod)
      shell "[ -e #{config_path}/mods-enabled/#{mod}.load ]"
    end
    def mod_disabled?(mod)
      not mod_enabled?(mod)
    end
    def enable_mod(mod)
      sudo "a2enmod #{mod}"
    end
    def disable_mod(mod)
      sudo "a2dismod #{mod}"
    end
  }
end

dep 'apache2', :template => 'managed' do
  installs %w[apache2 apache2-mpm-prefork]
end

dep 'apache2 dev packages', :template => 'managed' do
  installs %w[apache2-prefork-dev libapr1-dev libaprutil1-dev]
  provides %w[apxs2 apr-config]
end

dep 'configured.apache2' do
  requires 'apache2'

  met? {
    [
      config_path / "mods-available/status.conf",
      config_path / "conf.d/types.conf",
      config_path / "conf.d/virtualhost.conf",
      "/etc/logrotate.d/apache2"
    ].all? { |file|
      babushka_config? file
    }
  }

  meet {
    # stub out the default status location
    render_erb 'apache2/status.conf.erb',      :to => config_path / 'mods-available/status.conf', :sudo => true
    # include custom types
    render_erb 'apache2/types.conf.erb',       :to => config_path / 'conf.d/types.conf', :sudo => true
    # configure the virtualhost conf
    render_erb 'apache2/virtualhost.conf.erb', :to => config_path / 'conf.d/virtualhost.conf', :sudo => true
    # configure logrotate
    render_erb 'apache2/logrotate.erb',        :to => '/etc/logrotate.d/apache2', :sudo => true
  }

  after { restart_gracefully }
end

dep 'default site disabled.apache2' do
  met? { site_disabled? 'default' }
  meet { disable_site 'default' }
  after { restart_gracefully }
end

dep 'running.apache2' do
  requires 'configured.apache2'
  met? { apache2_running? }
  meet {
    apachectl "start"
  }
end

dep 'mod_rewrite enabled.apache2' do
  setup { set :module_name, 'rewrite' }
  requires 'module enabled.apache2'
end

dep 'proxy enabled.apache2' do
  setup { set :module_name, 'proxy' }
  requires 'module enabled.apache2'
end

dep 'proxy_http enabled.apache2' do
  setup { set :module_name, 'proxy_http' }
  requires 'module enabled.apache2'
end

dep 'ssl enabled.apache2' do
  setup { set :module_name, 'ssl' }
  requires 'module enabled.apache2'
end

dep 'headers enabled.apache2' do
  setup { set :module_name, 'headers' }
  requires 'module enabled.apache2'
end

dep 'include enabled.apache2' do
  setup { set :module_name, 'include' }
  requires 'module enabled.apache2'
end

dep 'vhost enabled.apache2' do
  requires 'apache2'
  met? { site_enabled? var(:domain) }
  meet { enable_site var(:domain) }
  after { restart_gracefully }
end

dep 'module enabled.apache2' do
  requires 'apache2'
  met? { mod_enabled? var(:module_name) }
  meet { enable_mod var(:module_name) }
  after { restart_gracefully }
end

dep 'apache2 runs on boot' do
  requires 'apache2'
  requires 'rcconf.managed'
  met? { shell("rcconf --list").val_for('apache2') == 'on' }
  meet { sudo "update-rc.d apache2 defaults" }
end

dep 'passenger vhost configured.apache2' do
  requires 'apache2 passenger mods configured'

  met? {
    site_available?(var(:domain)) && babushka_config?(vhost_config_path(var(:domain)))
  }
  meet {
    render_erb 'apache2/passenger_vhost.conf.erb', :to => vhost_config_path(var(:domain)), :sudo => true
  }
end

dep 'apache2-prefork-dev.managed' do
  provides ["apxs2"]
end

dep 'xsendfile.apache2' do
  requires 'apache2-prefork-dev.managed'
  met? {
    !!sudo("a2enmod xsendfile")
  }
  meet {
    cd "/tmp" do
      log_shell "cleaning   ", "rm -rf mod_xsendfile.c"
      log_shell "downloading", "wget --no-check-certificate -O mod_xsendfile.c https://tn123.org/mod_xsendfile/mod_xsendfile.c"
      log_shell "installing",  "sudo apxs2 -cia mod_xsendfile.c"
    end
  }
  after { restart_gracefully }
end
