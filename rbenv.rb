# Usage:
# [install rbenv like normal] https://github.com/sstephenson/rbenv
# babushka 1.9.3.rbenv
# rbenv global 1.9.3-rc1
# rbenv rehash

dep 'rbenv' do
  met? {
    in_path? 'rbenv'
  }
  meet {
    git 'https://github.com/sstephenson/rbenv.git', :to => '~/.rbenv'
  }
end

meta :rbenv do
  accepts_value_for :version, :basename
  accepts_value_for :patchlevel
  accepts_block_for :customise
  template {
    def version_spec
      "#{version}-#{patchlevel}"
    end
    def prefix
      "~/.rbenv/versions" / version_spec
    end
    def version_group
      version.scan(/^\d\.\d/).first
    end
    requires 'rbenv', 'yaml headers.managed', 'openssl.lib'
    met? {
      (prefix / 'bin/ruby').executable? and
      shell(prefix / 'bin/ruby -v')[/^ruby #{version}#{patchlevel}\b/]
    }
    meet {
      Babushka::Resource.extract "http://ftp.ruby-lang.org/pub/ruby/#{version_group}/ruby-#{version_spec}.tar.gz" do |path|
        invoke(:customise)
        log_shell 'Configure', "./configure --prefix='#{prefix}' --with-openssl-dir=$(brew --prefix openssl)"
        log_shell 'Build',     "make -j#{Babushka.host.cpus}"
        log_shell 'Install',   "make install"
     end
    }
    after {
      # TODO: hack for ruby bug where bin/* aren't installed when the build path
      # contains a dot-dir.
      # shell "cp bin/* #{prefix / 'bin'}"
      log_shell 'rbenv rehash', 'rbenv rehash'
    }
  }
end

dep '2.0.0.rbenv' do
  patchlevel 'preview1'
end

dep '1.9.3.rbenv' do
  patchlevel 'p327'
end

dep '1.9.3-falcon.rbenv' do
  version '1.9.3'
  patchlevel 'p0'
  customise {
    falcon_patch = 'https://raw.github.com/gist/1658360/afd06eec533ad0140011bdaf652e6cd82eedf7ec/cumulative_performance.patch'
    shell "curl '#{falcon_patch}' | git apply"
  }
end

dep '1.9.2.rbenv' do
  patchlevel 'p290'
end

dep '1.8.7.rbenv' do
  patchlevel 'p352'
end

dep '1.8.6.rbenv' do
  patchlevel 'p420'
end
