dep 'mail server' do
  requires 'postfix.managed'
end

dep 'postfix.managed' do
  installs { via :apt, "postfix telnet mailx" }
  provides 'mail'  
end
