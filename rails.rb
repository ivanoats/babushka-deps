dep 'migrated db' do
  requires 'deployed app', 'existing db', 'db gem'
  setup {
    if (db_config = yaml(var(:rails_root) / 'config/database.yml')[var(:rails_env)]).nil?
      log_error "There's no database.yml entry for the #{var(:rails_env)} environment."
    else
      set :db_name, db_config['database']
    end
  }
  met? {
    current_version = bundle_rake("db:version") {|shell| shell.stdout.val_for('Current version') }
    latest_version = Dir[
      var(:rails_root) / 'db/migrate/*.rb'
    ].map {|f| File.basename f }.push('0').sort.last.split('_', 2).first

    returning current_version.gsub(/^0+/, '') == latest_version.gsub(/^0+/, '') do |result|
      unless current_version.blank?
        if latest_version == '0'
          log_verbose "This app doesn't have any migrations yet."
        elsif result
          log_ok "DB is up to date at migration #{current_version}"
        else
          log "DB needs migrating from #{current_version} to #{latest_version}"
        end
      end
    end
  }
  meet { bundle_rake "db:migrate --trace" }
end

def check_log_path
  set(:logrotate_file_path, "/etc/logrotate.d/#{var(:rails_app_name)}")
  File.exist?(var(:logrotate_file_path))
end

def set_log_path  
  var(:base_path, :default=>"/var/vhosts")
  if File.exist?("#{var(:base_path)}/#{var(:rails_app_name)}/shared")
    set(:rails_app_path, "#{var(:base_path)}/#{var(:rails_app_name)}/shared/log")
  else
    set(:rails_app_path, "#{var(:base_path)}/#{var(:rails_app_name)}/log")
  end
end

def create_logrotate
  set_log_path
  render_erb "rails/logrotate.erb", :to => var(:logrotate_file_path), :sudo => true
end


dep 'add rails logrotate' do
  met? { check_log_path }
  meet { create_logrotate }
end

dep 'verify rails logrotate for all' do
  met? { !@completed.nil? }
  meet { 
    Dir["/var/vhosts/*"].each do |entry|
      if File.directory?(entry)
        parts = entry.split("/")
        set(:rails_app_name, parts.last)
        unless check_log_path
          # no file currently exists so create one
          create_logrotate
        end
      end
    end
    @completed = true
  }
end