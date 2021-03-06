dep 'imagemagick', :template => 'managed' do
  installs {
    via :brew, 'imagemagick'
    via :apt, 'imagemagick',"libmagickcore-dev", "libmagickwand-dev"
  }
  provides 'convert'
end

dep 'rmagick', :template => 'gem' do
  requires 'imagemagick'
end