dep 'byobu.managed' do
  installs { via :apt, 'byobu' }
  provides 'byobu'
end
