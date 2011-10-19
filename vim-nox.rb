dep 'vim-nox.managed' do
  installs { via :apt, 'vim-nox' }
  provides 'vim'
end
