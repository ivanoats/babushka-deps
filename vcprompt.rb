dep 'vcprompt' do
  requires 'mercurial'
  met? {
	  which 'vcprompt'
  }
  meet {
    shell "brew install vcprompt"
  }
end