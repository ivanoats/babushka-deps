dep 'mercurial' do
  met? {
    which 'hg'
  }
  meet {
    shell "sudo pip install mercurial"
  }
end