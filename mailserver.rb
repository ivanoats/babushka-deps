dep 'mail server' do
  requires 'postfix.managed'
end

dep 'postfix.managed' do
  installs { via :apt, "postfix" }
  installs { via :apt, "mailutils" }
  provides 'mail'  
end
