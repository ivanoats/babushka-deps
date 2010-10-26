dep 'imagemagick', :template => 'managed' do
  installs {
    via :brew, 'imagemagick'
    via :apt, 'imagemagick'
  }
  provides 'convert'
end

dep 'rmagick', :template => 'gem' do
  requires 'imagemagick',"libmagickcore-dev"
end